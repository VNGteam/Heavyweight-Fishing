--[[
    v2/combo/executor.lua
    Multi-Layer Skill Casting Engine with Safety Protection
--]]

local Services = require(script.Parent.Parent.core.services)
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local VirtualInputManager = Services.VirtualInputManager
local Tracker = require(script.Parent.tracker)

local Executor = {}

function Executor.CastSkill(sk, config, ticketQuestState)
    if not sk or sk == "" or sk == "Tắt" then return false end
    local cleanKey = sk:match("([ZXCVzxcv])") or sk
    cleanKey = cleanKey:upper()

    -- 1. KHÓA BẢO VỆ CHIÊU C (Tránh dùng nhầm chiêu tốn tài nguyên trừ khi người chơi cài đặt rõ ràng)
    if cleanKey == "C" and config then
        local userChoseC = false
        if config.TicketQuickSkill and config.TicketQuickSkill:find("[Cc]") then userChoseC = true end
        if config.TicketSkillKey and config.TicketSkillKey:find("[Cc]") then userChoseC = true end
        if config.TrainSkill and config.TrainSkill:find("[Cc]") then userChoseC = true end
        if config.QuickCatchSkill == "C" or config.OpenerSkill == "C" or config.EmergencyHealSkill == "C" then userChoseC = true end
        if (config.SmartComboEnabled or config.AutoSkills) and config.LoopSkills and config.LoopSkills:find("[Cc]") then
            userChoseC = true
        end
        if not userChoseC then
            return false
        end
    end

    -- 2. KHÓA BẢO VỆ NHIỆM VỤ VÉ (Nếu đang làm quest 100 cá hoặc 100 skill thì chỉ dùng chiêu được chỉ định)
    if ticketQuestState and ticketQuestState.currentQuestType then
        local curQ = ticketQuestState.currentQuestType
        if curQ == "skill_100" and config and config.TicketSkillKey then
            local allowed = config.TicketSkillKey:match("([ZXCVzxcv])%s*$")
            allowed = allowed and allowed:upper() or "Z"
            if cleanKey ~= allowed then return false end
        elseif curQ == "fish_100" and config and config.TicketQuickSkill then
            local allowed = config.TicketQuickSkill:match("([ZXCVzxcv])%s*$")
            allowed = allowed and allowed:upper() or "V"
            if cleanKey ~= allowed then return false end
        end
    end

    -- 3. TẦNG 1: Gửi RemoteEvent tới Server
    pcall(function()
        if Events then
            if Events:FindFirstChild("UseSkill") then
                Events.UseSkill:FireServer(cleanKey)
            end
            if Events:FindFirstChild("TriggerMinigameSkill") then
                Events.TriggerMinigameSkill:FireServer(cleanKey)
            end
        end
    end)

    -- 4. TẦNG 2: Giả lập phím bấm qua VirtualInputManager
    pcall(function()
        if VirtualInputManager and Enum.KeyCode[cleanKey] then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[cleanKey], false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[cleanKey], false, game)
        end
    end)

    -- 5. TẦNG 3: Giả lập kích hoạt trực tiếp nút bấm trên GUI Fishing
    pcall(function()
        local function clickBtn(btn)
            if not btn or not btn:IsA("GuiButton") or not btn.Visible then return false end
            if firesignal then
                if btn.Activated then firesignal(btn.Activated) end
                if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
            end
            if getconnections then
                for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
                for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            end
            return true
        end

        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        local mGui = pGui and pGui:FindFirstChild("MainGui")
        local f = mGui and mGui:FindFirstChild("Fishing")
        if f then
            local sb = f:FindFirstChild("SkillButton")
            local fr = sb and sb:FindFirstChild("Frame")
            local btn = fr and fr:FindFirstChild(cleanKey)
            if btn and clickBtn(btn) then
                return
            end
            for _, d in ipairs(f:GetDescendants()) do
                if d:IsA("GuiButton") and (d.Name:upper() == cleanKey or (d.Name:upper():find("SKILL") and d.Name:upper():find(cleanKey))) then
                    clickBtn(d)
                end
            end
        end
    end)

    -- Ghi nhận thời gian tung chiêu
    Tracker.RecordSkillUsed(cleanKey)
    return true
end

return Executor
