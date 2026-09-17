--[[
    v2/features/quest.lua
    Automated Daily Ticket Quests Lifecycle, Dialogue Handling & Cooldown Management
--]]

local Services = require(script.Parent.Parent.core.services)
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Services.LocalPlayer
local HttpService = Services.HttpService
local Events = Services.Events
local Utils = require(script.Parent.Parent.core.utils)

local Quest = {}

Quest.state = {
    active = false,
    currentQuestType = "none", -- "fish_15m", "bait_100", "skill_100", "fish_100", "none"
    currentQuestTitle = "Chưa nhận nhiệm vụ",
    currentProgress = 0,
    targetProgress = 100,
    isCompleted = false,
    isCooldown = false,
    cooldownEnd = 0,
    readyForNewQuest = false,
    isAcceptingQuest = false,
    isInteracting = false,
    lastAcceptTime = 0,
    lastClaimAttempt = 0,
    lastNpcInteract = 0,
    lastSyncTime = 0,
    lastBaitBuy = 0,
    lastBaitEquip = 0,
    isBusyRoutine = false,
    isAtHomeSpot = false,
    statusText = "Đang quét nhiệm vụ...",
    allQuestsDoneForToday = false,
    allQuestsDoneDate = nil,
    allQuestsDoneUtcDate = nil,
    savedDailyCount = nil,

    -- Spots
    spot100Fish = Vector3.new(-96, 9, 234),
    spot100Bait = Vector3.new(-96, 9, 231),
    spot100Skill = Vector3.new(-96, 9, 234),
    spot15MFish = Vector3.new(1619, 13, 334),
    spotNPC = Vector3.new(-200.7, 11.1, 35.9),

    cachedNPCModel = nil,
    cachedNPCPos = nil,
    cachedNPCCFrame = nil,
    cachedNPCPrompt = nil,
}

function Quest.GetServerTimeNow()
    local ok, t = pcall(function() return Workspace:GetServerTimeNow() end)
    if ok and t and t > 0 then return math.floor(t) end
    return os.time()
end

function Quest.GetPlayerDataFolder()
    local pData = ReplicatedStorage:FindFirstChild("Data")
    if pData and pData:FindFirstChild(tostring(LocalPlayer.UserId)) then
        return pData[tostring(LocalPlayer.UserId)]
    end
    return nil
end

function Quest.SerializeSpot(spot)
    if not spot then return nil end
    if typeof(spot) == "CFrame" then
        return { x = spot.Position.X, y = spot.Position.Y, z = spot.Position.Z, cframe = {spot:GetComponents()} }
    elseif typeof(spot) == "Vector3" then
        return { x = spot.X, y = spot.Y, z = spot.Z }
    elseif type(spot) == "table" and (spot.cframe or spot.x) then
        return spot
    end
    return nil
end

function Quest.DeserializeSpot(data, defaultCf)
    if not data then return defaultCf end
    if typeof(data) == "CFrame" then return data end
    if typeof(data) == "Vector3" then return CFrame.new(data) end
    if type(data) == "table" then
        if data.cframe and #data.cframe == 12 then
            return CFrame.new(table.unpack(data.cframe))
        elseif data.x and data.y and data.z then
            return CFrame.new(data.x, data.y, data.z)
        end
    end
    return defaultCf
end

function Quest.SaveSpots()
    if not (writefile and HttpService) then return end
    pcall(function()
        local data = {
            spot100Fish = Quest.SerializeSpot(Quest.state.spot100Fish),
            spot100Bait = Quest.SerializeSpot(Quest.state.spot100Bait),
            spot100Skill = Quest.SerializeSpot(Quest.state.spot100Skill),
            spot15MFish = Quest.SerializeSpot(Quest.state.spot15MFish),
            spotNPC = Quest.SerializeSpot(Quest.state.spotNPC),
            cooldownEnd = Quest.state.cooldownEnd,
        }
        writefile("HeavyweightFishing_TicketSpots.json", HttpService:JSONEncode(data))
    end)
end

function Quest.LoadSpots()
    if not (isfile and readfile and isfile("HeavyweightFishing_TicketSpots.json")) then return end
    pcall(function()
        local raw = readfile("HeavyweightFishing_TicketSpots.json")
        local dec = HttpService:JSONDecode(raw)
        if dec and type(dec) == "table" then
            if dec.spot100Fish then Quest.state.spot100Fish = Quest.DeserializeSpot(dec.spot100Fish, Quest.state.spot100Fish) end
            if dec.spot100Bait then Quest.state.spot100Bait = Quest.DeserializeSpot(dec.spot100Bait, Quest.state.spot100Bait) end
            if dec.spot100Skill then Quest.state.spot100Skill = Quest.DeserializeSpot(dec.spot100Skill, Quest.state.spot100Skill) end
            if dec.spot15MFish then Quest.state.spot15MFish = Quest.DeserializeSpot(dec.spot15MFish, Quest.state.spot15MFish) end
            if dec.spotNPC then Quest.state.spotNPC = Quest.DeserializeSpot(dec.spotNPC, Quest.state.spotNPC) end
            if dec.cooldownEnd and dec.cooldownEnd > tick() then
                Quest.state.cooldownEnd = dec.cooldownEnd
                Quest.state.isCooldown = true
            end
        end
    end)
end

function Quest.TeleportTo(target)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not target then return end

    local targetCf = nil
    if typeof(target) == "CFrame" then
        targetCf = target
    elseif typeof(target) == "Vector3" then
        targetCf = CFrame.new(target + Vector3.new(0, 1.5, 0))
    elseif type(target) == "table" then
        if target.cframe and #target.cframe == 12 then
            targetCf = CFrame.new(table.unpack(target.cframe))
        elseif target.x and target.y and target.z then
            targetCf = CFrame.new(target.x, target.y + 1.5, target.z)
        end
    end

    if targetCf then
        local wp = Workspace:FindFirstChild("IdenticalWaterPlatform") or Workspace:FindFirstChild("WaterPlatform")
        if not wp then
            wp = Instance.new("Part")
            wp.Name = "IdenticalWaterPlatform"
            wp.Size = Vector3.new(30, 2, 30)
            wp.Transparency = 1
            wp.Anchored = true
            wp.CanCollide = true
            wp.Parent = Workspace
        end
        wp.CFrame = CFrame.new(targetCf.Position.X, targetCf.Position.Y - 2.8, targetCf.Position.Z)
        wp.CanCollide = true

        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = targetCf + Vector3.new(0, 1.5, 0)
        task.wait(0.12)
        root.CFrame = targetCf
        task.wait(0.12)
    end
