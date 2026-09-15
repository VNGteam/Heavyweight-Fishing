--[[
    v2/core/config.lua
    Full Configuration Table, Defaults & Account Persistence from backup.lua
--]]

local Services = require(script.Parent.services)
local HttpService = Services.HttpService
local LocalPlayer = Services.LocalPlayer

local ConfigModule = {}

ConfigModule.SCRIPT_BUILD_COMMIT = "v2.1.8"

-- 1. Full Config Table from backup.lua
ConfigModule.Config = {
    -- Câu Cá Cốt Lõi
    AutoCast = false,
    CastDelay = 1.0,
    CastPower = 100,
    AnchorBar = true,
    AutoSlam = true,
    AutoCharge = true,
    AntiStuckEnabled = false,

    -- Smart Combo V2
    SmartComboEnabled = false,
    FishHpThreshold = 500,
    QuickCatchSkill = "Z",
    OpenerSkill = "Z",
    OpenerMaxCount = 1,
    LoopSkills = "Z, X, V",
    LoopStrictOrder = true,           -- [MẶC ĐỊNH BẬT V2]: Luôn giữ đúng thứ tự chiêu
    EmergencyHealSkill = "V",
    EmergencyHealHp = 40,
    SkillEffectDelay = 1.2,
    SmartEffectAutoDetect = true,
    AutoSkills = false,
    SelectedSkill = "One-Strike Heaven Gate",

    -- Auto Luyện Chiêu (Fast Cancel)
    AutoTrainSkill = false,
    TrainSkill = "Z",
    TrainCancelDelay = 0.45,
    Train_Z = false,
    Train_X = false,
    Train_C = true,
    Train_V = true,
    TrainTargetCount = 100,
    TrainCurrentCount = 0,
    TrainSkillCooldown = 6.0,
    TrainDelayCatch = true,

    -- Trang Bị Mồi & Cần
    AutoEquipBestBait = false,
    BaitChoiceNormal = "Mồi Tốt Nhất (Cao Nhất)",
    AutoEquipBossBait = true,
    BaitChoiceBoss = "Mồi Tốt Nhất (Cao Nhất)",
    AutoEquipBestRod = false,
    AutoEquipBestOrb = false,
    Loadout1_Rod = "Wooden Rod",
    Loadout1_Bait = "Basic Bait",
    Loadout2_Rod = "Wooden Rod",
    Loadout2_Bait = "Basic Bait",

    -- Bán Cá & Bảo Vệ
    AutoSell = false,
    SellInterval = 30,
    AutoFavouriteFish = false,
    FavouriteFishName = "Colossal Tigerfish",
    MaterialFarming = false,

    -- Minigame Khác & Săn Boss Thường
    OctoAutoMinigame = false,
    AutoFarmBoss = false,
    AutoFarmSecretBoss = false,
    SelectedBoss = "Enzo",

    -- Săn Secret Boss Theo Chat & Tại Đảo
    AutoHuntBoss = false,
    AutoChatSecretBoss = false,
    AutoServerHopOnDespawn = false,
    FastSkipNonBoss = true,
    SecretBossCheckPower = true,
    SecretBossTargets = {
        ["Verdant Alligator Gar"] = true,
        ["Verdant Grouper"] = true,
        ["Verdant Bonefang"] = true,
        ["Crimson Bonefang"] = true,
        ["Scarlet Fish"] = true,
        ["Elder Scarlet Fish"] = true,
        ["Crimson Electric Eel"] = true,
        ["Golden Dragonfish"] = true,
        ["Rainbow Dragonfish"] = true,
        ["Flying Fish Emperor"] = true,
        ["Flying Fish Empress"] = true,
        ["Draconic Koi"] = true,
        ["Sanguine Fish"] = true,
        ["Tigerfang Whale"] = true,
        ["Heavenpiercer Turtle"] = true,
        ["Heaven Piercer Turtle"] = true,
        ["Reborn Puffer Beast"] = true,
        ["Frost Kingfish"] = true,
        ["Frost Queenfish"] = true,
        ["Mountain Dragonwhale"] = true,
        ["Mirage Lanternfish"] = true,
        ["Nameless Octoparasite"] = true,
    },
    CustomBossSpots = {},
    SelectedCustomSpotIsland = "Đảo Tre (Bamboo Isle)",
    SelectedCustomSpotSlot = 1,
    BossSpotAllocationMode = "Tự Động (Theo Acc)",
    BossTeleportJitter = true,
    BossTeleportJitterDist = 1.0,
    ReturnToHomeWhenClear = true,
    HomeFarmSpot = nil,

    -- Thần Linh & NPC
    AutoGodSpiritCheck = false,
    AutoPrayGodSpirit = false,
    AutoServerHopGod = false,
    AutoServerHopMaoshan = false,
    AutoServerHopTaoist = false,

    -- Tìm Server Thời Tiết
    AutoWeatherHop = false,
    TargetWeather = "Bất Kỳ Thời Tiết Nào (Trừ Clear)",
    WeatherHopAutoFish = true,
    WeatherHopAlertWebhook = true,

    -- Nhiệm Vụ Vé Hàng Ngày
    AutoTicketQuest = false,
    TicketDifficulty = "Hard",
    TicketQuestMode = "Tự Động (Auto Detect)",
    TicketBaitChoice = "Basic Bait",
    TicketSkillKey = "Chiêu Z",
    TicketQuickSkill = "Chiêu V",
    TicketCooldownMinutes = 20,
    TicketAutoSellFull = true,
    TicketReturnHomeWhenDone = true,
    TicketAutoCastAtHome = true,
    TicketRemoteClaim = true,

    -- Quản Lý Độ Ưu Tiên (Priority Manager)
    PrioritySystemEnabled = true,
    PriorityPreset = "Mặc Định: Săn Boss > Vé NV > Thần Linh > Luyện Chiêu > Farm Thường",
    Priority_SecretBoss = 1,
    Priority_TicketQuest = 2,
    Priority_GodSpirit = 3,
    Priority_TrainSkill = 4,
    Priority_NormalFarm = 5,

    -- Phần Thưởng & Gacha & Chế Mồi
    AutoClaimDaily = false,
    DailyClaimDelay = 0.5,
    AutoCraftBait = false,
    CraftBaitName = "Nameless Bait",
    CraftAmount = 1,
    AutoBuyBait = false,
    BuyBaitName = "Ancestral Bait",
    BuyBaitAmount = 5,
    BuyBaitThreshold = 10,
    BuyBaitDelay = 1.0,

    -- ESP & Thị Giác
    ESP_GodSpirit = false,
    ESP_SecretRod = false,
    ESP_Boats = false,
    ESP_Maoshan = false,
    ESP_Taoist = false,
    ESP_Boss = false,
    ESP_Players = false,
    FishRedRing = true,
    ShowFishWeightRing = true,
    NoFog = false,
    Fullbright = false,
    PerformanceMode = false,
    HideGameUI = false,
    HideOverheadNames = false,

    -- Nhân Vật
    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    InfiniteJump = false,
    WalkOnWater = false,
    AcidWaterShield = false,
    Noclip = false,
    AntiAFK = true,
    AutoRejoin = true,

    -- Discord Webhook
    WebhookUrl = "",
    WebhookEnabled = false,
    WebhookNotifyBoss = true,
    WebhookHourlyStats = false,
    WebhookStatsInterval = 60,

    -- Keybinds
    UIKeybind = Enum.KeyCode.RightControl,
    StopKeybind = Enum.KeyCode.End
}

