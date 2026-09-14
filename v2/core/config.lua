--[[
    v2/core/config.lua
    Configuration Table, Defaults & Account-Based Persistence
--]]

local Services = require(script.Parent.services)
local HttpService = Services.HttpService
local LocalPlayer = Services.LocalPlayer

local ConfigModule = {}

-- 1. Default Configuration Table
ConfigModule.Config = {
    -- Fishing & Minigame
    AutoCast = false,
    AnchorBar = true,
    AutoSlam = true,
    AutoCharge = true,
    AutoSkills = false,
    AntiStuck = true,
    AutoRhythmHit = true,
    InventoryLimit = 150,

    -- Smart Combo (Rebuilt V2)
    SmartComboEnabled = false,
    LoopSkills = "Z, X, V",
    LoopStrictOrder = true,           -- [MẶC ĐỊNH BẬT]: Luôn giữ đúng thứ tự chiêu Z -> X -> V
    SkillEffectDelay = 1.2,           -- Khoảng cách an toàn giữa 2 lần ra chiêu (giây)
    SmartEffectAutoDetect = true,     -- Tự động phát hiện animation chiêu
    EmergencyHealSkill = "Tắt",       -- Chiêu cứu nguy (Z/X/C/V hoặc Tắt)
    EmergencyHealHp = 40,             -- Ngưỡng máu kích hoạt hồi máu khẩn cấp (%)
    OpenerSkill = "Tắt",              -- Chiêu mở màn
    OpenerMaxCount = 1,
    QuickCatchSkill = "Tắt",

    -- Train Skills
    AutoTrainSkill = false,
    TrainSkill = "Z",
    TrainDelay = 0.5,
    TrainTargetCount = 100,
    TrainCurrentCount = 0,

    -- Auto Bait & Rod & Sell
    AutoEquipBestBait = false,
    SelectedBait = "None",
    AutoEquipBestRod = false,
    AutoEquipOrb = false,
    AutoSellFish = false,
    AutoSellRarity = "All",           -- All / Normal / Rare
    SellInterval = 30,

    -- Secret Boss & Hunting
    AutoChatSecretBoss = false,
    AutoHuntBoss = false,
    FastSkipNonTarget = true,
    TargetBossName = "All",
    WebhookUrl = "",
    SecretBossAlertWebhook = true,
    CustomBossSpots = {},
    HomeFarmSpot = nil,

    -- Ticket Quest
    AutoTicketQuest = false,
    TicketAutoCastAtHome = true,
    TicketQuickSkill = "V",
    TicketSkillKey = "Z",

    -- Spirits & God
    AutoGodPray = false,
    AutoServerHopTaoist = false,
    AutoServerHopMaoshan = false,
    AutoServerHopGod = false,

    -- Shop & Rewards
    AutoClaimDaily = true,
    AutoRedeemCodes = false,
    AutoBuyBait = false,
    AutoBuyBaitType = "Basic Bait",
    AutoCraftBait = false,
    AutoCraftBaitType = "Secret Bait",

    -- Teleport & Server Hop
    AutoWeatherHop = false,
    TargetWeather = "Rain",

    -- Visuals & ESP
    ESP_Fish = false,
    ESP_FishRing = true,
    ESP_FishDetails = true,
    ESP_Players = false,
    ESP_Bosses = true,
    ESP_NPCs = false,
    Fullbright = false,
    RemoveFog = false,
    FPSBoost = false,
    HideUI = false,

    -- Character & Misc
    WalkSpeed = 16,
    CustomSpeedEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
    WalkOnWater = false,
    InfiniteJump = false,
    AntiAFK = true,

    -- System
    UIKeybind = Enum.KeyCode.RightControl,
    StopKeybind = Enum.KeyCode.End
}

-- Danh sách Boss bí mật theo dõi mặc định
ConfigModule.SecretBossTargets = {
    ["Abyssal Behemoth"] = true,
    ["Ancient Depth Serpent"] = true,
    ["Ancient Megalodon"] = true,
    ["Armored Shark"] = true,
    ["Colossal Blue Whale"] = true,
    ["Coral Guardian"] = true,
    ["Corrupted Kraken"] = true,
    ["Crystal Shark"] = true,
    ["Deep Sea Leviathan"] = true,
    ["Deepwater Guardian"] = true,
    ["Glacier Leviathan"] = true,
    ["Golden Shark"] = true,
    ["Golden Whale"] = true,
    ["Infernal Whale"] = true,
    ["Kraken"] = true,
    ["Lava Serpent"] = true,
    ["Magma Behemoth"] = true,
    ["Megalodon"] = true,
    ["Ocean Leviathan"] = true,
    ["Phantom Kraken"] = true,
    ["Radiant Sunfish"] = true,
    ["Shadow Leviathan"] = true,
    ["Spectral Serpent"] = true,
    ["Storm Whale"] = true,
    ["Volcanic Shark"] = true,
    ["Void Serpent"] = true,
    ["Abyss Dweller"] = true
}