end

function Quest.FindTicketNPC()
    if Quest.state.cachedNPCModel and Quest.state.cachedNPCModel.Parent and Quest.state.cachedNPCPos then
        return Quest.state.cachedNPCModel, Quest.state.cachedNPCPos, Quest.state.cachedNPCPrompt, Quest.state.cachedNPCCFrame
    end

    local function extractModelData(model)
        if not model then return nil, nil, nil end
        local p = model:FindFirstChildWhichIsA("ProximityPrompt", true)
        local hrp = (p and p.Parent:IsA("BasePart") and p.Parent)
            or model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("UpperTorso")
            or model.PrimaryPart
            or model:FindFirstChildWhichIsA("BasePart")
        local cf = (hrp and hrp.CFrame) or (model:IsA("Model") and model:GetPivot()) or model.CFrame
        return cf, p, hrp
    end

    -- 1. Ưu tiên tìm đúng cấu trúc: Workspace.NPC.Function["Ticket Quest Giver"]
    local directModel = nil
    local npcFolder = Workspace:FindFirstChild("NPC")
    if npcFolder then
        local funcFolder = npcFolder:FindFirstChild("Function")
        if funcFolder then
            directModel = funcFolder:FindFirstChild("Ticket Quest Giver")
        end
        if not directModel then
            for _, ch in ipairs(npcFolder:GetChildren()) do
                local n = ch.Name:lower()
                if ch:IsA("Model") and (n:find("ticket") or n:find("giver")) then
                    directModel = ch
                    break
                elseif ch:IsA("Folder") then
                    for _, sub in ipairs(ch:GetChildren()) do
                        local sn = sub.Name:lower()
                        if sub:IsA("Model") and (sn:find("ticket") or sn:find("giver")) then
                            directModel = sub
                            break
                        end
                    end
                end
                if directModel then break end
            end
        end
    end

    if not directModel then
        directModel = Workspace:FindFirstChild("Ticket Quest Giver", true)
            or Workspace:FindFirstChild("Ticket Quest", true)
            or Workspace:FindFirstChild("TicketNPC", true)
    end

    if directModel then
        local cf, p = extractModelData(directModel)
        if cf then
            Quest.state.cachedNPCModel = directModel
            Quest.state.cachedNPCPos = cf.Position
            Quest.state.cachedNPCCFrame = cf
            Quest.state.cachedNPCPrompt = p
            Quest.state.spotNPC = cf.Position
            return directModel, cf.Position, p, cf
        end
    end

    for _, fName in ipairs({"NPC", "NPCs", "Entities", "Characters", "Spawns"}) do
        local folder = Workspace:FindFirstChild(fName)
        if folder then
            for _, inst in ipairs(folder:GetDescendants()) do
                if inst:IsA("Model") then
                    local n = inst.Name:lower()
                    if n:find("ticket") or n:find("giver") then
                        local cf, p = extractModelData(inst)
                        if cf then
                            Quest.state.cachedNPCModel = inst
                            Quest.state.cachedNPCPos = cf.Position
                            Quest.state.cachedNPCCFrame = cf
                            Quest.state.cachedNPCPrompt = p
                            Quest.state.spotNPC = cf.Position
                            return inst, cf.Position, p, cf
                        end
                    end
                end
            end
        end
    end

    return nil, Quest.state.spotNPC, nil, nil
end

function Quest.OrientCameraTo(focusPos, standPos)
    local cam = Workspace.CurrentCamera
    if not cam or not focusPos then return end
    pcall(function()
        local dir = standPos and (standPos - focusPos) or -cam.CFrame.LookVector
        local dir2D = Vector3.new(dir.X, 0, dir.Z)
        if dir2D.Magnitude < 0.1 then
            dir2D = Vector3.new(0, 0, 1)
        else
            dir2D = dir2D.Unit
        end
        local refPos = standPos or (focusPos + dir2D * 3.0)
        local camPos = refPos + (dir2D * 4.5) + Vector3.new(0, 2.2, 0)
        local camFocus = focusPos + Vector3.new(0, 0.8, 0)
        cam.CameraType = Enum.CameraType.Custom
        cam.CFrame = CFrame.lookAt(camPos, camFocus)
        cam.Focus = CFrame.new(camFocus)
    end)
end

function Quest.TeleportToNPC()
    local npcModel, npcPos, prompt, npcCFrame = Quest.FindTicketNPC()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.Sit = false
            hum:UnequipTools()
        end)
    end
    if Events and Events:FindFirstChild("CancelCast") then
        pcall(function() Events.CancelCast:FireServer() end)
    end

    local promptFound = prompt
    if not promptFound and npcModel then
        promptFound = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true)
    end

    local focusPos, standPos, targetCF = nil, nil, nil

    if npcCFrame then
        focusPos = npcCFrame.Position
        local fwd = npcCFrame.LookVector
        local fwd2D = Vector3.new(fwd.X, 0, fwd.Z)
        if fwd2D.Magnitude > 0.05 then
            fwd2D = fwd2D.Unit
        else
            fwd2D = Vector3.new(0, 0, 1)
        end
        standPos = focusPos + (fwd2D * 2.8)
        standPos = Vector3.new(standPos.X, focusPos.Y, standPos.Z)
        targetCF = CFrame.lookAt(standPos, Vector3.new(focusPos.X, standPos.Y, focusPos.Z))
    elseif typeof(Quest.state.spotNPC) == "CFrame" then
        targetCF = Quest.state.spotNPC
        standPos = targetCF.Position
        focusPos = standPos + (targetCF.LookVector * 2.8)
    elseif npcPos or Quest.state.spotNPC then
        local rawPos = npcPos or (typeof(Quest.state.spotNPC) == "Vector3" and Quest.state.spotNPC) or (Quest.state.spotNPC and Quest.state.spotNPC.Position)
        if rawPos then
            focusPos = rawPos
            standPos = focusPos + Vector3.new(0, 0, 2.8)
            targetCF = CFrame.lookAt(standPos, focusPos)
        end
    end

    if root and targetCF and standPos then
        local dist = (root.Position - standPos).Magnitude
        if dist > 3.0 then
            Quest.TeleportTo(targetCF)
            task.wait(0.25)
        else
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = targetCF
            task.wait(0.08)
        end
        Quest.OrientCameraTo(focusPos, standPos)
    end

    if promptFound then
        pcall(function()
            promptFound.RequiresLineOfSight = false
            promptFound.MaxActivationDistance = math.max(promptFound.MaxActivationDistance or 10, 35)
            promptFound.Enabled = true
        end)
    end

    return npcModel, focusPos or npcPos, promptFound, standPos