-- 2. Config Label Map from backup.lua
ConfigModule.ConfigLabelMap = {
    ["Tự Động Quăng Cần (Auto Cast)"] = "AutoCast",
    ["Độ Trễ Quăng Cần"] = "CastDelay",
    ["Giữ Thanh Minigame (Anchor Bar)"] = "AnchorBar",
    ["Tự Dùng Kỹ Năng Cần"] = "AutoSkills",
    ["Tự Động Đập Cần (Auto Slam)"] = "AutoSlam",
    ["Tự Động Sạc Dây (Auto Charge)"] = "AutoCharge",
    ["Tự Động Chống Kẹt Cần (Anti-Stuck)"] = "AntiStuckEnabled",

    ["Bật Combo Kỹ Năng Tự Động"] = "SmartComboEnabled",
    ["Ngưỡng Máu Cá Phân Loại"] = "FishHpThreshold",
    ["Chiêu Bắt Nhanh (<= Ngưỡng HP)"] = "QuickCatchSkill",
    ["Chiêu Mở Màn (> Ngưỡng HP)"] = "OpenerSkill",
    ["Số Lần Dùng Chiêu Mở Màn"] = "OpenerMaxCount",
    ["Chuỗi Đảo Chiêu Luân Phiên"] = "LoopSkills",
    ["Tùy Biến Chuỗi Đảo Chiêu"] = "LoopSkills",
    ["Mẫu Chuỗi Chiêu (Preset)"] = "LoopSkills",
    ["Giữ Đúng Thứ Tự Combo (Strict Order)"] = "LoopStrictOrder",
    ["Chiêu Hồi Máu / Cứu Nguy"] = "EmergencyHealSkill",
    ["Kích Hoạt Hồi Máu Khi HP Dưới"] = "EmergencyHealHp",
    ["Thời Gian Chờ Ra Chiêu"] = "SkillEffectDelay",
    ["Tự Động Nhận Diện Hết Hiệu Ứng"] = "SmartEffectAutoDetect",

    ["Bật Auto Luyện Chiêu"] = "AutoTrainSkill",
    ["Chọn Chiêu Cần Luyện"] = "TrainSkill",
    ["Nhịp Chờ Xuất Chiêu (Cancel Delay)"] = "TrainCancelDelay",
    ["Mục Tiêu Số Lần Dùng"] = "TrainTargetCount",

    ["Tự Động Bán Cá Khi Đầy Túi"] = "AutoSell",
    ["Giãn Cách Bán Cá Tự Động"] = "SellInterval",
    ["Tự Động Khóa Cá Đột Biến (Mutations)"] = "AutoProtectMutations",
    ["Tự Động Gom Cá Nguyên Liệu (Crafting)"] = "MaterialFarming",
    ["Tự Động Khóa Cá Yêu Thích"] = "AutoFavouriteFish",
    ["Tên Loài Cá Cần Khóa"] = "FavouriteFishName",

    ["Tự Động Trang Bị Cần Tốt Nhất"] = "AutoEquipBestRod",
    ["Tự Dùng Cần Tốt Nhất"] = "AutoEquipBestRod",
    ["Tự Động Trang Bị Mồi"] = "AutoEquipBestBait",
    ["Tự Dùng Mồi (Auto Bait)"] = "AutoEquipBestBait",
    ["Tự Dùng Mồi Tốt Nhất"] = "AutoEquipBestBait",
    ["Chọn Mồi Khi Câu Thường"] = "BaitChoiceNormal",
    ["Tự Đổi Mồi Khi Săn Boss"] = "AutoEquipBossBait",
    ["Chọn Mồi Săn Boss"] = "BaitChoiceBoss",
    ["Tự Động Trang Bị Pháp Bảo Tốt Nhất"] = "AutoEquipBestOrb",
    ["Tự Dùng Ngọc Tốt Nhất"] = "AutoEquipBestOrb",

    ["Bật Chế Độ Săn Boss (Tự Quăng Cần & Lọc Cá)"] = "AutoHuntBoss",
    ["Bật Săn Secret Boss (Chat Sniper)"] = "AutoChatSecretBoss",
    ["Tự Động Săn Secret Boss Theo Chat"] = "AutoChatSecretBoss",
    ["Giật Cần Thả Lại (Fast Skip Cá Thường)"] = "FastSkipNonBoss",
    ["Bỏ Qua Cá Thường (Fast Skip)"] = "FastSkipNonBoss",
    ["Kiểm Tra Lực Cần (Power Check)"] = "SecretBossCheckPower",
    ["Chỉ Săn Khi Đủ Lực Cần (Power Check)"] = "SecretBossCheckPower",
    ["Tự Đổi Server Khi Hết Boss (Auto-Hop)"] = "AutoServerHopOnDespawn",
    ["Đổi Server Khi Hết Secret Boss"] = "AutoServerHopOnDespawn",
    ["Tự Về Vị Trí Farm Khi Hết Boss / Clear"] = "ReturnToHomeWhenClear",

    ["Tự Động Tìm Server Thời Tiết"] = "AutoWeatherHop",
    ["Chọn Thời Tiết Cần Tìm"] = "TargetWeather",
    ["Tự Động Câu / Săn Boss Khi Tìm Thấy"] = "WeatherHopAutoFish",
    ["Gửi Webhook Khi Tìm Thấy Server"] = "WeatherHopAlertWebhook",

    ["Tự Động Quét Trạng Thái Thần Linh"] = "AutoGodSpiritCheck",
    ["Tự Động Cầu Nguyện Thần Linh"] = "AutoPrayGodSpirit",
    ["Đổi Server Tìm Thần Linh"] = "AutoServerHopGod",
    ["Đổi Server Tìm Maoshan"] = "AutoServerHopMaoshan",
    ["Đổi Server Tìm Đạo Sĩ (Taoist)"] = "AutoServerHopTaoist",
    ["Đổi Server Tìm Taoist"] = "AutoServerHopTaoist",

    ["Tự Động Nộp Vé Nhiệm Vụ (Tickets)"] = "AutoTicketQuest",
    ["Chọn Độ Khó Vé Nhiệm Vụ"] = "TicketDifficulty",
    ["Chế Độ Nhiệm Vụ"] = "TicketQuestMode",
    ["Loại Mồi Làm Nhiệm Vụ 100 Mồi"] = "TicketBaitChoice",
    ["Chiêu Dùng Cho Nhiệm Vụ 100 Skill"] = "TicketSkillKey",
    ["Chiêu Giật Nhanh Cho 100 Con Cá"] = "TicketQuickSkill",
    ["Thời Gian Hồi Chiêu (Phút)"] = "TicketCooldownMinutes",
    ["Tự Bán Cá Khi Đầy Balo (Vé NV)"] = "TicketAutoSellFull",
    ["Tự Về Home Spot Khi Xong Nhiệm Vụ"] = "TicketReturnHomeWhenDone",
    ["Tự Động Quăng Cần Tại Home Spot"] = "TicketAutoCastAtHome",
    ["Nhận & Nộp Vé Từ Xa (Remote)"] = "TicketRemoteClaim",
    ["Tự Động Nhận Thưởng Hàng Ngày (Daily)"] = "AutoClaimDaily",
    ["Vòng Quay May Mắn (Auto Gacha)"] = "AutoGacha",
    ["Chọn Vòng Quay Gacha"] = "GachaBanner",
    ["Số Vé Mỗi Lần Quay"] = "GachaPullsPerAction",

    ["Bật Quản Lý Độ Ưu Tiên"] = "PrioritySystemEnabled",
    ["Mẫu Phân Cấp (Preset)"] = "PriorityPreset",
    ["Ưu Tiên: 🎯 Săn Secret Boss"] = "Priority_SecretBoss",
    ["Ưu Tiên: 📜 Làm Vé Nhiệm Vụ"] = "Priority_TicketQuest",
    ["Ưu Tiên: ⛩️ Cúng Thần Linh"] = "Priority_GodSpirit",
    ["Ưu Tiên: ⚔️ Auto Luyện Chiêu"] = "Priority_TrainSkill",
    ["Ưu Tiên: 🎣 Treo Farm Thường"] = "Priority_NormalFarm",

    ["ESP Thần Linh (God Spirit)"] = "ESP_GodSpirit",
    ["ESP Cần Câu Bí Mật"] = "ESP_SecretRod",
    ["ESP Thuyền Bè"] = "ESP_Boats",
    ["ESP Maoshan"] = "ESP_Maoshan",
    ["ESP Đạo Sĩ (Taoist)"] = "ESP_Taoist",
    ["ESP Trùm Boss"] = "ESP_Boss",
    ["ESP Người Chơi"] = "ESP_Players",
    ["Vòng Tròn Định Vị Cá"] = "FishRedRing",
    ["Hiện Cân Nặng & Đột Biến Trên Vòng Đỏ"] = "ShowFishWeightRing",
    ["Xóa Sương Mù & Mưa Bão"] = "NoFog",
    ["Sáng Màn Hình (Fullbright)"] = "Fullbright",
    ["Chế Độ Giảm Lag (Low GFX)"] = "PerformanceMode",
    ["Ẩn Giao Diện Gốc Của Game"] = "HideGameUI",
    ["Ẩn Tên Mặc Định Người Chơi"] = "HideOverheadNames",

    ["Tăng Tốc Độ Chạy (Speed)"] = "WalkSpeedEnabled",
    ["Chỉnh Tốc Độ"] = "WalkSpeedValue",
    ["Bay Lượn Tự Do (Fly)"] = "FlyEnabled",
    ["Tốc Độ Bay"] = "FlySpeed",
    ["Nhảy Vô Hạn (Infinite Jump)"] = "InfiniteJump",
    ["Đi Trên Mặt Nước"] = "WalkOnWater",
    ["Khiên Nước Axit (Acid Shield)"] = "AcidWaterShield",
    ["Đi Xuyên Tường (Noclip)"] = "Noclip",
    ["Chống Văng Game (Anti-AFK)"] = "AntiAFK",
    ["Tự Động Kết Nối Lại"] = "AutoRejoin",

    ["Webhook URL"] = "WebhookUrl",
    ["Bật Webhook"] = "WebhookEnabled",
    ["Thông Báo Bắt Được Boss"] = "WebhookNotifyBoss",
    ["Báo Cáo Tiến Độ Mỗi Giờ"] = "WebhookHourlyStats",
    ["Tần Suất Gửi Báo Cáo"] = "WebhookStatsInterval"
}

