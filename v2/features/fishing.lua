--[[
    v2/features/fishing.lua
    Automated Fishing, Minigame Anchor, Slam/Charge, Anti-Stuck & Bait/Rod Manager
--]]

local Services = require(script.Parent.Parent.core.services)
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Workspace = Services.Workspace
local Tracker = require(script.Parent.Parent.combo.tracker)
local Executor = require(script.Parent.Parent.combo.executor)

local Fishing = {}

-- State trackers
Fishing.fishingStartTime = 0
Fishing.minigameStartTime = 0
Fishing.lastCastTime = 0
Fishing.lastProgressionTime = 0
Fishing.lastEquipBaitTime = 0
Fishing.lastEquipRodTime = 0
Fishing.lastTrainTime = 0
Fishing.isTrainingBusy = false

-- Priority bait list from best to basic
Fishing.baitPriorityList = {
    "Nameless Bait",
    "Abyssal Bait",
    "Secret Bait",
    "Kraken Bait",
    "Corrupted Bait",
    "Deep Sea Bait",
    "Magma Bait",
    "Golden Bait",
    "Rare Bait",
    "Uncommon Bait",
    "Basic Bait"
}

-- 1. Anti-Stuck Check
function Fishing.CheckAntiStuck(config, isFishing, isMinigame)
    if not config.AntiStuck or Fishing.isTrainingBusy then return false end
    local now = tick()

    -- Bị kẹt khi đang quăng cần nhưng hơn 15 giây không có cá cắn câu
    if isFishing and not isMinigame and (now - Fishing.fishingStartTime > 15) and Fishing.fishingStartTime > 0 then
        Fishing.CancelAndRecast()
        Fishing.fishingStartTime = now
        return true
    end

    -- Bị kẹt trong minigame quá 25 giây
    if isMinigame and (now - Fishing.minigameStartTime > 25) and Fishing.minigameStartTime > 0 then
        Fishing.CancelAndRecast()
        Fishing.minigameStartTime = now
        return true
    end

    return false
end

-- 2. Cancel and Recast Rod
function Fishing.CancelAndRecast()
    pcall(function()
        if Events and Events:FindFirstChild("CancelCast") then
            Events.CancelCast:FireServer()
        end
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = LocalPlayer.Backpack
            task.wait(0.2)
            tool.Parent = char
        end
    end)
end