end

function Quest.GetDialogueGui()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local mg = pg:FindFirstChild("MainGui")
    if mg and mg:FindFirstChild("Menu") and mg.Menu:FindFirstChild("Dialogue") then
        return mg.Menu.Dialogue
    end
    for _, g in ipairs(pg:GetChildren()) do
        if g:IsA("ScreenGui") then
            local d = g:FindFirstChild("Dialogue", true)
            if d then return d end
        end
    end
    return nil
end

function Quest.IsDialogueOpen()
    local dlg = Quest.GetDialogueGui()
    return dlg and dlg.Visible == true
end

function Quest.GetDialogueButtons()
    local dlg = Quest.GetDialogueGui()
    if not dlg then return {} end
    local bf = dlg:FindFirstChild("ButtonFrame")
    if not bf then return {} end

    local buttons = {}
    for _, ch in ipairs(bf:GetChildren()) do
        if ch:IsA("TextButton") and ch.Name ~= "Template" and ch.Visible then
            local titleObj = ch:FindFirstChild("Title") or ch:FindFirstChildWhichIsA("TextLabel", true)
            local text = (titleObj and titleObj.Text) or ch.Text or ""
            local clean = text:lower():gsub("%*", ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
            local idx = tonumber(ch.Name) or 0
            table.insert(buttons, {
                button = ch,
                index = idx,
                name = ch.Name,
                text = text,
                clean = clean
            })
        end
    end
    table.sort(buttons, function(a, b) return a.index < b.index end)
    return buttons
end

function Quest.ClearUINavigation()
    pcall(function()
        local gs = game:GetService("GuiService")
        if gs then
            gs.SelectedObject = nil
            gs.GuiNavigationEnabled = false
        end
    end)
end

function Quest.ClickButtonEntry(entry, explicitActionId)
    if not entry or not entry.button then return false end
    local btn = entry.button
    local idx = entry.index
    local clean = entry.clean or ""
    local actionId = explicitActionId

    if not actionId then
        if clean == "quest" then
            actionId = "Quest"
        elseif clean:find("hard") then
            actionId = "HardAcceptQuest"
        elseif clean:find("easy") then
            actionId = "EasyAcceptQuest"
        elseif clean:find("leave") or clean:find("close") then
            actionId = "Close"
        end
    end

    pcall(function()
        if firesignal then
            if btn:IsA("GuiButton") and btn.Activated then firesignal(btn.Activated) end
            if btn:IsA("GuiButton") and btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
        end
    end)

    pcall(function()
        if getconnections then
            local conns = getconnections(btn.Activated)
            if not conns or #conns == 0 then conns = getconnections(btn.MouseButton1Click) end
            if conns then
                for _, c in ipairs(conns) do
                    if c.Fire then c:Fire() elseif c.Function then pcall(c.Function) end
                end
            end
        end
    end)

    if Events and Events:FindFirstChild("ChooseDialogueOption") then
        if actionId and #actionId > 0 then
            pcall(function() Events.ChooseDialogueOption:FireServer(actionId) end)
        end
        if idx and idx > 0 then
            pcall(function() Events.ChooseDialogueOption:FireServer(idx) end)
        end
    end

    return true
end

function Quest.CloseDialogue()
    if Events and Events:FindFirstChild("ChooseDialogueOption") then
        pcall(function() Events.ChooseDialogueOption:FireServer("Close") end)
    end
    pcall(function()
        local dlg = Quest.GetDialogueGui()
        if dlg then dlg.Visible = false end
    end)
    Quest.ClearUINavigation()
end

function Quest.ClickQuestButton()
    local buttons = Quest.GetDialogueButtons()
    for _, b in ipairs(buttons) do
        if b.clean == "quest" or (b.clean:find("quest") and not b.clean:find("accept") and not b.clean:find("nevermind")) then
            return Quest.ClickButtonEntry(b, "Quest")
        end
    end
    return false
end

function Quest.ClickLeaveOrClose()
    local buttons = Quest.GetDialogueButtons()
    for _, b in ipairs(buttons) do
        if b.clean:find("leave") or b.clean:find("close") or b.clean:find("xong") then
            return Quest.ClickButtonEntry(b, "Close")
        end
    end
    return false
end

function Quest.CheckAllQuestsDoneToday()
    local dlg = Quest.GetDialogueGui()
    if not dlg then return false end
    for _, d in ipairs(dlg:GetDescendants()) do
        if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
            local low = d.Text:lower()
            if (low:find("all the quests") or low:find("all the quest") or low:find("come back tomorrow"))
               and (low:find("today") or low:find("tomorrow") or low:find("more")) then
                return true, d.Text
            end
        end
    end
    return false
end

function Quest.IsAllQuestsDoneToday()
    if not Quest.state.allQuestsDoneForToday then return false end
    local today = os.date("%Y-%m-%d")
    local utcToday = os.date("!%Y-%m-%d")
    local pData = Quest.GetPlayerDataFolder()
    local curDailyCount = pData and pData:FindFirstChild("TicketQuestDailyCount") and tonumber(pData.TicketQuestDailyCount.Value)

    local isDateChanged = (Quest.state.allQuestsDoneDate and Quest.state.allQuestsDoneDate ~= today)
        or (Quest.state.allQuestsDoneUtcDate and Quest.state.allQuestsDoneUtcDate ~= utcToday)
    local isServerDailyReset = (Quest.state.savedDailyCount and curDailyCount and curDailyCount < Quest.state.savedDailyCount)

    if isDateChanged or isServerDailyReset then
        Quest.state.allQuestsDoneForToday = false
        Quest.state.allQuestsDoneDate = nil
        Quest.state.allQuestsDoneUtcDate = nil
        Quest.state.savedDailyCount = nil
        Quest.state.readyForNewQuest = true
        Quest.state.isCooldown = false
        Quest.state.isAtHomeSpot = false
        Quest.state.cooldownEnd = 0
        Quest.state.statusText = "Đã sang ngày mới! Chuẩn bị quay lại NPC nhận vé..."
        Utils.ShowNotification("Ngày Mới - Reset Vé", "Đã sang ngày mới! Bot tự động quay lại NPC nhận vé.", "SUCCESS", 6)
        return false
    end
    return true
end

function Quest.HandleDialogue(isClaiming, config)
    if not Quest.IsDialogueOpen() then return false end

    local isHard = (config and config.TicketDifficulty or "Hard") == "Hard"
    local targetDiffKeyword = isHard and "hard" or "easy"

    local buttons = Quest.GetDialogueButtons()
    if #buttons == 0 then
        task.wait(0.25)
        buttons = Quest.GetDialogueButtons()
    end
    if #buttons == 0 then return false end

    local questBtn, leaveBtn, diffBtn = nil, nil, nil
    for _, b in ipairs(buttons) do
        if b.clean == "quest" or (b.clean:find("quest") and not b.clean:find("accept") and not b.clean:find("nevermind")) then
            questBtn = b
        end
        if b.clean:find("leave") or b.clean:find("xong") or b.clean:find("close") then
            leaveBtn = b
        end
        if b.clean:find(targetDiffKeyword) and (b.clean:find("quest") or b.clean:find("accept")) then
            diffBtn = b
        end
    end

    local isDoneToday = Quest.CheckAllQuestsDoneToday()
    if isDoneToday then
        Quest.state.allQuestsDoneForToday = true
        Quest.state.allQuestsDoneDate = os.date("%Y-%m-%d")
        Quest.state.allQuestsDoneUtcDate = os.date("!%Y-%m-%d")
        local pData = Quest.GetPlayerDataFolder()
        if pData and pData:FindFirstChild("TicketQuestDailyCount") then
            Quest.state.savedDailyCount = tonumber(pData.TicketQuestDailyCount.Value) or 0
        end
        Quest.state.readyForNewQuest = false
        Quest.state.isCooldown = true
        Quest.state.statusText = "Đã hết nhiệm vụ hôm nay! (Hẹn ngày mai quay lại)"
        Utils.ShowNotification("Hết Nhiệm Vụ", "NPC: Đã hết tất cả vé nhiệm vụ hôm nay! Hẹn gặp lại ngày mai.", "WARN", 8)
        if leaveBtn then
            Quest.ClickButtonEntry(leaveBtn, "Close")
        end
        task.wait(0.3)
        Quest.CloseDialogue()
        return true
    end

    if leaveBtn then
        Quest.ClickButtonEntry(leaveBtn, "Close")
        task.wait(0.3)
        Quest.CloseDialogue()
        return true
    end

    if diffBtn then
        local action = isHard and "HardAcceptQuest" or "EasyAcceptQuest"
        Quest.ClickButtonEntry(diffBtn, action)
        task.wait(0.4)
        Quest.CloseDialogue()
        return true
    end

    if questBtn then
        Quest.ClickButtonEntry(questBtn, "Quest")
        local t0 = tick()
        while (tick() - t0) < 3.5 do
            task.wait(0.2)
            if not Quest.IsDialogueOpen() then return true end

            local nextButtons = Quest.GetDialogueButtons()
            for _, nb in ipairs(nextButtons) do
                if nb.clean:find("leave") or nb.clean:find("close") then
                    Quest.ClickButtonEntry(nb, "Close")
                    task.wait(0.3)
                    Quest.CloseDialogue()
                    return true
                end
                if not isClaiming and (nb.clean:find(targetDiffKeyword) or nb.clean:find("accept")) then
                    local act = isHard and "HardAcceptQuest" or "EasyAcceptQuest"
                    Quest.ClickButtonEntry(nb, act)
                    task.wait(0.4)
                    Quest.CloseDialogue()
                    return true
                end
            end
        end
    end

    return false
end

function Quest.InteractNPC(isClaiming, config)
    local isHard = (config and config.TicketDifficulty or "Hard") == "Hard"
    Quest.state.isInteracting = true

    local function _execute()
        if Quest.IsDialogueOpen() then
            if Quest.HandleDialogue(isClaiming, config) then
                return true
            end
            task.wait(0.4)
            if Quest.IsDialogueOpen() and Quest.HandleDialogue(isClaiming, config) then
                return true
            end
            return false
        end

        local npcModel, focusPos, promptFound, standPos = Quest.TeleportToNPC()
        if not promptFound and npcModel then
            promptFound = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        end

        if promptFound then
            pcall(function()
                promptFound.RequiresLineOfSight = false
                promptFound.MaxActivationDistance = math.max(promptFound.MaxActivationDistance or 10, 35)
                promptFound.Enabled = true
            end)
        end

        if not Quest.IsDialogueOpen() then
            if promptFound and fireproximityprompt then
                fireproximityprompt(promptFound)
            end
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                if vim then
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.08)
                    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end)
        end

        local success = false
        local t0 = tick()
        while (tick() - t0) < 4.5 do
            task.wait(0.2)
            if Quest.IsDialogueOpen() then
                if Quest.HandleDialogue(isClaiming, config) then
                    success = true
                    break
                end
            end
        end

        if Events and Events:FindFirstChild("ClaimQuest") and isClaiming then
            pcall(function() Events.ClaimQuest:FireServer("Ticket", config and config.TicketDifficulty or "Hard") end)
        end

        if success then
            if isClaiming then
                Utils.ShowNotification("Nhiệm Vụ Vé", "Đã nộp nhiệm vụ & nhận thưởng vé thành công!", "SUCCESS", 5)
            else
                Utils.ShowNotification("Nhiệm Vụ Vé", "Đã nhận thành công nhiệm vụ " .. (isHard and "Hard" or "Easy") .. " Ticket!", "SUCCESS", 5)
            end
        end

        return success
    end

    local ok, res = pcall(_execute)
    Quest.state.isInteracting = false
    Quest.ClearUINavigation()
    return ok and res or false