-- 3. Account Persistence Helpers
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
            if name then table.insert(list, name) end
        end
    end
    table.sort(list)
    return list
end

function ConfigModule.SaveAccountConfig(cfgName, uiControllers)
    if not writefile or not cfgName or cfgName == "" then return false, "Không hỗ trợ ghi file" end
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

    local encoded = HttpService:JSONEncode(serialize)
    local ok, err = pcall(writefile, path, encoded)
    return ok, ok and ("Đã lưu cấu hình [" .. cfgName .. "]") or tostring(err)
end

function ConfigModule.LoadAccountConfig(cfgName, uiControllers)
    if not readfile or not cfgName or cfgName == "" then return false, "Không hỗ trợ đọc file" end
    local path = ConfigModule.GetAccountConfigDir() .. "/" .. sanitizeFilename(cfgName) .. ".json"
    if not (isfile and isfile(path)) then return false, "Không tìm thấy file" end

    local ok, content = pcall(readfile, path)
    if not ok or not content then return false, "Không thể đọc nội dung file" end

    local decOk, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not decOk or type(decoded) ~= "table" then return false, "JSON lỗi" end

    for k, v in pairs(decoded) do
        if type(v) == "table" and v.__enum then
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

        if uiControllers and uiControllers[k] and uiControllers[k].Set then
            pcall(function() uiControllers[k].Set(ConfigModule.Config[k], true) end)
        end
    end
    return true, "Đã tải cấu hình thành công!"