-- 3. Minigame Mechanics (Anchor Bar, Perfect Slam, Max Charge, UpdateFishProgression)
function Fishing.HandleMinigame(config, fUI)
    if not fUI or not fUI.Visible then return end
    local now = tick()

    -- Anchor Bar (Giữ thanh cân bằng ở giữa)
    if config.AnchorBar then
        local barFrame = fUI:FindFirstChild("BarFrame")
        if barFrame and barFrame:FindFirstChild("Bar") then
            barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end

    -- Auto Slam ("Perfect")
    if config.AutoSlam and fUI:FindFirstChild("PerfectButton") and fUI.PerfectButton.Visible then
        if Events and Events:FindFirstChild("Slam") then
            Events.Slam:FireServer("Perfect")
        end
    end

    -- Auto Charge (100)
    if config.AutoCharge and fUI:FindFirstChild("Charge") and fUI.Charge.Visible then
        if Events and Events:FindFirstChild("Charge") then
            Events.Charge:FireServer(100)
        end
    end

    -- Update Fish Progression
    if config.AnchorBar and (now - Fishing.lastProgressionTime >= 0.08) then
        if Events and Events:FindFirstChild("UpdateFishProgression") then
            Events.UpdateFishProgression:FireServer()
        end
        Fishing.lastProgressionTime = now
    end

    -- Rhythm Hit (Octo minigame) - Giống người thật: phản xạ có trễ, bấm khi note gần vùng hit
    if config.AutoRhythmHit and fUI:FindFirstChild("RhythmFrame") then
        local rFrame = fUI.RhythmFrame
        if rFrame.Visible and Events and Events:FindFirstChild("RhythmHit") then
            -- Bảng nhớ các note đã "nhìn thấy" (để không bấm lại 2 lần cùng 1 note)
            if not Fishing._rhythmSeenNotes then
                Fishing._rhythmSeenNotes = {}
                Fishing._rhythmLastClean = now
            end

            -- Dọn bảng nhớ mỗi 3 giây (khi note mới spawn chu kỳ mới)
            if (now - Fishing._rhythmLastClean) > 3.0 then
                Fishing._rhythmSeenNotes = {}
                Fishing._rhythmLastClean = now
            end

            for _, hitNote in ipairs(rFrame:GetChildren()) do
                if hitNote.Name:find("Note") and hitNote:IsA("GuiObject") then
                    local noteId = hitNote.Name .. tostring(hitNote.AbsolutePosition.X)

                    -- Chỉ xử lý note chưa từng bấm
                    if not Fishing._rhythmSeenNotes[noteId] then
                        -- Kiểm tra note có đang ở gần vùng hit (X ~ 0.40 → 0.60 của frame)
                        local noteX = hitNote.AbsolutePosition.X
                        local frameW = rFrame.AbsoluteSize.X
                        local frameX = rFrame.AbsolutePosition.X
                        local relativeX = frameW > 0 and ((noteX - frameX) / frameW) or 0.5

                        -- Note chạy từ phải sang trái → chỉ bấm khi note đã vào vùng 35%–65%
                        if hitNote.Visible and relativeX >= 0.35 and relativeX <= 0.65 then
                            Fishing._rhythmSeenNotes[noteId] = true

                            -- Xác suất 6% "chậm tay" → bỏ qua note này (giống miss nhỏ của người thật)
                            local missChance = math.random(1, 100)
                            if missChance <= 6 then
                                -- Bỏ qua, để note trôi qua (late miss)
                            else
                                -- Reaction time người thật: 120ms–280ms (ngẫu nhiên)
                                local reactionDelay = 0.12 + math.random() * 0.16

                                -- Jitter nhỏ ±20ms để timing không đều đặn hoàn hảo
                                local jitter = (math.random() - 0.5) * 0.04

                                task.delay(reactionDelay + jitter, function()
                                    -- Xác nhận lại note vẫn còn trong frame (người thật cũng hủy nếu note đã qua)
                                    if rFrame and rFrame.Visible and hitNote and hitNote.Visible then
                                        pcall(function()
                                            Events.RhythmHit:FireServer(hitNote.Name)
                                        end)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 4. Auto Cast Fishing Rod
function Fishing.HandleAutoCast(config, isFishing, isMinigame)
    if not config.AutoCast or isFishing or isMinigame or Fishing.isTrainingBusy then return end
    local now = tick()
    if (now - Fishing.lastCastTime < 1.0) then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Events and Events:FindFirstChild("Fishing") then
        pcall(function()
            Events.Fishing:FireServer(root.CFrame)
            Fishing.lastCastTime = now
            Fishing.fishingStartTime = now
        end)
    end
end

-- 5. Auto Equip Best Bait
function Fishing.HandleAutoBait(config)
    if not config.AutoEquipBestBait or Fishing.isTrainingBusy then return end
    local now = tick()
    if (now - Fishing.lastEquipBaitTime < 3.0) then return end
    Fishing.lastEquipBaitTime = now

    local pData = LocalPlayer:FindFirstChild("Data")
    local inventory = pData and pData:FindFirstChild("Inventory")
    if not inventory or not Events or not Events:FindFirstChild("EquipBait") then return end

    if config.SelectedBait and config.SelectedBait ~= "None" then
        if inventory:FindFirstChild(config.SelectedBait) then
            Events.EquipBait:FireServer(config.SelectedBait)
            return
        end
    end

    for _, baitName in ipairs(Fishing.baitPriorityList) do
        if inventory:FindFirstChild(baitName) then
            Events.EquipBait:FireServer(baitName)
            break
        end
    end
end

-- 6. Auto Train Skill (Isolated Execution)
function Fishing.HandleTrainSkill(config, isMinigame)
    if not config.AutoTrainSkill or isMinigame then
        Fishing.isTrainingBusy = false
        return
    end

    local now = tick()
    local delay = tonumber(config.TrainDelay) or 0.5
    if (now - Fishing.lastTrainTime < delay) then return end

    local skillKey = config.TrainSkill or "Z"
    skillKey = skillKey:match("([ZXCVzxcv])")
    if not skillKey then return end
    skillKey = skillKey:upper()

    Fishing.isTrainingBusy = true
    Fishing.lastTrainTime = now

    pcall(function()
        Executor.CastSkill(skillKey, config, nil)
        config.TrainCurrentCount = (config.TrainCurrentCount or 0) + 1
        task.wait(0.2)
        if Events and Events:FindFirstChild("CancelCast") then
            Events.CancelCast:FireServer()
        end
    end)

    if config.TrainCurrentCount >= (tonumber(config.TrainTargetCount) or 100) then
        config.AutoTrainSkill = false
        Fishing.isTrainingBusy = false
    end
end

return Fishing
