--[[
    v2/combo/state_machine.lua
    Deterministic Sequential Combo Engine (Rebuilt from Scratch)
    Guarantees strict sequential execution: Z -> X -> V -> Z -> X -> V without skipping.
--]]

local Tracker = require(script.Parent.tracker)
local Executor = require(script.Parent.executor)

local StateMachine = {}

StateMachine.currentIndex = 1
StateMachine.lastActionTime = 0
StateMachine.minigameActive = false

-- 1. Parse combo string into a clean table of uppercase keys
function StateMachine.ParseComboKeys(comboStr)
    local keys = {}
    if not comboStr or comboStr == "" then return keys end
    for k in string.gmatch(comboStr, "([ZXCVzxcv])") do
        table.insert(keys, k:upper())
    end
    return keys
end

-- 2. Format preview for UI display (e.g. "Z ➔ X ➔ V")
function StateMachine.GetComboPreview(comboStr)
    local keys = StateMachine.ParseComboKeys(comboStr)
    if #keys == 0 then return "Trống (Chưa cài đặt)" end
    return table.concat(keys, " ➔ ") .. " (" .. tostring(#keys) .. " chiêu)"
end

-- 3. Minigame Event Hooks
function StateMachine.OnMinigameStart()
    StateMachine.minigameActive = true
    StateMachine.currentIndex = 1
    StateMachine.lastActionTime = 0
end

function StateMachine.OnMinigameEnd()
    StateMachine.minigameActive = false
    StateMachine.currentIndex = 1
    StateMachine.lastActionTime = 0
end

-- 4. Get Current Step Info for UI debug/status
function StateMachine.GetCurrentStatus(config)
    local keys = StateMachine.ParseComboKeys(config.LoopSkills or "Z, X, V")
    if #keys == 0 then return "Không có chiêu" end
    local idx = math.clamp(StateMachine.currentIndex, 1, #keys)
    local target = keys[idx] or "?"
    return string.format("Bước %d/%d: [%s]", idx, #keys, target)
end

-- 5. Main Execution Step (Called each tick during minigame)
function StateMachine.Step(config, fUI, playerHp, ticketQuestState)
    if not config or not config.SmartComboEnabled then return false end

    local now = tick()
    local effectDelay = tonumber(config.SkillEffectDelay) or 1.2

    -- 1. KIỂM TRA KHOẢNG CÁCH RA CHIÊU (Tránh spam liên tục làm nuốt chiêu của game)
    if (now - StateMachine.lastActionTime < effectDelay) then
        return false
    end

    -- 2. KIỂM TRA HOẠT ẢNH NHÂN VẬT (Nếu đang chém/tung chiêu thì chờ kết thúc)
    if config.SmartEffectAutoDetect and Tracker.IsCharacterCastingSkill() then
        return false
    end

    -- 3. CỨU NGUY HỒI MÁU KHẨN CẤP (Ưu tiên số 1 khi máu thấp, không làm mất thứ tự combo)
    local healKey = config.EmergencyHealSkill
    if healKey and healKey ~= "Tắt" and healKey ~= "" then
        healKey = healKey:match("([ZXCVzxcv])")
        if healKey then
            healKey = healKey:upper()
            local hpThreshold = tonumber(config.EmergencyHealHp) or 40
            if playerHp and playerHp <= hpThreshold then
                if Tracker.IsSkillReady(healKey, fUI) then
                    local castOk = Executor.CastSkill(healKey, config, ticketQuestState)
                    if castOk then
                        StateMachine.lastActionTime = now
                        return true -- Đã kích hoạt hồi máu, combo chính sẽ tiếp tục ở nhịp sau
                    end
                end
            end
        end
    end

    -- 4. XỬ LÝ CHUỖI COMBO TUẦN TỰ NGHIÊM NGẶT (STRICT ROTATION)
    local keys = StateMachine.ParseComboKeys(config.LoopSkills or "Z, X, V")
    if #keys == 0 then return false end

    -- Đảm bảo chỉ số con trỏ luôn nằm trong giới hạn hợp lệ
    if StateMachine.currentIndex < 1 or StateMachine.currentIndex > #keys then
        StateMachine.currentIndex = 1
    end

    local targetKey = keys[StateMachine.currentIndex]

    -- Kiểm tra xem chiêu hiện tại đã hồi xong hay chưa
    if Tracker.IsSkillReady(targetKey, fUI) then
        -- CHIÊU ĐÃ SẴN SÀNG -> THI TRIỂN
        local castSuccess = Executor.CastSkill(targetKey, config, ticketQuestState)
        if castSuccess then
            StateMachine.lastActionTime = now
            -- TỊNH TIẾN CON TRỎ SANG CHIÊU KẾ TIẾP TRONG CHUỖI
            StateMachine.currentIndex = (StateMachine.currentIndex % #keys) + 1
            return true
        end
    else
        -- CHIÊU CHƯA HỒI:
        -- TUYỆT ĐỐI CHỜ ĐỢI! KHÔNG NHẢY CÓC SANG CHIÊU KHÁC!
        -- KHÔNG THAY ĐỔI currentIndex!
        -- Việc này đảm bảo thứ tự luôn là: Z -> X -> V -> Z -> X -> V ...
        return false
    end

    return false
end

return StateMachine