end

function ConfigModule.DeleteAccountConfig(cfgName)
    if not delfile or not cfgName or cfgName == "" then return false end
    local path = ConfigModule.GetAccountConfigDir() .. "/" .. sanitizeFilename(cfgName) .. ".json"
    if isfile and isfile(path) then
        return pcall(delfile, path)
    end
    return false
end

-- 4. Smart Combo Persistence (HeavyweightFishing_SmartCombo.json)
local SMART_COMBO_FILE = "HeavyweightFishing_SmartCombo.json"
local SMART_COMBO_KEYS = {
    "SmartComboEnabled", "FishHpThreshold", "QuickCatchSkill", "OpenerSkill",
    "OpenerMaxCount", "LoopSkills", "LoopStrictOrder", "EmergencyHealSkill",
    "EmergencyHealHp", "SkillEffectDelay", "SmartEffectAutoDetect"
}

local _smartComboSavePending = false
function ConfigModule.SaveSmartCombo()
    if not writefile or _smartComboSavePending then return end
    _smartComboSavePending = true
    task.delay(0.3, function()
        _smartComboSavePending = false
        local data = {}
        for _, k in ipairs(SMART_COMBO_KEYS) do
            data[k] = ConfigModule.Config[k]
        end
        local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
        if ok and encoded then
            pcall(writefile, SMART_COMBO_FILE, encoded)
        end
    end)