end

function Quest.DetectActiveQuest()
    local detectedType = nil
    local detectedTitle = nil
    local detectedCur = 0
    local detectedMax = 0
    local isDone = false
    local detectedCooldownSec = nil

    local pData = Quest.GetPlayerDataFolder()
    if pData then
        local cdVal = pData:FindFirstChild("TicketQuestCooldown")
        if cdVal and tonumber(cdVal.Value) then
            local stamp = tonumber(cdVal.Value)
            local nowServer = Quest.GetServerTimeNow()
            if stamp > nowServer then
                detectedCooldownSec = stamp - nowServer
            end
        end

        local questFolder = pData:FindFirstChild("Quest")
        if questFolder then
            local tq = questFolder:FindFirstChild("Hard Ticket Quest", true) 
                or questFolder:FindFirstChild("Ticket Quest", true) 
                or questFolder:FindFirstChild("Easy Ticket Quest", true)
            if not tq then
                for _, ch in ipairs(questFolder:GetDescendants()) do
                    if ch:IsA("Folder") or ch:IsA("Configuration") then
                        local cn = ch.Name:lower()
                        if cn:find("ticket") and cn:find("quest") then
                            tq = ch
                            break
                        end
                    end
                end
            end

            if tq then
                local curVal = tq:FindFirstChild("1")
                if curVal and tonumber(curVal.Value) ~= nil then
                    detectedCur = tonumber(curVal.Value)
                end

                local objFolder = tq:FindFirstChild("Objective")
                local objVal = objFolder and objFolder:FindFirstChild("1")
                local objStr = objVal and tostring(objVal.Value or "") or ""
                local rawTitle, rawMax, rawCode = objStr:match("^([^,]+),([^,]+),?(.*)$")

                detectedMax = tonumber(rawMax) or 100
                detectedTitle = (rawTitle and #rawTitle > 0) and rawTitle or tq.Name
                local codeLow = (rawCode or ""):lower()
                local titleLow = (detectedTitle):lower()

                if codeLow:find("skill") or titleLow:find("skill") or titleLow:find("chiêu") or titleLow:find("kỹ năng") then
                    detectedType = "skill_100"
                    if detectedMax == 0 then detectedMax = 100 end
                elseif codeLow:find("bait") or titleLow:find("bait") or titleLow:find("mồi") then
                    detectedType = "bait_100"
                    if detectedMax == 0 then detectedMax = 100 end
                elseif detectedMax == 10 or titleLow:find("1.5") or titleLow:find("1500") or titleLow:find("heavy") then
                    detectedType = "fish_15m"
                    if detectedMax == 0 then detectedMax = 10 end
                else
                    detectedType = "fish_100"
                    if detectedMax == 0 then detectedMax = 100 end
                end

                if detectedMax > 0 and detectedCur >= detectedMax then
                    isDone = true
                end

                return detectedType, detectedTitle, detectedCur, detectedMax, isDone, detectedCooldownSec
            end
        end

        if detectedCooldownSec and detectedCooldownSec > 0 then
            return nil, nil, 0, 0, false, detectedCooldownSec
        else
            return nil, nil, 0, 0, false, nil
        end
    end

    return nil, nil, 0, 0, false, nil
end

--// HỆ THỐNG NHIỆM VỤ ZENG TIANGUO (SKILL UPGRADE) & SONG SONG //--
Quest.zengState = {
    active = false,
    currentQuestTitle = "Chưa nhận nhiệm vụ",
    currentProgress = 0,
    targetProgress = 0,
    isCompleted = false,
    objectiveCode = "none",
    zoneTarget = "",
    statusText = "Đang quét nhiệm vụ Zeng Tianguo...",
    lastSyncTime = 0,
    lastNpcInteract = 0,
    lastClaimAttempt = 0,

    spotBamboo = Vector3.new(-1223.0, 9.0, -24.1),
    spotFrost = Vector3.new(-1366.0, 14.0, -1495.4),
    spotSovereign = Vector3.new(-1276.4, 12.0, 1239.7),
    spotFallout = Vector3.new(65.5, 12.0, 1181.3),
    spotNPC = Vector3.new(65.5, 12.0, 1181.3),

    uiStatus = nil,
    uiProgress = nil,
    uiParallelBadge = nil,
}

function Quest.DetectActiveZengQuest()
    local pData = Quest.GetPlayerDataFolder()
    if not pData then return nil, "Chưa nhận nhiệm vụ", 0, 0, false, nil end
    local questFolder = pData:FindFirstChild("Quest")
    if not questFolder then return nil, "Chưa nhận nhiệm vụ", 0, 0, false, nil end

    local zq = questFolder:FindFirstChild("Zeng Tianguo Quest", true)
        or questFolder:FindFirstChild("Tang Thien Quoc Quest", true)
        or questFolder:FindFirstChild("Tang Thien Quoc", true)
        or questFolder:FindFirstChild("Zeng Tianguo", true)

    if not zq then
        for _, ch in ipairs(questFolder:GetDescendants()) do
            if ch:IsA("Folder") or ch:IsA("Configuration") then
                local cn = ch.Name:lower()
                if (cn:find("zeng") and cn:find("tianguo")) or (cn:find("tang") and cn:find("thien")) then
                    zq = ch
                    break
                end
            end
        end
    end

    if not zq then
        Quest.zengState.active = false
        Quest.zengState.currentQuestTitle = "Chưa nhận nhiệm vụ"
        Quest.zengState.currentProgress = 0
        Quest.zengState.targetProgress = 0
        Quest.zengState.isCompleted = false
        Quest.zengState.objectiveCode = "none"
        Quest.zengState.zoneTarget = ""
        Quest.zengState.statusText = "Chưa nhận nhiệm vụ từ Zeng Tianguo"
        return nil, "Chưa nhận nhiệm vụ", 0, 0, false, nil
    end

    local cur = 0
    local curVal = zq:FindFirstChild("1")
    if curVal and tonumber(curVal.Value) ~= nil then
        cur = tonumber(curVal.Value)
    end

    local objFolder = zq:FindFirstChild("Objective")
    local objVal = objFolder and objFolder:FindFirstChild("1")
    local objStr = objVal and tostring(objVal.Value or "") or ""

    local rawTitle, rawMax, rawCode, rawExtra = objStr:match("^([^,]+),([^,]+),([^,]+),?(.*)$")
    if not rawTitle then
        rawTitle, rawMax = objStr:match("^([^,]+),([^,]+)")
    end

    local max = tonumber(rawMax) or 100
    local title = (rawTitle and #rawTitle > 0) and rawTitle or zq.Name
    local code = rawCode or "none"
    local extra = rawExtra or ""

    local isDone = (max > 0 and cur >= max)

    Quest.zengState.active = true
    Quest.zengState.currentQuestTitle = title
    Quest.zengState.currentProgress = cur
    Quest.zengState.targetProgress = max
    Quest.zengState.isCompleted = isDone
    Quest.zengState.objectiveCode = code
    Quest.zengState.zoneTarget = extra

    if isDone then
        Quest.zengState.statusText = string.format("Đã xong: %s (%d/%d) - Sẵn sàng nộp quest!", title, cur, max)
    else
        Quest.zengState.statusText = string.format("Đang làm: %s (%d/%d)", title, cur, max)
    end

    return code, title, cur, max, isDone, extra
end

function Quest.GetTargetZengSpot()
    local zone = (Quest.zengState.zoneTarget or ""):lower()
    local title = (Quest.zengState.currentQuestTitle or ""):lower()
    if zone:find("bamboo") or zone:find("tre") or title:find("bamboo") then
        return Quest.zengState.spotBamboo
    elseif zone:find("frost") or zone:find("băng") or title:find("frost") then
        return Quest.zengState.spotFrost
    elseif zone:find("sovereign") or title:find("sovereign") then
        return Quest.zengState.spotSovereign
    elseif zone:find("fallout") or title:find("fallout") then
        return Quest.zengState.spotFallout
    end
    if Quest.zengState.objectiveCode == "UseSkillForTimes" or title:find("skill") or title:find("chiêu") then
        return nil
    end
    return Quest.zengState.spotBamboo
end

function Quest.FindZengNPCModel()
    local npcFolder = Workspace:FindFirstChild("NPC")
    if npcFolder then
        local funcFolder = npcFolder:FindFirstChild("Function")
        if funcFolder then
            local found = funcFolder:FindFirstChild("Zeng Tianguo") or funcFolder:FindFirstChild("Tang Thien Quoc")
            if found and (found:FindFirstChild("HumanoidRootPart") or found:FindFirstChildWhichIsA("BasePart")) then
                return found
            end
        end
        for _, sub in ipairs(npcFolder:GetChildren()) do
            local found = sub:FindFirstChild("Zeng Tianguo") or sub:FindFirstChild("Tang Thien Quoc")
            if found and (found:FindFirstChild("HumanoidRootPart") or found:FindFirstChildWhichIsA("BasePart")) then
                return found
            end
        end
    end
    local direct = Workspace:FindFirstChild("Zeng Tianguo", true) or Workspace:FindFirstChild("Tang Thien Quoc", true)
    if direct then return direct end

    if npcFolder then
        for _, ch in ipairs(npcFolder:GetDescendants()) do
            if ch:IsA("Model") then
                local n = ch.Name:lower()
                if (n:find("zeng") and n:find("tianguo")) or (n:find("tang") and n:find("thien")) then
                    return ch
                end
            end
        end
    end
    return nil
end

function Quest.TeleportToZengNPC()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local model = Quest.FindZengNPCModel()
    if model then
        local npcRoot = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChildWhichIsA("BasePart")
        if npcRoot then
            local targetPos = npcRoot.Position + Vector3.new(0, 3, 3)
            root.CFrame = CFrame.new(targetPos)
            Quest.zengState.spotNPC = targetPos
            return true, model, npcRoot
        end
    end

    if Quest.zengState.spotNPC then
        root.CFrame = CFrame.new(Quest.zengState.spotNPC)
        return true
    end
    return false
end

function Quest.InteractZengNPC(isClaim)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.Sit = false
            hum:UnequipTools()
        end)
    end
    if Events and Events:FindFirstChild("CancelCast") then
        pcall(function() Events.CancelCast:FireServer() end)
    end

    Quest.TeleportToZengNPC()
    task.wait(0.6)

    local npc = Quest.FindZengNPCModel()
    if npc then
        local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            task.wait(0.6)
        end
    end

    local dlg = Quest.GetDialogueGui()
    if dlg and dlg.Visible then
        task.wait(0.3)
        local clicked = false
        if isClaim then
            clicked = Quest.ClickLeaveOrClose()
        else
            clicked = Quest.ClickQuestButton() or Quest.ClickLeaveOrClose()
        end
        task.wait(0.5)
        Quest.CloseDialogue()
        return clicked
    end
    return false
end

function Quest.UpdateZengUI(config)
    if Quest.zengState.uiStatus and Quest.zengState.uiStatus.Set then
        Quest.zengState.uiStatus.Set(Quest.zengState.statusText)
    end
    if Quest.zengState.uiProgress and Quest.zengState.uiProgress.Set then
        local max = Quest.zengState.targetProgress
        local cur = Quest.zengState.currentProgress
        local pct = max > 0 and math.floor((cur / max) * 100) or 0
        Quest.zengState.uiProgress.Set(string.format("%d / %d (%d%%)", cur, max, pct))
    end
    if Quest.zengState.uiParallelBadge and Quest.zengState.uiParallelBadge.Set and config then
        if config.AutoTicketQuest and config.AutoZengTianguoQuest then
            Quest.zengState.uiParallelBadge.Set("⚡ SONG SONG (Ưu Tiên Vé)")
        elseif config.AutoTicketQuest then
            Quest.zengState.uiParallelBadge.Set("🎫 Chỉ Chạy Vé NV")
        elseif config.AutoZengTianguoQuest then
            Quest.zengState.uiParallelBadge.Set("⚡ Chỉ Chạy Zeng Tianguo")
        else
            Quest.zengState.uiParallelBadge.Set("Đang Tắt")
        end
    end
end

function Quest.ScanAndUpdateStatus()
    local qType, qTitle, cur, max, done, cdSec = Quest.DetectActiveQuest()
    if qType then
        Quest.state.currentQuestType = qType
        Quest.state.currentQuestTitle = qTitle or Quest.state.currentQuestTitle
        Quest.state.currentProgress = cur
        Quest.state.targetProgress = max
        Quest.state.isCompleted = done
        Quest.state.active = true
        Quest.state.isCooldown = false
        Quest.state.readyForNewQuest = false
        Quest.state.statusText = string.format("Đang làm: %s (%d/%d)", Quest.state.currentQuestTitle, cur, max)
    elseif cdSec and cdSec > 0 then
        Quest.state.isCooldown = true
        Quest.state.cooldownEnd = tick() + cdSec
        Quest.state.active = false
        Quest.state.currentQuestType = "none"
        Quest.state.currentProgress = 0
        local mins = math.floor(cdSec / 60)
        local secs = cdSec % 60
        Quest.state.statusText = string.format("Chờ hồi chiêu vé (%02d:%02d)", mins, secs)
    else
        Quest.state.active = false
        Quest.state.currentQuestType = "none"
        Quest.state.currentProgress = 0
        Quest.state.isCompleted = false
        Quest.state.readyForNewQuest = true
        Quest.state.isCooldown = false
        Quest.state.statusText = "Sẵn sàng nhận nhiệm vụ vé mới!"
    end
    return qType, qTitle, cur, max, done, cdSec
end

-- 4. Vòng lặp chính Tick của Ticket Quest & Zeng Tianguo
function Quest.Tick(config)
    if not config.AutoTicketQuest and not config.AutoZengTianguoQuest then return end
    if Quest.state.isBusyRoutine or Quest.state.isInteracting then return end

    local now = tick()

    -- Đồng bộ tiến độ Zeng Tianguo
    local zCode, zTitle, zCur, zMax, zDone, zZone = Quest.DetectActiveZengQuest()
    Quest.UpdateZengUI(config)

    -- NẾU CHỈ BẬT ZENG TIANGUO (KHÔNG BẬT VÉ): CHẠY CHẾ ĐỘ SOLO ZENG TIANGUO
    if not config.AutoTicketQuest and config.AutoZengTianguoQuest then
        if zDone then
            if now - (Quest.zengState.lastClaimAttempt or 0) >= 10.0 then
                Quest.zengState.lastClaimAttempt = now
                Quest.zengState.statusText = "Đã xong! Đang nộp quest Zeng Tianguo..."
                Quest.UpdateZengUI(config)
                Quest.InteractZengNPC(true)
                task.wait(1.0)
                Quest.DetectActiveZengQuest()
                Quest.UpdateZengUI(config)
            end
            return
        end

        local char = LocalPlayer.Character
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local isFishing = char and char:GetAttribute("Fishing") == true
        local isMinigame = char and (char:GetAttribute("Minigame") == true or (pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing") and pg.MainGui.Fishing.Visible))
        if isFishing or isMinigame then return end

        local targetSpot = Quest.GetTargetZengSpot() or Quest.state.spot100Fish
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local spotPos = typeof(targetSpot) == "CFrame" and targetSpot.Position or targetSpot
        if root and spotPos and (root.Position - spotPos).Magnitude > 25 then
            Quest.TeleportTo(targetSpot)
            Quest.CloseDialogue()
        end
        return
    end

    -- KIỂM TRA NẾU ĐÃ HẾT VÉ NHIỆM VỤ HÔM NAY
    if Quest.IsAllQuestsDoneToday() then
        Quest.state.statusText = "Đã hết nhiệm vụ hôm nay! (Hẹn ngày mai quay lại)"
        Quest.state.isCooldown = true
        Quest.state.readyForNewQuest = false

        -- NẾU BẬT ZENG TIANGUO VÀ CHƯA XONG: TẬN DỤNG CÀY NỐT ZENG TIANGUO THAY VÌ ĐỨNG IM!
        if config.AutoZengTianguoQuest and zCode and not zDone then
            local subSpot = Quest.GetTargetZengSpot() or Quest.state.spot100Fish
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local spotPos = typeof(subSpot) == "CFrame" and subSpot.Position or subSpot
            if root and spotPos and (root.Position - spotPos).Magnitude > 25 then
                Quest.TeleportTo(subSpot)
            end
            Quest.state.statusText = string.format("Hết vé: Cày Zeng Tianguo [%s (%d/%d)]", zTitle, zCur, zMax)
            Quest.UpdateZengUI(config)
            return
        end

        -- Tự động đưa về Home Spot để farm câu thường nếu có cài đặt
        if config.TicketReturnHomeWhenDone and config.HomeFarmSpot and not Quest.state.isAtHomeSpot then
            Quest.TeleportTo(config.HomeFarmSpot)
            Quest.state.isAtHomeSpot = true
            Quest.state.statusText = "Hết quest hôm nay: đã về Home Spot farm!"
            Utils.ShowNotification("Home Spot", "Đã về vị trí Home Spot farm vì đã hết vé hôm nay!", "SUCCESS", 5)
        end
        return
    end

    local qType, qTitle, cur, max, done, detectedCd = Quest.ScanAndUpdateStatus()
    local isDoneNow = Quest.state.isCompleted or done or (Quest.state.targetProgress > 0 and Quest.state.currentProgress >= Quest.state.targetProgress)

    if isDoneNow then
        Quest.state.isCooldown = false
        Quest.state.cooldownEnd = 0
    end

    -- 1. Cooldown
    local hasActiveQuest = (Quest.state.currentQuestType and Quest.state.currentQuestType ~= "none") or (qType ~= nil)
    if not hasActiveQuest and not isDoneNow and Quest.state.isCooldown then
        local remain = math.max(0, math.floor((Quest.state.cooldownEnd or 0) - now))
        if remain > 0 then
            local mins = math.floor(remain / 60)
            local secs = remain % 60
            Quest.state.statusText = string.format("Đang chờ hồi chiêu vé (còn %02d:%02d)", mins, secs)

            -- Trong thời gian hồi chiêu vé: nếu bật Zeng Tianguo thì tranh thủ làm Zeng Tianguo!
            if config.AutoZengTianguoQuest and zCode and not zDone then
                local subSpot = Quest.GetTargetZengSpot() or Quest.state.spot100Fish
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local spotPos = typeof(subSpot) == "CFrame" and subSpot.Position or subSpot
                if root and spotPos and (root.Position - spotPos).Magnitude > 25 then
                    Quest.TeleportTo(subSpot)
                end
                Quest.state.statusText = string.format("Chờ hồi vé (%02d:%02d): Cày Zeng Tianguo [%d/%d]", mins, secs, zCur, zMax)
                Quest.UpdateZengUI(config)
                return
            end

            if config.TicketReturnHomeWhenDone and config.HomeFarmSpot and not Quest.state.isAtHomeSpot then
                local homeTarget = config.HomeFarmSpot
                Quest.TeleportTo(homeTarget)
                Quest.state.isAtHomeSpot = true
                Quest.state.statusText = string.format("Chờ hồi: về Home Spot farm (còn %02d:%02d)", mins, secs)
                Utils.ShowNotification("Home Spot", "Đã về Home Spot để câu farm trong lúc chờ vé!", "SUCCESS", 5)
            end
            return
        else
            Quest.state.readyForNewQuest = true
            Quest.state.isCooldown = false
            Quest.state.isAtHomeSpot = false
            Quest.state.statusText = "Hồi chiêu đã xong! Chuẩn bị nhận vé mới..."
        end
    end

    -- 2. Đã hoàn thành nhiệm vụ -> Nộp vé tại NPC
    if isDoneNow then
        if now - (Quest.state.lastClaimAttempt or 0) >= 3.5 then
            Quest.state.lastClaimAttempt = now
            Quest.state.statusText = "Đã xong nhiệm vụ! Đang nộp vé..."

            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum.Sit = false hum:UnequipTools() end)
            end
            if Events and Events:FindFirstChild("CancelCast") then
                pcall(function() Events.CancelCast:FireServer() end)
            end

            local claimSuccess = Quest.InteractNPC(true, config)
            Quest.ClearUINavigation()
            task.wait(0.5)

            local checkType, _, _, _, checkDone, checkCd = Quest.DetectActiveQuest()
            if checkType == nil or claimSuccess or (checkCd and checkCd > 0) then
                local setCooldown = (checkCd and checkCd > 0) and checkCd or (20 * 60)
                Quest.state.cooldownEnd = now + setCooldown
                Quest.state.isCooldown = true
                Quest.state.isCompleted = false
                Quest.state.isAtHomeSpot = false
                Quest.state.currentQuestType = "none"
                Quest.state.currentProgress = 0
                Quest.state.active = false
                Quest.state.statusText = string.format("Đã nộp vé! Đang chờ hồi chiêu (%d phút)", math.ceil(setCooldown / 60))
                Quest.SaveSpots()
                Utils.ShowNotification("Nhiệm Vụ Vé", string.format("Đã nộp vé thành công! Hồi chiêu %d phút.", math.ceil(setCooldown / 60)), "SUCCESS", 8)
            end
        end
        return
    end

    -- 3. Chưa có quest nào -> Đến NPC nhận vé
    if Quest.state.currentQuestType == "none" then
        if now - Quest.state.lastNpcInteract >= 10.0 then
            Quest.state.lastNpcInteract = now
            Quest.state.statusText = "Đang tương tác NPC nhận vé mới..."
            Quest.state.isAcceptingQuest = true
            Quest.state.isCooldown = false
            Quest.state.isAtHomeSpot = false

            Quest.InteractNPC(false, config)
            Quest.ClearUINavigation()

            task.wait(3.0)
            Quest.state.isAcceptingQuest = false
            local freshType, freshTitle, freshCur, freshMax = Quest.DetectActiveQuest()
            if freshType then
                Quest.state.readyForNewQuest = false
                Quest.state.currentQuestType = freshType
                Quest.state.currentQuestTitle = freshTitle or "Nhiệm Vụ Vé"
                Quest.state.targetProgress = freshMax > 0 and freshMax or (freshType == "fish_15m" and 10 or 100)
                Quest.state.currentProgress = freshCur or 0
                Quest.state.active = true
                Quest.state.isAtHomeSpot = false
                Quest.state.statusText = "Đang làm: " .. Quest.state.currentQuestTitle

                local targetSpot = Quest.state.spot100Fish
                if freshType == "fish_15m" then targetSpot = Quest.state.spot15MFish
                elseif freshType == "bait_100" then targetSpot = Quest.state.spot100Bait or Quest.state.spot100Fish
                elseif freshType == "skill_100" then targetSpot = Quest.state.spot100Skill or Quest.state.spot100Fish end

                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local spotPos = typeof(targetSpot) == "CFrame" and targetSpot.Position or targetSpot
                if root and spotPos and (root.Position - spotPos).Magnitude > 25 then
                    Quest.TeleportTo(targetSpot)
                end
                Quest.CloseDialogue()
            end
        end
        return
    end

    -- 4. Quest đang hoạt động -> Bay tới điểm câu và làm nhiệm vụ
    Quest.state.active = true
    Quest.state.isAtHomeSpot = false

    local char = LocalPlayer.Character
    local isFishing = char and char:GetAttribute("Fishing") == true
    local isMinigame = char and char:GetAttribute("Minigame") == true
    if isFishing or isMinigame then return end

    local targetSpot = Quest.state.spot100Fish
    if Quest.state.currentQuestType == "fish_15m" then targetSpot = Quest.state.spot15MFish
    elseif Quest.state.currentQuestType == "bait_100" then targetSpot = Quest.state.spot100Bait or Quest.state.spot100Fish
    elseif Quest.state.currentQuestType == "skill_100" then targetSpot = Quest.state.spot100Skill or Quest.state.spot100Fish end

    local root = char and char:FindFirstChild("HumanoidRootPart")
    local spotPos = typeof(targetSpot) == "CFrame" and targetSpot.Position or targetSpot
    if root and spotPos and (root.Position - spotPos).Magnitude > 25 then
        Quest.TeleportTo(targetSpot)
        Quest.CloseDialogue()
    end

    -- Tự bán cá nếu đầy balo
    if config.TicketAutoSellFull then
        local pData = Quest.GetPlayerDataFolder()
        if pData and pData:FindFirstChild("InventoryLimit") then
            local invCount = 0
            if pData:FindFirstChild("Inventory") then invCount = invCount + #pData.Inventory:GetChildren() end
            if invCount >= (pData.InventoryLimit.Value - 1) then
                if Events and Events:FindFirstChild("SellFish") then
                    Events.SellFish:FireServer("All")
                end
            end
        end
    end

    -- Quản lý mồi cho quest 100 bait
    if Quest.state.currentQuestType == "bait_100" then
        local baitName = config.TicketBaitChoice or "Basic Bait"
        local pData = Quest.GetPlayerDataFolder()
        if pData and pData:FindFirstChild("Bait") then
            local bVal = pData.Bait:FindFirstChild(baitName)
            local bCount = bVal and bVal.Value or 0
            if bCount < 5 and (now - Quest.state.lastBaitBuy >= 2.0) then
                Quest.state.lastBaitBuy = now
                if Events and Events:FindFirstChild("BuyBait") then
                    Events.BuyBait:FireServer(baitName, 30)
                end
            end
            if pData:FindFirstChild("EquippedBait") and pData.EquippedBait.Value ~= baitName and (now - Quest.state.lastBaitEquip >= 2.0) then
                Quest.state.lastBaitEquip = now
                if Events and Events:FindFirstChild("EquipBait") then
                    task.spawn(function() Events.EquipBait:InvokeServer(baitName) end)
                end
            end
        end
    end
end

pcall(Quest.LoadSpots)

return Quest
