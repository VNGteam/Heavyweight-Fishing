--[[
    v2/features/boss.lua
    Secret Boss Hunting, Fast Skip, Spot Teleportation & Chat Sniper
--]]

local Services = require(script.Parent.Parent.core.services)
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Workspace = Services.Workspace
local HttpService = Services.HttpService
local Utils = require(script.Parent.Parent.core.utils)

local Boss = {}

-- 1. Database of Secret Bosses & Islands
Boss.database = {
    ["Coral Island"] = {
        islandName = "Coral Island",
        weather = "None",
        patterns = {"coral", "san ho"},
        reqPower = 100,
        pos = Vector3.new(-120, 15, -450),
        bosses = { "Coral Guardian", "Radiant Sunfish" }
    },
    ["Glacier Island"] = {
        islandName = "Glacier Island",
        weather = "Snow",
        patterns = {"glacier", "ice", "bang tuyet"},
        reqPower = 500,
        pos = Vector3.new(650, 20, -1200),
        bosses = { "Glacier Leviathan", "Armored Shark" }
    },
    ["Volcano Island"] = {
        islandName = "Volcano Island",
        weather = "None",
        patterns = {"volcano", "nui lua", "lava", "magma"},
        reqPower = 1000,
        pos = Vector3.new(-1400, 25, 800),
        bosses = { "Lava Serpent", "Magma Behemoth", "Volcanic Shark" }
    },
    ["Deep Ocean"] = {
        islandName = "Deep Ocean",
        weather = "Storm",
        patterns = {"ocean", "deep", "kraken"},
        reqPower = 1500,
        pos = Vector3.new(2000, 10, 2000),
        bosses = { "Kraken", "Corrupted Kraken", "Phantom Kraken", "Ancient Megalodon", "Megalodon" }
    },
    ["Abyssal Trench"] = {
        islandName = "Abyssal Trench",
        weather = "None",
        patterns = {"abyss", "vuc tham", "depth"},
        reqPower = 2500,
        pos = Vector3.new(-2500, 5, -3000),
        bosses = { "Abyssal Behemoth", "Ancient Depth Serpent", "Void Serpent", "Abyss Dweller" }
    }
}

-- Lookup table: Boss Name -> Island info
Boss.lookup = {}
for islandName, info in pairs(Boss.database) do
    for _, bossName in ipairs(info.bosses) do
        Boss.lookup[bossName] = info
    end
end

Boss.activeBoss = nil
Boss.isCatchingTarget = false
Boss.lastHookedCheckTime = 0
Boss.webhookSentForCurrent = false

-- 2. Detect Currently Hooked Fish Name
function Boss.GetCurrentHookedFishName(fUI)
    -- Check Attribute on Character or Player
    local char = LocalPlayer.Character
    if char then
        local fishName = char:GetAttribute("HookedFish") or char:GetAttribute("FishName") or char:GetAttribute("TargetFish")
        if fishName and tostring(fishName) ~= "" then
            return tostring(fishName)
        end
    end

    -- Check TextLabels inside Fishing UI
    if fUI then
        for _, d in ipairs(fUI:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                local txt = d.Text
                for bossName in pairs(Boss.lookup) do
                    if txt:lower():find(bossName:lower(), 1, true) then
                        return bossName
                    end
                end
            end
        end
    end

    return "Unknown"
end

-- 3. Fast-Skip Non-Target Fish
function Boss.HandleFastSkip(config, fUI, isMinigame)
    if not isMinigame or not config.FastSkipNonTarget then return end
    local now = tick()
    if (now - Boss.lastHookedCheckTime < 0.2) then return end
    Boss.lastHookedCheckTime = now

    local hookedName = Boss.GetCurrentHookedFishName(fUI)
    if hookedName and hookedName ~= "Unknown" then
        local isTarget = false
        if config.SecretBossTargets and config.SecretBossTargets[hookedName] == true then
            isTarget = true
        end

        if isTarget then
            Boss.isCatchingTarget = true
            -- Send Discord Webhook Alert once per boss encounter
            if config.SecretBossAlertWebhook and not Boss.webhookSentForCurrent and config.WebhookUrl ~= "" then
                Boss.webhookSentForCurrent = true
                Utils.SendDiscordWebhook(
                    "🔥 ĐÃ CẮN CÂU SECRET BOSS!",
                    string.format("Người chơi **%s** vừa móc câu thành công Boss: **%s**!", LocalPlayer.Name, hookedName),
                    16711680,
                    {
                        { name = "Boss Name", value = hookedName, inline = true },
                        { name = "Tọa Độ", value = tostring(LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or "N/A"), inline = true }
                    },
                    config.WebhookUrl
                )
            end
        else
            -- Not our target boss -> Fast Skip!
            Boss.isCatchingTarget = false
            pcall(function()
                if Events and Events:FindFirstChild("CancelCast") then
                    Events.CancelCast:FireServer()
                end
            end)
        end
    end
end

-- 4. Chat Sniper (Monitor system announcements for boss spawns)
function Boss.HandleChatMessage(message, config)
    if not config.AutoChatSecretBoss or not message or message == "" then return end
    local lowerMsg = message:lower()

    for bossName, islandData in pairs(Boss.lookup) do
        if lowerMsg:find(bossName:lower(), 1, true) then
            Utils.ShowNotification("Săn Boss Bí Mật", "Phát hiện Boss [" .. bossName .. "] xuất hiện! Đang chuẩn bị...", "WARN", 5)
            Boss.activeBoss = bossName

            -- Teleport player to island location
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and islandData.pos then
                root.CFrame = CFrame.new(islandData.pos + Vector3.new(0, 5, 0))
            end
            break
        end
    end
end

return Boss