end

function ConfigModule.LoadSmartComboAndSyncUI(uiControllers, onSyncLoopSkills)
    if not (isfile and isfile(SMART_COMBO_FILE) and readfile) then return end
    local ok, content = pcall(readfile, SMART_COMBO_FILE)
    if not ok or not content or #content == 0 then return end
    local decOk, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not decOk or type(data) ~= "table" then return end

    for _, k in ipairs(SMART_COMBO_KEYS) do
        if data[k] ~= nil then
            ConfigModule.Config[k] = data[k]
        end
    end

    task.spawn(function()
        task.wait(0.1)
        for _, k in ipairs(SMART_COMBO_KEYS) do
            if uiControllers and uiControllers[k] and uiControllers[k].Set and ConfigModule.Config[k] ~= nil then
                pcall(function() uiControllers[k].Set(ConfigModule.Config[k], true) end)
            end
        end
        if onSyncLoopSkills and ConfigModule.Config.LoopSkills then
            pcall(onSyncLoopSkills, ConfigModule.Config.LoopSkills)
        end
    end)
end

-- 5. Boss Targets Persistence (HeavyweightFishing_BossTargets.json)
local BOSS_TARGETS_FILE = "HeavyweightFishing_BossTargets.json"
local _bossTargetsSavePending = false

