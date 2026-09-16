--[[
    v2/features/spirits.lua
    God Spirit Praying, Taoist & Maoshan Scanning, Teleportation & Auto Server Hop
--]]

local Services = require(script.Parent.Parent.core.services)
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Services.LocalPlayer
local HttpService = Services.HttpService
local TeleportService = Services.TeleportService
local Events = Services.Events
local Utils = require(script.Parent.Parent.core.utils)
local Colors = require(script.Parent.Parent.ui.theme).Colors

local Spirits = {}

Spirits.cachedTaoist = nil
Spirits.lastTaoistScan = 0
Spirits.cachedMaoshan = nil
Spirits.lastMaoshanScan = 0
Spirits.cachedGod = nil
Spirits.lastGodScan = 0
Spirits.lastGodPrayTime = 0
Spirits.lastHopAttempt = 0
Spirits.npcHopVisited = {}

local function getCandidateNPCFolders()
    local candidateFolders = {}
    for _, fName in ipairs({"NPC", "NPCs", "Merchant", "Merchants", "Entities", "Characters"}) do
        local f = Workspace:FindFirstChild(fName)
        if f then
            table.insert(candidateFolders, f)
            for _, subName in ipairs({"Function", "Merchant", "Merchants", "Taoist", "SellFish", "SetSpawn", "BuyBait", "BuyFishingRod"}) do
                local sf = f:FindFirstChild(subName)
                if sf then table.insert(candidateFolders, sf) end
            end
        end
    end
    return candidateFolders
end

local function isTaoistText(str)
    if not str or typeof(str) ~= "string" or str == "" then return false end
    local s = str:lower()
    if s:find("angler") or s:find("blind") or s:find("maoshan") or s:find("mao shan") then
        return false
    end
    return (s:find("taoist") or s:find("đạo sĩ") or s:find("dao si") or s:find("daoshi")) ~= nil
end

local function isMaoshanText(str)
    if not str or typeof(str) ~= "string" or str == "" then return false end
    local s = str:lower()
    if s:find("angler") or s:find("blind") then
        return false
    end
    return (s:find("maoshan") or s:find("mao shan") or s:find("mao_shan") or s:find("biao ge")) ~= nil
end

local function isNPCModel(inst)
    if not inst or not inst:IsA("Model") then return false end
    return inst:FindFirstChildOfClass("Humanoid") ~= nil
        or inst:FindFirstChild("HumanoidRootPart") ~= nil
        or inst:FindFirstChild("Head") ~= nil
end

-- Quét tìm Đạo Sĩ (Taoist)
function Spirits.ScanForTaoistNPC()
    local candidateFolders = getCandidateNPCFolders()

    for _, folder in ipairs(candidateFolders) do
        for _, n in ipairs(folder:GetChildren()) do
            if isNPCModel(n) and isTaoistText(n.Name) then
                return n, "Đạo Sĩ (Taoist)", "Taoist", Colors.AccentOrange or Color3.fromRGB(255, 170, 0), "📜"
            end
        end
    end

    for _, folder in ipairs(candidateFolders) do
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local act = tostring(d.ActionText or "")
                local obj = tostring(d.ObjectText or "")
                local pName = d.Parent and d.Parent.Name or ""
                if isTaoistText(act) or isTaoistText(obj) or isTaoistText(pName) then
                    local model = d:FindFirstAncestorOfClass("Model") or d.Parent
                    if model and not (model.Name:lower():find("angler") or model.Name:lower():find("blind")) then
                        return model, "Đạo Sĩ (Taoist)", "Taoist", Colors.AccentOrange or Color3.fromRGB(255, 170, 0), "📜"
                    end
                end
            elseif d:IsA("TextLabel") and d.Visible and d.Text and #d.Text > 0 then
                if isTaoistText(d.Text) then
                    local model = d:FindFirstAncestorOfClass("Model") or d.Parent
                    if model and not (model.Name:lower():find("angler") or model.Name:lower():find("blind")) then
                        return model, "Đạo Sĩ (Taoist)", "Taoist", Colors.AccentOrange or Color3.fromRGB(255, 170, 0), "📜"
                    end
                end
            end
        end
    end

    for _, n in ipairs(Workspace:GetChildren()) do
        if isNPCModel(n) and isTaoistText(n.Name) then
            return n, "Đạo Sĩ (Taoist)", "Taoist", Colors.AccentOrange or Color3.fromRGB(255, 170, 0), "📜"
        end
    end

    return nil
end

