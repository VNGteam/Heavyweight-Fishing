--[[
    v2/features/boss.lua
    Secret Boss Hunting, Fast Skip, Spot Allocation, Teleportation & Chat Sniper
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
        bosses = { "Glacier Leviathan", "Armored Shark", "Frost Kingfish", "Frost Queenfish" }
    },
    ["Volcano Island"] = {
        islandName = "Volcano Island",
        weather = "None",
        patterns = {"volcano", "nui lua", "lava", "magma"},
        reqPower = 1000,
        pos = Vector3.new(-1400, 25, 800),
        bosses = { "Lava Serpent", "Magma Behemoth", "Volcanic Shark", "Reborn Puffer Beast" }
    },
    ["Deep Ocean"] = {
        islandName = "Deep Ocean",
        weather = "Storm",
        patterns = {"ocean", "deep", "kraken"},
        reqPower = 1500,
        pos = Vector3.new(2000, 10, 2000),
        bosses = { "Kraken", "Corrupted Kraken", "Phantom Kraken", "Ancient Megalodon", "Megalodon", "Heaven Piercer Turtle" }
    },
    ["Abyssal Trench"] = {
        islandName = "Abyssal Trench",
        weather = "None",
        patterns = {"abyss", "vuc tham", "depth"},
        reqPower = 2500,
        pos = Vector3.new(-2500, 5, -3000),
        bosses = { "Abyssal Behemoth", "Ancient Depth Serpent", "Void Serpent", "Abyss Dweller", "Mountain Dragonwhale", "Mirage Lanternfish", "Nameless Octoparasite" }
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
Boss.customSpots = {}

-- 2. Quản lý Slot Điểm Câu An Toàn Theo Acc & Jitter
function Boss.GetAllocatedSlot(config)
    if config.BossSpotAllocationMode == "Tự Động (Theo Acc)" then
        local uid = LocalPlayer.UserId or 12345
        return (uid % 5) + 1
    else
        return tonumber(config.SelectedCustomSpotSlot) or 1
    end
end

function Boss.ApplyJitter(pos, config)
    if not config.BossTeleportJitter or not pos then return pos end
    local dist = tonumber(config.BossTeleportJitterDist) or 1.0
    local rx = (math.random() - 0.5) * 2 * dist
    local rz = (math.random() - 0.5) * 2 * dist
    return pos + Vector3.new(rx, 0, rz)
end

function Boss.LoadCustomSpots()
    if not (isfile and readfile and isfile("HeavyweightFishing_CustomSpots.json")) then return end
    pcall(function()
        local raw = readfile("HeavyweightFishing_CustomSpots.json")
        local dec = HttpService:JSONDecode(raw)
        if dec and type(dec) == "table" then
            Boss.customSpots = dec
        end
    end)
end

function Boss.SaveCustomSpots()
    if not (writefile and HttpService) then return end
    pcall(function()
        writefile("HeavyweightFishing_CustomSpots.json", HttpService:JSONEncode(Boss.customSpots))
    end)
end

function Boss.SetCustomSpot(island, slot, pos)
    if not Boss.customSpots[island] then Boss.customSpots[island] = {} end
    Boss.customSpots[island][tostring(slot)] = { x = pos.X, y = pos.Y, z = pos.Z }
    Boss.SaveCustomSpots()
end

function Boss.GetCustomSpot(island, slot)
    if Boss.customSpots[island] and Boss.customSpots[island][tostring(slot)] then
        local p = Boss.customSpots[island][tostring(slot)]
        return Vector3.new(p.x, p.y, p.z)
    end
    return nil
end

-- 3. Detect Currently Hooked Fish Name
function Boss.GetCurrentHookedFishName(fUI)
    local char = LocalPlayer.Character
    if char then
        local fishName = char:GetAttribute("HookedFish") or char:GetAttribute("FishName") or char:GetAttribute("TargetFish")
        if fishName and tostring(fishName) ~= "" then
            return tostring(fishName)
        end
    end

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

-- 4. Fast-Skip Non-Target Fish
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
            if config.SecretBossAlertWebhook and not Boss.webhookSentForCurrent then
                Boss.webhookSentForCurrent = true
                if config.WebhookUrl ~= "" then
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
                if config.TelegramNotifyBoss and config.TelegramBotToken ~= "" and config.TelegramChatId ~= "" then
                    Utils.SendTelegramMessage(
                        config,
                        string.format("🔥 *ĐÃ CẮN CÂU SECRET BOSS!*\\nNgười chơi: `%s`\\nBoss: *%s*", LocalPlayer.Name, hookedName)
                    )
                end
            end
        else
            Boss.isCatchingTarget = false
            pcall(function()
                if Events and Events:FindFirstChild("CancelCast") then
                    Events.CancelCast:FireServer()
                end
            end)
        end
    end
end

-- 5. Chat Sniper & Teleport
function Boss.HandleChatMessage(message, config)
    if not config.AutoChatSecretBoss or not message or message == "" then return end
    local lowerMsg = message:lower()

    if lowerMsg:find("caught") or lowerMsg:find("has caught") or lowerMsg:find("câu được") or lowerMsg:find("bắt được") then
        return
    end

    for bossName, islandData in pairs(Boss.lookup) do
        if lowerMsg:find(bossName:lower(), 1, true) then
            Utils.ShowNotification("Săn Boss Bí Mật", "Phát hiện Boss [" .. bossName .. "] xuất hiện! Đang di chuyển...", "WARN", 5)
            Boss.activeBoss = bossName

            local slot = Boss.GetAllocatedSlot(config)
            local customPos = Boss.GetCustomSpot(islandData.islandName, slot)
            local targetPos = customPos or islandData.pos

            if targetPos then
                targetPos = Boss.ApplyJitter(targetPos, config)
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                end
            end
            break
        end
    end
end

pcall(Boss.LoadCustomSpots)

return Boss