-- 2. Account Directory Helpers
local function sanitizeFilename(name)
    return name:gsub("[%c%p%s]", "_")
end

function ConfigModule.GetAccountConfigDir()
    local pName = LocalPlayer and LocalPlayer.Name or "DefaultUser"
    return "Identical/HeavyweightFishing/Configs/" .. sanitizeFilename(pName)
end

function ConfigModule.EnsureAccountConfigDir()
    if not makefolder then return false end
    pcall(makefolder, "Identical")
    pcall(makefolder, "Identical/HeavyweightFishing")
    pcall(makefolder, "Identical/HeavyweightFishing/Configs")
    local dir = ConfigModule.GetAccountConfigDir()
    pcall(makefolder, dir)
    return true
end

function ConfigModule.GetSavedConfigList()
    local list = {}
    if not listfiles then return list end
    ConfigModule.EnsureAccountConfigDir()
    local dir = ConfigModule.GetAccountConfigDir()
    local success, files = pcall(listfiles, dir)
    if success and type(files) == "table" then
        for _, f in ipairs(files) do
            local name = f:match("([^/\\]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    end
    table.sort(list)
    return list
end

-- 3. Save / Load / Delete Account Config
function ConfigModule.SaveAccountConfig(cfgName, uiControllers)
    if not writefile or not cfgName or cfgName == "" then
        return false, "Không hỗ trợ ghi file hoặc tên cấu hình rỗng"
    end
    ConfigModule.EnsureAccountConfigDir()
    local path = ConfigModule.GetAccountConfigDir() .. "/" .. sanitizeFilename(cfgName) .. ".json"

    local serialize = {}
    for k, v in pairs(ConfigModule.Config) do
        if typeof(v) == "EnumItem" then
            serialize[k] = { __enum = tostring(v) }
        elseif typeof(v) == "CFrame" then
            serialize[k] = { __cframe = { v:GetComponents() } }
        elseif typeof(v) == "Vector3" then
            serialize[k] = { __vector3 = { v.X, v.Y, v.Z } }
        else
            serialize[k] = v
        end
    end
    serialize._SecretBossTargets = ConfigModule.SecretBossTargets

    local encoded = HttpService:JSONEncode(serialize)
    local ok, err = pcall(writefile, path, encoded)
    if ok then
        return true, "Đã lưu cấu hình [" .. cfgName .. "] thành công!"
    else
        return false, "Lỗi khi ghi file: " .. tostring(err)
    end
end

function ConfigModule.LoadAccountConfig(cfgName, uiControllers)
    if not readfile or not cfgName or cfgName == "" then
        return false, "Không hỗ trợ đọc file"
    end
    local path = ConfigModule.GetAccountConfigDir() .. "/" .. sanitizeFilename(cfgName) .. ".json"
    if not (isfile and isfile(path)) then
        return false, "Không tìm thấy file cấu hình: " .. cfgName
    end

    local ok, content = pcall(readfile, path)
    if not ok or not content then
        return false, "Không thể đọc nội dung file"
    end

    local decOk, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not decOk or type(decoded) ~= "table" then
        return false, "File cấu hình bị hỏng hoặc sai định dạng JSON"
    end

    for k, v in pairs(decoded) do
        if k == "_SecretBossTargets" and type(v) == "table" then
            ConfigModule.SecretBossTargets = v
        elseif type(v) == "table" and v.__enum then
            local str = v.__enum
            local enumType, enumItem = str:match("Enum%.([^%.]+)%.([^%.]+)")
            if enumType and enumItem and Enum[enumType] and Enum[enumType][enumItem] then
                ConfigModule.Config[k] = Enum[enumType][enumItem]
            end
        elseif type(v) == "table" and v.__cframe then
            ConfigModule.Config[k] = CFrame.new(unpack(v.__cframe))
        elseif type(v) == "table" and v.__vector3 then
            ConfigModule.Config[k] = Vector3.new(unpack(v.__vector3))
        else
            ConfigModule.Config[k] = v
        end

        -- Đồng bộ lên UI nếu có UIControllers
        if uiControllers and uiControllers[k] and uiControllers[k].Set then
            pcall(function()
                uiControllers[k].Set(ConfigModule.Config[k], true)
            end)
        end
    end

    return true, "Đã tải cấu hình [" .. cfgName .. "] thành công!"
end

function ConfigModule.DeleteAccountConfig(cfgName)
    if not delfile or not cfgName or cfgName == "" then return false end
    local path = ConfigModule.GetAccountConfigDir() .. "/" .. sanitizeFilename(cfgName) .. ".json"
    if isfile and isfile(path) then
        local ok = pcall(delfile, path)
        return ok
    end
    return false
end

return ConfigModule