-- Quét tìm Đạo Sĩ Mao Sơn (Maoshan)
function Spirits.ScanForMaoshanNPC()
    local candidateFolders = getCandidateNPCFolders()

    for _, folder in ipairs(candidateFolders) do
        for _, n in ipairs(folder:GetChildren()) do
            if isNPCModel(n) and isMaoshanText(n.Name) then
                return n, "Đạo Sĩ Maoshan", "Maoshan", Colors.PurplePrimary or Color3.fromRGB(168, 85, 247), "✨"
            end
        end
    end

    for _, folder in ipairs(candidateFolders) do
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local act = tostring(d.ActionText or "")
                local obj = tostring(d.ObjectText or "")
                local pName = d.Parent and d.Parent.Name or ""
                if isMaoshanText(act) or isMaoshanText(obj) or isMaoshanText(pName) then
                    local model = d:FindFirstAncestorOfClass("Model") or d.Parent
                    if model and not (model.Name:lower():find("angler") or model.Name:lower():find("blind")) then
                        return model, "Đạo Sĩ Maoshan", "Maoshan", Colors.PurplePrimary or Color3.fromRGB(168, 85, 247), "✨"
                    end
                end
            elseif d:IsA("TextLabel") and d.Visible and d.Text and #d.Text > 0 then
                if isMaoshanText(d.Text) then
                    local model = d:FindFirstAncestorOfClass("Model") or d.Parent
                    if model and not (model.Name:lower():find("angler") or model.Name:lower():find("blind")) then
                        return model, "Đạo Sĩ Maoshan", "Maoshan", Colors.PurplePrimary or Color3.fromRGB(168, 85, 247), "✨"
                    end
                end
            end
        end
    end

    for _, n in ipairs(Workspace:GetChildren()) do
        if isNPCModel(n) and isMaoshanText(n.Name) then
            return n, "Đạo Sĩ Maoshan", "Maoshan", Colors.PurplePrimary or Color3.fromRGB(168, 85, 247), "✨"
        end
    end

    return nil
end

-- Quét tìm Thần Linh (God Spirit)
function Spirits.ScanForGodSpirit()
    local godKeywords = {"spirit", "god spirit", "godspirit", "thần linh", "than linh"}
    local function matchesGod(str)
        if not str or typeof(str) ~= "string" or str == "" then return nil end
        local s = str:lower()
        for _, pat in ipairs(godKeywords) do
            if s:find(pat, 1, true) then return pat end
        end
        return nil
    end

    local candidateFolders = {}
    for _, fName in ipairs({"NPC", "NPCs", "Entities", "Characters"}) do
        local f = Workspace:FindFirstChild(fName)
        if f then table.insert(candidateFolders, f) end
    end

    for _, folder in ipairs(candidateFolders) do
        for _, n in ipairs(folder:GetChildren()) do
            if (n:IsA("Model") or n:IsA("BasePart")) and matchesGod(n.Name) then
                return n
            end
        end
    end

    for _, folder in ipairs(candidateFolders) do
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local pat = matchesGod(d.ActionText) or matchesGod(d.ObjectText) or matchesGod(d.Parent and d.Parent.Name)
                if pat then
                    return d:FindFirstAncestorOfClass("Model") or d.Parent
                end
            elseif d:IsA("TextLabel") and d.Visible and d.Text and #d.Text > 0 then
                if matchesGod(d.Text) then
                    return d:FindFirstAncestorOfClass("Model") or d.Parent
                end
            end
        end
    end

    for _, n in ipairs(Workspace:GetChildren()) do
        if (n:IsA("Model") or n:IsA("BasePart")) and matchesGod(n.Name) then
            return n
        end
    end

    return nil
end

-- Lưu & Xóa Trạng Thái Hop NPC
function Spirits.SaveNPCHopState(config)
    if not (writefile and isfile) then return end
    local isAnyActive = config.AutoServerHopTaoist or config.AutoServerHopMaoshan or config.AutoServerHopGod
    if isAnyActive then
        pcall(function()
            writefile("HeavyweightFishing_NPCHop.json", HttpService:JSONEncode({
                Active = true,
                Taoist = config.AutoServerHopTaoist == true,
                Maoshan = config.AutoServerHopMaoshan == true,
                God = config.AutoServerHopGod == true,
                Visited = Spirits.npcHopVisited or {},
                StartTime = tick()
            }))
        end)
    else
        pcall(function()
            if isfile("HeavyweightFishing_NPCHop.json") and delfile then
                delfile("HeavyweightFishing_NPCHop.json")
            end
        end)
    end
end

function Spirits.ClearNPCHopState(config)
    config.AutoServerHopTaoist = false
    config.AutoServerHopMaoshan = false
    config.AutoServerHopGod = false
    pcall(function()
        if isfile and isfile("HeavyweightFishing_NPCHop.json") and delfile then
            delfile("HeavyweightFishing_NPCHop.json")
        end
    end)