function ConfigModule.SaveBossTargets()
    if not writefile or _bossTargetsSavePending then return end
    _bossTargetsSavePending = true
    task.delay(0.3, function()
        _bossTargetsSavePending = false
        local data = {}
        for k, v in pairs(ConfigModule.Config.SecretBossTargets) do
            data[k] = v
        end
        local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
        if ok and encoded then
            pcall(writefile, BOSS_TARGETS_FILE, encoded)
        end
    end)
end

function ConfigModule.LoadBossTargetsAndSyncUI(bossTogglesMap)
    if not (isfile and isfile(BOSS_TARGETS_FILE) and readfile) then return end
    local ok, content = pcall(readfile, BOSS_TARGETS_FILE)
    if not ok or not content or #content == 0 then return end
    local decOk, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not decOk or type(data) ~= "table" then return end

    for k, v in pairs(data) do
        if ConfigModule.Config.SecretBossTargets[k] ~= nil then
            ConfigModule.Config.SecretBossTargets[k] = v
        end
    end

    task.spawn(function()
        task.wait(0.1)
        if bossTogglesMap then
            for bName, val in pairs(ConfigModule.Config.SecretBossTargets) do
                if bossTogglesMap[bName] and bossTogglesMap[bName].Set then
                    pcall(function() bossTogglesMap[bName].Set(val, true) end)
                end
            end
        end
    end)
end

return ConfigModule