end

function Spirits.CheckNPCHopOnJoin(config)
    if not (isfile and readfile and isfile("HeavyweightFishing_NPCHop.json")) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("HeavyweightFishing_NPCHop.json"))
    end)
    if ok and type(data) == "table" and data.Active then
        if data.Taoist then config.AutoServerHopTaoist = true end
        if data.Maoshan then config.AutoServerHopMaoshan = true end
        if data.God then config.AutoServerHopGod = true end
        Spirits.npcHopVisited = data.Visited or {}
        Utils.ShowNotification("Đổi Server", "Tiếp tục quét tìm NPC trong server mới...", "INFO", 5)
    end
end

-- Teleport tới NPC
function Spirits.TeleportToNPC(inst)
    if not inst then return false end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local cf = nil
    if inst:IsA("Model") then
        cf = inst:GetPivot()
    elseif inst:IsA("BasePart") then
        cf = inst.CFrame
    end

    if cf then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = cf + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

-- 1. Auto God Pray
function Spirits.HandleGodPray(config)
    if not (config.AutoGodSpiritCheck or config.AutoPrayGodSpirit) then return end
    local now = tick()
    if (now - Spirits.lastGodPrayTime < 60) then return end

    local sp = Spirits.ScanForGodSpirit()
    if sp then
        pcall(function()
            Utils.SendNPCDetectionAlert(config, "GodSpirit", "Thần Linh (God Spirit)", sp)
        end)
        if config.AutoPrayGodSpirit and Events and Events:FindFirstChild("Pray") then
            pcall(function()
                Events.Pray:FireServer()
                Spirits.lastGodPrayTime = now
                Utils.ShowNotification("Thần Linh", "Đã thực hiện bái Thần!", "SUCCESS", 3)
            end)
        end
    end
end

-- 2. Vòng lặp Auto Hop Đạo Sĩ / Mao Sơn / Thần Linh
function Spirits.Tick(config)
    Spirits.HandleGodPray(config)

    if not (config.AutoServerHopTaoist or config.AutoServerHopMaoshan or config.AutoServerHopGod) then
        return
    end

    local now = tick()
    if (now - Spirits.lastHopAttempt < 10) then return end

    local enabledTargets = {}
    local foundTargets = {}

    if config.AutoServerHopTaoist then
        table.insert(enabledTargets, "Đạo Sĩ (Taoist)")
        local tInst, tName = Spirits.ScanForTaoistNPC()
        if tInst then
            table.insert(foundTargets, tostring(tName or "Đạo Sĩ (Taoist)"))
            pcall(function()
                Utils.SendNPCDetectionAlert(config, "Taoist", tName or "Đạo Sĩ (Taoist)", tInst)
            end)
        end
    end

    if config.AutoServerHopMaoshan then
        table.insert(enabledTargets, "Đạo Sĩ Maoshan")
        local mInst, mName = Spirits.ScanForMaoshanNPC()
        if mInst then
            table.insert(foundTargets, tostring(mName or "Đạo Sĩ Maoshan"))
            pcall(function()
                Utils.SendNPCDetectionAlert(config, "Maoshan", mName or "Đạo Sĩ Mao Sơn", mInst)
            end)
        end
    end

    if config.AutoServerHopGod then
        table.insert(enabledTargets, "Thần Linh (God Spirit)")
        local sp = Spirits.ScanForGodSpirit()
        if sp then
            table.insert(foundTargets, "Thần Linh (God Spirit)")
            pcall(function()
                Utils.SendNPCDetectionAlert(config, "GodSpirit", "Thần Linh (God Spirit)", sp)
            end)
        end
    end

    -- Nếu tìm thấy ít nhất 1 NPC mục tiêu
    if #foundTargets > 0 then
        local foundStr = table.concat(foundTargets, ", ")
        Utils.ShowNotification("ĐÃ TÌM THẤY!", "Đã phát hiện " .. foundStr .. " trong server này! Dừng đổi server.", "SUCCESS", 8)
        Spirits.ClearNPCHopState(config)
        return
    end

    -- Nếu không thấy mục tiêu -> Tiến hành nhảy Server tiếp theo
    Spirits.lastHopAttempt = now
    Spirits.SaveNPCHopState(config)
    local targetList = table.concat(enabledTargets, ", ")
    Utils.ShowNotification("Đổi Server", "Không có " .. targetList .. " ở server này. Đang tìm server khác...", "INFO", 5)
    task.delay(1.5, function()
        Utils.ServerHop(Spirits.npcHopVisited)
    end)
end

return Spirits
