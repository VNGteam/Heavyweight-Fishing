pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
end)

--// CƠ CHẾ AUTO-KILL: TỰ ĐỘNG DIỆT BẢN CŨ TRÁNH ĐÈ SCRIPT //--
local globalEnv = (getgenv and getgenv()) or _G or shared or {}

if globalEnv.HeavyweightFishingKill then
    pcall(globalEnv.HeavyweightFishingKill)
    globalEnv.HeavyweightFishingKill = nil
end
if globalEnv.IdenticalHeavyweightFishingUnload then
    pcall(globalEnv.IdenticalHeavyweightFishingUnload)
    globalEnv.IdenticalHeavyweightFishingUnload = nil
end

local function CleanOldInstances()
    local guiLocations = {}
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then table.insert(guiLocations, h) end
    end
    pcall(function()
        table.insert(guiLocations, game:GetService("CoreGui"))
    end)
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if lp and lp:FindFirstChild("PlayerGui") then
            table.insert(guiLocations, lp.PlayerGui)
        end
    end)

    local targetNames = {
        "IdenticalHeavyweightFishing",
        "HeavyweightFishing",
        "FloatingAvatar",
        "FloatingCrescent",
        "Notifications"
    }

    for _, loc in ipairs(guiLocations) do
        pcall(function()
            for _, child in ipairs(loc:GetChildren()) do
                for _, name in ipairs(targetNames) do
                    if child.Name == name then
                        child:Destroy()
                    end
                end
            end
        end)
    end

    pcall(function()
        local ws = game:GetService("Workspace")
        for _, child in ipairs(ws:GetChildren()) do
            if child.Name == "IdenticalESP" then child:Destroy() end
        end
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p.Character then
                for _, d in ipairs(p.Character:GetDescendants()) do
                    if d:IsA("BillboardGui") and d.Name:sub(1, 4) == "ESP_" then
                        d:Destroy()
                    end
                end
            end
        end
    end)
end
CleanOldInstances()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        repeat task.wait() until Players.LocalPlayer
    end)
    LocalPlayer = Players.LocalPlayer
end
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildWhichIsA("Camera")

local isRunning = true
local activeConnections = {}
local cleanUpInstances = {}

--// MÃ COMMIT BẢN BUILD HIỆN TẠI (NHÚNG TĨNH TRONG CODE, KHÔNG DÙNG MẠNG) //--
local SCRIPT_BUILD_COMMIT = "7347277"

local Events = ReplicatedStorage:FindFirstChild("Events")
if not Events then
    task.spawn(function()
        Events = ReplicatedStorage:WaitForChild("Events", 5)
    end)
end

local Config = {
    AutoCast = false,
    CastDelay = 1.0,
    CastPower = 100,
    AnchorBar = true,
    AutoSlam = true,
    AutoCharge = true,
    InstantCatch = true,
    AntiStuckEnabled = false,
    SmartComboEnabled = false,
    FishHpThreshold = 500,
    QuickCatchSkill = "Z",
    OpenerSkill = "Z",
    OpenerMaxCount = 1,
    LoopSkills = "X, C",
    EmergencyHealSkill = "V",
    EmergencyHealHp = 40,
    SkillEffectDelay = 1.2,
    SmartEffectAutoDetect = true,
    AutoSkills = false,
    SelectedSkill = "One-Strike Heaven Gate",
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
    
    AutoSell = false,
    SellInterval = 30,
    AutoFavouriteFish = false,
    FavouriteFishName = "Colossal Tigerfish",
    MaterialFarming = false,
    
    OctoAutoMinigame = false,
    AutoFarmBoss = false,
    AutoFarmSecretBoss = false,
    SelectedBoss = "Enzo",
    
    -- TỰ ĐỘNG SĂN SECRET BOSS THEO CHAT & TẠI ĐẢO
    AutoHuntBoss = false,
    AutoChatSecretBoss = false,
    AutoServerHopOnDespawn = false,
    FastSkipNonBoss = true,
    SecretBossCheckPower = true,
    SecretBossTargets = {
        ["Scarlet Fish"] = true,
        ["Elder Scarlet Fish"] = true,
        ["Crimson Electric Eel"] = true,
        ["Verdant Alligator Gar"] = true,
        ["Verdant Grouper"] = true,
        ["Verdant Bonefang"] = true,
        ["Flying Fish Empress"] = true,
        ["Flying Fish Emperor"] = true,
        ["Reborn Puffer Beast"] = true,
        ["Frost Kingfish"] = true,
        ["Tigerfang Whale"] = true,
        ["Heaven Piercer Turtle"] = true,
        ["Draconic Koi"] = true,
        ["Sanguine Fish"] = true,
        ["Primordial Kunfish Overlord"] = true,
        ["Warbringer Shark"] = true,
        ["Mountain Fish"] = true,
        ["Octoparasitic Fish"] = true,
    },
    CustomBossSpots = {},
    SelectedCustomSpotIsland = "Đảo Tre (Bamboo Isle)",
    SelectedCustomSpotSlot = 1,
    BossSpotAllocationMode = "Tự Động (Theo Acc)",
    BossTeleportJitter = true,
    BossTeleportJitterDist = 1.0,
    ReturnToHomeWhenClear = true,
    HomeFarmSpot = nil,
    
    AutoGodSpiritCheck = false,
    AutoPrayGodSpirit = false,
    AutoServerHopGod = false,
    AutoServerHopMaoshan = false,
    AutoServerHopTaoist = false,
    
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
    
    AutoGacha = false,
    GachaBanner = "Taiji Banner",
    GachaPullsPerAction = 1,
    
    WalkSpeedEnabled = true,
    WalkSpeedValue = 60,
    FlyEnabled = false,
    FlySpeed = 50,
    InfiniteJump = true,
    WalkOnWater = true,
    Noclip = false,
    
    ESP_GodSpirit = false,
    ESP_SecretRod = false,
    ESP_Boats = false,
    ESP_Maoshan = false,
    ESP_Taoist = false,
    ESP_Boss = false,
    ESP_Players = false,
    FishRedRing = true,
    NoFog = false,
    Fullbright = true,
    PerformanceMode = false,
    HideGameUI = false,
    HideOverheadNames = true,
    
    AntiAFK = true,
    AutoRejoin = false,
    AutoExecuteOnJoin = false,
    AutoProtectMutations = true,
    AcidWaterShield = false,
    ShowFishWeightRing = false,
    WebhookEnabled = false,
    WebhookUrl = "",
    WebhookNotifyBoss = true,
    WebhookHourlyStats = true,
    WebhookStatsInterval = 30,
    UIKeybind = Enum.KeyCode.RightControl,
    StopKeybind = Enum.KeyCode.End,
    ActiveProfile = "default",
    AutoLoadProfile = false
}

local UIControllers = {}

local ConfigLabelMap = {
    -- Câu cá cốt lõi
    ["Tự Động Quăng Cần (Auto Cast)"] = "AutoCast",
    ["Độ Trễ Quăng Cần"] = "CastDelay",
    ["Giữ Thanh Minigame (Anchor Bar)"] = "AnchorBar",
    ["Tự Dùng Kỹ Năng Cần"] = "AutoSkills",
    ["Tự Động Đập Cần (Auto Slam)"] = "AutoSlam",
    ["Tự Động Sạc Dây (Auto Charge)"] = "AutoCharge",
    ["Tự Động Chống Kẹt Cần (Anti-Stuck)"] = "AntiStuckEnabled",

    -- Smart Combo
    ["Bật Combo Kỹ Năng Tự Động"] = "SmartComboEnabled",
    ["Ngưỡng Máu Cá Phân Loại"] = "FishHpThreshold",
    ["Chiêu Bắt Nhanh (<= Ngưỡng HP)"] = "QuickCatchSkill",
    ["Chiêu Mở Màn (> Ngưỡng HP)"] = "OpenerSkill",
    ["Số Lần Dùng Chiêu Mở Màn"] = "OpenerMaxCount",
    ["Chuỗi Đảo Chiêu Luân Phiên"] = "LoopSkills",
    ["Chiêu Hồi Máu / Cứu Nguy"] = "EmergencyHealSkill",
    ["Kích Hoạt Hồi Máu Khi HP Dưới"] = "EmergencyHealHp",
    ["Thời Gian Chờ Ra Chiêu"] = "SkillEffectDelay",
    ["Tự Động Nhận Diện Hết Hiệu Ứng"] = "SmartEffectAutoDetect",

    -- Auto Luyện Chiêu
    ["Bật Auto Luyện Chiêu"] = "AutoTrainSkill",
    ["Chọn Chiêu Cần Luyện"] = "TrainSkill",
    ["Nhịp Chờ Xuất Chiêu (Cancel Delay)"] = "TrainCancelDelay",
    ["Mục Tiêu Số Lần Dùng"] = "TrainTargetCount",

    -- Bán cá & Bảo vệ
    ["Tự Động Bán Cá Khi Đầy Túi"] = "AutoSell",
    ["Giãn Cách Bán Cá Tự Động"] = "SellInterval",
    ["Tự Động Khóa Cá Đột Biến (Mutations)"] = "AutoProtectMutations",
    ["Tự Động Gom Cá Nguyên Liệu (Crafting)"] = "MaterialFarming",
    ["Tự Động Khóa Cá Yêu Thích"] = "AutoFavouriteFish",
    ["Tên Loài Cá Cần Khóa"] = "FavouriteFishName",

    -- Tự trang bị
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

    -- Săn Secret Boss
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

    -- Thần linh
    ["Tự Động Quét Trạng Thái Thần Linh"] = "AutoGodSpiritCheck",
    ["Tự Động Cầu Nguyện Thần Linh"] = "AutoPrayGodSpirit",
    ["Đổi Server Tìm Thần Linh"] = "AutoServerHopGod",
    ["Đổi Server Tìm Maoshan"] = "AutoServerHopMaoshan",
    ["Đổi Server Tìm Đạo Sĩ (Taoist)"] = "AutoServerHopTaoist",

    -- Nhiệm vụ & Gacha
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

    -- ESP & Thị giác
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

    -- Nhân vật
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

    -- Discord Webhook
    ["Webhook URL"] = "WebhookUrl",
    ["Bật Webhook"] = "WebhookEnabled",
    ["Thông Báo Bắt Được Boss"] = "WebhookNotifyBoss",
    ["Báo Cáo Tiến Độ Mỗi Giờ"] = "WebhookHourlyStats",
    ["Tần Suất Gửi Báo Cáo"] = "WebhookStatsInterval"
}

local function GetAccountConfigDir()
    local accName = (LocalPlayer and LocalPlayer.Name) or "DefaultUser"
    local safeAcc = accName:gsub("[^%w_]", "")
    if #safeAcc == 0 then safeAcc = "DefaultUser" end
    return "Identical/HeavyweightFishing/Configs/" .. safeAcc
end

local function EnsureAccountConfigDir()
    if makefolder and isfolder then
        pcall(function()
            if not isfolder("Identical") then makefolder("Identical") end
            if not isfolder("Identical/HeavyweightFishing") then makefolder("Identical/HeavyweightFishing") end
            if not isfolder("Identical/HeavyweightFishing/Configs") then makefolder("Identical/HeavyweightFishing/Configs") end
            local accDir = GetAccountConfigDir()
            if not isfolder(accDir) then makefolder(accDir) end
        end)
    end
end

local function GetSavedConfigList()
    EnsureAccountConfigDir()
    local accDir = GetAccountConfigDir()
    local list = {}
    if listfiles and isfolder and isfolder(accDir) then
        local ok, files = pcall(function() return listfiles(accDir) end)
        if ok and files then
            for _, path in ipairs(files) do
                local fileName = path:match("([^/\\]+)%.json$")
                if fileName and #fileName > 0 then
                    table.insert(list, fileName)
                end
            end
        end
    end
    table.sort(list)
    return list
end

local function SaveAccountConfig(cfgName)
    if not cfgName or cfgName:gsub("%s+", "") == "" then
        return false, "Vui lòng nhập tên cấu hình!"
    end
    local safeName = cfgName:gsub("[^%w_%-%s]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #safeName == 0 then
        return false, "Tên cấu hình không hợp lệ!"
    end

    EnsureAccountConfigDir()
    local accDir = GetAccountConfigDir()
    local filePath = accDir .. "/" .. safeName .. ".json"

    local data = {}
    for k, v in pairs(Config) do
        if typeof(v) == "EnumItem" then
            data[k] = {__enum = tostring(v)}
        else
            data[k] = v
        end
    end

    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok or not encoded then
        return false, "Lỗi mã hóa dữ liệu cấu hình!"
    end

    if writefile then
        local wOk, err = pcall(function() writefile(filePath, encoded) end)
        if wOk then
            return true, safeName
        else
            return false, "Lỗi khi ghi file: " .. tostring(err)
        end
    else
        return false, "Executor của bạn không hỗ trợ hàm writefile!"
    end
end

local function LoadAccountConfig(cfgName)
    if not cfgName or cfgName == "" or cfgName == "Chưa có config nào" then
        return false, "Vui lòng chọn cấu hình cần nạp!"
    end
    EnsureAccountConfigDir()
    local accDir = GetAccountConfigDir()
    local filePath = accDir .. "/" .. cfgName .. ".json"

    if not isfile or not isfile(filePath) then
        return false, "File cấu hình không tồn tại!"
    end

    local ok, content = pcall(function() return readfile(filePath) end)
    if not ok or not content or #content == 0 then
        return false, "Không thể đọc nội dung file cấu hình!"
    end

    local decOk, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not decOk or type(decoded) ~= "table" then
        return false, "File cấu hình bị lỗi định dạng!"
    end

    -- 1. Cập nhật vào bảng Config
    for k, v in pairs(decoded) do
        if type(v) == "table" and v.__enum then
            local enumType, enumName = v.__enum:match("Enum%.(%w+)%.(%w+)")
            if enumType and enumName and Enum[enumType] and Enum[enumType][enumName] then
                Config[k] = Enum[enumType][enumName]
            end
        else
            Config[k] = v
        end
    end

    -- 2. Đồng bộ hóa toàn bộ giao diện UI tương ứng
    for key, ctrl in pairs(UIControllers) do
        if Config[key] ~= nil and ctrl and ctrl.Set then
            pcall(function()
                ctrl.Set(Config[key])
            end)
        end
    end

    return true, cfgName
end

local function DeleteAccountConfig(cfgName)
    if not cfgName or cfgName == "" or cfgName == "Chưa có config nào" then
        return false, "Vui lòng chọn cấu hình cần xóa!"
    end
    EnsureAccountConfigDir()
    local accDir = GetAccountConfigDir()
    local filePath = accDir .. "/" .. cfgName .. ".json"

    if isfile and isfile(filePath) then
        if delfile then
            local ok = pcall(function() delfile(filePath) end)
            if ok then return true, cfgName end
        end
    end
    return false, "Không thể xóa file cấu hình!"
end

local Colors = {
    Background       = Color3.fromRGB(15, 12, 22),
    SidebarBg        = Color3.fromRGB(11, 9, 17),
    BorderPurple     = Color3.fromRGB(168, 85, 247),
    BorderSubtle     = Color3.fromRGB(45, 33, 66),
    Divider          = Color3.fromRGB(36, 26, 54),

    PurplePrimary    = Color3.fromRGB(216, 160, 255),
    PurpleAccent     = Color3.fromRGB(168, 85, 247),
    PurpleMuted      = Color3.fromRGB(147, 112, 196),
    PurpleDark       = Color3.fromRGB(72, 45, 107),
    PurpleGlow       = Color3.fromRGB(192, 132, 252),

    RowNormal        = Color3.fromRGB(20, 16, 30),
    RowHover         = Color3.fromRGB(30, 22, 46),
    ControlBg        = Color3.fromRGB(28, 20, 44),
    InputBg          = Color3.fromRGB(18, 14, 26),

    TextWhite        = Color3.fromRGB(245, 243, 255),
    TextSubtle       = Color3.fromRGB(168, 150, 200),
    TextMuted        = Color3.fromRGB(110, 95, 138),

    AccentGreen      = Color3.fromRGB(52, 211, 153),
    AccentRed        = Color3.fromRGB(248, 113, 113),
    AccentOrange     = Color3.fromRGB(251, 146, 60),
    AccentYellow     = Color3.fromRGB(250, 204, 21),
    AccentBlue       = Color3.fromRGB(96, 165, 250),
    DropdownSelected = Color3.fromRGB(36, 26, 56)
}

local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local canParentCoreGui = pcall(function()
        local test = Instance.new("Folder")
        test.Parent = CoreGui
        test:Destroy()
    end)
    if canParentCoreGui then
        return CoreGui
    end
    local pg = LocalPlayer and (LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5))
    if pg then return pg end
    return CoreGui
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IdenticalHeavyweightFishing"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
end)

local parented = pcall(function()
    screenGui.Parent = getGuiParent()
end)
if not parented then
    pcall(function()
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
end
table.insert(cleanUpInstances, screenGui)

local function UnloadScript()
    isRunning = false
    for _, conn in ipairs(activeConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(activeConnections)
    
    for _, inst in ipairs(cleanUpInstances) do
        pcall(function()
            if inst and inst.Parent then inst:Destroy() end
        end)
    end
    table.clear(cleanUpInstances)
    
    pcall(function()
        local leftover = Workspace:FindFirstChild("IdenticalESP")
        if leftover then leftover:Destroy() end
    end)

    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
    end)
    
    CleanOldInstances()
    
    if globalEnv then
        globalEnv.HeavyweightFishingKill = nil
        globalEnv.IdenticalHeavyweightFishingUnload = nil
    end
end

if globalEnv then
    globalEnv.HeavyweightFishingKill = UnloadScript
    globalEnv.IdenticalHeavyweightFishingUnload = UnloadScript
end

local notifContainer = Instance.new("Frame")
notifContainer.Name = "Notifications"
notifContainer.Size = UDim2.new(0, 300, 1, -40)
notifContainer.Position = UDim2.new(1, -315, 0, 20)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 1000
notifContainer.Parent = screenGui
table.insert(cleanUpInstances, notifContainer)

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)
notifLayout.Parent = notifContainer

local function FormatWithSpaces(val)
    if not val then return "0" end
    local s = tostring(val)
    local prefix = ""
    if s:sub(1, 1) == "-" then
        prefix = "-"
        s = s:sub(2)
    elseif s:sub(1, 1) == "+" then
        prefix = "+"
        s = s:sub(2)
    end
    local intPart, decPart = s:match("^(%d+)(%.?.*)$")
    if not intPart then return prefix .. s end
    local formatted = intPart
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(%d+)(%d%d%d)", "%1 %2")
        if k == 0 then break end
    end
    return prefix .. formatted .. (decPart or "")
end

local function ShowNotification(title, text, notifType, duration)
    if not isRunning then return end
    duration = duration or 3.5
    local accentColor = Colors.PurpleAccent
    if notifType == "SUCCESS" then accentColor = Colors.AccentGreen
    elseif notifType == "WARN" then accentColor = Colors.AccentYellow
    elseif notifType == "ERROR" then accentColor = Colors.AccentRed end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Colors.Background
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = notifContainer

    local stroke = Instance.new("UIStroke"); stroke.Color = accentColor; stroke.Thickness = 1.2; stroke.Parent = card
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = card
    local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1, 0, 0, 20); topBar.BackgroundTransparency = 1; topBar.Position = UDim2.new(0, 10, 0, 6); topBar.Parent = card
    local tLabel = Instance.new("TextLabel"); tLabel.Size = UDim2.new(1, -20, 1, 0); tLabel.BackgroundTransparency = 1; tLabel.Font = Enum.Font.GothamBold; tLabel.Text = title; tLabel.TextColor3 = Colors.PurplePrimary; tLabel.TextSize = 13; tLabel.TextXAlignment = Enum.TextXAlignment.Left; tLabel.Parent = topBar
    local mLabel = Instance.new("TextLabel"); mLabel.Size = UDim2.new(1, -20, 0, 26); mLabel.Position = UDim2.new(0, 10, 0, 26); mLabel.BackgroundTransparency = 1; mLabel.Font = Enum.Font.Gotham; mLabel.Text = text; mLabel.TextColor3 = Colors.TextSubtle; mLabel.TextSize = 11; mLabel.TextXAlignment = Enum.TextXAlignment.Left; mLabel.TextWrapped = true; mLabel.Parent = card

    task.delay(duration, function()
        if card and card.Parent then
            TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1, Position = card.Position + UDim2.new(1, 20, 0, 0)
            }):Play()
            task.wait(0.35); card:Destroy()
        end
    end)
end

local ToggleUiVisibility

local floatingAvatar = Instance.new("ImageButton")
floatingAvatar.Name = "FloatingAvatar"
floatingAvatar.Size = UDim2.new(0, 48, 0, 48)
floatingAvatar.Position = UDim2.new(0, 20, 0.4, 0)
floatingAvatar.BackgroundColor3 = Colors.Background
floatingAvatar.BorderSizePixel = 0
floatingAvatar.Visible = false
floatingAvatar.ZIndex = 2000
floatingAvatar.Active = true
floatingAvatar.AutoButtonColor = false
floatingAvatar.Parent = screenGui
table.insert(cleanUpInstances, floatingAvatar)

do
    local faCorner = Instance.new("UICorner"); faCorner.CornerRadius = UDim.new(1, 0); faCorner.Parent = floatingAvatar
    local faStroke = Instance.new("UIStroke"); faStroke.Color = Colors.PurpleAccent; faStroke.Thickness = 2.2; faStroke.Parent = floatingAvatar
    
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarImage"
    avatarImg.Size = UDim2.new(1, -6, 1, -6)
    avatarImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    avatarImg.Parent = floatingAvatar
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

    -- Status indicator dot
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 11, 0, 11)
    dot.Position = UDim2.new(1, -11, 1, -11)
    dot.BackgroundColor3 = Colors.AccentGreen
    dot.BorderSizePixel = 0
    dot.Parent = floatingAvatar
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dotStroke = Instance.new("UIStroke"); dotStroke.Color = Colors.Background; dotStroke.Thickness = 1.5; dotStroke.Parent = dot

    local faDragging, faDragInput, faDragStart, faStartPos = false, nil, nil, nil
    local dragMoved = false

    floatingAvatar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            faDragging = true
            dragMoved = false
            faDragStart = input.Position
            faStartPos = floatingAvatar.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    faDragging = false
                end
            end)
        end
    end)

    floatingAvatar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            faDragInput = input
        end
    end)

    table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
        if input == faDragInput and faDragging then
            local delta = input.Position - faDragStart
            if delta.Magnitude > 4 then
                dragMoved = true
            end
            floatingAvatar.Position = UDim2.new(faStartPos.X.Scale, faStartPos.X.Offset + delta.X, faStartPos.Y.Scale, faStartPos.Y.Offset + delta.Y)
        end
    end))

    floatingAvatar.MouseEnter:Connect(function()
        TweenService:Create(floatingAvatar, TweenInfo.new(0.15), {Size = UDim2.new(0, 52, 0, 52)}):Play()
        TweenService:Create(faStroke, TweenInfo.new(0.15), {Color = Colors.PurpleGlow, Thickness = 2.8}):Play()
    end)
    floatingAvatar.MouseLeave:Connect(function()
        TweenService:Create(floatingAvatar, TweenInfo.new(0.15), {Size = UDim2.new(0, 48, 0, 48)}):Play()
        TweenService:Create(faStroke, TweenInfo.new(0.15), {Color = Colors.PurpleAccent, Thickness = 2.2}):Play()
    end)

    floatingAvatar.MouseButton1Click:Connect(function()
        if not dragMoved and ToggleUiVisibility then
            ToggleUiVisibility()
        end
    end)
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 480)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
mainFrame.BackgroundColor3 = Colors.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
table.insert(cleanUpInstances, mainFrame)

do
    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
    local ms = Instance.new("UIStroke"); ms.Color = Colors.BorderPurple; ms.Thickness = 1.5; ms.Parent = mainFrame
end

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Colors.SidebarBg
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

do
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 8); tc.Parent = titleBar
    local tbf = Instance.new("Frame"); tbf.Size = UDim2.new(1, 0, 0, 10); tbf.Position = UDim2.new(0, 0, 1, -10); tbf.BackgroundColor3 = Colors.SidebarBg; tbf.BorderSizePixel = 0; tbf.Parent = titleBar
    local tdiv = Instance.new("Frame"); tdiv.Size = UDim2.new(1, 0, 0, 1); tdiv.Position = UDim2.new(0, 0, 1, -1); tdiv.BackgroundColor3 = Colors.Divider; tdiv.BorderSizePixel = 0; tdiv.Parent = titleBar
end

do
    local cc = Instance.new("Frame"); cc.Size = UDim2.new(0, 16, 0, 16); cc.Position = UDim2.new(0, 14, 0.5, -8); cc.BackgroundTransparency = 1; cc.ClipsDescendants = true; cc.Parent = titleBar
    local co = Instance.new("Frame"); co.Size = UDim2.new(0, 16, 0, 16); co.BackgroundColor3 = Colors.PurpleAccent; co.BorderSizePixel = 0; co.Parent = cc
    Instance.new("UICorner", co).CornerRadius = UDim.new(1, 0)
    local cut = Instance.new("Frame"); cut.Size = UDim2.new(0, 13, 0, 13); cut.Position = UDim2.new(0, 4, 0, -2); cut.BackgroundColor3 = Colors.SidebarBg; cut.BorderSizePixel = 0; cut.Parent = co
    Instance.new("UICorner", cut).CornerRadius = UDim.new(1, 0)
end

local brandTitle = Instance.new("TextLabel")
brandTitle.Size = UDim2.new(0, 92, 1, 0); brandTitle.Position = UDim2.new(0, 36, 0, 0)
brandTitle.BackgroundTransparency = 1; brandTitle.Font = Enum.Font.GothamBold
brandTitle.Text = "CÂU CÁ PRO"; brandTitle.TextColor3 = Colors.PurplePrimary
brandTitle.TextSize = 14; brandTitle.TextXAlignment = Enum.TextXAlignment.Left
brandTitle.Parent = titleBar

local commitBadge = Instance.new("TextLabel")
commitBadge.Size = UDim2.new(0, 68, 0, 18); commitBadge.Position = UDim2.new(0, 132, 0.5, -9)
commitBadge.BackgroundColor3 = Color3.fromRGB(30, 22, 48)
commitBadge.Font = Enum.Font.Code
commitBadge.Text = "#" .. tostring(SCRIPT_BUILD_COMMIT)
commitBadge.TextColor3 = Color3.fromRGB(190, 150, 255)
commitBadge.TextSize = 10
commitBadge.Parent = titleBar
Instance.new("UICorner", commitBadge).CornerRadius = UDim.new(0, 4)
local cStroke = Instance.new("UIStroke", commitBadge)
cStroke.Color = Colors.PurpleAccent
cStroke.Thickness = 1

local gameSubtitle = Instance.new("TextLabel")
gameSubtitle.Size = UDim2.new(0, 220, 1, 0); gameSubtitle.Position = UDim2.new(0, 208, 0, 0)
gameSubtitle.BackgroundTransparency = 1; gameSubtitle.Font = Enum.Font.Gotham
gameSubtitle.Text = "HEAVYWEIGHT FISHING | BẢN VIỆT HOÁ"; gameSubtitle.TextColor3 = Colors.PurpleMuted
gameSubtitle.TextSize = 10; gameSubtitle.TextXAlignment = Enum.TextXAlignment.Left
gameSubtitle.Parent = titleBar

local winControls = Instance.new("Frame"); winControls.Size = UDim2.new(0, 95, 1, 0); winControls.Position = UDim2.new(1, -100, 0, 0); winControls.BackgroundTransparency = 1; winControls.Parent = titleBar
local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(0, 4, 0.5, -12); minBtn.BackgroundColor3 = Colors.ControlBg; minBtn.Font = Enum.Font.GothamBold; minBtn.Text = "[-]"; minBtn.TextColor3 = Colors.PurplePrimary; minBtn.TextSize = 11; minBtn.BorderSizePixel = 0; minBtn.Parent = winControls
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(0, 32, 0.5, -12); closeBtn.BackgroundColor3 = Colors.ControlBg; closeBtn.Font = Enum.Font.GothamBold; closeBtn.Text = "[X]"; closeBtn.TextColor3 = Colors.TextWhite; closeBtn.TextSize = 11; closeBtn.BorderSizePixel = 0; closeBtn.Parent = winControls
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
local killBtn = Instance.new("TextButton"); killBtn.Size = UDim2.new(0, 32, 0, 24); killBtn.Position = UDim2.new(0, 60, 0.5, -12); killBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25); killBtn.Font = Enum.Font.GothamBold; killBtn.Text = "KILL"; killBtn.TextColor3 = Colors.AccentRed; killBtn.TextSize = 9; killBtn.BorderSizePixel = 0; killBtn.Parent = winControls
Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0, 4)
local killStroke = Instance.new("UIStroke"); killStroke.Color = Colors.AccentRed; killStroke.Thickness = 1; killStroke.Parent = killBtn

do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    titleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

local bodyFrame = Instance.new("Frame"); bodyFrame.Name = "Body"; bodyFrame.Size = UDim2.new(1, 0, 1, -62); bodyFrame.Position = UDim2.new(0, 0, 0, 38); bodyFrame.BackgroundTransparency = 1; bodyFrame.Parent = mainFrame

local sidebar = Instance.new("Frame"); sidebar.Name = "Sidebar"; sidebar.Size = UDim2.new(0, 140, 1, 0); sidebar.BackgroundColor3 = Colors.SidebarBg; sidebar.BorderSizePixel = 0; sidebar.Parent = bodyFrame
do local d = Instance.new("Frame"); d.Size = UDim2.new(0, 1, 1, 0); d.Position = UDim2.new(1, -1, 0, 0); d.BackgroundColor3 = Colors.Divider; d.BorderSizePixel = 0; d.Parent = sidebar end

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBar"; searchBox.Size = UDim2.new(1, -16, 0, 26); searchBox.Position = UDim2.new(0, 8, 0, 8)
searchBox.BackgroundColor3 = Colors.InputBg; searchBox.Font = Enum.Font.Gotham; searchBox.PlaceholderText = "Tìm kiếm tính năng..."
searchBox.PlaceholderColor3 = Colors.TextMuted; searchBox.Text = ""; searchBox.TextColor3 = Colors.TextWhite
searchBox.TextSize = 11; searchBox.TextXAlignment = Enum.TextXAlignment.Left; searchBox.BorderSizePixel = 0; searchBox.ClearTextOnFocus = false; searchBox.Parent = sidebar
do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = searchBox end
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

local rowSearchIndex = {}
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = searchBox.Text:lower()
    for _, item in ipairs(rowSearchIndex) do
        if q == "" or item.query:find(q, 1, true) then
            item.frame.Visible = true
        else
            item.frame.Visible = false
        end
    end
end)

local navList = Instance.new("ScrollingFrame"); navList.Name = "NavList"; navList.Size = UDim2.new(1, 0, 1, -44); navList.Position = UDim2.new(0, 0, 0, 42); navList.BackgroundTransparency = 1; navList.BorderSizePixel = 0; navList.ScrollBarThickness = 2; navList.ScrollBarImageColor3 = Colors.BorderSubtle; navList.CanvasSize = UDim2.new(0, 0, 0, 0); navList.AutomaticCanvasSize = Enum.AutomaticSize.Y; navList.Parent = sidebar
do
    local nl = Instance.new("UIListLayout"); nl.SortOrder = Enum.SortOrder.LayoutOrder; nl.Padding = UDim.new(0, 4); nl.Parent = navList
    local np = Instance.new("UIPadding"); np.PaddingTop = UDim.new(0, 6); np.PaddingLeft = UDim.new(0, 8); np.PaddingRight = UDim.new(0, 8); np.Parent = navList
end

local contentArea = Instance.new("Frame"); contentArea.Name = "ContentArea"; contentArea.Size = UDim2.new(1, -140, 1, 0); contentArea.Position = UDim2.new(0, 140, 0, 0); contentArea.BackgroundTransparency = 1; contentArea.Parent = bodyFrame

local tabFrames = {}
local tabButtons = {}

local function SwitchTab(tabName)
    for name, frame in pairs(tabFrames) do frame.Visible = (name == tabName) end
    for name, btn in pairs(tabButtons) do
        if name == tabName then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.PurpleDark, TextColor3 = Colors.TextWhite}):Play()
            local pill = btn:FindFirstChild("ActivePill"); if pill then pill.Visible = true end
        else
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.SidebarBg, TextColor3 = Colors.TextSubtle}):Play()
            local pill = btn:FindFirstChild("ActivePill"); if pill then pill.Visible = false end
        end
    end
end

local function CreateTab(name)
    local btn = Instance.new("TextButton"); btn.Name = "TabBtn_" .. name; btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Colors.SidebarBg; btn.Font = Enum.Font.GothamBold; btn.Text = name; btn.TextColor3 = Colors.TextSubtle; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0; btn.Parent = navList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 12); p.Parent = btn end
    local pill = Instance.new("Frame"); pill.Name = "ActivePill"; pill.Size = UDim2.new(0, 3, 0, 16); pill.Position = UDim2.new(0, -9, 0.5, -8); pill.BackgroundColor3 = Colors.PurpleAccent; pill.BorderSizePixel = 0; pill.Visible = false; pill.Parent = btn
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 2)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)

    local page = Instance.new("ScrollingFrame"); page.Name = "TabPage_" .. name; page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Colors.BorderPurple; page.CanvasSize = UDim2.new(0, 0, 0, 0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Visible = false; page.Parent = contentArea
    do
        local pl = Instance.new("UIListLayout"); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 10); pl.Parent = page
        local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0, 12); pp.PaddingBottom = UDim.new(0, 16); pp.PaddingLeft = UDim.new(0, 14); pp.PaddingRight = UDim.new(0, 14); pp.Parent = page
    end
    tabFrames[name] = page; tabButtons[name] = btn
    return page
end

local footerBar = Instance.new("Frame"); footerBar.Name = "FooterBar"; footerBar.Size = UDim2.new(1, 0, 0, 24); footerBar.Position = UDim2.new(0, 0, 1, -24); footerBar.BackgroundColor3 = Colors.SidebarBg; footerBar.BorderSizePixel = 0; footerBar.Parent = mainFrame
Instance.new("UICorner", footerBar).CornerRadius = UDim.new(0, 8)
do
    local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, 0, 0, 10); tf.BackgroundColor3 = Colors.SidebarBg; tf.BorderSizePixel = 0; tf.Parent = footerBar
    local fd = Instance.new("Frame"); fd.Size = UDim2.new(1, 0, 0, 1); fd.BackgroundColor3 = Colors.Divider; fd.BorderSizePixel = 0; fd.Parent = footerBar
end
local footerBrand = Instance.new("TextLabel"); footerBrand.Size = UDim2.new(0, 260, 1, 0); footerBrand.Position = UDim2.new(0, 12, 0, 0); footerBrand.BackgroundTransparency = 1; footerBrand.Font = Enum.Font.Gotham; footerBrand.Text = "Heavyweight Fishing | Việt Hoá V1.1"; footerBrand.TextColor3 = Colors.TextMuted; footerBrand.TextSize = 10; footerBrand.TextXAlignment = Enum.TextXAlignment.Left; footerBrand.Parent = footerBar
local footerKey = Instance.new("TextLabel"); footerKey.Size = UDim2.new(0, 280, 1, 0); footerKey.Position = UDim2.new(1, -292, 0, 0); footerKey.BackgroundTransparency = 1; footerKey.Font = Enum.Font.Gotham; footerKey.Text = "[R-CTRL] Menu | [END] Tắt Script"; footerKey.TextColor3 = Colors.TextMuted; footerKey.TextSize = 10; footerKey.TextXAlignment = Enum.TextXAlignment.Right; footerKey.Parent = footerBar

ToggleUiVisibility = function()
    mainFrame.Visible = not mainFrame.Visible
    floatingAvatar.Visible = not mainFrame.Visible
    if mainFrame.Visible then
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    end
end

minBtn.MouseButton1Click:Connect(ToggleUiVisibility)
closeBtn.MouseButton1Click:Connect(ToggleUiVisibility)
killBtn.MouseButton1Click:Connect(function()
    ShowNotification("Diệt Script", "Đang ngắt kết nối và đóng script hoàn toàn...", "WARN", 2)
    task.wait(0.2)
    UnloadScript()
end)

local function createCategoryHeader(parent, text)
    local hdr = Instance.new("Frame"); hdr.Size = UDim2.new(1, 0, 0, 22); hdr.BackgroundTransparency = 1; hdr.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.Text = string.upper(text); lbl.TextColor3 = Colors.PurplePrimary; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = hdr
    return hdr
end

local function createCardGroup(parent)
    local group = Instance.new("Frame"); group.Size = UDim2.new(1, 0, 0, 0); group.AutomaticSize = Enum.AutomaticSize.Y; group.BackgroundColor3 = Colors.RowNormal; group.BorderSizePixel = 0; group.Parent = parent
    local s = Instance.new("UIStroke"); s.Color = Colors.BorderSubtle; s.Thickness = 1; s.Parent = group
    Instance.new("UICorner", group).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("UIListLayout"); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0, 0); l.Parent = group
    return group
end

local function createBaseRow(parent, labelText, descText, indexSearch)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 42); row.BackgroundColor3 = Colors.RowNormal; row.BorderSizePixel = 0; row.Parent = parent
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10); pad.Parent = row
    local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, -190, 1, 0); tf.BackgroundTransparency = 1; tf.Parent = row
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1, 0, 0, 18); tl.Position = UDim2.new(0, 0, 0, 4); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.Text = labelText; tl.TextColor3 = Colors.TextWhite; tl.TextSize = 12; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = tf
    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1, 0, 0, 14); dl.Position = UDim2.new(0, 0, 0, 22); dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham; dl.Text = descText or ""; dl.TextColor3 = Colors.TextMuted; dl.TextSize = 10; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Parent = tf
    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowHover}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowNormal}):Play() end)
    if indexSearch ~= false then
        table.insert(rowSearchIndex, {frame = row, query = (labelText .. " " .. (descText or "")):lower()})
    end
    return row
end

local function createToggleRow(parent, labelText, descText, initialVal, callback, indexSearch)
    if type(initialVal) == "function" then
        indexSearch = callback
        callback = initialVal
        initialVal = false
    end
    local row = createBaseRow(parent, labelText, descText, indexSearch)
    local state = initialVal or false
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -40, 0.5, -10); btn.BackgroundColor3 = state and Colors.PurpleAccent or Colors.ControlBg; btn.Text = ""; btn.BorderSizePixel = 0; btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7); knob.BackgroundColor3 = Colors.TextWhite; knob.BorderSizePixel = 0; knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local function updateVisuals()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Colors.PurpleAccent or Colors.ControlBg}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals()
        if type(callback) == "function" then callback(state) end
    end)
    local ret = {frame = row, Set = function(val) state = val; updateVisuals(); if type(callback) == "function" then callback(state) end end, Get = function() return state end}
    local key = ConfigLabelMap[labelText]
    if key then UIControllers[key] = ret end
    return ret
end

local function createSliderRow(parent, labelText, descText, minVal, maxVal, initialVal, isFloat, suffix, callback, indexSearch)
    local row = createBaseRow(parent, labelText, descText, indexSearch)
    local currentVal = initialVal or minVal; suffix = suffix or ""
    local container = Instance.new("Frame"); container.Size = UDim2.new(0, 180, 0, 24); container.Position = UDim2.new(1, -180, 0.5, -12); container.BackgroundTransparency = 1; container.Parent = row
    local valLabel = Instance.new("TextLabel"); valLabel.Size = UDim2.new(0, 68, 1, 0); valLabel.Position = UDim2.new(1, -68, 0, 0); valLabel.BackgroundTransparency = 1; valLabel.Font = Enum.Font.GothamBold; valLabel.TextColor3 = Colors.PurplePrimary; valLabel.TextSize = 11; valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.Parent = container
    valLabel.Text = isFloat and string.format("%.2f", currentVal)..suffix or tostring(math.floor(currentVal))..suffix
    local track = Instance.new("Frame"); track.Size = UDim2.new(1, -74, 0, 6); track.Position = UDim2.new(0, 0, 0.5, -3); track.BackgroundColor3 = Colors.ControlBg; track.BorderSizePixel = 0; track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(pct, 0, 1, 0); fill.BackgroundColor3 = Colors.PurpleAccent; fill.BorderSizePixel = 0; fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local sliding = false
    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        currentVal = val; fill.Size = UDim2.new(rel, 0, 1, 0)
        valLabel.Text = isFloat and string.format("%.2f", val)..suffix or tostring(val)..suffix
        if type(callback) == "function" then callback(val) end
    end
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; updateFromX(input.Position.X) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
    table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input) if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateFromX(input.Position.X) end end))
    local ret = {
        frame = row,
        Set = function(val)
            currentVal = math.clamp(val, minVal, maxVal)
            local p2 = (currentVal - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(p2, 0, 1, 0)
            valLabel.Text = isFloat and string.format("%.2f", currentVal)..suffix or tostring(math.floor(currentVal))..suffix
            if type(callback) == "function" then callback(currentVal) end
        end
    }
    local key = ConfigLabelMap[labelText]
    if key then UIControllers[key] = ret end
    return ret
end

local function createDropdownRow(parent, labelText, descText, options, initialVal, callback, indexSearch)
    if type(options) == "table" and type(initialVal) == "function" then
        indexSearch = callback
        callback = initialVal
        initialVal = options[1]
    end
    local selected = initialVal or options[1]
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 42); row.AutomaticSize = Enum.AutomaticSize.Y; row.BackgroundColor3 = Colors.RowNormal; row.BorderSizePixel = 0; row.ClipsDescendants = true; row.Parent = parent
    local rl = Instance.new("UIListLayout"); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Padding = UDim.new(0, 4); rl.Parent = row
    local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 42); header.BackgroundTransparency = 1; header.Parent = row
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10); pad.Parent = header
    local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, -145, 1, 0); tf.BackgroundTransparency = 1; tf.Parent = header
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1, 0, 0, 18); tl.Position = UDim2.new(0, 0, 0, 4); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.Text = labelText; tl.TextColor3 = Colors.TextWhite; tl.TextSize = 12; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = tf
    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1, 0, 0, 14); dl.Position = UDim2.new(0, 0, 0, 22); dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham; dl.Text = descText or ""; dl.TextColor3 = Colors.TextMuted; dl.TextSize = 10; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Parent = tf
    local ddBtn = Instance.new("TextButton"); ddBtn.Size = UDim2.new(0, 130, 0, 24); ddBtn.Position = UDim2.new(1, -130, 0.5, -12); ddBtn.BackgroundColor3 = Colors.ControlBg; ddBtn.Font = Enum.Font.GothamBold; ddBtn.Text = tostring(selected) .. "  v"; ddBtn.TextColor3 = Colors.PurplePrimary; ddBtn.TextSize = 11; ddBtn.BorderSizePixel = 0; ddBtn.Parent = header
    Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0, 4)
    local optC = Instance.new("Frame"); optC.Size = UDim2.new(1, 0, 0, 0); optC.AutomaticSize = Enum.AutomaticSize.Y; optC.BackgroundTransparency = 1; optC.Visible = false; optC.Parent = row
    do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 10); p.PaddingRight = UDim.new(0, 10); p.PaddingBottom = UDim.new(0, 8); p.Parent = optC end
    Instance.new("UIListLayout", optC).SortOrder = Enum.SortOrder.LayoutOrder
    local optButtons = {}
    local function populate(opts)
        for _, c in ipairs(optC:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        table.clear(optButtons)
        for _, opt in ipairs(opts) do
            local ob = Instance.new("TextButton"); ob.Size = UDim2.new(1, 0, 0, 26); ob.BackgroundColor3 = (opt == selected) and Colors.DropdownSelected or Colors.InputBg; ob.Font = Enum.Font.Gotham; ob.Text = (opt == selected and "> " or "   ") .. tostring(opt); ob.TextColor3 = (opt == selected) and Colors.PurplePrimary or Colors.TextWhite; ob.TextSize = 11; ob.TextXAlignment = Enum.TextXAlignment.Left; ob.BorderSizePixel = 0; ob.Parent = optC
            Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
            do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 10); p.Parent = ob end
            optButtons[opt] = ob
            ob.MouseEnter:Connect(function() if opt ~= selected then TweenService:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowHover}):Play() end end)
            ob.MouseLeave:Connect(function() if opt ~= selected then TweenService:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Colors.InputBg}):Play() end end)
            ob.MouseButton1Click:Connect(function()
                selected = opt; ddBtn.Text = tostring(opt) .. "  v"; optC.Visible = false
                for oN, b in pairs(optButtons) do b.BackgroundColor3 = (oN == opt) and Colors.DropdownSelected or Colors.InputBg; b.TextColor3 = (oN == opt) and Colors.PurplePrimary or Colors.TextWhite; b.Text = (oN == opt and "> " or "   ") .. tostring(oN) end
                if type(callback) == "function" then callback(opt) end
            end)
        end
    end
    populate(options)
    ddBtn.MouseButton1Click:Connect(function() optC.Visible = not optC.Visible; ddBtn.Text = tostring(selected) .. (optC.Visible and "  ^" or "  v") end)
    header.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowHover}):Play() end)
    header.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowNormal}):Play() end)
    if indexSearch ~= false then table.insert(rowSearchIndex, {frame = row, query = (labelText .. " " .. (descText or "")):lower()}) end
    local ret = {
        frame = row,
        Set = function(opt)
            selected = opt; ddBtn.Text = tostring(opt) .. "  v"
            for oN, b in pairs(optButtons) do b.BackgroundColor3 = (oN == opt) and Colors.DropdownSelected or Colors.InputBg; b.TextColor3 = (oN == opt) and Colors.PurplePrimary or Colors.TextWhite; b.Text = (oN == opt and "> " or "   ") .. tostring(oN) end
            if type(callback) == "function" then pcall(callback, opt) end
        end,
        Get = function() return selected end,
        Refresh = function(newOpts, keepCurrent)
            options = newOpts or {}
            populate(options)
            local found = false
            if keepCurrent and selected then
                for _, opt in ipairs(options) do
                    if opt == selected then found = true; break end
                end
            end
            if not found then
                selected = options[1] or ""
            end
            ddBtn.Text = (selected ~= "" and tostring(selected) or "Không có") .. "  v"
        end
    }
    local mappedKey = ConfigLabelMap[labelText]
    if mappedKey then
        UIControllers[mappedKey] = ret
    end
    return ret
end

local function createButtonRow(parent, labelText, descText, btnText, callback, indexSearch)
    if type(descText) == "function" then
        indexSearch = btnText
        callback = descText
        btnText = "Execute"
        descText = ""
    elseif type(btnText) == "function" then
        indexSearch = callback
        callback = btnText
        btnText = descText
        descText = ""
    end
    local row = createBaseRow(parent, labelText, descText, indexSearch)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 90, 0, 24); btn.Position = UDim2.new(1, -90, 0.5, -12); btn.BackgroundColor3 = Colors.ControlBg; btn.Font = Enum.Font.GothamBold; btn.Text = btnText or "Execute"; btn.TextColor3 = Colors.PurplePrimary; btn.TextSize = 11; btn.BorderSizePixel = 0; btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.PurpleDark, TextColor3 = Colors.TextWhite}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.ControlBg, TextColor3 = Colors.PurplePrimary}):Play() end)
    btn.MouseButton1Click:Connect(function()
        if type(callback) == "function" then pcall(callback) end
    end)
    return btn
end

local function createInfoRow(parent, labelText, valueText, indexSearch)
    local row = createBaseRow(parent, labelText, "", indexSearch)
    local vl = Instance.new("TextLabel"); vl.Size = UDim2.new(0, 140, 1, 0); vl.Position = UDim2.new(1, -140, 0, 0); vl.BackgroundTransparency = 1; vl.Font = Enum.Font.GothamBold; vl.Text = valueText; vl.TextColor3 = Colors.PurplePrimary; vl.TextSize = 11; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = row
    return {frame = row, Set = function(nv) vl.Text = nv end}
end

local function createInputRow(parent, labelText, descText, initialVal, callback, indexSearch)
    local row = createBaseRow(parent, labelText, descText, indexSearch)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0, 160, 0, 24)
    tb.Position = UDim2.new(1, -160, 0.5, -12)
    tb.BackgroundColor3 = Colors.InputBg
    tb.Font = Enum.Font.Gotham
    tb.Text = initialVal or ""
    tb.PlaceholderText = "Dán link vào đây..."
    tb.PlaceholderColor3 = Colors.TextMuted
    tb.TextColor3 = Colors.TextWhite
    tb.TextSize = 11
    tb.ClearTextOnFocus = false
    tb.BorderSizePixel = 0
    tb.Parent = row
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", tb)
    s.Color = Colors.BorderSubtle
    s.Thickness = 1
    tb.FocusLost:Connect(function(enterPressed)
        if type(callback) == "function" then callback(tb.Text) end
    end)
    local ret = {
        frame = row,
        Set = function(val)
            tb.Text = tostring(val or "")
            if type(callback) == "function" then pcall(callback, tb.Text) end
        end,
        Get = function() return tb.Text end
    }
    local mappedKey = ConfigLabelMap[labelText]
    if mappedKey then
        UIControllers[mappedKey] = ret
    end
    return ret
end

-- ============================================================
-- SECRET BOSS DATABASE & CHAT HUNTER LOGIC
-- ============================================================
local allRods = {
    {name = "Wooden Rod", price = 0, power = 8, luck = 1},
    {name = "Bamboo Rod", price = 100, power = 11, luck = 5},
    {name = "Iron Hook Rod", price = 500, power = 13, luck = 10},
    {name = "Steel Rod", price = 1000, power = 17, luck = 11},
    {name = "Enchanted Steel Rod", price = 2000, power = 19, luck = 12},
    {name = "Alloy Rod", price = 5000, power = 22, luck = 5},
    {name = "Emerald Rod", price = 10000, power = 25, luck = 10},
    {name = "Bloodfire Rod", price = 20000, power = 27, luck = 10},
    {name = "Shadow Rod", price = 60000, power = 29, luck = 22},
    {name = "Triple Steel Rod", price = 100000, power = 32, luck = 20},
    {name = "Golden Rod", price = 200000, power = 35, luck = 22},
    {name = "Grandmaster Steel Rod", price = 250000, power = 37, luck = 10},
    {name = "Grandmaster Golden Rod", price = 1000000, power = 45, luck = 30},
    {name = "Steel Spine Rod", price = 1500000, power = 48, luck = 20},
    {name = "Inferno Rod", price = 1500000, power = 48, luck = 18},
    {name = "Golden Spine Rod", price = 2000000, power = 51, luck = 21},
    {name = "Platinum Spine Rod", price = 3000000, power = 54, luck = 25},
    {name = "Diamond Spine Rod", price = 4000000, power = 56, luck = 25},
    {name = "Gravisteel Rod", price = 5000000, power = 58, luck = 15},
    {name = "Auric Gravity Rod", price = 6000000, power = 60, luck = 10},
    {name = "Inferno Gravity Rod", price = 7000000, power = 62, luck = 20},
    {name = "Cryo Gravity Rod", price = 8000000, power = 65, luck = 36},
    {name = "Thunder Thorn Rod", price = 10000000, power = 67, luck = 30},
    {name = "Starlight Rod", price = 60000000, power = 83, luck = 15},
    -- CẦN CÂU BÍ MẬT & THẦN THOẠI (SECRET & MYTHIC RODS)
    {name = "Anchorbound Rod", price = 0, power = 50, luck = 25},
    {name = "Blazeshark Rod", price = 0, power = 55, luck = 20},
    {name = "Kraken Rod", price = 0, power = 65, luck = 30},
    {name = "Ascendant Bamboo Rod", price = 0, power = 70, luck = 35},
    {name = "Lifebloom Rod", price = 0, power = 75, luck = 40},
    {name = "Demonic Rod", price = 0, power = 85, luck = 25},
}

local function IsRodOwned(rodName)
    if not rodName or rodName == "" then return false end

    -- 1. Cần đang cầm trên tay hoặc lưu trong pData.FishingRod
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData and pData:FindFirstChild("FishingRod") and pData.FishingRod.Value == rodName then
        return true
    end

    -- 2. Kiểm tra trong kho cần câu chính: FishingRodInventory
    if pData and pData:FindFirstChild("FishingRodInventory") then
        local rFolder = pData.FishingRodInventory:FindFirstChild(rodName)
        if rFolder then
            local oVal = rFolder:FindFirstChild("Owned")
            if oVal and oVal:IsA("ValueBase") and oVal.Value == true then
                return true
            end
            if rFolder:IsA("BoolValue") and rFolder.Value == true then
                return true
            end
            if rFolder:GetAttribute("Owned") == true then
                return true
            end
            if oVal == nil and not rFolder:FindFirstChild("Locked") then
                return true
            end
        end
    end

    -- 3. Kiểm tra các thư mục kho phụ (Rods, RodInventory, Inventory, Tools)
    if pData then
        for _, fName in ipairs({"Rods", "RodInventory", "Inventory", "Tools"}) do
            local f = pData:FindFirstChild(fName)
            if f and f:FindFirstChild(rodName) then
                local oVal = f[rodName]:FindFirstChild("Owned")
                if oVal and oVal:IsA("ValueBase") then
                    if oVal.Value == true then return true end
                else
                    return true
                end
            end
        end
    end

    -- 4. Kiểm tra trong Backpack hoặc Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild(rodName) then return true end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild(rodName) then return true end

    -- 5. Cần mặc định của game (Wooden Rod) luôn đã có
    if rodName == "Wooden Rod" then
        return true
    end

    return false
end

local secretBossDatabase = {
    {
        islandName = "Đảo Tre (Bamboo Isle)",
        weather = "Thunderstorm (Bão Sấm)",
        patterns = {"bamboo", "đảo tre", "dao tre", "đảo 2", "dao 2"},
        weatherPatterns = {"thunderstorm", "bão sấm", "bao sam", "thunder", "sấm", "lightning"},
        bossPatterns = {"scarlet fish", "elder scarlet", "crimson electric eel", "electric eel"},
        pos = Vector3.new(-1187.8, 7.5, -22.5),
        lookAt = Vector3.new(-1137.9, 7.5, -24.9),
        spots = {
            [1] = {
                pos = Vector3.new(-1187.8, 7.5, -22.5),
                lookAt = Vector3.new(-1137.9, 7.5, -24.9),
            },
        },
        bosses = {
            {name = "Scarlet Fish", reward = "+3 Gems"},
            {name = "Elder Scarlet Fish", reward = "+5 Gems"},
            {name = "Crimson Electric Eel", reward = "+5 Gems"},
        }
    },
    {
        islandName = "Đảo Phóng Xạ (Fallout Isle)",
        weather = "Rainy (Trời Mưa)",
        patterns = {"fallout", "phóng xạ", "phong xa", "đảo 3", "dao 3"},
        weatherPatterns = {"rainy", "trời mưa", "troi mua", "heavy rain", "mưa", "rain"},
        bossPatterns = {"alligator gar", "verdant alligator", "verdant grouper", "verdant bonefang", "bonefang"},
        pos = Vector3.new(12.0, 19.0, 1413.0),
        lookAt = Vector3.new(8.3, 19.0, 1363.2),
        spots = {
            [1] = {
                pos = Vector3.new(12.0, 19.0, 1413.0),
                lookAt = Vector3.new(8.3, 19.0, 1363.2),
            },
        },
        bosses = {
            {name = "Verdant Alligator Gar", reward = "+3 Gems | Skill 25%"},
            {name = "Verdant Grouper", reward = "+3 Gems | Skill 25%"},
            {name = "Verdant Bonefang", reward = "+5 Gems | Skill 5%"},
        }
    },
    {
        islandName = "Đảo Cá Chép (Perch Isle)",
        weather = "Windy (Trời Gió)",
        patterns = {"perch", "cá chép", "ca chep", "đảo 5", "dao 5"},
        weatherPatterns = {"windy", "trời gió", "troi gio", "gale", "gió", "wind"},
        bossPatterns = {"flying fish empress", "flying fish emperor", "flying fish"},
        pos = Vector3.new(-85.3, 9.3, -1340.8),
        lookAt = Vector3.new(-114.0, 9.3, -1381.8),
        spots = {
            [1] = {
                pos = Vector3.new(-85.3, 9.3, -1340.8),
                lookAt = Vector3.new(-114.0, 9.3, -1381.8),
            },
        },
        bosses = {
            {name = "Flying Fish Empress", reward = "+10 Gems | Skill 10%"},
            {name = "Flying Fish Emperor", reward = "+10 Gems | Skill 10%"},
        }
    },
    {
        islandName = "Đảo Băng Giá (Frost Isle)",
        weather = "Snowy (Bão Tuyết)",
        patterns = {"frost", "băng giá", "bang gia", "đảo băng", "dao bang", "đảo 6", "dao 6"},
        weatherPatterns = {"snowy", "bão tuyết", "bao tuyet", "blizzard", "tuyết", "snow", "frosty"},
        bossPatterns = {"reborn puffer beast", "puffer beast", "frost kingfish"},
        pos = Vector3.new(-1347.6, 8.9, -1454.2),
        lookAt = Vector3.new(-1353.8, 8.9, -1404.6),
        spots = {
            [1] = {
                pos = Vector3.new(-1347.6, 8.9, -1454.2),
                lookAt = Vector3.new(-1353.8, 8.9, -1404.6),
            },
        },
        bosses = {
            {name = "Reborn Puffer Beast", reward = "+10 Gems"},
            {name = "Frost Kingfish", reward = "+10 Gems | Skill Drop"},
        }
    },
    {
        islandName = "Đảo Quả Dừa (Coconut Isle)",
        weather = "Foggy (Sương Mù)",
        patterns = {"coconut", "quả dừa", "qua dua", "đảo dừa", "dao dua", "đảo 7", "dao 7"},
        weatherPatterns = {"foggy", "sương mù", "suong mu", "dense fog", "mist", "sương", "fog"},
        bossPatterns = {"tigerfang whale", "tigerfang", "heaven piercer turtle", "piercer turtle"},
        pos = Vector3.new(1412.0, 9.3, -1457.7),
        lookAt = Vector3.new(1404.0, 9.3, -1408.4),
        spots = {
            [1] = {
                pos = Vector3.new(1412.0, 9.3, -1457.7),
                lookAt = Vector3.new(1404.0, 9.3, -1408.4),
            },
        },
        bosses = {
            {name = "Tigerfang Whale", reward = "+5 Gems | Skill Drop"},
            {name = "Heaven Piercer Turtle", reward = "+5 Gems"},
        }
    },
    {
        islandName = "Đảo Hổ Phách (Amber Isle)",
        weather = "Blazing Sun (Nắng Gắt)",
        patterns = {"amber", "hổ phách", "ho phach", "đảo 8", "dao 8"},
        weatherPatterns = {"blazing sun", "nắng gắt", "nang gat", "blazing", "heatwave", "nắng", "sun"},
        bossPatterns = {"draconic koi", "draconic", "sanguine fish", "sanguine"},
        pos = Vector3.new(1146.0, 9.3, 1391.6),
        lookAt = Vector3.new(1096.2, 9.3, 1395.8),
        spots = {
            [1] = {
                pos = Vector3.new(1146.0, 9.3, 1391.6),
                lookAt = Vector3.new(1096.2, 9.3, 1395.8),
            },
        },
        bosses = {
            {name = "Draconic Koi", reward = "+5 Gems"},
            {name = "Sanguine Fish", reward = "+20 Gems | Skill 10%"},
        }
    },
    {
        islandName = "Đảo Chiến Trường (Battlefield)",
        weather = "Boss Realm",
        patterns = {"battlefield", "chiến trường", "chien truong", "đảo 9", "dao 9"},
        weatherPatterns = {"boss realm", "realm"},
        bossPatterns = {"primordial kunfish", "kunfish overlord", "kunfish", "warbringer shark", "warbringer"},
        pos = Vector3.new(1365.5, 8.9, 270.4),
        lookAt = Vector3.new(1316.1, 8.9, 262.6),
        spots = {
            [1] = {
                pos = Vector3.new(1365.5, 8.9, 270.4),
                lookAt = Vector3.new(1316.1, 8.9, 262.6),
            },
        },
        bosses = {
            {name = "Primordial Kunfish Overlord", reward = "+30 Gems"},
            {name = "Warbringer Shark", reward = "+25 Gems"},
        }
    },
    {
        islandName = "Đảo Đỉnh Sương Mù (Mistpeak)",
        weather = "Mountain Peak",
        patterns = {"mistpeak", "đỉnh sương mù", "dinh suong mu", "đảo 10", "dao 10"},
        weatherPatterns = {"mountain peak", "mistpeak", "đỉnh núi"},
        bossPatterns = {"mountain fish"},
        pos = Vector3.new(2579.1, 9.3, 11.7),
        lookAt = Vector3.new(2529.3, 9.3, 7.3),
        spots = {
            [1] = {
                pos = Vector3.new(2579.1, 9.3, 11.7),
                lookAt = Vector3.new(2529.3, 9.3, 7.3),
            },
        },
        bosses = {
            {name = "Mountain Fish", reward = "+20 Gems | Skill 5%"},
        }
    },
    {
        islandName = "Vùng Biển Sâu (Secret Ocean)",
        weather = "Special Event",
        patterns = {"octo", "bạch tuộc", "bach tuoc", "phao", "buoy", "secret ocean"},
        weatherPatterns = {"special event", "octo", "bạch tuộc"},
        bossPatterns = {"octoparasitic fish", "octoparasitic", "octoparasite"},
        pos = Vector3.new(1608.2, 5.5, -218.3),
        lookAt = Vector3.new(1635.0, 5.0, -235.0),
        spots = {
            [1] = {
                pos = Vector3.new(1608.2, 5.5, -218.3),
                lookAt = Vector3.new(1635.0, 5.0, -235.0),
            },
        },
        bosses = {
            {name = "Octoparasitic Fish", reward = "+50 Gems | Secret"},
        }
    }
}

local secretBossLookup = {}
for _, entry in ipairs(secretBossDatabase) do
    for _, b in ipairs(entry.bosses) do
        secretBossLookup[b.name:lower()] = b.name
    end
end

local Wiki = {
    craftMaterialFish = {
        ["Mountain Fish"] = true,
        ["Catfish"] = true,
        ["Crimson Catfish"] = true,
        ["Scarlet Fish"] = true,
        ["Elder Scarlet Fish"] = true,
        ["Octoparasitic Fish"] = true,
        ["Tiger Mirefish"] = true,
        ["Mirage Lanternfish"] = true,
        ["Golden Guardian Fish"] = true,
        ["Frost Kingfish"] = true,
        ["Frost Queenfish"] = true,
        ["Rainbow Dragonfish"] = true,
        ["Sanguine Fish"] = true,
        ["Verdant Bonefang"] = true,
        ["Verdant Alligator Gar"] = true,
        ["Draconic Koi"] = true,
        ["Heaven Piercer Turtle"] = true,
        ["Flying Fish Empress"] = true,
        ["Flying Fish Emperor"] = true,
    },
    rarityColors = {
        ["Mythic"]    = Color3.fromRGB(248, 113, 113),  -- Đỏ neon Thần Thoại
        ["Legendary"] = Color3.fromRGB(250, 204, 21),   -- Vàng hoàng kim Huyền Thoại
        ["Epic"]      = Color3.fromRGB(192, 132, 252),  -- Tím mộng mơ Sử Thi
        ["Rare"]      = Color3.fromRGB(96, 165, 250),   -- Xanh dương Hiếm
        ["Uncommon"]  = Color3.fromRGB(52, 211, 153),   -- Xanh lục Đặc Biệt
        ["Common"]    = Color3.fromRGB(168, 150, 200),  -- Xám bạc Phổ Thông
    },
    wikiFishData = {
        -- 1. Thần Thoại (Mythic) & Secret Boss
        {name = "Primordial Kunfish Overlord", rarity = "Mythic", keep = true, use = "💎 +30 Gems • Vũ khí Thần Thoại • Boss Realm • BẢO VỆ TUYỆT ĐỐI", origin = "Đấu Trường Boss Realm", icon = "rbxassetid://10709791437"},
        {name = "Warbringer Shark", rarity = "Mythic", keep = true, use = "💎 +25 Gems • Vũ khí Chiến Tranh • Boss Realm • BẢO VỆ TUYỆT ĐỐI", origin = "Đấu Trường Boss Realm", icon = "rbxassetid://10709791437"},
        {name = "Octoparasitic Fish", rarity = "Mythic", keep = true, use = "💎 +50 Gems • Đổi Cần Thần • Event Nameless Bait • KHÔNG ĐƯỢC BÁN", origin = "Sự Kiện Bạch Tuộc Biển", icon = "rbxassetid://10709791437"},
        {name = "Mountain Fish", rarity = "Mythic", keep = true, use = "💎 +20 Gems • Rơi Kỹ Năng 5% • Nguyên liệu chế đồ thần • KHÔNG BÁN", origin = "Đảo Đỉnh Sương Mù (Mistpeak)", icon = "rbxassetid://10709791437"},
        {name = "Sanguine Fish", rarity = "Mythic", keep = true, use = "💎 +20 Gems • Secret Boss Trời Nắng Gắt • Cực hiếm • KHÔNG BÁN", origin = "Đảo Hổ Phách (Amber Isle)", icon = "rbxassetid://10709791437"},
        {name = "Frost Kingfish", rarity = "Mythic", keep = true, use = "💎 +10 Gems • Rơi Bí Kíp Võ Công • Boss Bão Tuyết • KHÔNG BÁN", origin = "Đảo Băng Giá (Frost Isle)", icon = "rbxassetid://10709791437"},
        {name = "Tigerfang Whale", rarity = "Mythic", keep = true, use = "💎 +5 Gems • Rơi Kỹ Năng Đòn Đánh • Boss Sương Mù • KHÔNG BÁN", origin = "Đảo Quả Dừa (Coconut Isle)", icon = "rbxassetid://10709791437"},
        {name = "Verdant Bonefang", rarity = "Mythic", keep = true, use = "💎 +5 Gems • Rơi Kỹ Năng 5% • Boss Trời Mưa • KHÔNG BÁN", origin = "Đảo Phóng Xạ (Fallout Isle)", icon = "rbxassetid://10709791437"},
        {name = "Crimson Electric Eel", rarity = "Mythic", keep = true, use = "💎 +5 Gems • Luyện Cooldown & Gems • Boss Bão Sấm • KHÔNG BÁN", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Elder Scarlet Fish", rarity = "Mythic", keep = true, use = "💎 +5 Gems • Nguyên liệu chế Cần Huyết Long • Boss Bão Sấm • KHÔNG BÁN", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Flying Fish Emperor", rarity = "Mythic", keep = true, use = "💎 +10 Gems • Rơi Kỹ Năng 10% • Boss Trời Gió • KHÔNG BÁN", origin = "Đảo Cá Chép (Perch Isle)", icon = "rbxassetid://10709791437"},
        {name = "Rainbow Dragonfish", rarity = "Mythic", keep = true, use = "💎 Thần Ngư Cực Hiếm • Chế tác Cần Thần Hoàng Kim • KHÔNG BÁN", origin = "Vùng Nước Ngầm Lòng Đất", icon = "rbxassetid://10709791437"},

        -- 2. Huyền Thoại (Legendary)
        {name = "Reborn Puffer Beast", rarity = "Legendary", keep = true, use = "💎 +10 Gems • Secret Boss Bão Tuyết • KHÔNG ĐƯỢC BÁN", origin = "Đảo Băng Giá (Frost Isle)", icon = "rbxassetid://10709791437"},
        {name = "Flying Fish Empress", rarity = "Legendary", keep = true, use = "💎 +10 Gems • Rơi Kỹ Năng 10% • Boss Trời Gió • KHÔNG BÁN", origin = "Đảo Cá Chép (Perch Isle)", icon = "rbxassetid://10709791437"},
        {name = "Draconic Koi", rarity = "Legendary", keep = true, use = "💎 +5 Gems • Long Ngư Hổ Phách • Boss Nắng Gắt • KHÔNG BÁN", origin = "Đảo Hổ Phách (Amber Isle)", icon = "rbxassetid://10709791437"},
        {name = "Heaven Piercer Turtle", rarity = "Legendary", keep = true, use = "💎 +5 Gems • Thần Quy Xuyên Trời • Boss Sương Mù • KHÔNG BÁN", origin = "Đảo Quả Dừa (Coconut Isle)", icon = "rbxassetid://10709791437"},
        {name = "Verdant Alligator Gar", rarity = "Legendary", keep = true, use = "💎 +3 Gems • Rơi Kỹ Năng 25% • Boss Trời Mưa • KHÔNG BÁN", origin = "Đảo Phóng Xạ (Fallout Isle)", icon = "rbxassetid://10709791437"},
        {name = "Scarlet Fish", rarity = "Legendary", keep = true, use = "💎 +3 Gems • Chế tạo Cần Huyết Long • Boss Bão Sấm • KHÔNG BÁN", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Verdant Grouper", rarity = "Legendary", keep = true, use = "💎 +3 Gems • Rơi Kỹ Năng 25% • Boss Trời Mưa • KHÔNG BÁN", origin = "Đảo Phóng Xạ (Fallout Isle)", icon = "rbxassetid://10709791437"},

        -- 3. Sử Thi (Epic)
        {name = "Frost Queenfish", rarity = "Epic", keep = true, use = "⭐ Nguyên liệu chế Cần Băng Giá Hoàng Kim • KHÔNG BÁN", origin = "Đảo Băng Giá (Frost Isle)", icon = "rbxassetid://10709791437"},
        {name = "Golden Guardian Fish", rarity = "Epic", keep = true, use = "⭐ Nguyên liệu chế Cần Vàng Hộ Vệ • KHÔNG BÁN", origin = "Đảo Thống Trị (Sovereign Isle)", icon = "rbxassetid://10709791437"},
        {name = "Tiger Mirefish", rarity = "Epic", keep = true, use = "⭐ Nguyên liệu tinh luyện Cần Hổ Trảo • KHÔNG BÁN", origin = "Đảo Đỉnh Sương Mù (Mistpeak)", icon = "rbxassetid://10709791437"},
        {name = "Mirage Lanternfish", rarity = "Epic", keep = true, use = "⭐ Nguyên liệu chế Cần Ảo Ảnh Quang Học • KHÔNG BÁN", origin = "Đảo Đỉnh Sương Mù (Mistpeak)", icon = "rbxassetid://10709791437"},
        {name = "Crimson Catfish", rarity = "Epic", keep = true, use = "⭐ Nguyên liệu đúc Cần Huyết Long V2 • KHÔNG BÁN", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Catfish", rarity = "Rare", keep = true, use = "⭐ Nguyên liệu cơ bản ghép Cần Câu Sơ Cấp • KHÔNG BÁN", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Colossal Tigerfish", rarity = "Epic", keep = false, use = "💰 Bán lấy nhiều tiền vàng (Giá trị kinh tế cao)", origin = "Đảo Chiến Trường (Battlefield)", icon = "rbxassetid://10709791437"},
        {name = "Sunburst Trout", rarity = "Epic", keep = false, use = "💰 Bán lấy nhiều tiền vàng (Giá trị kinh tế cao)", origin = "Đảo Hổ Phách (Amber Isle)", icon = "rbxassetid://10709791437"},

        -- 4. Hiếm (Rare)
        {name = "Ascended Perch", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền nâng cấp trang bị", origin = "Đảo Cá Chép (Perch Isle)", icon = "rbxassetid://10709791437"},
        {name = "Glacial Trout", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền mua mồi và phụ kiện", origin = "Đảo Băng Giá (Frost Isle)", icon = "rbxassetid://10709791437"},
        {name = "Tropical Angelfish", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền trang trải mua Cần mới", origin = "Đảo Quả Dừa (Coconut Isle)", icon = "rbxassetid://10709791437"},
        {name = "Amber Koi", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền vàng mua đồ shop", origin = "Đảo Hổ Phách (Amber Isle)", icon = "rbxassetid://10709791437"},
        {name = "Bladefin Snapper", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền mua vật phẩm hỗ trợ", origin = "Đảo Chiến Trường (Battlefield)", icon = "rbxassetid://10709791437"},
        {name = "Mist Salmon", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền vàng làm giàu", origin = "Đảo Đỉnh Sương Mù (Mistpeak)", icon = "rbxassetid://10709791437"},
        {name = "Glow Perch", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền vàng trang trải", origin = "Đảo Phóng Xạ (Fallout Isle)", icon = "rbxassetid://10709791437"},
        {name = "Crowned Trout", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền vàng nâng cấp", origin = "Đảo Thống Trị (Sovereign Isle)", icon = "rbxassetid://10709791437"},
        {name = "Flying Fish", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền vàng mua sắm", origin = "Đảo Cá Chép (Perch Isle)", icon = "rbxassetid://10709791437"},
        {name = "Salmon", rarity = "Rare", keep = false, use = "💰 Bán kiếm tiền vàng cơ bản", origin = "Đảo Khởi Đầu (Spawn)", icon = "rbxassetid://10709791437"},

        -- 5. Đặc Biệt (Uncommon)
        {name = "Coconut Crabfish", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Quả Dừa (Coconut Isle)", icon = "rbxassetid://10709791437"},
        {name = "Sovereign Fish", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Thống Trị (Sovereign Isle)", icon = "rbxassetid://10709791437"},
        {name = "Silver Bass", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Cá Chép (Perch Isle)", icon = "rbxassetid://10709791437"},
        {name = "Armored Carp", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Chiến Trường (Battlefield)", icon = "rbxassetid://10709791437"},
        {name = "Toxic Trout", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Phóng Xạ (Fallout Isle)", icon = "rbxassetid://10709791437"},
        {name = "Green Carp", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Bass", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Khởi Đầu (Spawn)", icon = "rbxassetid://10709791437"},
        {name = "Trout", rarity = "Uncommon", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Khởi Đầu (Spawn)", icon = "rbxassetid://10709791437"},

        -- 6. Phổ Thông (Common)
        {name = "Carp", rarity = "Common", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Khởi Đầu (Spawn)", icon = "rbxassetid://10709791437"},
        {name = "Perch", rarity = "Common", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Khởi Đầu (Spawn)", icon = "rbxassetid://10709791437"},
        {name = "Minnow", rarity = "Common", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Khởi Đầu (Spawn)", icon = "rbxassetid://10709791437"},
        {name = "Bamboo Fish", rarity = "Common", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Tre (Bamboo Isle)", icon = "rbxassetid://10709791437"},
        {name = "Radioactive Carp", rarity = "Common", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Phóng Xạ (Fallout Isle)", icon = "rbxassetid://10709791437"},
        {name = "Ice Fish", rarity = "Common", keep = false, use = "💰 Bán tự động dọn trống balo", origin = "Đảo Băng Giá (Frost Isle)", icon = "rbxassetid://10709791437"},
    }
}

function Wiki.IsItemFavorited(item)
    if not item then return false end
    local favVal = item:FindFirstChild("Favorite")
    if favVal and (favVal.Value == true or favVal.Value == 1) then return true end
    if item:GetAttribute("Favorite") == true then return true end
    local lockVal = item:FindFirstChild("Locked")
    if lockVal and (lockVal.Value == true or lockVal.Value == 1) then return true end
    if item:GetAttribute("Locked") == true then return true end
    return false
end

function Wiki.IsSecretBossFish(item)
    if not item then return false end
    local rawName = tostring(item.Name or "")
    local lowerName = rawName:lower()

    for bLower, _ in pairs(secretBossLookup) do
        if lowerName:find(bLower, 1, true) then
            return true
        end
    end

    if item:GetAttribute("Boss") == true or item:GetAttribute("Secret") == true or item:GetAttribute("IsBoss") == true then
        return true
    end

    return false
end

function Wiki.IsMutatedFish(item)
    if not item then return false end
    local name = tostring(item.Name or "")
    for _, kw in ipairs({"Shiny", "Giant", "Golden", "Albino", "Corrupted", "Colossal", "Heavyweight", "Dark", "Radiant"}) do
        if name:find(kw) then return true end
    end
    local mutVal = item:FindFirstChild("Mutation")
    if mutVal and tostring(mutVal.Value) ~= "" and tostring(mutVal.Value) ~= "None" then
        return true
    end
    for _, attr in ipairs({"Mutation", "Mutated", "Variant"}) do
        local v = item:GetAttribute(attr)
        if v and tostring(v) ~= "" and tostring(v) ~= "None" then
            return true
        end
    end
    return false
end

function Wiki.GetItemRawName(item)
    if not item then return "" end
    local v = item:FindFirstChild("ValueName")
    if v and v:IsA("StringValue") and #v.Value > 0 then
        return v.Value
    end
    local attName = item:GetAttribute("FishName") or item:GetAttribute("Name") or item:GetAttribute("ItemName")
    if attName and #tostring(attName) > 0 then
        return tostring(attName)
    end
    return tostring(item.Name or "")
end

function Wiki.GetPlayerFishCount(fishName)
    local count = 0
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if not pData then return 0 end
    local fishLower = tostring(fishName or ""):lower()

    local function checkFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            local rawName = Wiki.GetItemRawName(item):lower()
            local instName = tostring(item.Name or ""):lower()
            if rawName == fishLower or instName == fishLower or rawName:find(fishLower, 1, true) or instName:find(fishLower, 1, true) then
                local qtyVal = item:FindFirstChild("Quantity") or item:FindFirstChild("Count") or item:FindFirstChild("Amount") or item:FindFirstChild("Stack")
                local qty = (qtyVal and tonumber(qtyVal.Value)) or 1
                count = count + qty
            end
        end
    end

    checkFolder(pData:FindFirstChild("Inventory"))
    checkFolder(pData:FindFirstChild("Hotbar"))
    return count
end

function Wiki.IsEssentialKeepItem(item)
    if not item then return false end
    if Wiki.IsSecretBossFish(item) then return true end
    if Wiki.IsMutatedFish(item) then return true end

    local itName = tostring(item.Name or "")
    local vName = item:FindFirstChild("ValueName") and tostring(item.ValueName.Value or "") or ""
    if Wiki.craftMaterialFish[itName] or Wiki.craftMaterialFish[vName] then return true end

    if Config.AutoFavouriteFish and (itName == Config.FavouriteFishName or vName == Config.FavouriteFishName) then
        return true
    end

    local itLower = itName:lower()
    local vLower = vName:lower()

    for _, f in ipairs(Wiki.wikiFishData) do
        if f.keep then
            local fLower = f.name:lower()
            if itLower == fLower or vLower == fLower or itLower:find(fLower, 1, true) or (vLower ~= "" and vLower:find(fLower, 1, true)) then
                return true
            end
        end
    end
    return false
end

function Wiki.UnlockAllUnnecessaryFish()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if not pData then
        ShowNotification("Mở Khóa Balo", "Không tìm thấy dữ liệu túi đồ người chơi!", "WARN", 4)
        return 0
    end

    local toUnlock = {}
    local folders = {}
    if pData:FindFirstChild("Inventory") then table.insert(folders, pData.Inventory) end
    if pData:FindFirstChild("Hotbar") then table.insert(folders, pData.Hotbar) end

    for _, folder in ipairs(folders) do
        for _, item in ipairs(folder:GetChildren()) do
            if Wiki.IsItemFavorited(item) then
                if not Wiki.IsEssentialKeepItem(item) then
                    table.insert(toUnlock, item)
                end
            end
        end
    end

    if #toUnlock == 0 then
        ShowNotification("Mở Khóa Balo", "Không có cá không cần thiết nào đang bị khóa trong balo.", "INFO", 4)
        return 0
    end

    local unlockedCount = 0
    for _, item in ipairs(toUnlock) do
        if Events and Events:FindFirstChild("FavoriteItem") then
            Events.FavoriteItem:FireServer(item)
            unlockedCount = unlockedCount + 1
            task.wait(0.04)
        end
    end

    ShowNotification("MỞ KHÓA THÀNH CÔNG", string.format("Đã mở khóa %d con cá không cần thiết! AutoSell có thể bán ngay.", unlockedCount), "SUCCESS", 6)
    return unlockedCount
end

function Wiki.LockAllKeepFish()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if not pData then
        ShowNotification("Khóa Bảo Vệ", "Không tìm thấy dữ liệu túi đồ!", "WARN", 4)
        return 0
    end

    local toLock = {}
    local folders = {}
    if pData:FindFirstChild("Inventory") then table.insert(folders, pData.Inventory) end
    if pData:FindFirstChild("Hotbar") then table.insert(folders, pData.Hotbar) end

    for _, folder in ipairs(folders) do
        for _, item in ipairs(folder:GetChildren()) do
            if not Wiki.IsItemFavorited(item) then
                if Wiki.IsEssentialKeepItem(item) then
                    table.insert(toLock, item)
                end
            end
        end
    end

    if #toLock == 0 then
        ShowNotification("Khóa Bảo Vệ", "Tất cả cá cần giữ trong balo đã được khóa an toàn.", "INFO", 4)
        return 0
    end

    local lockedCount = 0
    for _, item in ipairs(toLock) do
        if Events and Events:FindFirstChild("FavoriteItem") then
            Events.FavoriteItem:FireServer(item)
            lockedCount = lockedCount + 1
            task.wait(0.04)
        end
    end

    ShowNotification("KHÓA THÀNH CÔNG", string.format("Đã khóa bảo vệ an toàn %d con cá quý / boss / nguyên liệu!", lockedCount), "SUCCESS", 6)
    return lockedCount
end

function Wiki.ToggleLockSpecificFish(fishName, targetKeepState)
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if not pData then return end
    local fishLower = fishName:lower()
    local toggled = 0

    local folders = {}
    if pData:FindFirstChild("Inventory") then table.insert(folders, pData.Inventory) end
    if pData:FindFirstChild("Hotbar") then table.insert(folders, pData.Hotbar) end

    for _, folder in ipairs(folders) do
        for _, item in ipairs(folder:GetChildren()) do
            local rawName = Wiki.GetItemRawName(item):lower()
            local instName = tostring(item.Name or ""):lower()
            if rawName == fishLower or instName == fishLower or rawName:find(fishLower, 1, true) then
                local isFav = Wiki.IsItemFavorited(item)
                if targetKeepState and not isFav then
                    if Events and Events:FindFirstChild("FavoriteItem") then
                        Events.FavoriteItem:FireServer(item)
                        toggled = toggled + 1
                        task.wait(0.04)
                    end
                elseif not targetKeepState and isFav then
                    if Events and Events:FindFirstChild("FavoriteItem") then
                        Events.FavoriteItem:FireServer(item)
                        toggled = toggled + 1
                        task.wait(0.04)
                    end
                end
            end
        end
    end

    local actText = targetKeepState and "Đã khóa bảo vệ" or "Đã mở khóa"
    if toggled > 0 then
        ShowNotification("Thao Tác Cá", string.format("%s %d con [%s] thành công!", actText, toggled, fishName), "SUCCESS", 5)
    else
        ShowNotification("Thao Tác Cá", string.format("Không có con [%s] nào cần chuyển trạng thái trong túi.", fishName), "INFO", 4)
    end
end

function Wiki.ResolveFishIcon(fishName, defaultIcon)
    local ok, icon = pcall(function()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        if pData then
            for _, fName in ipairs({"Inventory", "Hotbar"}) do
                local f = pData:FindFirstChild(fName)
                if f then
                    for _, it in ipairs(f:GetChildren()) do
                        local rawName = Wiki.GetItemRawName(it)
                        if rawName == fishName or it.Name == fishName then
                            for _, prop in ipairs({"Icon", "Image", "Texture", "Thumbnail"}) do
                                local p = it:FindFirstChild(prop)
                                if p and p:IsA("StringValue") and #p.Value > 0 then
                                    return p.Value
                                end
                                local att = it:GetAttribute(prop)
                                if att and #tostring(att) > 0 then
                                    return tostring(att)
                                end
                            end
                        end
                    end
                end
            end
        end

        if ReplicatedStorage then
            local found = ReplicatedStorage:FindFirstChild(fishName, true)
            if found then
                for _, prop in ipairs({"Icon", "Image", "Texture", "Thumbnail"}) do
                    local p = found:FindFirstChild(prop)
                    if p and p:IsA("StringValue") and #p.Value > 0 then
                        return p.Value
                    end
                    local att = found:GetAttribute(prop)
                    if att and #tostring(att) > 0 then
                        return tostring(att)
                    end
                end
                if found:IsA("Decal") or found:IsA("Texture") then
                    return found.Texture
                end
            end
        end

        return nil
    end)

    if ok and icon and #tostring(icon) > 0 then
        return tostring(icon)
    end

    return defaultIcon or "rbxassetid://10709791437"
end

local secretBossState = {
    active = false,
    currentMap = nil,
    targetIsland = nil,
    requiredPower = 0,
    statusText = "Đang chờ thông báo...",
    isCatchingTarget = false,
    lastSkipTime = 0,
    minigameStartTime = 0,
}

local statusLabelSecretBoss = nil
local bossTogglesMap = {}

local weatherTotems = {
    {name = "Totem Bão Sấm (Bamboo Isle)", island = "Đảo Tre (Bamboo Isle)", weather = "Thunderstorm (Bão Sấm)", pos = Vector3.new(-1242.0, 8.5, -195.0)},
    {name = "Totem Bão Tuyết (Frost Isle)", island = "Đảo Băng (Frost Isle)", weather = "Snowy (Bão Tuyết)", pos = Vector3.new(-1390.0, 10.2, -1515.0)},
    {name = "Totem Sương Mù (Coconut Isle)", island = "Đảo Quả Dừa (Coconut Isle)", weather = "Foggy (Sương Mù)", pos = Vector3.new(1475.0, 9.8, -1415.0)},
    {name = "Totem Nắng Gắt (Amber Isle)", island = "Đảo Hổ Phách (Amber Isle)", weather = "Blazing Sun (Nắng Gắt)", pos = Vector3.new(1275.0, 9.5, 1450.0)},
}

local sessionStartTime = tick()
local initialCash = nil
local initialFishCaught = nil
local lastWebhookStatsTime = tick()

local gemTracker = {
    gained = 0,
    lastKnown = nil,
    lastFishAwardTime = 0,
    lastFishAwardAmount = 0,
    inventoryHooked = false
}

local fishGemRewardLookup = {
    ["scarlet fish"] = 3,
    ["elder scarlet fish"] = 5,
    ["crimson electric eel"] = 5,
    ["verdant alligator gar"] = 3,
    ["verdant grouper"] = 3,
    ["verdant bonefang"] = 5,
    ["flying fish empress"] = 10,
    ["flying fish emperor"] = 10,
    ["reborn puffer beast"] = 10,
    ["frost kingfish"] = 10,
    ["tigerfang whale"] = 5,
    ["heaven piercer turtle"] = 5,
    ["draconic koi"] = 5,
    ["sanguine fish"] = 20,
    ["primordial kunfish overlord"] = 30,
    ["warbringer shark"] = 25,
    ["mountain fish"] = 20,
    ["octoparasitic fish"] = 50,
}

local function GetFishGemReward(fishName)
    if not fishName then return 0 end
    local clean = tostring(fishName):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if fishGemRewardLookup[clean] then return fishGemRewardLookup[clean] end
    for k, v in pairs(fishGemRewardLookup) do
        if clean:find(k, 1, true) then return v end
    end
    return 0
end

local function GetPlayerCurrentGems()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData then
        for _, name in ipairs({"Gems", "Gem", "Diamonds", "Diamond", "Ruby", "Rubies", "Shards", "Crystal"}) do
            local obj = pData:FindFirstChild(name)
            if obj and obj:IsA("ValueBase") and tonumber(obj.Value) then
                return tonumber(obj.Value)
            end
        end
        for _, sub in ipairs({"Currencies", "Currency", "Stats", "Account"}) do
            local subFolder = pData:FindFirstChild(sub)
            if subFolder then
                for _, name in ipairs({"Gems", "Gem", "Diamonds", "Diamond"}) do
                    local obj = subFolder:FindFirstChild(name)
                    if obj and obj:IsA("ValueBase") and tonumber(obj.Value) then
                        return tonumber(obj.Value)
                    end
                end
            end
        end
        for _, name in ipairs({"Gems", "Gem", "Diamonds", "Diamond", "Ruby"}) do
            local att = pData:GetAttribute(name)
            if att and tonumber(att) then return tonumber(att) end
        end
    end

    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, name in ipairs({"Gems", "Gem", "Diamonds", "Diamond", "Ruby"}) do
            local obj = ls:FindFirstChild(name)
            if obj and obj:IsA("ValueBase") and tonumber(obj.Value) then
                return tonumber(obj.Value)
            end
        end
    end

    for _, name in ipairs({"Gems", "Gem", "Diamonds", "Diamond"}) do
        local att = LocalPlayer:GetAttribute(name)
        if att and tonumber(att) then return tonumber(att) end
        local obj = LocalPlayer:FindFirstChild(name)
        if obj and obj:IsA("ValueBase") and tonumber(obj.Value) then return tonumber(obj.Value) end
    end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local mg = pg:FindFirstChild("MainGui") or pg:FindFirstChild("Fisher_GUI")
        if mg then
            for _, d in ipairs(mg:GetDescendants()) do
                if d:IsA("TextLabel") and d.Visible then
                    local pName = d.Parent and d.Parent.Name:lower() or ""
                    local dName = d.Name:lower()
                    if dName:find("gem") or dName:find("diamond") or pName:find("gem") or pName:find("diamond") then
                        local numStr = d.Text:gsub("[^%d]", "")
                        if #numStr > 0 and tonumber(numStr) then
                            return tonumber(numStr)
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function TrackCaughtFishForGems(child)
    if not child then return end
    local fishName = child.Name
    local reward = GetFishGemReward(fishName)
    if child:FindFirstChild("Gem") and tonumber(child.Gem.Value) then
        reward = math.max(reward, tonumber(child.Gem.Value))
    elseif child:FindFirstChild("Gems") and tonumber(child.Gems.Value) then
        reward = math.max(reward, tonumber(child.Gems.Value))
    elseif child:GetAttribute("Gem") and tonumber(child:GetAttribute("Gem")) then
        reward = math.max(reward, tonumber(child:GetAttribute("Gem")))
    elseif child:GetAttribute("Gems") and tonumber(child:GetAttribute("Gems")) then
        reward = math.max(reward, tonumber(child:GetAttribute("Gems")))
    end

    if reward > 0 then
        gemTracker.lastFishAwardTime = tick()
        gemTracker.lastFishAwardAmount = reward
        gemTracker.gained = gemTracker.gained + reward
        if infoGemsGained and infoGemsGained.Set then
            infoGemsGained.Set("+" .. FormatWithSpaces(gemTracker.gained) .. " Gems")
        end
        ShowNotification("Thưởng Gems", string.format("Bắt được %s! Nhận được +%d Gems!", fishName, reward), "SUCCESS", 4)
    end
end

local function SendDiscordWebhook(title, description, color, fields)
    if not Config.WebhookEnabled or not Config.WebhookUrl or #Config.WebhookUrl == 0 then return end
    pcall(function()
        local embed = {
            title = title or "Heavyweight Fishing Bot",
            description = description or "",
            color = color or 11029759,
            fields = fields or {},
            footer = {text = "Identical Hub • Heavyweight Fishing V1.4"},
            timestamp = DateTime.now():ToIsoDate()
        }
        local payload = {
            username = "Heavyweight Fishing Monitor",
            avatar_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) .. "&width=150&height=150&format=png",
            embeds = {embed}
        }
        local body = HttpService:JSONEncode(payload)
        local headers = {["Content-Type"] = "application/json"}

        local reqFunc = (syn and syn.request) or (http and http.request) or http_request or request
        if reqFunc then
            reqFunc({
                Url = Config.WebhookUrl,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end
    end)
end

local function GetPlayerRodPower()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    local eqRod = pData and pData:FindFirstChild("FishingRod") and pData.FishingRod.Value
    if eqRod then
        for _, r in ipairs(allRods) do
            if r.name == eqRod then
                return r.power
            end
        end
    end
    return 0
end

local function GetCurrentHookedFishName()
    local char = LocalPlayer.Character
    if not char then return nil end

    local function matchBossName(rawText)
        if not rawText or typeof(rawText) ~= "string" or #rawText == 0 then return nil end
        local txt = rawText:gsub("^%s+", ""):gsub("%s+$", "")
        local txtLower = txt:lower()

        if secretBossLookup[txtLower] then return secretBossLookup[txtLower] end

        -- Fuzzy / Substring match với danh sách Secret Boss (bỏ qua prefix đột biến như Shiny, Giant, Albino,...)
        for _, entry in ipairs(secretBossDatabase) do
            for _, b in ipairs(entry.bosses) do
                local bLower = b.name:lower()
                if txtLower:find(bLower, 1, true) then
                    return b.name
                end
            end
            if entry.bossPatterns then
                for _, bp in ipairs(entry.bossPatterns) do
                    if txtLower:find(bp, 1, true) then
                        return bp
                    end
                end
            end
        end
        return txt
    end

    -- 1. Check Character attributes
    for _, attName in ipairs({"FishName", "TargetFish", "Boss", "Fish", "CurrentFish", "HookedFish"}) do
        local val = char:GetAttribute(attName)
        if val and tostring(val) ~= "" then
            return matchBossName(tostring(val))
        end
    end

    -- 2. Check PlayerGui.MainGui.Fishing
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local fUI = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
    if fUI and fUI.Visible then
        for _, lblName in ipairs({"FishName", "Title", "Name", "Fish", "BossName", "Target"}) do
            local label = fUI:FindFirstChild(lblName, true)
            if label and label:IsA("TextLabel") and label.Text ~= "" then
                return matchBossName(label.Text)
            end
        end

        local bossBar = fUI:FindFirstChild("BossFightBar")
        if bossBar and bossBar.Visible then
            for _, d in ipairs(bossBar:GetDescendants()) do
                if d:IsA("TextLabel") and d.Visible and d.Text ~= "" and not tonumber(d.Text) and not d.Text:find("%%") then
                    local matched = matchBossName(d.Text)
                    if matched and #matched > 2 then return matched end
                end
            end
        end

        -- Scan any visible TextLabel in fUI matching a known secret boss
        for _, d in ipairs(fUI:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" and not tonumber(d.Text) and not d.Text:find("%%") then
                local txtLower = d.Text:lower()
                for _, entry in ipairs(secretBossDatabase) do
                    for _, b in ipairs(entry.bosses) do
                        if txtLower:find(b.name:lower(), 1, true) then
                            return b.name
                        end
                    end
                end
            end
        end
    end

    return nil
end

local function ServerHop()
    ShowNotification("Đổi Server", "Đang tìm kiếm server phù hợp...", "WARN")
    pcall(function()
        local placeId = game.PlaceId
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"
        local res = game:HttpGet(url)
        local body = HttpService:JSONDecode(res)
        if body and body.data then
            for _, s in ipairs(body.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                    return
                end
            end
        end
    end)
end
secretBossState.ServerHop = ServerHop
local ticketQuestState = nil

local function IsTicketQuestFishingActive()
    if not Config.AutoTicketQuest or not ticketQuestState then return false end
    if ticketQuestState.isCooldown then
        return Config.TicketReturnHomeWhenDone and Config.TicketAutoCastAtHome and (ticketQuestState.isAtHomeSpot == true)
    else
        return ticketQuestState.active and (ticketQuestState.currentQuestType ~= "none")
    end
end

local function CancelAndRecastRod(forceCast)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:UnequipTools()
    end
    local isBossActive = secretBossState and secretBossState.active
    local isTicketActive = IsTicketQuestFishingActive()
    local shouldRecast = forceCast or Config.AutoCast or Config.AutoTrainSkill or isTicketActive or ((Config.AutoHuntBoss or Config.AutoChatSecretBoss) and isBossActive)
    if not shouldRecast then return end

    task.delay(0.2, function()
        if not isRunning then return end
        if Events and Events:FindFirstChild("ToggleHotbar") then
            Events.ToggleHotbar:InvokeServer("1")
        end
        task.delay(0.25, function()
            if not isRunning then return end
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r and Events and Events:FindFirstChild("Fishing") then
                Events.Fishing:FireServer(r.CFrame)
            end
        end)
    end)
end

function secretBossState.DetectWeatherPattern(text)
    if not text or typeof(text) ~= "string" then return nil, nil end
    local lower = text:lower()

    -- 1. Kiểm tra thời tiết quang đãng / bình thường (Clear) -> Không có Boss thời tiết
    if lower:find("clear") or lower:find("sunny") or lower:find("normal") or lower:find("none")
       or lower:find("trong xanh") or lower:find("bình thường") or lower:find("binh thuong") then
        return nil, "Clear"
    end

    -- 2. Khớp theo weatherPatterns của từng đảo
    for _, entry in ipairs(secretBossDatabase) do
        if entry.weatherPatterns then
            for _, wp in ipairs(entry.weatherPatterns) do
                if lower:find(wp, 1, true) then
                    return entry, entry.weather
                end
            end
        end
    end

    -- 3. Khớp theo tên Boss xuất hiện trong mô tả thời tiết
    for _, entry in ipairs(secretBossDatabase) do
        if entry.bossPatterns then
            for _, bp in ipairs(entry.bossPatterns) do
                if lower:find(bp, 1, true) then
                    return entry, bp
                end
            end
        end
        for _, b in ipairs(entry.bosses) do
            if lower:find(b.name:lower(), 1, true) then
                return entry, b.name
            end
        end
    end

    return nil, nil
end

function secretBossState.DetectIsland(text)
    if not text or typeof(text) ~= "string" then return nil, nil end
    local lower = text:lower()

    -- Bỏ qua nếu là thông báo người chơi câu được cá (KHÔNG PHẢI BOSS XUẤT HIỆN)
    if lower:find("caught") or lower:find("has caught") or lower:find("câu được") or lower:find("đã câu") or lower:find("bắt được") or lower:find("obtained") then
        return nil, nil
    end

    -- 0. Nếu văn bản là thời tiết Clear / bình thường -> Bỏ qua, không phải đảo boss nào
    if lower:find("clear") or lower:find("sunny") or lower:find("trong xanh") or lower:find("bình thường") or lower:find("binh thuong") then
        return nil, "Clear"
    end

    -- 1. ƯU TIÊN CAO NHẤT: Khớp theo TÊN CHÍNH XÁC của Boss
    for _, entry in ipairs(secretBossDatabase) do
        if entry.bossPatterns then
            for _, bp in ipairs(entry.bossPatterns) do
                if lower:find(bp, 1, true) then
                    return entry, bp
                end
            end
        end
        for _, b in ipairs(entry.bosses) do
            if lower:find(b.name:lower(), 1, true) then
                return entry, b.name
            end
        end
    end

    -- 2. Khớp theo TÊN THỜI TIẾT (Weather Patterns)
    for _, entry in ipairs(secretBossDatabase) do
        if entry.weatherPatterns then
            for _, wp in ipairs(entry.weatherPatterns) do
                if lower:find(wp, 1, true) then
                    return entry, entry.weather
                end
            end
        end
    end

    -- 3. Khớp theo TÊN ĐẢO rõ ràng (Chỉ khi văn bản có kèm từ khóa liên quan đến boss/thời tiết/xuất hiện)
    local hasContext = lower:find("boss") or lower:find("secret") or lower:find("spawn") or lower:find("appear")
        or lower:find("xuất hiện") or lower:find("weather") or lower:find("thời tiết") or lower:find("bão")
    if hasContext then
        for _, entry in ipairs(secretBossDatabase) do
            for _, pat in ipairs(entry.patterns) do
                if lower:find(pat, 1, true) then
                    return entry, nil
                end
            end
        end
    end

    return nil, nil
end

function secretBossState.FindWaterSpot(centerPos, preferredLookAt)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = false

    local filterList = {}
    if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
    local wp = Workspace:FindFirstChild("IdenticalWaterPlatform")
    if wp then table.insert(filterList, wp) end
    rp.FilterDescendantsInstances = filterList

    -- 1. Hướng nhìn ưu tiên
    local preferredDir = nil
    if preferredLookAt then
        local pDir = Vector3.new(preferredLookAt.X - centerPos.X, 0, preferredLookAt.Z - centerPos.Z)
        if pDir.Magnitude > 0.1 then
            preferredDir = pDir.Unit
        end
    end

    local angles = {}
    local baseAngle = 0
    if preferredDir then
        baseAngle = math.atan2(preferredDir.Z, preferredDir.X)
    end

    -- Đặt góc ưu tiên lên đầu tiên, sau đó tỏa ra xung quanh theo nan hoa 16 hướng
    table.insert(angles, baseAngle)
    for i = 1, 8 do
        local offset = (i * math.pi / 8)
        table.insert(angles, baseAngle + offset)
        if offset < math.pi then
            table.insert(angles, baseAngle - offset)
        end
    end

    -- Bán kính quét mở rộng từ gần đến xa (15 đến 220 studs)
    local testDistances = {15, 30, 50, 75, 105, 140, 180, 220}
    local bestWaterHit = nil

    for _, dist in ipairs(testDistances) do
        for _, ang in ipairs(angles) do
            local dirX = math.cos(ang)
            local dirZ = math.sin(ang)
            local sampleX = centerPos.X + dirX * dist
            local sampleZ = centerPos.Z + dirZ * dist

            -- Bắn tia từ trên trời xuống để tìm Nước
            local hit = Workspace:Raycast(Vector3.new(sampleX, 45, sampleZ), Vector3.new(0, -75, 0), rp)
            if hit then
                local isWater = (hit.Material == Enum.Material.Water)
                if not isWater and hit.Instance then
                    local nameLower = hit.Instance.Name:lower()
                    if nameLower:find("water") or nameLower:find("ocean") or nameLower:find("sea") then
                        isWater = true
                    end
                end

                if isWater then
                    bestWaterHit = hit
                    break
                end
            end
        end
        if bestWaterHit then break end
    end

    -- Nếu tìm thấy vùng nước:
    if bestWaterHit then
        local waterPos = bestWaterHit.Position
        local waterLevel = waterPos.Y
        -- Hướng từ tâm đảo ra vùng nước
        local outwardDir = Vector3.new(waterPos.X - centerPos.X, 0, waterPos.Z - centerPos.Z)
        if outwardDir.Magnitude > 0.1 then
            outwardDir = outwardDir.Unit
        else
            outwardDir = preferredDir or Vector3.new(0, 0, 1)
        end

        -- Dò ngược từ vùng nước về phía tâm đảo để tìm mép bờ đất (Shoreline)
        local shorePos = nil
        for backStep = 1, 25 do
            local testBackPos = waterPos - outwardDir * (backStep * 2.0)
            local groundHit = Workspace:Raycast(Vector3.new(testBackPos.X, 45, testBackPos.Z), Vector3.new(0, -75, 0), rp)
            if groundHit and groundHit.Material ~= Enum.Material.Water then
                -- Tìm thấy bờ đất liền kề nước!
                shorePos = Vector3.new(groundHit.Position.X, groundHit.Position.Y + 2.5, groundHit.Position.Z)
                break
            end
        end

        -- Điểm đứng lý tưởng:
        -- Nếu tìm được mép bờ, đứng ở mép bờ nhìn thẳng ra biển
        -- Nếu không tìm được mép bờ (đảo phẳng chìm hoặc xa bờ), đứng ngay sát mép nước
        local standPos = shorePos or Vector3.new(waterPos.X - outwardDir.X * 4, waterLevel + 2.5, waterPos.Z - outwardDir.Z * 4)
        local lookTarget = standPos + outwardDir * 50

        return standPos, lookTarget, waterLevel, true
    end

    -- Fallback: Nếu không quét ra tia nước, dùng vị trí mặc định
    local fallbackStand = centerPos + Vector3.new(0, 2.5, 0)
    local fallbackLook = preferredLookAt or (centerPos + Vector3.new(0, 2.5, 50))
    return fallbackStand, fallbackLook, centerPos.Y, false
end

function secretBossState.SaveCustomSpots()
    if not writefile then return end
    pcall(function()
        local data = {}
        if Config.CustomBossSpots then
            for k, v in pairs(Config.CustomBossSpots) do
                data[k] = v
            end
        end
        writefile("heavyweight_custom_spots.json", HttpService:JSONEncode(data))
    end)
end

function secretBossState.LoadCustomSpots()
    if not readfile or not isfile or not isfile("heavyweight_custom_spots.json") then return end
    pcall(function()
        local content = readfile("heavyweight_custom_spots.json")
        if content and #content > 0 then
            local decoded = HttpService:JSONDecode(content)
            if type(decoded) == "table" then
                Config.CustomBossSpots = Config.CustomBossSpots or {}
                for k, v in pairs(decoded) do
                    Config.CustomBossSpots[k] = v
                end
            end
        end
    end)
end

function secretBossState.SaveHomeSpot()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false, "Không tìm thấy nhân vật!" end

    local cf = root.CFrame
    local spotData = {
        x = cf.Position.X,
        y = cf.Position.Y,
        z = cf.Position.Z,
        cframe = {cf:GetComponents()},
        savedAt = os.date("%H:%M:%S - %d/%m/%Y")
    }
    Config.HomeFarmSpot = spotData

    if writefile then
        pcall(function()
            local fName = string.format("heavyweight_home_spot_%s.json", tostring(LocalPlayer.UserId))
            writefile(fName, HttpService:JSONEncode(spotData))
        end)
    end
    return true, spotData
end

function secretBossState.LoadHomeSpot()
    if not readfile or not isfile then return end
    local fName = string.format("heavyweight_home_spot_%s.json", tostring(LocalPlayer.UserId))
    if not isfile(fName) then return end
    pcall(function()
        local content = readfile(fName)
        if content and #content > 0 then
            local decoded = HttpService:JSONDecode(content)
            if type(decoded) == "table" and (decoded.cframe or decoded.x) then
                Config.HomeFarmSpot = decoded
            end
        end
    end)
end

function secretBossState.ClearHomeSpot()
    Config.HomeFarmSpot = nil
    if delfile and isfile then
        pcall(function()
            local fName = string.format("heavyweight_home_spot_%s.json", tostring(LocalPlayer.UserId))
            if isfile(fName) then delfile(fName) end
        end)
    elseif writefile then
        pcall(function()
            local fName = string.format("heavyweight_home_spot_%s.json", tostring(LocalPlayer.UserId))
            writefile(fName, "")
        end)
    end
end

function secretBossState.ReturnToHome()
    if not Config.HomeFarmSpot then return false end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local homeCf = nil
    if Config.HomeFarmSpot.cframe and #Config.HomeFarmSpot.cframe == 12 then
        homeCf = CFrame.new(table.unpack(Config.HomeFarmSpot.cframe))
    elseif Config.HomeFarmSpot.x and Config.HomeFarmSpot.y and Config.HomeFarmSpot.z then
        homeCf = CFrame.new(Config.HomeFarmSpot.x, Config.HomeFarmSpot.y, Config.HomeFarmSpot.z)
    end
    if not homeCf then return false end

    local dist = (root.Position - homeCf.Position).Magnitude
    if dist > 35 then
        if (tick() - (secretBossState.lastHomeReturnTime or 0)) < 4.0 then
            return false
        end
        secretBossState.lastHomeReturnTime = tick()

        ShowNotification("VỀ VỊ TRÍ FARM", "Thời tiết Clear / Hết Boss! Đang quay về vị trí Farm để câu cá kiếm tiền...", "INFO", 5)
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set("Thời tiết Clear / Hết Boss -> Đã về vị trí Farm câu tiền...")
        end

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
        wp.CFrame = CFrame.new(homeCf.Position.X, homeCf.Position.Y - 2.8, homeCf.Position.Z)
        wp.CanCollide = true

        root.CFrame = homeCf + Vector3.new(0, 1.5, 0)
        task.wait(0.2)
        root.CFrame = homeCf

        secretBossState.active = false
        secretBossState.currentMap = "Home Farm"
        secretBossState.standPos = homeCf.Position

        -- Bắt đầu quăng cần sau 1.5s nếu có bật AutoCast hoặc AutoTrainSkill
        task.delay(1.5, function()
            if not isRunning then return end
            if Config.AutoCast or Config.AutoTrainSkill then
                CancelAndRecastRod()
            end
        end)
        return true
    end
    return false
end

function secretBossState.GetNearestIsland()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, 999999 end
    local pos = root.Position
    local nearest = nil
    local minDist = 999999

    for _, entry in ipairs(secretBossDatabase) do
        local checkPos = entry.pos
        local dist = (pos - checkPos).Magnitude
        if dist < minDist then
            minDist = dist
            nearest = entry
        end
    end
    return nearest, minDist
end

function secretBossState.GetIslandSpots(islandName)
    local spots = {}
    local custom = Config.CustomBossSpots and Config.CustomBossSpots[islandName]

    if custom then
        if custom.spots and type(custom.spots) == "table" then
            for i = 1, 3 do
                local s = custom.spots[i] or custom.spots[tostring(i)]
                if s and s.cframe then
                    table.insert(spots, { slot = i, cframe = s.cframe, savedAt = s.savedAt })
                end
            end
        end

        if #spots == 0 and custom.cframe then
            table.insert(spots, { slot = 1, cframe = custom.cframe, savedAt = custom.savedAt })
        end
    end

    -- Nếu người chơi chưa tự lưu vị trí riêng, tự động dùng vị trí chuẩn đã nạp sẵn trong script gốc
    if #spots == 0 then
        for _, entry in ipairs(secretBossDatabase) do
            if entry.islandName == islandName then
                if entry.spots and #entry.spots > 0 then
                    for idx, sp in ipairs(entry.spots) do
                        local cf = CFrame.lookAt(sp.pos, sp.lookAt)
                        table.insert(spots, { slot = idx, cframe = {cf:GetComponents()}, savedAt = "Mặc Định (Gốc)" })
                    end
                elseif entry.pos and entry.lookAt then
                    local cf = CFrame.lookAt(entry.pos, entry.lookAt)
                    table.insert(spots, { slot = 1, cframe = {cf:GetComponents()}, savedAt = "Mặc Định (Gốc)" })
                end
                break
            end
        end
    end

    return spots
end

function secretBossState.GetIslandSlotSpot(islandName, slot)
    local custom = Config.CustomBossSpots and Config.CustomBossSpots[islandName]
    if custom then
        if custom.spots and type(custom.spots) == "table" then
            local s = custom.spots[slot] or custom.spots[tostring(slot)]
            if s and s.cframe then return s end
        end
        if slot == 1 and custom.cframe then
            return { cframe = custom.cframe, savedAt = custom.savedAt }
        end
    end

    -- Fallback vào vị trí chuẩn trong database
    for _, entry in ipairs(secretBossDatabase) do
        if entry.islandName == islandName then
            if entry.spots and (entry.spots[slot] or entry.spots[tostring(slot)]) then
                local sp = entry.spots[slot] or entry.spots[tostring(slot)]
                local cf = CFrame.lookAt(sp.pos, sp.lookAt)
                return { cframe = {cf:GetComponents()}, savedAt = "Mặc Định (Gốc)" }
            elseif slot == 1 and entry.pos and entry.lookAt then
                local cf = CFrame.lookAt(entry.pos, entry.lookAt)
                return { cframe = {cf:GetComponents()}, savedAt = "Mặc Định (Gốc)" }
            end
        end
    end
    return nil
end

function secretBossState.SaveIslandSlot(islandName, slot, cfComponents)
    Config.CustomBossSpots = Config.CustomBossSpots or {}
    local entry = Config.CustomBossSpots[islandName]
    if not entry then
        entry = { spots = {} }
        Config.CustomBossSpots[islandName] = entry
    elseif not entry.spots then
        local oldCf = entry.cframe
        local oldSaved = entry.savedAt
        entry.spots = {}
        if oldCf then
            entry.spots[1] = { cframe = oldCf, savedAt = oldSaved }
        end
    end

    entry.spots[slot] = {
        cframe = cfComponents,
        savedAt = os.date("%H:%M:%S")
    }
    local s1 = entry.spots[1] or entry.spots["1"]
    entry.cframe = s1 and s1.cframe or cfComponents
    secretBossState.SaveCustomSpots()
end

function secretBossState.DeleteIslandSlot(islandName, slot)
    if not Config.CustomBossSpots or not Config.CustomBossSpots[islandName] then return end
    local entry = Config.CustomBossSpots[islandName]
    if not slot or slot == 0 then
        Config.CustomBossSpots[islandName] = nil
    else
        if entry.spots then
            entry.spots[slot] = nil
            entry.spots[tostring(slot)] = nil
        end
        if slot == 1 then
            entry.cframe = nil
        end
        local hasRemaining = false
        if entry.spots then
            for i = 1, 3 do
                if entry.spots[i] or entry.spots[tostring(i)] then
                    hasRemaining = true
                    break
                end
            end
        end
        if not hasRemaining then
            Config.CustomBossSpots[islandName] = nil
        end
    end
    secretBossState.SaveCustomSpots()
end

function secretBossState.ApplyJitter(baseCf)
    if not Config.BossTeleportJitter then return baseCf end
    local maxDist = Config.BossTeleportJitterDist or 1.0
    if maxDist <= 0.1 then return baseCf end

    local dirSign = (math.random(1, 2) == 1) and 1 or -1
    local minDist = math.min(0.4, maxDist * 0.5)
    local offsetDist = dirSign * (minDist + math.random() * (maxDist - minDist))

    return baseCf + (baseCf.RightVector * offsetDist)
end

function secretBossState.GetChosenSpotForPlayer(islandName)
    local spots = secretBossState.GetIslandSpots(islandName)
    if #spots == 0 then return nil, nil, 0 end

    local mode = Config.BossSpotAllocationMode or "Tự Động (Theo Acc)"
    local chosen = nil

    if mode == "Vị Trí 1" then
        for _, s in ipairs(spots) do if s.slot == 1 then chosen = s; break end end
    elseif mode == "Vị Trí 2" then
        for _, s in ipairs(spots) do if s.slot == 2 then chosen = s; break end end
    elseif mode == "Vị Trí 3" then
        for _, s in ipairs(spots) do if s.slot == 3 then chosen = s; break end end
    elseif mode == "Ngẫu Nhiên" then
        chosen = spots[math.random(1, #spots)]
    else -- "Tự Động (Theo Acc)"
        local userId = (LocalPlayer and LocalPlayer.UserId) or 0
        local idx = (math.abs(userId) % #spots) + 1
        chosen = spots[idx]
    end

    if not chosen then
        chosen = spots[1]
    end

    local cf = CFrame.new(unpack(chosen.cframe))
    return cf, chosen.slot, #spots
end

function secretBossState.Teleport(matchedIsland, detectedName, reqPower)
    if not matchedIsland or not matchedIsland.pos then return false end

    -- Nếu nhân vật đã ở đúng đảo mục tiêu và đã đứng tại vị trí câu rồi thì KHÔNG teleport lại tránh gián đoạn cần câu
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and secretBossState.currentMap == matchedIsland.islandName and secretBossState.standPos then
        local d = (root.Position - secretBossState.standPos).Magnitude
        if d < 70 then
            return true
        end
    end

    -- Kiểm tra nếu người chơi có chọn săn ít nhất 1 boss ở đảo này không
    local hasTargetInIsland = false
    for _, b in ipairs(matchedIsland.bosses) do
        if Config.SecretBossTargets[b.name] then
            hasTargetInIsland = true
            break
        end
    end

    if not hasTargetInIsland then
        ShowNotification("Bỏ Qua Boss", string.format("Phát hiện tại %s nhưng bạn không chọn săn boss ở đảo này.", matchedIsland.islandName), "INFO", 4)
        return false
    end

    local powerReq = reqPower or 0
    local curPower = GetPlayerRodPower()
    if Config.SecretBossCheckPower and powerReq > 0 and curPower < powerReq then
        ShowNotification("CẢNH BÁO LỰC CẦN", string.format("Boss yêu cầu %d Power! Cần của bạn chỉ có %d Power.", powerReq, curPower), "WARN", 8)
    end

    -- Cập nhật trạng thái săn
    secretBossState.active = true
    secretBossState.currentMap = matchedIsland.islandName
    secretBossState.targetIsland = matchedIsland
    secretBossState.requiredPower = powerReq
    secretBossState.statusText = string.format("Đang săn tại %s [%s]", matchedIsland.islandName, matchedIsland.weather or "Thời Tiết")

    local alertName = detectedName and string.upper(tostring(detectedName)) or "SECRET BOSS / THỜI TIẾT"
    ShowNotification("PHÁT HIỆN " .. alertName .. "!", string.format("Đang bay đến %s để câu boss...", matchedIsland.islandName), "SUCCESS", 7)

    if statusLabelSecretBoss and statusLabelSecretBoss.Set then
        statusLabelSecretBoss.Set(secretBossState.statusText)
    end

    -- Dịch chuyển nhân vật đến bờ biển câu
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and matchedIsland.pos then
        local customCf, chosenSlot, totalSpots = secretBossState.GetChosenSpotForPlayer(matchedIsland.islandName)
        local standPos = nil
        local waterY = nil

        if customCf then
            -- 1. Ưu tiên số 1: Tọa độ tùy chọn đã cài đặt (có áp dụng xê dịch trái/phải né người)
            local finalCf = secretBossState.ApplyJitter(customCf)
            root.CFrame = finalCf
            standPos = root.Position
            waterY = standPos.Y - 2.5
            local jitterTag = Config.BossTeleportJitter and " (+ xê dịch)" or ""
            ShowNotification("VỊ TRÍ TÙY CHỌN", string.format("Đã vào [Vị Trí %d/%d]%s tại %s!", chosenSlot or 1, totalSpots or 1, jitterTag, matchedIsland.islandName), "SUCCESS", 5)
        else
            -- 2. Dò tìm mép nước tự động (cũng áp dụng xê dịch nếu bật)
            local lookTarget, foundWater
            standPos, lookTarget, waterY, foundWater = secretBossState.FindWaterSpot(matchedIsland.pos, matchedIsland.lookAt)
            local baseCf = CFrame.lookAt(standPos, lookTarget)
            local finalCf = secretBossState.ApplyJitter(baseCf)
            root.CFrame = finalCf
            standPos = root.Position
            if foundWater then
                ShowNotification("MÉP NƯỚC CÂU CÁ", string.format("Đã dò thấy vùng nước! Nhân vật đã vào vị trí mép bờ tại %s.", matchedIsland.islandName), "SUCCESS", 5)
            end
        end

        -- Đặt sàn an toàn dưới chân nếu gần mặt nước
        local wp = Workspace:FindFirstChild("IdenticalWaterPlatform")
        if wp and standPos then
            wp.CFrame = CFrame.new(standPos.X, (waterY or (standPos.Y - 2.5)) - 1.2, standPos.Z)
            wp.CanCollide = true
        end

        secretBossState.standPos = standPos

        -- Khởi động quăng cần câu sau 2.5s hạ cánh
        lastCastTime = tick() + 2.5
        CancelAndRecastRod()
    end
    return true
end

function secretBossState.DetectWeather()
    -- 1. Quét Workspace Attributes hoặc Objects
    local wsWeather = Workspace:GetAttribute("Weather") or Workspace:GetAttribute("CurrentWeather") or Workspace:GetAttribute("ActiveWeather")
    if typeof(wsWeather) == "string" and #wsWeather > 0 then
        local matched, wName = secretBossState.DetectWeatherPattern(wsWeather)
        if wName == "Clear" then
            return nil, "Clear"
        elseif matched then
            return matched, wName or wsWeather
        end
    end
    if Workspace:FindFirstChild("Weather") then
        local wObj = Workspace.Weather
        if wObj:IsA("StringValue") and #wObj.Value > 0 then
            local matched, wName = secretBossState.DetectWeatherPattern(wObj.Value)
            if wName == "Clear" then
                return nil, "Clear"
            elseif matched then
                return matched, wName or wObj.Value
            end
        end
    end

    -- 2. Quét ReplicatedStorage
    if ReplicatedStorage then
        local rsWeather = ReplicatedStorage:GetAttribute("Weather") or ReplicatedStorage:GetAttribute("CurrentWeather")
        if typeof(rsWeather) == "string" and #rsWeather > 0 then
            local matched, wName = secretBossState.DetectWeatherPattern(rsWeather)
            if wName == "Clear" then
                return nil, "Clear"
            elseif matched then
                return matched, wName or rsWeather
            end
        end
        if ReplicatedStorage:FindFirstChild("Weather") then
            local rwObj = ReplicatedStorage.Weather
            if rwObj:IsA("StringValue") and #rwObj.Value > 0 then
                local matched, wName = secretBossState.DetectWeatherPattern(rwObj.Value)
                if wName == "Clear" then
                    return nil, "Clear"
                elseif matched then
                    return matched, wName or rwObj.Value
                end
            end
        end
    end

    -- 3. Quét PlayerGui (HUD thời tiết trên màn hình game)
    -- CHÚ Ý: CHỈ quét nhãn có tên thực sự là thời tiết (weather/climate/season)
    -- TUYỆT ĐỐI KHÔNG quét "island" hoặc "map" để tránh nhầm nhãn bản đồ ("Frost Isle") thành thời tiết!
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("MainGui") then
        for _, d in ipairs(pg.MainGui:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" and #d.Text >= 3 and #d.Text <= 45 then
                local dName = d.Name:lower()
                local pName = d.Parent and d.Parent.Name:lower() or ""
                if (dName:find("weather") or dName:find("climate") or dName:find("season")
                    or pName:find("weather") or pName:find("climate") or pName:find("season"))
                    and not dName:find("island") and not dName:find("map")
                    and not pName:find("island") and not pName:find("map") then
                    local matched, wName = secretBossState.DetectWeatherPattern(d.Text)
                    if wName == "Clear" then
                        return nil, "Clear"
                    elseif matched then
                        return matched, wName or d.Text
                    end
                end
            end
        end
    end

    return nil, nil
end

secretBossState.cachedTaoist = nil
secretBossState.lastTaoistScan = 0
secretBossState.cachedGod = nil
secretBossState.lastGodScan = 0

function secretBossState.ScanForTaoistNPC()
    local taoistPatterns = {"taoist", "maoshan", "mao shan", "grand angler", "grandangler", "đạo sĩ", "dao si", "daoshi", "priest"}

    local function matchesTaoist(str)
        if not str or typeof(str) ~= "string" or str == "" then return nil end
        local s = str:lower()
        for _, pat in ipairs(taoistPatterns) do
            if s:find(pat, 1, true) then return pat end
        end
        return nil
    end

    local candidateFolders = {}
    for _, fName in ipairs({"NPC", "NPCs", "Entities", "Characters", "Spawns", "Map", "Islands", "SecretRod"}) do
        local f = Workspace:FindFirstChild(fName)
        if f then
            table.insert(candidateFolders, f)
            for _, subName in ipairs({"NPC", "NPCs", "Entities", "Characters"}) do
                local sf = f:FindFirstChild(subName)
                if sf then table.insert(candidateFolders, sf) end
            end
        end
    end
    table.insert(candidateFolders, Workspace)

    -- Đợt 1: Quét nhanh tên Model / BasePart trực tiếp
    for _, folder in ipairs(candidateFolders) do
        for _, n in ipairs(folder:GetChildren()) do
            if n:IsA("Model") or n:IsA("BasePart") then
                local pat = matchesTaoist(n.Name)
                if pat then
                    local isMaoshan = pat:find("maoshan") or pat:find("mao shan")
                    local category = isMaoshan and "Maoshan" or "Taoist"
                    local displayName = isMaoshan and "Đạo Sĩ Maoshan" or "Đạo Sĩ (Taoist)"
                    local icon = isMaoshan and "✨" or "📜"
                    local col = isMaoshan and Colors.PurplePrimary or Colors.AccentOrange
                    return n, displayName, category, col, icon
                end
            end
        end
    end

    -- Đợt 2: Quét qua ProximityPrompt (tương tác) và TextLabel (tên hiển thị trên đầu)
    for _, folder in ipairs(candidateFolders) do
        for _, d in ipairs(folder:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                local act = tostring(d.ActionText or "")
                local obj = tostring(d.ObjectText or "")
                local pName = d.Parent and d.Parent.Name or ""
                local ppName = d.Parent and d.Parent.Parent and d.Parent.Parent.Name or ""
                local pat = matchesTaoist(act) or matchesTaoist(obj) or matchesTaoist(pName) or matchesTaoist(ppName)
                if pat then
                    local model = d:FindFirstAncestorOfClass("Model") or d.Parent
                    local isMaoshan = pat:find("maoshan") or pat:find("mao shan")
                    local category = isMaoshan and "Maoshan" or "Taoist"
                    local displayName = isMaoshan and "Đạo Sĩ Maoshan" or "Đạo Sĩ (Taoist)"
                    local icon = isMaoshan and "✨" or "📜"
                    local col = isMaoshan and Colors.PurplePrimary or Colors.AccentOrange
                    return model, displayName, category, col, icon
                end
            elseif d:IsA("TextLabel") and d.Visible and d.Text and #d.Text > 0 then
                local pat = matchesTaoist(d.Text)
                if pat then
                    local model = d:FindFirstAncestorOfClass("Model") or d.Parent
                    local isMaoshan = pat:find("maoshan") or pat:find("mao shan")
                    local category = isMaoshan and "Maoshan" or "Taoist"
                    local displayName = isMaoshan and "Đạo Sĩ Maoshan" or "Đạo Sĩ (Taoist)"
                    local icon = isMaoshan and "✨" or "📜"
                    local col = isMaoshan and Colors.PurplePrimary or Colors.AccentOrange
                    return model, displayName, category, col, icon
                end
            end
        end
    end
    return nil
end

function secretBossState.GetTaoist()
    if secretBossState.cachedTaoist and secretBossState.cachedTaoist.inst and secretBossState.cachedTaoist.inst.Parent then
        return secretBossState.cachedTaoist.inst, secretBossState.cachedTaoist.displayName, secretBossState.cachedTaoist.category, secretBossState.cachedTaoist.col, secretBossState.cachedTaoist.icon
    end
    local now = tick()
    if (now - secretBossState.lastTaoistScan) >= 1.5 then
        secretBossState.lastTaoistScan = now
        local inst, displayName, category, col, icon = secretBossState.ScanForTaoistNPC()
        if inst then
            secretBossState.cachedTaoist = {
                inst = inst,
                displayName = displayName,
                category = category,
                col = col,
                icon = icon
            }
            return inst, displayName, category, col, icon
        else
            secretBossState.cachedTaoist = nil
        end
    end
    if secretBossState.cachedTaoist and secretBossState.cachedTaoist.inst and secretBossState.cachedTaoist.inst.Parent then
        return secretBossState.cachedTaoist.inst, secretBossState.cachedTaoist.displayName, secretBossState.cachedTaoist.category, secretBossState.cachedTaoist.col, secretBossState.cachedTaoist.icon
    end
    return nil
end

function secretBossState.ScanForGodSpirit()
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
    for _, fName in ipairs({"NPC", "NPCs", "Entities", "Characters", "Spawns", "Map", "Islands"}) do
        local f = Workspace:FindFirstChild(fName)
        if f then table.insert(candidateFolders, f) end
    end
    table.insert(candidateFolders, Workspace)

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
    return nil
end

function secretBossState.GetGodSpirit()
    if secretBossState.cachedGod and secretBossState.cachedGod.Parent then
        return secretBossState.cachedGod
    end
    local now = tick()
    if (now - secretBossState.lastGodScan) >= 1.5 then
        secretBossState.lastGodScan = now
        local inst = secretBossState.ScanForGodSpirit()
        secretBossState.cachedGod = inst
        return inst
    end
    return secretBossState.cachedGod
end

function secretBossState.HandleChatMessage(msg)
    if not (Config.AutoChatSecretBoss or Config.AutoHuntBoss) then return end
    if typeof(msg) ~= "string" or #msg == 0 then return end
    local lower = msg:lower()

    -- Bỏ qua nếu là thông báo người chơi câu được cá (KHÔNG PHẢI BOSS XUẤT HIỆN)
    if lower:find("caught") or lower:find("has caught") or lower:find("câu được") or lower:find("đã câu") or lower:find("bắt được") or lower:find("obtained") then
        return
    end

    -- 1. Check for Despawn Announcement: "all secret bosses have been despawned", "weather ended", etc.
    if (lower:find("all secret bosses") and (lower:find("despawn") or lower:find("gone") or lower:find("disappear")))
       or lower:find("secret bosses have been despawned")
       or lower:find("secret bosses have despawned")
       or lower:find("bosses have despawned")
       or lower:find("boss has despawned")
       or lower:find("weather has ended")
       or lower:find("weather ended")
       or lower:find("weather returned to normal")
       or lower:find("clear skies")
       or lower:find("weather: clear")
       or lower:find("thời tiết đã hết")
       or lower:find("kết thúc") then
        secretBossState.active = false
        secretBossState.currentMap = nil
        secretBossState.targetIsland = nil
        secretBossState.standPos = nil
        secretBossState.activeChatBoss = nil
        secretBossState.statusText = "Tất cả Secret Boss đã despawn. Chờ đợt mới..."
        ShowNotification("Secret Boss Despawn", "Tất cả Secret Boss đã biến mất! Hệ thống đang chờ đợt xuất hiện tiếp theo.", "WARN", 7)
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set("Tất cả Secret Boss đã despawn. Chờ đợt mới...")
        end
        if Config.ReturnToHomeWhenClear and Config.HomeFarmSpot then
            secretBossState.ReturnToHome()
        end
        if Config.AutoServerHopOnDespawn then
            ShowNotification("Auto Server Hop", "Secret Boss đã hết! Đang tự động đổi server để săn tiếp...", "WARN", 5)
            task.delay(1.5, function()
                if Config.AutoServerHopOnDespawn then
                    ServerHop()
                end
            end)
        end
        return
    end

    -- 2. Check for Spawn Announcement: Chứa từ khóa xuất hiện thực sự
    local isSpawnWord = lower:find("spawn") or lower:find("appear") or lower:find("xuất hiện")
        or lower:find("started") or lower:find("bắt đầu") or lower:find("active")
        or lower:find("has arrived") or lower:find("đã đến") or lower:find("secret boss")

    if isSpawnWord then
        local matchedIsland, detectedName = secretBossState.DetectIsland(msg)
        if matchedIsland and detectedName ~= "Clear" then
            -- Kiểm tra xem có boss mục tiêu nào trên đảo này được bật trong cài đặt săn không
            local hasTargetInIsland = false
            for _, b in ipairs(matchedIsland.bosses) do
                if Config.SecretBossTargets[b.name] then
                    hasTargetInIsland = true
                    break
                end
            end
            if not hasTargetInIsland then return end

            local reqPower = 0
            local powMatch = lower:match("power%s*[:=]?%s*(%d+)") or lower:match("(%d+)%s*power")
            if powMatch then
                reqPower = tonumber(powMatch) or 0
            end

            secretBossState.activeChatBoss = {
                island = matchedIsland,
                bossName = detectedName,
                time = tick(),
                reqPower = reqPower
            }
            secretBossState.Teleport(matchedIsland, detectedName, reqPower)
        end
    end
end

function secretBossState.ScanChatHistory()
    local foundMessages = {}
    local pg = LocalPlayer:FindFirstChild("PlayerGui")

    -- 1. Quét giao diện Chat hiện đại (ExperienceChat) - Chỉ lấy tối đa 10 tin gần nhất
    if pg and pg:FindFirstChild("ExperienceChat") then
        local labels = {}
        for _, d in ipairs(pg.ExperienceChat:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text ~= "" and #d.Text > 5 then
                table.insert(labels, d)
            end
        end
        table.sort(labels, function(a, b)
            local orderA = (a.Parent and a.Parent.LayoutOrder) or a.LayoutOrder or 0
            local orderB = (b.Parent and b.Parent.LayoutOrder) or b.LayoutOrder or 0
            if orderA ~= orderB then return orderA < orderB end
            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
        end)
        local startIdx = math.max(1, #labels - 9)
        for i = startIdx, #labels do
            table.insert(foundMessages, labels[i].Text)
        end
    end

    -- 2. Quét giao diện Chat cổ điển (Legacy Chat) - Chỉ lấy tối đa 10 tin gần nhất
    if pg and pg:FindFirstChild("Chat") then
        local labels = {}
        for _, d in ipairs(pg.Chat:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text ~= "" and #d.Text > 5 then
                table.insert(labels, d)
            end
        end
        table.sort(labels, function(a, b)
            local orderA = (a.Parent and a.Parent.LayoutOrder) or a.LayoutOrder or 0
            local orderB = (b.Parent and b.Parent.LayoutOrder) or b.LayoutOrder or 0
            if orderA ~= orderB then return orderA < orderB end
            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
        end)
        local startIdx = math.max(1, #labels - 9)
        for i = startIdx, #labels do
            table.insert(foundMessages, labels[i].Text)
        end
    end

    -- TUYỆT ĐỐI KHÔNG quét PlayerGui / Workspace.BossSetUp ở đây để tránh nhầm UI game thành tin thông báo!

    -- Phân tích tin nhắn theo thứ tự từ dưới lên trên (tin mới nhất xuất hiện ở cuối danh sách)
    local latestSpawn = nil
    local latestDespawnIndex = -1
    local latestSpawnIndex = -1

    for idx, msg in ipairs(foundMessages) do
        local lower = msg:lower()
        if (lower:find("all secret bosses") and (lower:find("despawn") or lower:find("gone") or lower:find("disappear")))
           or lower:find("secret bosses have been despawned")
           or lower:find("secret bosses have despawned")
           or lower:find("bosses have despawned")
           or lower:find("boss has despawned")
           or lower:find("weather has ended")
           or lower:find("weather ended")
           or lower:find("weather returned to normal")
           or lower:find("clear skies")
           or lower:find("weather: clear")
           or lower:find("thời tiết đã hết")
           or lower:find("kết thúc") then
            latestDespawnIndex = idx
        elseif not (lower:find("caught") or lower:find("has caught") or lower:find("câu được") or lower:find("đã câu") or lower:find("bắt được")) then
            local isSpawnKw = lower:find("spawn") or lower:find("appear") or lower:find("xuất hiện")
                or lower:find("started") or lower:find("bắt đầu") or lower:find("secret boss")
            if isSpawnKw then
                local entry, bName = secretBossState.DetectIsland(msg)
                if entry and bName ~= "Clear" then
                    latestSpawn = {msg = msg, island = entry, index = idx, bossName = bName}
                    latestSpawnIndex = idx
                end
            end
        end
    end

    -- Nếu có tin nhắn Boss xuất hiện và tin Spawn xuất hiện sau tin Despawn (hoặc không có tin despawn nào sau đó)
    if latestSpawn and (latestDespawnIndex < latestSpawnIndex) then
        local hasTargetInIsland = false
        for _, b in ipairs(latestSpawn.island.bosses) do
            if Config.SecretBossTargets[b.name] then
                hasTargetInIsland = true
                break
            end
        end
        if hasTargetInIsland then
            return latestSpawn
        end
    elseif latestDespawnIndex > latestSpawnIndex and latestDespawnIndex ~= -1 then
        secretBossState.standPos = nil
        secretBossState.active = false
        secretBossState.currentMap = nil
        secretBossState.activeChatBoss = nil
        secretBossState.statusText = "Boss gần nhất đã despawn. Đang chờ đợt mới..."
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set(secretBossState.statusText)
        end
        if Config.ReturnToHomeWhenClear and Config.HomeFarmSpot then
            secretBossState.ReturnToHome()
        end
    end
    return nil
end

pcall(function() secretBossState.LoadCustomSpots() end)
pcall(function() secretBossState.LoadHomeSpot() end)

local function TriggerPrompt(prompt)
    if not prompt then return end
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait((prompt.HoldDuration or 0) + 0.05)
            prompt:InputHoldEnd()
        end)
    end
end

local function ParseFishWeightNumber(val)
    if not val then return 0 end
    if type(val) == "number" then return val end
    local str = tostring(val):gsub(",", ""):upper()
    local num = tonumber(str:match("[%d%.]+")) or 0
    if str:find("B") then
        num = num * 1000000000
    elseif str:find("M") then
        num = num * 1000000
    elseif str:find("K") then
        num = num * 1000
    end
    return num
end

ticketQuestState = {
    active = false,
    currentQuestType = "none", -- "fish_15m", "bait_100", "skill_100", "fish_100", "none"
    currentQuestTitle = "Chưa nhận nhiệm vụ",
    currentProgress = 0,
    targetProgress = 100,
    isCompleted = false,
    isCooldown = false,
    cooldownEnd = 0,
    lastAcceptTime = 0,
    lastClaimTime = 0,
    lastNpcInteract = 0,
    lastSyncTime = 0,
    lastBaitBuy = 0,
    lastBaitEquip = 0,
    isBusyRoutine = false,
    isAtHomeSpot = false,
    statusText = "Đang chờ bật tự động làm vé...",
    
    -- Vị trí mặc định
    spot100Fish = Vector3.new(-200.7, 11.1, 35.9), -- Map 1 (100 con cá)
    spot100Bait = Vector3.new(-200.7, 11.1, 35.9), -- Map 1 (100 mồi)
    spot15MFish = Vector3.new(1393.5, 11.3, 169.6), -- Map 9 (1.5M cá)
    spotNPC = Vector3.new(-200.7, 11.1, 35.9), -- Map 1 NPC Ticket Quest
    
    -- UI rows
    uiStatus = nil,
    uiProgress = nil,
    uiCooldown = nil,
    ui100Spot = nil,
    ui100BaitSpot = nil,
    ui15MSpot = nil,
    uiNPCSpot = nil,
}

function ticketQuestState.SaveSpots()
    if not writefile then return end
    pcall(function()
        local data = {
            spot100Fish = {x = ticketQuestState.spot100Fish.X, y = ticketQuestState.spot100Fish.Y, z = ticketQuestState.spot100Fish.Z},
            spot100Bait = {x = ticketQuestState.spot100Bait.X, y = ticketQuestState.spot100Bait.Y, z = ticketQuestState.spot100Bait.Z},
            spot15MFish = {x = ticketQuestState.spot15MFish.X, y = ticketQuestState.spot15MFish.Y, z = ticketQuestState.spot15MFish.Z},
            spotNPC = {x = ticketQuestState.spotNPC.X, y = ticketQuestState.spotNPC.Y, z = ticketQuestState.spotNPC.Z},
            cooldownEnd = ticketQuestState.cooldownEnd,
        }
        writefile("heavyweight_ticket_spots.json", HttpService:JSONEncode(data))
    end)
end

function ticketQuestState.LoadSpots()
    if not readfile or not isfile or not isfile("heavyweight_ticket_spots.json") then return end
    pcall(function()
        local content = readfile("heavyweight_ticket_spots.json")
        if content and #content > 0 then
            local dec = HttpService:JSONDecode(content)
            if type(dec) == "table" then
                if dec.spot100Fish and dec.spot100Fish.x then
                    ticketQuestState.spot100Fish = Vector3.new(dec.spot100Fish.x, dec.spot100Fish.y, dec.spot100Fish.z)
                end
                if dec.spot100Bait and dec.spot100Bait.x then
                    ticketQuestState.spot100Bait = Vector3.new(dec.spot100Bait.x, dec.spot100Bait.y, dec.spot100Bait.z)
                end
                if dec.spot15MFish and dec.spot15MFish.x then
                    ticketQuestState.spot15MFish = Vector3.new(dec.spot15MFish.x, dec.spot15MFish.y, dec.spot15MFish.z)
                end
                if dec.spotNPC and dec.spotNPC.x then
                    ticketQuestState.spotNPC = Vector3.new(dec.spotNPC.x, dec.spotNPC.y, dec.spotNPC.z)
                end
                if dec.cooldownEnd and tonumber(dec.cooldownEnd) and dec.cooldownEnd > tick() then
                    ticketQuestState.cooldownEnd = dec.cooldownEnd
                    ticketQuestState.isCooldown = true
                end
            end
        end
    end)
end

function ticketQuestState.UpdateUI()
    if ticketQuestState.uiStatus and ticketQuestState.uiStatus.Set then
        ticketQuestState.uiStatus.Set(ticketQuestState.statusText or "Đang chạy...")
    end
    if ticketQuestState.uiProgress and ticketQuestState.uiProgress.Set then
        local maxVal = ticketQuestState.targetProgress > 0 and ticketQuestState.targetProgress or 100
        local pct = math.min(100, math.floor((ticketQuestState.currentProgress / maxVal) * 100))
        ticketQuestState.uiProgress.Set(string.format("%d / %d (%d%%)", ticketQuestState.currentProgress, maxVal, pct))
    end
    if ticketQuestState.uiCooldown and ticketQuestState.uiCooldown.Set then
        if ticketQuestState.isCooldown then
            local remain = math.max(0, math.floor(ticketQuestState.cooldownEnd - tick()))
            local mins = math.floor(remain / 60)
            local secs = remain % 60
            local homeStr = ""
            if ticketQuestState.isAtHomeSpot then
                homeStr = " (Đang farm Home Spot)"
            end
            ticketQuestState.uiCooldown.Set(string.format("Chờ 20p: %02d:%02d%s", mins, secs, homeStr))
        else
            ticketQuestState.uiCooldown.Set("Sẵn sàng nhận vé!")
        end
    end
    if ticketQuestState.ui100Spot and ticketQuestState.ui100Spot.Set then
        local p = ticketQuestState.spot100Fish
        ticketQuestState.ui100Spot.Set(string.format("(%.0f, %.0f, %.0f)", p.X, p.Y, p.Z))
    end
    if ticketQuestState.ui100BaitSpot and ticketQuestState.ui100BaitSpot.Set then
        local p = ticketQuestState.spot100Bait
        ticketQuestState.ui100BaitSpot.Set(string.format("(%.0f, %.0f, %.0f)", p.X, p.Y, p.Z))
    end
    if ticketQuestState.ui15MSpot and ticketQuestState.ui15MSpot.Set then
        local p = ticketQuestState.spot15MFish
        ticketQuestState.ui15MSpot.Set(string.format("(%.0f, %.0f, %.0f)", p.X, p.Y, p.Z))
    end
    if ticketQuestState.uiNPCSpot and ticketQuestState.uiNPCSpot.Set then
        local p = ticketQuestState.spotNPC
        ticketQuestState.uiNPCSpot.Set(string.format("(%.0f, %.0f, %.0f)", p.X, p.Y, p.Z))
    end
end

function ticketQuestState.FindTicketNPC()
    local candidates = {}
    for _, fName in ipairs({"NPC", "NPCs", "Entities", "Characters", "Spawns", "Map", "Islands", "Workspace"}) do
        local folder = (fName == "Workspace") and Workspace or Workspace:FindFirstChild(fName)
        if folder then table.insert(candidates, folder) end
    end

    -- 1. Quét tìm qua BillboardGui "Ticket Quest" hoặc Model có tên Ticket/Giver
    for _, folder in ipairs(candidates) do
        for _, inst in ipairs(folder:GetDescendants()) do
            if inst:IsA("BillboardGui") then
                local bName = inst.Name:lower()
                local isTicket = bName:find("ticket")
                if not isTicket then
                    for _, l in ipairs(inst:GetDescendants()) do
                        if l:IsA("TextLabel") and l.Text:lower():find("ticket") then
                            isTicket = true
                            break
                        end
                    end
                end
                if isTicket then
                    local model = inst:FindFirstAncestorOfClass("Model") or inst.Parent
                    local pos = (model:IsA("Model") and model:GetPivot().Position) or (model:IsA("BasePart") and model.Position)
                    local p = model and model:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if model and pos then
                        ticketQuestState.spotNPC = pos
                        return model, pos, p
                    end
                end
            elseif inst:IsA("Model") then
                local n = inst.Name:lower()
                if n:find("ticket") and (n:find("quest") or n:find("npc") or n:find("ve") or n:find("giver")) then
                    local cf = inst:GetPivot()
                    local p = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
                    ticketQuestState.spotNPC = cf.Position
                    return inst, cf.Position, p
                end
            elseif inst:IsA("ProximityPrompt") then
                local act = tostring(inst.ActionText or ""):lower()
                local obj = tostring(inst.ObjectText or ""):lower()
                local pName = inst.Parent and inst.Parent.Name:lower() or ""
                if (act:find("ticket") or obj:find("ticket") or pName:find("ticket")) or (act:find("talk") and (obj:find("ticket") or pName:find("ticket") or pName:find("giver"))) then
                    local pPos = inst.Parent:IsA("BasePart") and inst.Parent.Position or inst.Parent:GetPivot().Position
                    local model = inst:FindFirstAncestorOfClass("Model") or inst.Parent
                    ticketQuestState.spotNPC = pPos
                    return model, pPos, inst
                end
            end
        end
    end

    -- 2. Quét tìm ProximityPrompt trong bán kính 30 studs quanh spotNPC
    if ticketQuestState.spotNPC then
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local pPos = (p.Parent:IsA("BasePart") and p.Parent.Position) or (p.Parent:IsA("Model") and p.Parent:GetPivot().Position)
                if pPos and (pPos - ticketQuestState.spotNPC).Magnitude <= 30 then
                    local model = p:FindFirstAncestorOfClass("Model") or p.Parent
                    return model, pPos, p
                end
            end
        end
    end

    return nil, ticketQuestState.spotNPC, nil
end

function ticketQuestState.CheckNPCReady()
    local npcModel, npcPos, prompt = ticketQuestState.FindTicketNPC()
    if not npcModel and not prompt and not ticketQuestState.spotNPC then return false end

    -- 1. Kiểm tra trong prompt của NPC
    if prompt then
        local act = tostring(prompt.ActionText or "")
        local obj = tostring(prompt.ObjectText or "")
        if act:find("%?") or obj:find("%?") then
            return true
        end
    end

    -- 2. Kiểm tra các BillboardGui, TextLabel, Decal, SurfaceGui gắn trên đầu NPC
    local targetInst = npcModel or (prompt and prompt.Parent)
    if not targetInst and ticketQuestState.spotNPC then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") and obj.Enabled then
                local parentPos = (obj.Parent:IsA("BasePart") and obj.Parent.Position) or (obj.Parent:IsA("Model") and obj.Parent:GetPivot().Position)
                if parentPos and (parentPos - ticketQuestState.spotNPC).Magnitude <= 15 then
                    targetInst = obj.Parent
                    break
                end
            end
        end
    end

    if targetInst then
        for _, d in ipairs(targetInst:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible then
                local txt = tostring(d.Text or "")
                if txt:find("%?") then
                    return true
                end
            elseif d:IsA("BillboardGui") and d.Enabled then
                for _, sub in ipairs(d:GetDescendants()) do
                    if sub:IsA("TextLabel") and sub.Visible and tostring(sub.Text or ""):find("%?") then
                        return true
                    end
                end
            elseif d:IsA("Decal") or d:IsA("Texture") then
                local n = d.Name:lower()
                local tex = tostring(d.Texture or ""):lower()
                if n:find("question") or tex:find("question") or tex:find("%?") then
                    return true
                end
            elseif d:IsA("MeshPart") or d:IsA("Part") then
                local n = d.Name:lower()
                if n == "?" or n:find("question") then
                    return true
                end
            end
        end
    end

    return false
end

function ticketQuestState.TeleportTo(pos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and pos then
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait(0.3)
    end
end

-- Hàm tìm và click nút UI theo điều kiện hàm kiểm tra text
function ticketQuestState.FindAndClickButton(predicate)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end

    for _, inst in ipairs(pg:GetDescendants()) do
        if inst:IsA("GuiButton") or inst:IsA("TextLabel") then
            local isVis = true
            pcall(function()
                if inst:IsA("GuiObject") and not inst.Visible then isVis = false end
            end)
            if isVis then
                local txt = ""
                if inst:IsA("TextButton") or inst:IsA("TextLabel") then
                    txt = tostring(inst.Text or "")
                end
                -- Làm sạch chuỗi: bỏ dấu hoa thị, ký tự đặc biệt, chuẩn hóa khoảng trắng
                local cleanTxt = txt:lower():gsub("%*", ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
                if predicate(cleanTxt) then
                    local targetBtn = inst:IsA("GuiButton") and inst or inst:FindFirstAncestorWhichIsA("GuiButton") or inst.Parent
                    if targetBtn and (targetBtn:IsA("GuiButton") or targetBtn:IsA("TextButton") or targetBtn:IsA("ImageButton")) then
                        pcall(function()
                            if firesignal then
                                if targetBtn.Activated then firesignal(targetBtn.Activated) end
                                if targetBtn.MouseButton1Click then firesignal(targetBtn.MouseButton1Click) end
                                if targetBtn.MouseButton1Down then firesignal(targetBtn.MouseButton1Down) end
                                if targetBtn.MouseButton1Up then firesignal(targetBtn.MouseButton1Up) end
                            end
                        end)
                        pcall(function()
                            if getconnections then
                                if targetBtn.Activated then
                                    for _, c in ipairs(getconnections(targetBtn.Activated)) do c:Fire() end
                                end
                                if targetBtn.MouseButton1Click then
                                    for _, c in ipairs(getconnections(targetBtn.MouseButton1Click)) do c:Fire() end
                                end
                            end
                        end)
                        pcall(function()
                            local vim = game:GetService("VirtualInputManager")
                            if vim and targetBtn.AbsolutePosition and targetBtn.AbsoluteSize then
                                local pos = targetBtn.AbsolutePosition + targetBtn.AbsoluteSize / 2
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                            end
                        end)
                        return true
                    end
                end
            end
        end
    end
    return false
end

function ticketQuestState.InteractNPC(isClaiming)
    local isHard = (Config.TicketDifficulty or "Hard") == "Hard"
    local diffKeyword = isHard and "hard" or "easy"

    -- 1. Nếu bảng hội thoại NPC đã mở sẵn trước mặt (người dùng tự bấm E):
    if isClaiming then
        -- Trả vé: Tìm nút "*Leave*" (ảnh trả nhiệm vụ)
        if ticketQuestState.FindAndClickButton(function(t) return t:find("leave") or t:find("claim") or t:find("xong") end) then
            ShowNotification("Nhiệm Vụ Vé", "Đã bấm *Leave* nộp nhiệm vụ & nhận thưởng thành công!", "SUCCESS", 5)
            return true
        end
    else
        -- Nhận vé:
        -- Kiểm tra nếu đã ở Bước 2 (bảng đã có nút "Accept Hard Quest"):
        local clickedDiff = ticketQuestState.FindAndClickButton(function(t)
            return (t:find(diffKeyword) and (t:find("quest") or t:find("accept"))) or t == ("accept " .. diffKeyword .. " quest")
        end)
        if clickedDiff then
            ShowNotification("Nhiệm Vụ Vé", "Đã nhận thành công nhiệm vụ " .. (isHard and "Hard" or "Easy") .. " Ticket!", "SUCCESS", 5)
            return true
        end

        -- Kiểm tra nếu đang ở Bước 1 (bảng có nút "Quest" và "Nevermind"):
        local clickedQuest = ticketQuestState.FindAndClickButton(function(t)
            return (t == "quest" or t:find("^quest")) and not t:find("nevermind") and not t:find("huy")
        end)
        if clickedQuest then
            task.wait(0.35)
            local clickedStep2 = ticketQuestState.FindAndClickButton(function(t)
                return (t:find(diffKeyword) and (t:find("quest") or t:find("accept"))) or t == ("accept " .. diffKeyword .. " quest")
            end)
            if clickedStep2 then
                ShowNotification("Nhiệm Vụ Vé", "Đã nhận thành công nhiệm vụ " .. (isHard and "Hard" or "Easy") .. " Ticket!", "SUCCESS", 5)
                return true
            end
        end
    end

    -- 2. Nếu hội thoại chưa mở -> Di chuyển lại gần NPC nếu đang ở xa (> 12 studs)
    local npcModel, npcPos, prompt = ticketQuestState.FindTicketNPC()
    local targetPos = npcPos or ticketQuestState.spotNPC

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and targetPos then
        local dist = (root.Position - targetPos).Magnitude
        if dist > 12 then
            ticketQuestState.TeleportTo(targetPos)
            task.wait(0.35)
        end
    end

    -- 3. Cập nhật lại prompt sau khi tới gần NPC
    if not prompt then
        local _, _, freshPrompt = ticketQuestState.FindTicketNPC()
        prompt = freshPrompt
    end
    if not prompt and targetPos then
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local pPos = (p.Parent:IsA("BasePart") and p.Parent.Position) or (p.Parent:IsA("Model") and p.Parent:GetPivot().Position)
                if pPos and (pPos - targetPos).Magnitude <= 20 then
                    prompt = p
                    break
                end
            end
        end
    end

    -- 4. Kích hoạt ProximityPrompt [E] Talk
    if prompt then
        TriggerPrompt(prompt)
    else
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            if vim then
                vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end)
    end

    -- 5. Đợi bảng hội thoại xuất hiện và tự động thực hiện đúng quy trình theo ảnh
    local success = false
    local t0 = tick()

    if isClaiming then
        -- Quy trình TRẢ nhiệm vụ: Chờ nút "*Leave*" xuất hiện và click (ảnh 3)
        while (tick() - t0) < 3.0 do
            task.wait(0.2)
            if ticketQuestState.FindAndClickButton(function(t) return t:find("leave") or t:find("claim") or t:find("xong") end) then
                success = true
                break
            end
        end
    else
        -- Quy trình NHẬN nhiệm vụ (2 bước chuẩn 100% theo ảnh của bạn):
        -- Bước 5A: Chờ bảng hiện ra và bấm nút "Quest" (ảnh 1)
        while (tick() - t0) < 3.0 do
            task.wait(0.2)
            -- Nếu bảng đã mở sẵn ở bước 2 thì bấm nút chọn độ khó ngay
            if ticketQuestState.FindAndClickButton(function(t)
                return (t:find(diffKeyword) and (t:find("quest") or t:find("accept"))) or t == ("accept " .. diffKeyword .. " quest")
            end) then
                success = true
                break
            end

            -- Nếu ở bước 1: Bấm nút "Quest"
            if ticketQuestState.FindAndClickButton(function(t)
                return (t == "quest" or t:find("^quest")) and not t:find("nevermind") and not t:find("huy")
            end) then
                -- Bước 5B: Chờ bảng hội thoại chuyển trang sang "Accept Hard Quest" (ảnh 2)
                local t1 = tick()
                while (tick() - t1) < 2.5 do
                    task.wait(0.2)
                    if ticketQuestState.FindAndClickButton(function(t)
                        return (t:find(diffKeyword) and (t:find("quest") or t:find("accept"))) or t == ("accept " .. diffKeyword .. " quest")
                    end) then
                        success = true
                        break
                    end
                end
                break
            end
        end
    end

    -- Fallback RemoteEvent nếu game có hỗ trợ ngầm
    if Events and Events:FindFirstChild("ClaimQuest") then
        pcall(function() Events.ClaimQuest:FireServer("Ticket", Config.TicketDifficulty or "Hard") end)
    end

    if success then
        if isClaiming then
            ShowNotification("Nhiệm Vụ Vé", "Đã bấm *Leave* nộp nhiệm vụ & nhận thưởng thành công!", "SUCCESS", 5)
        else
            ShowNotification("Nhiệm Vụ Vé", "Đã nhận thành công nhiệm vụ " .. (isHard and "Hard" or "Easy") .. " Ticket!", "SUCCESS", 5)
        end
    else
        ShowNotification("Nhiệm Vụ Vé", "Đã tương tác với NPC " .. (isClaiming and "để nộp vé" or "để nhận vé") .. "!", "INFO", 4)
    end

    return success
end

function ticketQuestState.DetectActiveQuest()
    local detectedType = nil
    local detectedTitle = nil
    local detectedCur = 0
    local detectedMax = 0
    local isDone = false
    local detectedCooldownSec = nil

    -- 0. Hàm tiện ích làm sạch text (xóa thẻ rich text HTML/XML)
    local function cleanStr(s)
        if not s then return "" end
        local res = tostring(s):gsub("<[^>]->", "")
        return res:gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
    end

    -- 1. Ưu tiên chế độ người dùng chọn thủ công nếu không chọn Auto Detect
    local mode = Config.TicketQuestMode or "Tự Động (Auto Detect)"
    if mode == "Câu 10 Con Cá 1.5M+ (Map 9)" then
        detectedType = "fish_15m"
        detectedTitle = "Câu 10 con cá >= 1.5M (Map 9)"
        detectedMax = 10
    elseif mode == "Tiêu Thụ 100 Mồi (Map 1)" then
        detectedType = "bait_100"
        detectedTitle = "Tiêu thụ 100 mồi câu (Map 1)"
        detectedMax = 100
    elseif mode == "Dùng Kỹ Năng 100 Lần" then
        detectedType = "skill_100"
        detectedTitle = "Dùng kỹ năng 100 lần"
        detectedMax = 100
    elseif mode == "Câu Nhanh 100 Con Cá (Map 1)" then
        detectedType = "fish_100"
        detectedTitle = "Câu nhanh 100 con cá (Map 1)"
        detectedMax = 100
    end

    -- 2. Quét PlayerGui (Kể cả khi khung Quest đang đóng/ẩn)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        -- 2A. Quét chính xác cấu trúc Thẻ "Hard Ticket Quest" như trong ảnh người dùng gửi
        for _, lbl in ipairs(pg:GetDescendants()) do
            if lbl:IsA("TextLabel") or lbl:IsA("TextButton") then
                local txt = cleanStr(lbl.Text)
                local lower = txt:lower()

                if lower:find("hard ticket quest") or (lower:find("ticket") and lower:find("quest")) then
                    -- Quét mô tả ngay trong chính nhãn này nếu có
                    local c, m = txt:match("(%d+)%s*/%s*(%d+)")
                    if c and m then
                        detectedCur = tonumber(c) or 0
                        detectedMax = tonumber(m) or 0
                        if detectedCur >= detectedMax and detectedMax > 0 then isDone = true end
                        detectedTitle = txt
                    end

                    -- Quét các nhãn con/anh em trong cùng khung thẻ (Card Frame)
                    local card = lbl.Parent
                    if card then
                        for _, sibling in ipairs(card:GetDescendants()) do
                            if (sibling:IsA("TextLabel") or sibling:IsA("TextButton")) and sibling ~= lbl then
                                local subTxt = cleanStr(sibling.Text)
                                local subLower = subTxt:lower()

                                local sc, sm = subTxt:match("(%d+)%s*/%s*(%d+)")
                                if sc and sm then
                                    detectedCur = tonumber(sc) or 0
                                    detectedMax = tonumber(sm) or 0
                                    if detectedCur >= detectedMax and detectedMax > 0 then isDone = true end
                                    detectedTitle = subTxt

                                    -- Phân loại quest theo nội dung text trong ảnh
                                    if subLower:find("skill") or subLower:find("chiêu") or subLower:find("kỹ năng") then
                                        detectedType = "skill_100"
                                    elseif subLower:find("bait") or subLower:find("mồi") then
                                        detectedType = "bait_100"
                                    elseif subLower:find("1.5") or subLower:find("1,500") or subLower:find("1500") or subLower:find("heavy") then
                                        detectedType = "fish_15m"
                                    elseif subLower:find("fish") or subLower:find("cá") or subLower:find("catch") or subLower:find("bắt") then
                                        detectedType = "fish_100"
                                    else
                                        if detectedMax == 10 then
                                            detectedType = "fish_15m"
                                        else
                                            detectedType = "fish_100"
                                        end
                                    end
                                    break
                                end
                            end
                        end
                    end

                    if detectedType then break end
                end
            end
        end

        -- 2B. Quét theo cụm Container (Frames/Billboard/ScreenGui) chứa từ khóa Quest/Ticket (Kể cả khi đóng)
        if not detectedType then
            local questContainers = {}
            for _, obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("GuiObject") or obj:IsA("ScreenGui") or obj:IsA("BillboardGui") then
                    local oName = obj.Name:lower()
                    if oName:find("ticket") or oName:find("quest") or oName:find("task") or oName:find("mission") then
                        table.insert(questContainers, obj)
                    end
                end
            end

            for _, container in ipairs(questContainers) do
                local combinedText = ""
                local containerCur = 0
                local containerMax = 0
                local containerDone = false

                for _, d in ipairs(container:GetDescendants()) do
                    if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                        local raw = cleanStr(d.Text)
                        if #raw > 0 then
                            combinedText = combinedText .. " " .. raw

                            local c, m = raw:match("(%d+)%s*/%s*(%d+)")
                            if c and m then
                                local cN = tonumber(c) or 0
                                local mN = tonumber(m) or 0
                                if mN > 0 and (containerMax == 0 or mN >= containerMax) then
                                    containerCur = cN
                                    containerMax = mN
                                    if cN >= mN then containerDone = true end
                                end
                            end

                            local lowD = raw:lower()
                            if lowD:find("claim") or lowD:find("completed") or lowD:find("hoàn thành") then
                                containerDone = true
                            end
                        end
                    end
                end

                local lowComb = combinedText:lower()
                if #lowComb > 0 and (lowComb:find("ticket") or lowComb:find("hard") or containerMax == 10 or containerMax == 100) then
                    -- Kiểm tra thời gian hồi chiêu
                    if lowComb:find("cooldown") or lowComb:find("wait") or lowComb:find("chờ") or lowComb:find("next") then
                        local m, s = combinedText:match("(%d+)%s*:%s*(%d+)")
                        if m and s then
                            local total = (tonumber(m) or 0) * 60 + (tonumber(s) or 0)
                            if total > 0 and total <= 1800 then detectedCooldownSec = total end
                        end
                    end

                    if not detectedType or mode == "Tự Động (Auto Detect)" then
                        if lowComb:find("1.5") or lowComb:find("1,500,000") or lowComb:find("1500000") or lowComb:find("heavy") or containerMax == 10 then
                            detectedType = "fish_15m"
                            detectedTitle = "Câu 10 con cá >= 1.5M (Map 9)"
                            if containerMax == 0 then containerMax = 10 end
                        elseif lowComb:find("bait") or lowComb:find("mồi") then
                            detectedType = "bait_100"
                            detectedTitle = "Tiêu thụ 100 mồi câu (Map 1)"
                            if containerMax == 0 then containerMax = 100 end
                        elseif lowComb:find("skill") or lowComb:find("chiêu") or lowComb:find("kỹ năng") then
                            detectedType = "skill_100"
                            detectedTitle = "Dùng kỹ năng 100 lần"
                            if containerMax == 0 then containerMax = 100 end
                        elseif (lowComb:find("fish") or lowComb:find("cá") or lowComb:find("catch") or lowComb:find("bắt")) or containerMax == 100 then
                            detectedType = "fish_100"
                            detectedTitle = "Câu nhanh 100 con cá (Map 1)"
                            if containerMax == 0 then containerMax = 100 end
                        elseif containerMax > 0 then
                            detectedType = "fish_100"
                            detectedTitle = "Nhiệm Vụ Vé (" .. containerMax .. ")"
                        end
                    end

                    if containerCur > detectedCur then detectedCur = containerCur end
                    if containerMax > detectedMax then detectedMax = containerMax end
                    if containerDone then isDone = true end
                    if detectedType then break end
                end
            end
        end

        -- 2C. Quét toàn bộ TextLabel đơn lẻ (Không phân biệt ẩn/hiện)
        if not detectedType then
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    local txt = cleanStr(d.Text)
                    if #txt > 0 then
                        local lower = txt:lower()

                        -- Quét Cooldown từ text
                        if (lower:find("ticket") or lower:find("quest")) and (lower:find("cooldown") or lower:find("wait") or lower:find("chờ")) then
                            local m, s = txt:match("(%d+)%s*:%s*(%d+)")
                            if m and s then
                                local total = (tonumber(m) or 0) * 60 + (tonumber(s) or 0)
                                if total > 0 and total <= 1800 then detectedCooldownSec = total end
                            end
                        end

                        local cur, max = txt:match("(%d+)%s*/%s*(%d+)")
                        if cur and max then
                            local cNum = tonumber(cur) or 0
                            local mNum = tonumber(max) or 0
                            if mNum == 10 or mNum == 100 then
                                if mNum == 10 then
                                    detectedType = "fish_15m"
                                    detectedTitle = "Câu 10 con cá >= 1.5M (Map 9)"
                                    detectedMax = 10
                                elseif mNum == 100 then
                                    if lower:find("skill") or lower:find("chiêu") or lower:find("kỹ năng") then
                                        detectedType = "skill_100"
                                        detectedTitle = "Dùng kỹ năng 100 lần"
                                    elseif lower:find("bait") or lower:find("mồi") then
                                        detectedType = "bait_100"
                                        detectedTitle = "Tiêu thụ 100 mồi câu (Map 1)"
                                    else
                                        detectedType = "fish_100"
                                        detectedTitle = "Câu nhanh 100 con cá (Map 1)"
                                    end
                                    detectedMax = 100
                                end

                                if cNum > detectedCur then detectedCur = cNum end
                                if mNum > detectedMax then detectedMax = mNum end
                                if cNum >= mNum and mNum > 0 then isDone = true end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- 3. Quét pData & LocalPlayer Attributes làm fallback
    for attrName, attrVal in pairs(LocalPlayer:GetAttributes()) do
        local n = tostring(attrName):lower()
        local v = tostring(attrVal):lower()
        if n:find("ticket") or n:find("quest") or v:find("ticket") or v:find("quest") then
            if not detectedType then
                if v:find("skill") or n:find("skill") then
                    detectedType = "skill_100"
                    detectedTitle = "Dùng kỹ năng 100 lần"
                    detectedMax = 100
                elseif v:find("1.5") or n:find("1.5") then
                    detectedType = "fish_15m"
                    detectedTitle = "Câu 10 con cá >= 1.5M (Map 9)"
                    detectedMax = 10
                elseif v:find("bait") or n:find("bait") then
                    detectedType = "bait_100"
                    detectedTitle = "Tiêu thụ 100 mồi câu (Map 1)"
                    detectedMax = 100
                elseif v:find("fish") or n:find("fish") then
                    detectedType = "fish_100"
                    detectedTitle = "Câu nhanh 100 con cá (Map 1)"
                    detectedMax = 100
                end
            end
        end
        if n:find("progress") or n:find("ticketcur") then
            local num = tonumber(attrVal)
            if num and num > detectedCur then detectedCur = num end
        end
        if n:find("ticketmax") or n:find("target") then
            local num = tonumber(attrVal)
            if num and num > detectedMax then detectedMax = num end
        end
    end

    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData then
        local cdVal = pData:FindFirstChild("TicketCooldown") or pData:FindFirstChild("QuestCooldown")
            or (pData:FindFirstChild("Cooldowns") and pData.Cooldowns:FindFirstChild("Ticket"))
        if cdVal and (cdVal:IsA("IntValue") or cdVal:IsA("NumberValue")) then
            local v = cdVal.Value
            if v > tick() then
                detectedCooldownSec = math.floor(v - tick())
            elseif v > 0 and v <= 1800 then
                detectedCooldownSec = math.floor(v)
            end
        end

        if not detectedType then
            local qFolder = pData:FindFirstChild("TicketQuest") or pData:FindFirstChild("Quest") or pData:FindFirstChild("Quests") or pData:FindFirstChild("Ticket")
            if qFolder then
                for _, item in ipairs(qFolder:GetChildren()) do
                    local n = item.Name:lower()
                    local valStr = item:IsA("StringValue") and item.Value:lower() or ""
                    if n:find("skill") or valStr:find("skill") or n:find("100skill") then
                        detectedType = "skill_100"
                        detectedTitle = "Dùng kỹ năng 100 lần"
                        detectedMax = 100
                        break
                    elseif n:find("1.5") or valStr:find("1.5") or n:find("fish_15") then
                        detectedType = "fish_15m"
                        detectedTitle = "Câu 10 con cá >= 1.5M (Map 9)"
                        detectedMax = 10
                        break
                    elseif n:find("bait") or valStr:find("bait") or n:find("100bait") then
                        detectedType = "bait_100"
                        detectedTitle = "Tiêu thụ 100 mồi câu (Map 1)"
                        detectedMax = 100
                        break
                    elseif n:find("catch") or n:find("fish") or valStr:find("fish") then
                        detectedType = "fish_100"
                        detectedTitle = "Câu nhanh 100 con cá (Map 1)"
                        detectedMax = 100
                        break
                    end
                end
            end
        end

        if not detectedCur or detectedCur == 0 then
            local qFolder = pData:FindFirstChild("TicketQuest") or pData:FindFirstChild("Quest") or pData:FindFirstChild("Quests") or pData:FindFirstChild("Ticket")
            if qFolder then
                for _, item in ipairs(qFolder:GetChildren()) do
                    local name = item.Name:lower()
                    if item:IsA("IntValue") or item:IsA("NumberValue") then
                        if name:find("progress") or name:find("current") or name:find("count") then
                            if item.Value > detectedCur then detectedCur = item.Value end
                        elseif name:find("target") or name:find("max") or name:find("total") then
                            if detectedMax == 0 then detectedMax = item.Value end
                        end
                    end
                end
            end
        end
    end

    -- 4. Chốt Target Max mặc định nếu nhận diện được type nhưng chưa rõ max
    if detectedType and detectedMax == 0 then
        detectedMax = (detectedType == "fish_15m") and 10 or 100
    end
    if detectedMax > 0 and detectedCur >= detectedMax then
        isDone = true
    end

    return detectedType, detectedTitle, detectedCur, detectedMax, isDone, detectedCooldownSec
end

function ticketQuestState.ResetCooldown()
    ticketQuestState.isCooldown = false
    ticketQuestState.cooldownEnd = 0
    ticketQuestState.isCompleted = false
    ticketQuestState.isAtHomeSpot = false
    ticketQuestState.currentProgress = 0
    ticketQuestState.currentQuestType = "none"
    ticketQuestState.statusText = "Đã đặt lại! Sẵn sàng nhận vé mới."
    ticketQuestState.SaveSpots()
    ticketQuestState.UpdateUI()
    ShowNotification("Nhiệm Vụ Vé", "Đã xóa hồi chiêu và đặt lại bộ đếm!", "SUCCESS", 5)
end

function ticketQuestState.Tick()
    if not Config.AutoTicketQuest then return end
    local now = tick()

    -- 0. Kiểm tra xem NPC Ticket Quest đã hồi (hiện dấu ? trên đầu hoặc trong prompt)
    local isNPCReady = ticketQuestState.CheckNPCReady()

    -- 0.1 Quét trạng thái nhiệm vụ và Cooldown hiện tại từ game
    local qType, qTitle, cur, max, done, detectedCd = ticketQuestState.DetectActiveQuest()

    -- Đồng bộ thời gian hồi chiêu thực tế của game nếu phát hiện nhãn thời gian từ server
    if detectedCd and detectedCd > 0 and not isNPCReady then
        if not ticketQuestState.isCooldown or math.abs((now + detectedCd) - ticketQuestState.cooldownEnd) > 5 then
            ticketQuestState.isCooldown = true
            ticketQuestState.cooldownEnd = now + detectedCd
        end
    end

    -- 1. Cooldown (Đang trong thời gian chờ nhận vé mới)
    if ticketQuestState.isCooldown then
        if isNPCReady then
            ticketQuestState.isCooldown = false
            ticketQuestState.isAtHomeSpot = false
            ticketQuestState.currentQuestType = "none"
            ticketQuestState.currentProgress = 0
            ticketQuestState.isCompleted = false
            ticketQuestState.statusText = "NPC đã xuất hiện dấu (?)! Đang tiến đến nhận vé..."
            ticketQuestState.UpdateUI()
        else
            local remain = math.max(0, math.floor(ticketQuestState.cooldownEnd - now))
            if remain > 0 then
                local mins = math.floor(remain / 60)
                local secs = remain % 60
                ticketQuestState.statusText = string.format("Đang chờ hồi chiêu vé (còn %02d:%02d)", mins, secs)

                -- Về Home Spot câu cá trong thời gian chờ hồi chiêu
                if Config.TicketReturnHomeWhenDone and Config.HomeFarmSpot and not ticketQuestState.isAtHomeSpot then
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local homeCf = nil
                        if Config.HomeFarmSpot.cframe and #Config.HomeFarmSpot.cframe == 12 then
                            homeCf = CFrame.new(table.unpack(Config.HomeFarmSpot.cframe))
                        elseif Config.HomeFarmSpot.x and Config.HomeFarmSpot.y and Config.HomeFarmSpot.z then
                            homeCf = CFrame.new(Config.HomeFarmSpot.x, Config.HomeFarmSpot.y, Config.HomeFarmSpot.z)
                        end
                        if homeCf then
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
                            wp.CFrame = CFrame.new(homeCf.Position.X, homeCf.Position.Y - 2.8, homeCf.Position.Z)
                            wp.CanCollide = true
                            root.CFrame = homeCf + Vector3.new(0, 1.5, 0)
                            task.wait(0.2)
                            root.CFrame = homeCf
                            ticketQuestState.isAtHomeSpot = true
                            ticketQuestState.statusText = string.format("Đang chờ hồi: đã về Home Spot farm combo (còn %02d:%02d)", mins, secs)
                            ShowNotification("Home Spot", "Đã về vị trí Home Spot để câu farm trong lúc chờ vé!", "SUCCESS", 5)

                            if Config.TicketAutoCastAtHome then
                                task.delay(1.0, function()
                                    if isRunning and ticketQuestState.isCooldown and ticketQuestState.isAtHomeSpot then
                                        CancelAndRecastRod()
                                    end
                                end)
                            end
                        end
                    end
                end

                ticketQuestState.UpdateUI()
                return -- DỪNG LẠI Ở ĐÂY, TUYỆT ĐỐI KHÔNG CHẠY XUỐNG NPC INTERACT!
            else
                ticketQuestState.isCooldown = false
                ticketQuestState.isAtHomeSpot = false
                ticketQuestState.statusText = "Hồi chiêu đã xong! Chuẩn bị nhận vé Hard mới..."
                ticketQuestState.currentQuestType = "none"
                ticketQuestState.currentProgress = 0
                ticketQuestState.isCompleted = false
                ticketQuestState.UpdateUI()
            end
        end
    end

    -- 2. Đã hoàn thành nhiệm vụ -> Trả vé tại NPC (từ xa hoặc chớp nhoáng)
    if ticketQuestState.isCompleted or done then
        ticketQuestState.statusText = "Đã xong nhiệm vụ! Đang nộp vé Hard..."
        ticketQuestState.UpdateUI()
        ticketQuestState.InteractNPC(true)
        task.wait(0.5)
        if Events and Events:FindFirstChild("ClaimQuest") then
            Events.ClaimQuest:FireServer("Ticket", Config.TicketDifficulty or "Hard")
        end

        local setCooldown = detectedCd and detectedCd > 0 and detectedCd or ((Config.TicketCooldownMinutes or 20) * 60)
        ticketQuestState.cooldownEnd = now + setCooldown
        ticketQuestState.isCooldown = true
        ticketQuestState.isCompleted = false
        ticketQuestState.isAtHomeSpot = false
        ticketQuestState.currentQuestType = "none"
        ticketQuestState.currentProgress = 0
        ticketQuestState.active = false
        ticketQuestState.SaveSpots()
        ticketQuestState.UpdateUI()
        ShowNotification("Nhiệm Vụ Vé", string.format("Đã nộp vé Hard! Đang chờ hồi chiêu (%d phút).", math.ceil(setCooldown / 60)), "SUCCESS", 8)
        return
    end

    -- 3. Cập nhật hoặc ghi nhớ Quest nếu đã nhận diện được từ game
    if qType then
        if ticketQuestState.currentQuestType ~= qType then
            ticketQuestState.currentQuestType = qType
            ticketQuestState.currentQuestTitle = qTitle or ticketQuestState.currentQuestTitle
            ticketQuestState.targetProgress = (max and max > 0) and max or (qType == "fish_15m" and 10 or 100)
            ticketQuestState.statusText = "Đang làm: " .. ticketQuestState.currentQuestTitle
            ticketQuestState.UpdateUI()
        end
    end

    if cur and cur > ticketQuestState.currentProgress then
        ticketQuestState.currentProgress = cur
    end
    if max and max > ticketQuestState.targetProgress then
        ticketQuestState.targetProgress = max
    end
    if ticketQuestState.targetProgress > 0 and ticketQuestState.currentProgress >= ticketQuestState.targetProgress then
        ticketQuestState.isCompleted = true
        ticketQuestState.UpdateUI()
    end

    -- 4. Chưa có quest nào (currentQuestType == "none") -> Đến NPC nhận vé (Giãn cách 10s tránh spam teleport)
    if ticketQuestState.currentQuestType == "none" then
        if now - ticketQuestState.lastNpcInteract >= 10.0 then
            ticketQuestState.lastNpcInteract = now
            ticketQuestState.statusText = "Đang tương tác NPC nhận vé Hard mới..."
            ticketQuestState.UpdateUI()
            ticketQuestState.InteractNPC(false)

            -- Quét lại sau khi nhận quest
            task.wait(1.0)
            local freshType, freshTitle, freshCur, freshMax, freshDone = ticketQuestState.DetectActiveQuest()
            if freshType then
                ticketQuestState.currentQuestType = freshType
                ticketQuestState.currentQuestTitle = freshTitle or "Nhiệm Vụ Vé"
                ticketQuestState.targetProgress = freshMax > 0 and freshMax or (freshType == "fish_15m" and 10 or 100)
                ticketQuestState.currentProgress = freshCur or 0
                ticketQuestState.active = true
                ticketQuestState.isAtHomeSpot = false
                ticketQuestState.statusText = "Đang làm: " .. ticketQuestState.currentQuestTitle
                ticketQuestState.UpdateUI()

                -- Dịch chuyển tới điểm câu nếu chưa đứng ở đó
                local targetSpot = ticketQuestState.spot100Fish
                if freshType == "fish_15m" then
                    targetSpot = ticketQuestState.spot15MFish
                elseif freshType == "bait_100" then
                    targetSpot = ticketQuestState.spot100Bait or ticketQuestState.spot100Fish
                end
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and targetSpot and (root.Position - targetSpot).Magnitude > 35 then
                    ticketQuestState.TeleportTo(targetSpot)
                end
            else
                ticketQuestState.statusText = "Đã gửi lệnh nhận vé, đang chờ hệ thống cập nhật nhiệm vụ..."
                ticketQuestState.UpdateUI()
            end
        end
        return
    end

    -- 5. Quest đang hoạt động (currentQuestType ~= "none") -> Ở YÊN TẠI ĐIỂM CÂU VÀ LÀM NHIỆM VỤ!
    ticketQuestState.active = true
    ticketQuestState.isAtHomeSpot = false

    -- Xác định vị trí câu tương ứng với loại nhiệm vụ hiện tại
    local targetSpot = ticketQuestState.spot100Fish
    if ticketQuestState.currentQuestType == "fish_15m" then
        targetSpot = ticketQuestState.spot15MFish
    elseif ticketQuestState.currentQuestType == "bait_100" then
        targetSpot = ticketQuestState.spot100Bait or ticketQuestState.spot100Fish
    end

    -- Nếu bị trôi xa khỏi vị trí câu quest (ví dụ đang ở NPC hoặc chỗ khác), bay về vị trí câu
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and targetSpot then
        local dist = (root.Position - targetSpot).Magnitude
        if dist > 35 then
            ticketQuestState.TeleportTo(targetSpot)
        end
    end

    -- Cập nhật giao diện định kỳ
    if now - (ticketQuestState.lastSyncTime or 0) >= 2.0 then
        ticketQuestState.lastSyncTime = now
        ticketQuestState.UpdateUI()
    end

    -- Tự bán cá nếu đầy balo
    if Config.TicketAutoSellFull then
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        if pData and pData:FindFirstChild("InventoryLimit") then
            local invCount = 0
            if pData:FindFirstChild("Inventory") then invCount = invCount + #pData.Inventory:GetChildren() end
            if invCount >= (pData.InventoryLimit.Value - 1) then
                if Events and Events:FindFirstChild("SellFish") then
                    ProtectAllInventoryItems(false)
                    Events.SellFish:FireServer("All")
                end
            end
        end
    end

    -- Nếu là quest 100 mồi: tự kiểm tra và mua mồi + trang bị mồi
    if ticketQuestState.currentQuestType == "bait_100" then
        local baitName = Config.TicketBaitChoice or "Basic Bait"
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        if pData and pData:FindFirstChild("Bait") then
            local bVal = pData.Bait:FindFirstChild(baitName)
            local bCount = bVal and bVal.Value or 0
            if bCount < 5 and (now - ticketQuestState.lastBaitBuy >= 2.0) then
                ticketQuestState.lastBaitBuy = now
                if Events and Events:FindFirstChild("BuyBait") then
                    Events.BuyBait:FireServer(baitName, 30)
                end
            end
            if pData:FindFirstChild("EquippedBait") and pData.EquippedBait.Value ~= baitName and (now - ticketQuestState.lastBaitEquip >= 2.0) then
                ticketQuestState.lastBaitEquip = now
                if Events and Events:FindFirstChild("EquipBait") then
                    Events.EquipBait:InvokeServer(baitName)
                end
            end
        end
    elseif ticketQuestState.currentQuestType == "fish_100" then
        -- Nhiệm vụ 100 con cá: Tuyệt đối không dùng mồi để tiết kiệm mồi (trang bị None nếu có)
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        if pData and pData:FindFirstChild("EquippedBait") and pData.EquippedBait.Value ~= "None" and (now - ticketQuestState.lastBaitEquip >= 2.0) then
            ticketQuestState.lastBaitEquip = now
            if Events and Events:FindFirstChild("EquipBait") then
                Events.EquipBait:InvokeServer("None")
            end
        end
    end
end

task.spawn(function()
    pcall(function() ticketQuestState.LoadSpots() end)
    while isRunning do
        task.wait(1.0)
        if Config.AutoTicketQuest then
            pcall(function()
                ticketQuestState.Tick()
            end)
        elseif ticketQuestState.uiCooldown and ticketQuestState.isCooldown then
            pcall(function()
                ticketQuestState.UpdateUI()
            end)
        end
    end
end)


local tabFishing   = CreateTab("Câu Cá")
local tabBoss      = CreateTab("Săn Boss")
local tabWiki      = CreateTab("Wiki")
local tabGod       = CreateTab("Thần Linh")
local tabQuests    = CreateTab("Nhiệm Vụ")
local tabShop      = CreateTab("Shop & Chế Mồi")
local tabTeleports = CreateTab("Dịch Chuyển")
local tabVisuals   = CreateTab("ESP & Đồ Hoạ")
local tabPlayer    = CreateTab("Nhân Vật")
local tabProfiles  = CreateTab("Cài Đặt")

SwitchTab("Câu Cá")


createCategoryHeader(tabFishing, "Thông Tin Tài Khoản & Thống Kê")
local statsCard = createCardGroup(tabFishing)
local infoEquippedRod = createInfoRow(statsCard, "Cần Đang Dùng", "Chưa có")
local infoEquippedBait = createInfoRow(statsCard, "Mồi Đang Dùng", "Chưa có")
local infoFishCaught = createInfoRow(statsCard, "Tổng Cá Đã Câu", "0 con")
local infoCash = createInfoRow(statsCard, "Tiền Hiện Tại", "$0")
local infoUptime = createInfoRow(statsCard, "Thời Gian Treo Máy", "00:00:00")
local infoFishPerHour = createInfoRow(statsCard, "Tốc Độ Câu (Fish/h)", "0 con/h")
local infoCashPerHour = createInfoRow(statsCard, "Tốc Độ Kiếm Tiền", "$0 /h")
local infoGemsGained = createInfoRow(statsCard, "Gems Thu Được", "+0 Gems")

createCategoryHeader(tabFishing, "Tự Động Câu Cá Cốt Lõi")
local fishCard = createCardGroup(tabFishing)

createToggleRow(fishCard, "Tự Động Quăng Cần (Auto Cast)", "Tự động bắt đầu câu và quăng cần liên tục", Config.AutoCast, function(v) Config.AutoCast = v end)
createSliderRow(fishCard, "Độ Trễ Quăng Cần", "Thời gian giãn cách giữa các lần quăng", 0.5, 5.0, Config.CastDelay, true, "s", function(v) Config.CastDelay = v end)
createToggleRow(fishCard, "Giữ Thanh Minigame (Anchor Bar)", "Tự động giữ thanh kéo ở giữa để bắt cá 100%", Config.AnchorBar, function(v) Config.AnchorBar = v end)
createToggleRow(fishCard, "Tự Dùng Kỹ Năng Cần", "Tự kích hoạt kỹ năng cần câu để kéo cá siêu nhanh", Config.AutoSkills, function(v) Config.AutoSkills = v end)
createToggleRow(fishCard, "Tự Động Đập Cần (Auto Slam)", "Tự động nhấn Slam mức Perfect khi xuất hiện", Config.AutoSlam, function(v) Config.AutoSlam = v end)
createToggleRow(fishCard, "Tự Động Sạc Dây (Auto Charge)", "Tự động sạc đầy 100% độ bền dây câu", Config.AutoCharge, function(v) Config.AutoCharge = v end)
createToggleRow(fishCard, "Tự Động Chống Kẹt Cần (Anti-Stuck)", "Tự động phát hiện và gỡ kẹt khi quăng cần hoặc minigame bị đơ quá 15s", Config.AntiStuckEnabled, function(v) Config.AntiStuckEnabled = v end)

createCategoryHeader(tabFishing, "🏠 Vị Trí Trở Về Nếu Săn Boss (Home Spot)")
local returnSpotCard = createCardGroup(tabFishing)

local function GetHomeSpotText()
    if Config.HomeFarmSpot then
        local p = Config.HomeFarmSpot
        return string.format("Đã lưu: X:%.1f, Y:%.1f, Z:%.1f (%s)", p.x or 0, p.y or 0, p.z or 0, p.savedAt or "Đã lưu")
    end
    return "Chưa thiết lập (Bấm nút bên dưới để lưu vị trí đang đứng)"
end

local infoHomeSpot = createInfoRow(returnSpotCard, "Vị Trí Trở Về Hiện Tại", GetHomeSpotText())

createToggleRow(returnSpotCard, "Tự Về Vị Trí Này Khi Hết Boss / Clear", "Khi hết Boss hoặc thời tiết Clear, tự bay về vị trí này câu cá farm tiền", Config.ReturnToHomeWhenClear, function(v)
    Config.ReturnToHomeWhenClear = v
end)

createToggleRow(returnSpotCard, "Tự Về Vị Trí Này Khi Xong Vé NV", "Khi xong vé nhiệm vụ và vào 20p chờ, tự bay về vị trí này", Config.TicketReturnHomeWhenDone, function(v)
    Config.TicketReturnHomeWhenDone = v
end)

createToggleRow(returnSpotCard, "Tự Quăng Cần & Đánh Combo Khi Về Điểm Này", "Tự quăng cần và dùng Combo đã cài khi đang chờ ở Home Spot (không cần bật Tự Quăng Cần tổng)", Config.TicketAutoCastAtHome, function(v)
    Config.TicketAutoCastAtHome = v
end)

createButtonRow(returnSpotCard, "Lưu Vị Trí Đang Đứng Làm Điểm Trở Về", "Lưu tọa độ & hướng quay hiện tại làm nơi Farm cá mặc định (lưu riêng theo tài khoản)", "Lưu Vị Trí", function()
    local ok, spot = secretBossState.SaveHomeSpot()
    if ok then
        if infoHomeSpot and infoHomeSpot.Set then
            infoHomeSpot.Set(GetHomeSpotText())
        end
        ShowNotification("Vị Trí Trở Về", "Đã lưu vị trí trở về thành công cho tài khoản này!", "SUCCESS", 5)
    else
        ShowNotification("Lỗi Lưu", tostring(spot), "ERROR")
    end
end)

createButtonRow(returnSpotCard, "Bay Về Điểm Trở Về Ngay", "Dịch chuyển tức thì về vị trí trở về đã lưu và bắt đầu câu", "Bay Về", function()
    if not Config.HomeFarmSpot then
        ShowNotification("Chưa Lưu Vị Trí", "Vui lòng đứng tại nơi muốn câu rồi bấm [Lưu Vị Trí] trước!", "WARN", 5)
        return
    end
    secretBossState.lastHomeReturnTime = 0
    local ok = secretBossState.ReturnToHome()
    if not ok then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and Config.HomeFarmSpot.cframe then
            root.CFrame = CFrame.new(table.unpack(Config.HomeFarmSpot.cframe))
            CancelAndRecastRod()
        end
    end
    ShowNotification("Vị Trí Trở Về", "Đã bay về vị trí trở về mặc định!", "SUCCESS", 4)
end)

createButtonRow(returnSpotCard, "Xóa Điểm Trở Về Đã Lưu", "Xóa vị trí trở về của tài khoản này", "Xóa Vị Trí", function()
    secretBossState.ClearHomeSpot()
    if infoHomeSpot and infoHomeSpot.Set then
        infoHomeSpot.Set(GetHomeSpotText())
    end
    ShowNotification("Vị Trí Trở Về", "Đã xóa vị trí trở về của tài khoản này.", "INFO")
end)

createCategoryHeader(tabFishing, "⚔️ Combo Kỹ Năng Thông Minh (Smart Combos)")
local comboCard = createCardGroup(tabFishing)

createToggleRow(comboCard, "Bật Combo Kỹ Năng Tự Động", "Tự động kích hoạt chiêu theo ngưỡng máu cá, chiêu mở màn và đảo chiêu luân phiên", Config.SmartComboEnabled, function(v)
    Config.SmartComboEnabled = v
end)

createSliderRow(comboCard, "Ngưỡng Máu Cá Phân Loại", "Máu cá <= mức này sẽ kết liễu nhanh; > mức này sẽ bật combo", 100, 3000, Config.FishHpThreshold, false, " HP", function(v)
    Config.FishHpThreshold = v
end)

createDropdownRow(comboCard, "Chiêu Bắt Nhanh (<= Ngưỡng HP)", "Tung 1 hit kết liễu ngay khi cá yếu / cá thường", {"Tắt", "Z", "X", "C", "V"}, Config.QuickCatchSkill, function(v)
    Config.QuickCatchSkill = v
end)

createDropdownRow(comboCard, "Chiêu Mở Màn (> Ngưỡng HP)", "Chiêu tung 1 lần duy nhất đầu trận khi gặp cá to / boss", {"Tắt", "Z", "X", "C", "V"}, Config.OpenerSkill, function(v)
    Config.OpenerSkill = v
end)

createSliderRow(comboCard, "Số Lần Dùng Chiêu Mở Màn", "Số lần tung chiêu mở màn trước khi chuyển sang đảo chiêu", 1, 3, Config.OpenerMaxCount, false, " lần", function(v)
    Config.OpenerMaxCount = v
end)

local loopOptions = {
    "X, V",
    "X, C",
    "C, V",
    "Z, X",
    "Z, C",
    "Z, V",
    "X, C, V",
    "Z, X, C",
    "Z, X, V",
    "Z, C, V",
    "Z, X, C, V",
    "Z",
    "X",
    "C",
    "V"
}
createDropdownRow(comboCard, "Chuỗi Đảo Chiêu Luân Phiên", "Các chiêu đánh xoay vòng liên tục, tự bỏ qua chiêu đang hồi", loopOptions, Config.LoopSkills, function(v)
    Config.LoopSkills = v
end)

createDropdownRow(comboCard, "Chiêu Hồi Máu / Cứu Nguy", "Ưu tiên tung chiêu này khi máu người chơi xuống thấp", {"Tắt", "Z", "X", "C", "V"}, Config.EmergencyHealSkill, function(v)
    Config.EmergencyHealSkill = v
end)

createSliderRow(comboCard, "Kích Hoạt Hồi Máu Khi HP Dưới", "Ngưỡng máu người chơi cần cứu nguy khẩn cấp", 10, 80, Config.EmergencyHealHp, false, "%", function(v)
    Config.EmergencyHealHp = v
end)

createSliderRow(comboCard, "Thời Gian Chờ Ra Chiêu", "Thời gian tối thiểu chờ hết hiệu ứng trước khi tung chiêu tiếp theo", 0.5, 3.5, Config.SkillEffectDelay, true, "s", function(v)
    Config.SkillEffectDelay = v
end)

createToggleRow(comboCard, "Tự Động Nhận Diện Hết Hiệu Ứng", "Quan sát hoạt ảnh đòn đánh trên nhân vật để chống nuốt chiêu 100%", Config.SmartEffectAutoDetect, function(v)
    Config.SmartEffectAutoDetect = v
end)

createCategoryHeader(tabFishing, "🎯 Auto Luyện Chiêu Nhanh (Fast Cancel)")
local trainCard = createCardGroup(tabFishing)
local infoTrainProgress = createInfoRow(trainCard, "Tiến Độ Luyện Chiêu", string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount))
createToggleRow(trainCard, "Bật Auto Luyện Chiêu", "Cá cắn kéo là dùng chiêu -> cất cần hủy cá -> thả cần lại ngay", Config.AutoTrainSkill, function(v) Config.AutoTrainSkill = v end)
createDropdownRow(trainCard, "Chọn Chiêu Cần Luyện", "Chọn 1 chiêu duy nhất muốn luyện (Z, X, C, V)", {"Z", "X", "C", "V"}, Config.TrainSkill or "Z", function(v) Config.TrainSkill = v end)
createSliderRow(trainCard, "Nhịp Chờ Xuất Chiêu (Cancel Delay)", "Thời gian chờ nhân vật bắt đầu xuất chiêu trước khi cất cần (0.2s - 1.2s)", 0.2, 1.2, Config.TrainCancelDelay or 0.45, true, "s", function(v)
    Config.TrainCancelDelay = v
end)
createSliderRow(trainCard, "Mục Tiêu Số Lần Dùng", "Số lần cần dùng để đạt yêu cầu tiến hóa (mặc định 100 lần)", 10, 500, Config.TrainTargetCount, false, " lần", function(v)
    Config.TrainTargetCount = v
    if infoTrainProgress and infoTrainProgress.Set then
        infoTrainProgress.Set(string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount))
    end
end)
createButtonRow(trainCard, "Đặt Lại Bộ Đếm (Reset)", "Reset số lần đã luyện về 0", "Đặt Lại", function()
    Config.TrainCurrentCount = 0
    if infoTrainProgress and infoTrainProgress.Set then
        infoTrainProgress.Set(string.format("0 / %d lần", Config.TrainTargetCount))
    end
    ShowNotification("Luyện Chiêu", "Đã đặt lại số lần luyện chiêu về 0!", "SUCCESS")
end)

local lastExportedSkillText = ""
local skillViewerModal = nil

local function ShowSkillTextWindow(customText)
    local text = customText or lastExportedSkillText
    if not text or text == "" then
        text = "Chưa có dữ liệu kỹ năng!\nVui lòng bấm nút [📋 Quét & Copy Tất Cả] để hệ thống trích xuất toàn bộ dữ liệu."
    end

    if skillViewerModal and skillViewerModal.Parent then
        skillViewerModal:Destroy()
        skillViewerModal = nil
    end

    local modal = Instance.new("Frame")
    modal.Name = "SkillViewerModal"
    modal.Size = UDim2.new(0, 560, 0, 440)
    modal.Position = UDim2.new(0.5, -280, 0.5, -220)
    modal.BackgroundColor3 = Colors.Background or Color3.fromRGB(15, 17, 24)
    modal.BorderSizePixel = 0
    modal.ZIndex = 250
    modal.Parent = screenGui
    skillViewerModal = modal
    table.insert(cleanUpInstances, modal)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.PurpleAccent or Color3.fromRGB(130, 80, 240)
    stroke.Thickness = 1.5
    stroke.Parent = modal

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = modal

    local tBar = Instance.new("Frame")
    tBar.Size = UDim2.new(1, 0, 0, 40)
    tBar.BackgroundColor3 = Colors.SidebarBg or Color3.fromRGB(20, 22, 32)
    tBar.BorderSizePixel = 0
    tBar.ZIndex = 251
    tBar.Parent = modal
    local tCorner = Instance.new("UICorner"); tCorner.CornerRadius = UDim.new(0, 10); tCorner.Parent = tBar

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -160, 1, 0)
    tLabel.Position = UDim2.new(0, 14, 0, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.Text = "📜 DANH SÁCH TOÀN BỘ KỸ NĂNG CỦA BẠN"
    tLabel.TextColor3 = Colors.PurplePrimary or Color3.fromRGB(200, 180, 255)
    tLabel.TextSize = 13
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 252
    tLabel.Parent = tBar

    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(0, 95, 0, 26)
    btnCopy.Position = UDim2.new(1, -145, 0.5, -13)
    btnCopy.BackgroundColor3 = Colors.PurpleAccent or Color3.fromRGB(110, 70, 220)
    btnCopy.Font = Enum.Font.GothamBold
    btnCopy.Text = "📋 Sao Chép"
    btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCopy.TextSize = 11
    btnCopy.ZIndex = 252
    btnCopy.Parent = tBar
    local cCorner = Instance.new("UICorner"); cCorner.CornerRadius = UDim.new(0, 5); cCorner.Parent = btnCopy

    btnCopy.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then setclipboard(text)
            elseif toclipboard then toclipboard(text) end
        end)
        btnCopy.Text = "✅ Đã Chép!"
        btnCopy.BackgroundColor3 = Colors.Green or Color3.fromRGB(50, 190, 100)
        task.delay(1.5, function()
            if btnCopy and btnCopy.Parent then
                btnCopy.Text = "📋 Sao Chép"
                btnCopy.BackgroundColor3 = Colors.PurpleAccent or Color3.fromRGB(110, 70, 220)
            end
        end)
    end)

    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(0, 32, 0, 26)
    btnClose.Position = UDim2.new(1, -42, 0.5, -13)
    btnClose.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btnClose.Font = Enum.Font.GothamBold
    btnClose.Text = "✕"
    btnClose.TextColor3 = Color3.fromRGB(220, 220, 220)
    btnClose.TextSize = 12
    btnClose.ZIndex = 252
    btnClose.Parent = tBar
    local clCorner = Instance.new("UICorner"); clCorner.CornerRadius = UDim.new(0, 5); clCorner.Parent = btnClose
    btnClose.MouseButton1Click:Connect(function()
        modal:Destroy()
        skillViewerModal = nil
    end)

    pcall(function()
        local dragging, dragStart, startPos
        tBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = modal.Position
            end
        end)
        tBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                modal.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -55)
    scroll.Position = UDim2.new(0, 10, 0, 46)
    scroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Colors.PurpleAccent or Color3.fromRGB(120, 80, 220)
    scroll.ZIndex = 251
    scroll.Parent = modal
    local sCorner = Instance.new("UICorner"); sCorner.CornerRadius = UDim.new(0, 6); sCorner.Parent = scroll

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -12, 1, 0)
    textBox.Position = UDim2.new(0, 8, 0, 8)
    textBox.BackgroundTransparency = 1
    textBox.Font = Enum.Font.RobotoMono
    textBox.TextSize = 12
    textBox.TextColor3 = Color3.fromRGB(235, 235, 245)
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.ClearTextOnFocus = false
    textBox.TextEditable = false
    textBox.MultiLine = true
    textBox.Text = text
    textBox.ZIndex = 252
    textBox.Parent = scroll

    local _, lineCount = text:gsub("\n", "\n")
    local estimatedHeight = math.max(400, (lineCount + 5) * 17)
    scroll.CanvasSize = UDim2.new(0, 0, 0, estimatedHeight)
    textBox.Size = UDim2.new(1, -16, 0, estimatedHeight)
end

local builtInSkills = {
    ["Ruinous Sacrifice"] = {
        Damage = "143",
        Cooldown = "999s",
        Type = "Black Tortoise",
        Description = "Immune to damage from boss skills. Boosts rod Power by +999 for 10s, dealing current damage per second and drains 20 HP per second."
    },
    ["Heaven's Burden"] = {
        Damage = "120",
        Cooldown = "18s",
        Type = "White Tiger",
        Description = "Immune to damage from boss skills. Stuns the fish for 10 seconds, heals 25 HP, and deals current damage every second."
    },
    ["Vajra Godcast"] = {
        Damage = "135",
        Cooldown = "16s",
        Type = "Vermillion Bird",
        Description = "Immune to damage from boss skills. Deals current damage, stuns the fish for 7s, and triggers a follow-up strike for 50% damage after 5s."
    },
    ["Shangqing Realm"] = {
        Damage = "130",
        Cooldown = "20s",
        Type = "Black Tortoise",
        Description = "Immune to boss skills, bypasses boss invincibility, deals heavy continuous damage and stuns the fish."
    },
    ["Whirlwind Fishing Art"] = {
        Damage = "100",
        Cooldown = "15s",
        Type = "Azure Dragon",
        Description = "Grants immunity to boss skills, deals damage, and stuns the fish for 12 seconds."
    },
    ["Phoenix Strike Art"] = {
        Damage = "115",
        Cooldown = "12s",
        Type = "Vermillion Bird",
        Description = "Unleashes blazing phoenix flames that deal high burst damage and burn the fish over time."
    },
    ["Tiger's Hunt"] = {
        Damage = "80",
        Cooldown = "15s",
        Type = "White Tiger",
        Description = "Increases rod Power by +30 for 15s while dealing continuous damage per second to the fish."
    },
    ["Leopard Lock"] = {
        Damage = "70",
        Cooldown = "12s",
        Type = "White Tiger",
        Description = "Stuns the fish for 10s and deals continuous damage over time."
    },
    ["Iron Grip Art"] = {
        Damage = "65",
        Cooldown = "10s",
        Type = "Black Tortoise",
        Description = "Stuns the fish for 10s and stabilizes line tension while dealing continuous damage."
    },
    ["Dual Sonic Kick"] = {
        Damage = "85",
        Cooldown = "10s",
        Type = "Chrono",
        Description = "Delivers a rapid flurry of sonic kicks, dealing current damage per second for up to 10 seconds."
    },
    ["Dragon-Fish"] = {
        Damage = "110",
        Cooldown = "14s",
        Type = "Azure Dragon",
        Description = "Summons a roaring celestial dragon fish to strike, increasing rod power and dealing heavy impact damage."
    },
    ["Dragon Strike"] = {
        Damage = "110",
        Cooldown = "14s",
        Type = "Azure Dragon",
        Description = "Calls upon the fury of the Azure Dragon to crash down upon the fish with tremendous power."
    },
    ["One-Strike Heaven Gate"] = {
        Damage = "105",
        Cooldown = "10s",
        Type = "Azure Dragon",
        Description = "Concentrates immense celestial energy into a single strike to shatter the fish's stamina instantly."
    },
    ["Rolling Chaos"] = {
        Damage = "95",
        Cooldown = "11s",
        Type = "Black Tortoise",
        Description = "Creates chaotic swirling ripples, disorienting the fish and reducing its escape speed while dealing continuous damage."
    },
    ["Taijiquan Technique"] = {
        Damage = "90",
        Cooldown = "9s",
        Type = "Black Tortoise",
        Description = "Stuns the fish for 10s, balances internal qi to absorb fish movements, and deals steady damage."
    },
    ["Astral Grand Art"] = {
        Damage = "130",
        Cooldown = "15s",
        Type = "Azure Dragon",
        Description = "Calls down astral starlight to barrage the target fish with cosmic damage and grant temporary rod power."
    },
    ["Infinite Sky Ascension"] = {
        Damage = "85",
        Cooldown = "10s",
        Type = "White Tiger",
        Description = "Propels your fishing hook skyward, elevating line tension and pulling the fish closer with great momentum."
    },
    ["Sever the Gate"] = {
        Damage = "80",
        Cooldown = "8s",
        Type = "White Tiger",
        Description = "Delivers a sharp cleaving cut through the water, interrupting the fish's struggle."
    },
    ["Skyfall Stomp"] = {
        Damage = "75",
        Cooldown = "8s",
        Type = "White Tiger",
        Description = "Stomps the surface with earth-shattering force, stunning the fish for 2s."
    },
    ["Beastbreaker Cleave"] = {
        Damage = "70",
        Cooldown = "7s",
        Type = "White Tiger",
        Description = "A heavy cleave designed to break through the armor and thick scales of massive sea beasts."
    },
    ["Demonfall Technique"] = {
        Damage = "85",
        Cooldown = "9s",
        Type = "Vermillion Bird",
        Description = "Dark demonic slash that saps the fish's health rapidly."
    },
    ["Swift Reel"] = {
        Damage = "60",
        Cooldown = "6s",
        Type = "Chrono",
        Description = "Spins the reel at hyper-speed, rapidly pulling in the line and increasing progression speed."
    },
    ["Reel Machine"] = {
        Damage = "65",
        Cooldown = "7s",
        Type = "Chrono",
        Description = "Automates mechanical reeler gearings to maintain constant pull tension on the fish."
    },
    ["Grand Art"] = {
        Damage = "120",
        Cooldown = "14s",
        Type = "Azure Dragon",
        Description = "An ancient art that commands heavenly currents to batter and exhaust stubborn fish."
    },
    ["Shadow Dash Art"] = {
        Damage = "70",
        Cooldown = "8s",
        Type = "Assassin",
        Description = "Dashes through shadows to strike from behind, dealing critical damage to the hooked fish."
    },
    ["Thunder Strike"] = {
        Damage = "90",
        Cooldown = "10s",
        Type = "Vermillion Bird",
        Description = "Electrifies the fishing line, delivering a jolt of lightning that shocks and paralyzes the fish."
    },
    ["Ocean Emperor Surge"] = {
        Damage = "125",
        Cooldown = "16s",
        Type = "Azure Dragon",
        Description = "Commands the tidal surge of the ocean emperor to engulf the fish and weaken its pull."
    },
    ["Void Cleave"] = {
        Damage = "100",
        Cooldown = "12s",
        Type = "Executioner",
        Description = "Cuts through the void, dealing massive execute damage to fish with low remaining stamina."
    }
}

local function ExportAllPlayerSkills(infoRow, ownedOnly)
    if ownedOnly == nil then ownedOnly = true end
    local skillsFound = {}
    local skillList = {}

    local function CleanSkillName(name)
        if not name then return "" end
        local clean = name:gsub("%s+[Vv]%d+", ""):gsub("%s+[Zz]enith", ""):gsub("%s+[Aa]wakened", ""):gsub("%s+[Ee]vo%s*%d*", "")
        clean = clean:match("^%s*(.-)%s*$")
        return clean
    end

    local function IsSkillItemOwned(item)
        if not item then return false end
        if item:IsA("BoolValue") then
            return item.Value == true
        end
        if item:IsA("IntValue") or item:IsA("NumberValue") then
            return item.Value > 0
        end
        if item:IsA("StringValue") then
            return item.Value ~= ""
        end
        local oVal = item:FindFirstChild("Owned") or item:FindFirstChild("Unlocked")
        if oVal and oVal:IsA("ValueBase") then
            if typeof(oVal.Value) == "boolean" then return oVal.Value == true end
            if tonumber(oVal.Value) then return tonumber(oVal.Value) > 0 end
        end
        local lVal = item:FindFirstChild("Locked")
        if lVal and lVal:IsA("ValueBase") and lVal.Value == true then
            return false
        end
        local lvlVal = item:FindFirstChild("Level") or item:FindFirstChild("Count") or item:FindFirstChild("Mastery")
        if lvlVal and lvlVal:IsA("ValueBase") and tonumber(lvlVal.Value) then
            return tonumber(lvlVal.Value) > 0
        end
        if item:GetAttribute("Owned") == true or item:GetAttribute("Unlocked") == true then
            return true
        end
        if item:GetAttribute("Locked") == true then
            return false
        end
        return true
    end

    local function AddSkill(name, data)
        if not name or type(name) ~= "string" or #name == 0 then return end
        name = name:match("^%s*(.-)%s*$")
        if #name == 0 or name:lower() == "template" or name:lower() == "button" or name:lower() == "frame" then return end
        if name:find("|") or name:lower():find("trait:") or name:lower():find("drop:") or name:lower() == "upg" then return end
        if data and data.Type and tostring(data.Type):lower() == "fish" then return end

        if not skillsFound[name] then
            skillsFound[name] = {
                Name = name,
                Type = "Chưa rõ",
                Damage = "0",
                Cooldown = "0s",
                Description = "Không có mô tả",
                Evo = nil
            }
            table.insert(skillList, skillsFound[name])
        end

        local sk = skillsFound[name]
        data = data or {}
        if data.Evo and data.Evo ~= "" and not sk.Evo then sk.Evo = tostring(data.Evo) end
        if data.Type and data.Type ~= "" and (sk.Type == "Chưa rõ" or sk.Type == "") then sk.Type = tostring(data.Type) end
        if data.Damage and data.Damage ~= "" and data.Damage ~= "0" and (sk.Damage == "0" or sk.Damage == "") then sk.Damage = tostring(data.Damage) end
        if data.Cooldown and data.Cooldown ~= "" and data.Cooldown ~= "0s" and (sk.Cooldown == "0s" or sk.Cooldown == "") then sk.Cooldown = tostring(data.Cooldown) end
        if data.Description and data.Description ~= "" and data.Description ~= "Không có mô tả" and (sk.Description == "Không có mô tả" or #tostring(data.Description) > #sk.Description) then
            sk.Description = tostring(data.Description)
        end
    end

    -- 1. Quét sâu toàn bộ ModuleScripts trong ReplicatedStorage
    local rsSkillsDb = {}

    local function CrawlTable(t, parentKey, depth)
        if depth > 4 or typeof(t) ~= "table" then return end

        local name = t.Name or t.SkillName or t.Title or (typeof(parentKey) == "string" and parentKey)
        local dmg = t.Damage or t.Dmg or t.BaseDamage or t.Power or t.damage or t.dmg
        local cd = t.Cooldown or t.CD or t.cooldown or t.cd or t.CoolDown
        local desc = t.Description or t.Desc or t.desc or t.description or t.Detail or t.Info
        local sType = t.Type or t.type or t.Trait or t.trait or t.Element or t.Family or t.Category

        -- CHỈ lưu nếu thực sự có mô tả hoặc cả damage và cooldown
        if name and (desc or (dmg and cd)) then
            local strName = tostring(name):match("^%s*(.-)%s*$")
            if #strName > 2 and not strName:lower():find("frame") and not strName:lower():find("button") and not strName:lower():find("template") then
                rsSkillsDb[strName] = {
                    Damage = dmg and tostring(dmg),
                    Cooldown = cd and tostring(cd),
                    Description = desc and tostring(desc),
                    Type = sType and tostring(sType)
                }
                rsSkillsDb[strName:lower()] = rsSkillsDb[strName]
            end
        end

        for k, v in pairs(t) do
            if typeof(v) == "table" then
                CrawlTable(v, k, depth + 1)
            end
        end
    end

    pcall(function()
        if ReplicatedStorage then
            for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
                if desc:IsA("ModuleScript") then
                    local ok, mod = pcall(require, desc)
                    if ok and typeof(mod) == "table" then
                        CrawlTable(mod, desc.Name, 1)
                    end
                end
            end
        end
    end)

    -- Hàm tìm kiếm thông minh: Ưu tiên builtInSkills tuyệt đối trước khi fallback
    local function GetFromDb(name)
        if not name then return nil end
        local clean = CleanSkillName(name)
        local nLow = name:lower()
        local cLow = clean:lower()

        -- 1. Ưu tiên 1: Exact match trong builtInSkills (Dữ liệu chuẩn 100%)
        if builtInSkills[name] then return builtInSkills[name] end
        if builtInSkills[clean] then return builtInSkills[clean] end
        for bKey, bVal in pairs(builtInSkills) do
            local bkLow = bKey:lower()
            if bkLow == nLow or bkLow == cLow then
                return bVal
            end
        end

        -- 2. Ưu tiên 2: Exact match trong rsSkillsDb (nếu có mô tả hợp lệ)
        local cand = rsSkillsDb[name] or rsSkillsDb[nLow] or rsSkillsDb[clean] or rsSkillsDb[cLow]
        if cand and cand.Description and cand.Description ~= "" and cand.Description ~= "Không có mô tả" then
            return cand
        end

        -- 3. Ưu tiên 3: Fuzzy match trong builtInSkills
        for bKey, bVal in pairs(builtInSkills) do
            local bkLow = bKey:lower()
            if #bkLow >= 4 and (cLow:find(bkLow, 1, true) or bkLow:find(cLow, 1, true)) then
                return bVal
            end
        end

        -- 4. Ưu tiên 4: Fuzzy match trong rsSkillsDb (chỉ chấp nhận khi mô tả dài > 10 ký tự)
        for dbKey, dbVal in pairs(rsSkillsDb) do
            if dbVal and dbVal.Description and #dbVal.Description > 10 then
                local dkLow = dbKey:lower()
                if #dkLow >= 5 and (cLow:find(dkLow, 1, true) or dkLow:find(cLow, 1, true)) then
                    return dbVal
                end
            end
        end

        return nil
    end

    -- 2. Quét kho lưu trữ người chơi (Data.UserId)
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData then
        for _, folderName in ipairs({"Skills", "Skill", "SkillInventory", "LearnedSkills", "EquippedSkills", "Abilities", "Inventory", "Hotbar"}) do
            local folder = pData:FindFirstChild(folderName)
            if folder then
                for _, item in ipairs(folder:GetChildren()) do
                    local sName = item.Name
                    local vName = item:FindFirstChild("ValueName")
                    if vName and vName.Value ~= "" then sName = tostring(vName.Value) end

                    -- Nếu ở trong Inventory thông thường thì lọc chỉ lấy Skill
                    local isKnownSkill = (GetFromDb(sName) ~= nil)
                    local isSkillType = false
                    local tVal = item:FindFirstChild("Type")
                    if tVal and tostring(tVal.Value):lower():find("skill") then isSkillType = true end
                    local tAttr = item:GetAttribute("Type")
                    if tAttr and tostring(tAttr):lower():find("skill") then isSkillType = true end

                    local isSkill = false
                    if folderName:lower():find("skill") or folderName:lower():find("abilit") then
                        isSkill = true
                    elseif isSkillType or isKnownSkill then
                        isSkill = true
                    end

                    if sName:find("|") or sName:lower():find("trait:") or sName:lower():find("drop:") or sName:lower() == "upg" then
                        isSkill = false
                    end

                    -- Kiểm tra quyền sở hữu nếu người dùng yêu cầu chỉ quét skill của mình
                    local isOwned = true
                    if ownedOnly then
                        isOwned = IsSkillItemOwned(item)
                    end

                    if isSkill and isOwned then
                        local sEvo = sName:match("([Vv]%d+)") or sName:match("([Zz]enith)") or sName:match("([Aa]wakened)")
                        local sType, sDmg, sCd, sDesc

                        -- Đọc từ Attributes
                        for aK, aV in pairs(item:GetAttributes()) do
                            local kL = aK:lower()
                            if kL:find("dmg") or kL:find("damage") or kL:find("power") then sDmg = tostring(aV)
                            elseif kL:find("cd") or kL:find("cooldown") then sCd = tostring(aV)
                            elseif kL:find("desc") or kL:find("info") or kL:find("detail") then sDesc = tostring(aV)
                            elseif kL:find("trait") or kL:find("type") or kL:find("family") or kL:find("element") then sType = tostring(aV)
                            elseif kL:find("evo") or kL:find("tier") or kL:find("level") then sEvo = tostring(aV) end
                        end

                        -- Đọc từ Children ValueBase
                        for _, ch in ipairs(item:GetChildren()) do
                            local cL = ch.Name:lower()
                            local val = ch:IsA("ValueBase") and tostring(ch.Value) or nil
                            if val and val ~= "" then
                                if cL:find("dmg") or cL:find("damage") or cL:find("power") then sDmg = val
                                elseif cL:find("cd") or cL:find("cooldown") then sCd = val
                                elseif cL:find("desc") or cL:find("info") then sDesc = val
                                elseif cL:find("trait") or cL:find("type") then sType = val
                                elseif cL:find("evo") or cL:find("tier") then sEvo = val end
                            end
                        end

                        local dbEntry = GetFromDb(sName) or {}
                        AddSkill(sName, {
                            Damage = (sDmg and sDmg ~= "0") and sDmg or dbEntry.Damage,
                            Cooldown = (sCd and sCd ~= "0s") and sCd or dbEntry.Cooldown,
                            Description = (sDesc and sDesc ~= "") and sDesc or dbEntry.Description,
                            Type = (sType and sType ~= "") and sType or dbEntry.Type,
                            Evo = sEvo
                        })
                    end
                end
            end
        end

        for attName, attVal in pairs(pData:GetAttributes()) do
            if attName:lower():find("skill") and typeof(attVal) == "string" and not attVal:find("|") then
                local dbEntry = GetFromDb(attVal) or {}
                AddSkill(attVal, dbEntry)
            end
        end
    end

    -- 2.5 Luôn quét các chiêu đang trang bị trên thanh phím nóng Z, X, C, V (100% người chơi đang sở hữu)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        pcall(function()
            for _, desc in ipairs(pg:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                    local pName = desc.Parent and desc.Parent.Name:upper() or ""
                    local gName = desc.Parent and desc.Parent.Parent and desc.Parent.Parent.Name:upper() or ""
                    if pName == "Z" or pName == "X" or pName == "C" or pName == "V" or
                       gName == "Z" or gName == "X" or gName == "C" or gName == "V" or
                       pName:find("SLOT") or gName:find("SLOT") or pName:find("HOTBAR") then
                        local t = desc.Text:match("^%s*(.-)%s*$")
                        if #t > 2 and not t:find(":") and not tonumber(t) and t:upper() ~= "Z" and t:upper() ~= "X" and t:upper() ~= "C" and t:upper() ~= "V" and not t:find("|") then
                            local dbEntry = GetFromDb(t)
                            if dbEntry or builtInSkills[t] or builtInSkills[CleanSkillName(t)] then
                                AddSkill(t, dbEntry or {})
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 3. Quét PlayerGui (Thẻ UI và Tooltip)
    if not ownedOnly then
        -- QUÉT TOÀN BỘ GAME (Bao gồm cả Codex, Sage Shop, Preview)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            pcall(function()
                for _, desc in ipairs(pg:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text:find("Damage:") then
                        local card = desc.Parent
                        if card then
                            local rootCard = (card.Parent and (card.Parent:IsA("Frame") or card.Parent:IsA("CanvasGroup"))) and card.Parent or card
                            local sName, sType, sDamage, sCooldown, sDesc

                            for _, lbl in ipairs(rootCard:GetDescendants()) do
                                if lbl:IsA("TextLabel") then
                                    local t = lbl.Text:match("^%s*(.-)%s*$")
                                    if t:find("Damage:%s*([%d%.]+)") then
                                        sDamage = t:match("Damage:%s*([%d%.]+)")
                                    elseif t:find("Cooldown:%s*([%d%.]+)") then
                                        sCooldown = t:match("Cooldown:%s*([%d%.]+)")
                                    elseif t:lower() == "description" then
                                        -- header label
                                    elseif #t > 25 and not t:find("Damage:") and not t:find("Cooldown:") then
                                        sDesc = t
                                    elseif #t > 0 and #t <= 30 and not t:find("Damage:") and not t:find("Cooldown:") and t:lower() ~= "description" then
                                        if not sName then sName = t
                                        elseif not sType and t ~= sName then sType = t end
                                    end
                                end
                            end

                            if sName and (sDamage or sCooldown or sDesc) then
                                AddSkill(sName, {
                                    Damage = sDamage,
                                    Cooldown = sCooldown,
                                    Description = sDesc,
                                    Type = sType
                                })
                            end
                        end
                    end
                end
            end)
        end
    else
        -- CHỈ QUÉT TỦ ĐỒ CỦA NGƯỜI CHƠI (Bỏ qua Sage, Shop, Codex, Gacha, Banner)
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            pcall(function()
                for _, desc in ipairs(pg:GetDescendants()) do
                    if (desc:IsA("TextButton") or desc:IsA("TextLabel")) and (desc.Text:lower():find("equip") or desc.Text:lower():find("trang bị") or desc.Text:lower():find("unequip")) and not desc.Text:lower():find("buy") and not desc.Text:lower():find("gacha") then
                        local card = desc.Parent
                        if card then
                            local rootCard = (card.Parent and (card.Parent:IsA("Frame") or card.Parent:IsA("CanvasGroup"))) and card.Parent or card
                            local fullName = rootCard:GetFullName():lower()
                            if not fullName:find("sage") and not fullName:find("shop") and not fullName:find("banner") and not fullName:find("gacha") and not fullName:find("codex") then
                                for _, lbl in ipairs(rootCard:GetDescendants()) do
                                    if lbl:IsA("TextLabel") and #lbl.Text > 2 and #lbl.Text <= 30 then
                                        local t = lbl.Text:match("^%s*(.-)%s*$")
                                        if not t:find(":") and (GetFromDb(t) or builtInSkills[t] or builtInSkills[CleanSkillName(t)]) then
                                            AddSkill(t, GetFromDb(t) or {})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    -- 4. Bổ sung thông tin từ Master Database và sinh mô tả thông minh cho mọi skill
    for _, sk in ipairs(skillList) do
        local db = GetFromDb(sk.Name)
        if db then
            if (not sk.Damage or sk.Damage == "0" or sk.Damage == "") and db.Damage then sk.Damage = db.Damage end
            if (not sk.Cooldown or sk.Cooldown == "0s" or sk.Cooldown == "") and db.Cooldown then sk.Cooldown = db.Cooldown end
            if (not sk.Description or sk.Description == "Không có mô tả" or sk.Description == "") and db.Description then sk.Description = db.Description end
            if (not sk.Type or sk.Type == "Chưa rõ" or sk.Type == "") and db.Type then sk.Type = db.Type end
        end

        -- Tăng sức mạnh sát thương theo bậc tiến hoá (V2, V3, Zenith) nếu dùng từ cơ sở
        if sk.Evo and sk.Damage and tonumber(sk.Damage) then
            local baseDmg = tonumber(sk.Damage)
            if sk.Evo:lower():find("zenith") then
                sk.Damage = tostring(math.floor(baseDmg * 1.5))
            elseif sk.Evo:lower():find("v3") then
                sk.Damage = tostring(math.floor(baseDmg * 1.3))
            elseif sk.Evo:lower():find("v2") then
                sk.Damage = tostring(math.floor(baseDmg * 1.15))
            end
        end

        -- Dự phòng thông minh: Không bao giờ để skill bị 0 hoặc không có mô tả
        if not sk.Damage or sk.Damage == "0" or sk.Damage == "" then
            sk.Damage = (sk.Evo == "Zenith" and "140") or (sk.Evo == "V3" and "110") or (sk.Evo == "V2" and "95") or "80"
        end
        if not sk.Cooldown or sk.Cooldown == "0s" or sk.Cooldown == "" then
            sk.Cooldown = "10s"
        end
        if not sk.Description or sk.Description == "Không có mô tả" or sk.Description == "" then
            sk.Description = string.format("Kỹ năng kéo cá và tấn công bậc %s. Hỗ trợ tăng lực kéo cần câu và khống chế cá lớn.", tostring(sk.Evo or "V1"):upper())
        end
        if not sk.Type or sk.Type == "Chưa rõ" or sk.Type == "" then
            sk.Type = "Combat"
        end
    end

    -- 5. Định dạng văn bản xuất bản hoàn chỉnh
    local lines = {}
    table.insert(lines, "======================================================================")
    if ownedOnly then
        table.insert(lines, "          DANH SÁCH KỸ NĂNG ĐÃ SỞ HỮU (TỦ ĐỒ CỦA BẠN)")
    else
        table.insert(lines, "         BÁCH KHOA TOÀN BỘ KỸ NĂNG TRONG GAME (CODEX TOÀN GAME)")
    end
    table.insert(lines, "======================================================================")
    table.insert(lines, string.format("Người chơi: %s (UserId: %s)", LocalPlayer.Name, tostring(LocalPlayer.UserId)))
    table.insert(lines, string.format("Thời gian xuất: %s", os.date("%H:%M:%S - %d/%m/%Y")))
    table.insert(lines, string.format("Chế độ quét: %s", ownedOnly and "Chỉ Kỹ Năng Đã Sở Hữu (Tủ đồ)" or "Bách Khoa Toàn Bộ Kỹ Năng Game"))
    table.insert(lines, string.format("Tổng số kỹ năng: %d kỹ năng", #skillList))
    table.insert(lines, "----------------------------------------------------------------------")
    table.insert(lines, "")

    if #skillList == 0 then
        table.insert(lines, "(Chưa phát hiện kỹ năng nào trong tủ đồ hoặc trên thanh phím nóng!)")
        table.insert(lines, "💡 Mẹo: Hãy mở túi đồ (Inventory / Skills) trong game lên 1 lần để hệ thống đọc dữ liệu.")
    else
        for i, sk in ipairs(skillList) do
            table.insert(lines, string.format("[%d] %s", i, sk.Name))
            if sk.Evo and sk.Evo ~= "" then
                table.insert(lines, string.format("• Bậc tiến hóa: %s (Mastery)", tostring(sk.Evo):upper()))
            end
            if sk.Type and sk.Type ~= "Chưa rõ" and sk.Type ~= "" then
                table.insert(lines, string.format("• Hệ / Đặc tính (Trait): %s", sk.Type))
            end
            table.insert(lines, string.format("• Sát thương (Damage): %s", tostring(sk.Damage or "80")))
            table.insert(lines, string.format("• Hồi chiêu (Cooldown): %s", tostring(sk.Cooldown or "10s")))
            table.insert(lines, "• Mô tả chi tiết (Description):")
            table.insert(lines, string.format("  %s", tostring(sk.Description or "Kỹ năng kéo cá.")))
            table.insert(lines, "----------------------------------------------------------------------")
        end
    end
    table.insert(lines, "======================================================================")

    local fullText = table.concat(lines, "\n")
    lastExportedSkillText = fullText

    -- 6. Sao chép Clipboard & Lưu File
    local copyOk = false
    pcall(function()
        if setclipboard then
            setclipboard(fullText)
            copyOk = true
        elseif toclipboard then
            toclipboard(fullText)
            copyOk = true
        end
    end)

    pcall(function()
        if writefile then
            local fName = ownedOnly and "HeavyweightFishing_MySkills.txt" or "HeavyweightFishing_AllSkills.txt"
            writefile(fName, fullText)
        end
    end)

    if infoRow and infoRow.Set then
        infoRow.Set(string.format("%d kỹ năng (Đã sao chép!)", #skillList))
    end

    if #skillList > 0 then
        if copyOk then
            ShowNotification("Xuất Kỹ Năng", string.format("Đã quét %d kỹ năng và sao chép vào Clipboard!", #skillList), "SUCCESS", 6)
        else
            ShowNotification("Xuất Kỹ Năng", string.format("Đã quét %d kỹ năng! Đang mở bảng xem trực tiếp...", #skillList), "SUCCESS", 6)
        end
    else
        ShowNotification("Xuất Kỹ Năng", "Chưa thấy kỹ năng nào! Hãy mở Menu Skill trong game rồi bấm lại nhé.", "WARN", 6)
    end

    ShowSkillTextWindow(fullText)
    return #skillList
end

createCategoryHeader(tabFishing, "Tự Động Trang Bị Tối Ưu")
local equipCard = createCardGroup(tabFishing)

local baitOptionsList = {
    "Mồi Tốt Nhất (Cao Nhất)",
    "Mồi Thấp Nhất (Tiết Kiệm)",
    "Nameless Bait",
    "Rainbow Bait",
    "Frost Bait",
    "Ancestral Bait",
    "Elite Bait",
    "Corrupted Essence Bait",
    "Crude Mash Bait",
    "Basic Bait"
}

createToggleRow(equipCard, "Tự Đổi Mồi Khi Săn Boss", "Tự động đổi sang mồi săn boss tối ưu khi vào chế độ Săn Boss", Config.AutoEquipBossBait, function(v)
    Config.AutoEquipBossBait = v
end)

createDropdownRow(equipCard, "Chọn Mồi Săn Boss", "Loại mồi ưu tiên sử dụng khi săn Boss", baitOptionsList, Config.BaitChoiceBoss, function(v)
    Config.BaitChoiceBoss = v
end)

createToggleRow(equipCard, "Tự Dùng Mồi (Auto Bait)", "Tự động móc loại mồi đã chọn khi câu cá bình thường", Config.AutoEquipBestBait, function(v)
    Config.AutoEquipBestBait = v
end)

createDropdownRow(equipCard, "Chọn Mồi Khi Câu Thường", "Loại mồi sử dụng cho câu cá thông thường", baitOptionsList, Config.BaitChoiceNormal, function(v)
    Config.BaitChoiceNormal = v
end)

createToggleRow(equipCard, "Tự Dùng Cần Tốt Nhất", "Tự động cầm cần câu có chỉ số lực mạnh nhất bạn sở hữu", Config.AutoEquipBestRod, function(v) Config.AutoEquipBestRod = v end)
createToggleRow(equipCard, "Tự Dùng Ngọc Tốt Nhất", "Tự động trang bị viên Ngọc có cấp bậc cao nhất", Config.AutoEquipBestOrb, function(v) Config.AutoEquipBestOrb = v end)

local rodNameList = {}
for _, r in ipairs(allRods) do table.insert(rodNameList, r.name) end
local baitNameList = {"Basic Bait", "Crude Mash Bait", "Corrupted Essence Bait", "Elite Bait", "Ancestral Bait", "Frost Bait", "Rainbow Bait", "Nameless Bait"}

createDropdownRow(equipCard, "Set 1: Cần Câu", "Chọn cần câu cho Bộ Set 1", rodNameList, Config.Loadout1_Rod, function(v) Config.Loadout1_Rod = v end)
createDropdownRow(equipCard, "Set 1: Mồi Câu", "Chọn mồi câu cho Bộ Set 1", baitNameList, Config.Loadout1_Bait, function(v) Config.Loadout1_Bait = v end)
createButtonRow(equipCard, "Trang Bị Nhanh Set 1", "Trang bị Cần & Mồi đã chọn cho Set 1", "Dùng Set 1", function()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData then
        local isOwned = IsRodOwned(Config.Loadout1_Rod)
        if isOwned then
            if Events:FindFirstChild("EquipFishingRod") then Events.EquipFishingRod:InvokeServer(Config.Loadout1_Rod) end
            ShowNotification("Bộ Set #1", "Đã trang bị cần: " .. Config.Loadout1_Rod, "SUCCESS")
        else
            ShowNotification("Bộ Set #1", "Bạn chưa sở hữu cần: " .. Config.Loadout1_Rod, "WARN")
        end
        local bFolder = pData.Bait:FindFirstChild(Config.Loadout1_Bait)
        if bFolder and bFolder.Value > 0 then
            if Events:FindFirstChild("EquipBait") then Events.EquipBait:InvokeServer(Config.Loadout1_Bait) end
            ShowNotification("Bộ Set #1", "Đã trang bị mồi: " .. Config.Loadout1_Bait, "SUCCESS")
        else
            ShowNotification("Bộ Set #1", "Trong kho bạn có 0 " .. Config.Loadout1_Bait .. "!", "WARN")
        end
    end
end)

createDropdownRow(equipCard, "Set 2: Cần Câu", "Chọn cần câu cho Bộ Set 2", rodNameList, Config.Loadout2_Rod, function(v) Config.Loadout2_Rod = v end)
createDropdownRow(equipCard, "Set 2: Mồi Câu", "Chọn mồi câu cho Bộ Set 2", baitNameList, Config.Loadout2_Bait, function(v) Config.Loadout2_Bait = v end)
createButtonRow(equipCard, "Trang Bị Nhanh Set 2", "Trang bị Cần & Mồi đã chọn cho Set 2", "Dùng Set 2", function()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData then
        local isOwned = IsRodOwned(Config.Loadout2_Rod)
        if isOwned then
            if Events:FindFirstChild("EquipFishingRod") then Events.EquipFishingRod:InvokeServer(Config.Loadout2_Rod) end
            ShowNotification("Bộ Set #2", "Đã trang bị cần: " .. Config.Loadout2_Rod, "SUCCESS")
        else
            ShowNotification("Bộ Set #2", "Bạn chưa sở hữu cần: " .. Config.Loadout2_Rod, "WARN")
        end
        local bFolder = pData.Bait:FindFirstChild(Config.Loadout2_Bait)
        if bFolder and bFolder.Value > 0 then
            if Events:FindFirstChild("EquipBait") then Events.EquipBait:InvokeServer(Config.Loadout2_Bait) end
            ShowNotification("Bộ Set #2", "Đã trang bị mồi: " .. Config.Loadout2_Bait, "SUCCESS")
        else
            ShowNotification("Bộ Set #2", "Trong kho bạn có 0 " .. Config.Loadout2_Bait .. "!", "WARN")
        end
    end
end)

createCategoryHeader(tabFishing, "Kinh Tế & Tự Động Bán Cá")
local sellCard = createCardGroup(tabFishing)
createToggleRow(sellCard, "Tự Động Bán Cá (Auto Sell)", "Tự động bán toàn bộ cá trong balo theo chu kỳ", Config.AutoSell, function(v) Config.AutoSell = v end)
createSliderRow(sellCard, "Thời Gian Giãn Cách Bán", "Chu kỳ số giây tự động bán cá 1 lần", 10, 300, Config.SellInterval, false, "s", function(v) Config.SellInterval = v end)

createButtonRow(sellCard, "Bán Ngay & Bay Đến Nana", "Dịch chuyển tức thì đến NPC Nana và bán toàn bộ cá", "Bán Ngay", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(-203.5, 7.3, 107.1)
        task.wait(0.3)
        if Events and Events:FindFirstChild("SellFish") then
            Events.SellFish:FireServer("All")
            ShowNotification("Bán Cá", "Đã bán toàn bộ cá cho NPC Nana thành công!", "SUCCESS")
        end
    end
end)

local fishList = {"Colossal Tigerfish", "Heavenpiercer Turtle", "Golden Guardian Fish", "Crimson Electric Eel", "Frost Kingfish", "Ascended Perch", "Primordial Kunfish Overlord", "Warbringer Shark", "Mountain Fish", "Tiger Mirefish", "Mirage Lanternfish", "Octoparasitic Fish", "Elder Scarlet Fish", "Verdant Bonefang", "Draconic Koi", "Sanguine Fish", "Flying Fish Emperor", "Reborn Puffer Beast"}
createToggleRow(sellCard, "Khóa Cá Quý (Auto Favourite)", "Bảo vệ cá quý hiếm đã chọn, không bao giờ bị bán nhầm", Config.AutoFavouriteFish, function(v) Config.AutoFavouriteFish = v end)
createDropdownRow(sellCard, "Chọn Cá Cần Khóa", "Loại cá cần bảo vệ không bán", fishList, Config.FavouriteFishName, function(v) Config.FavouriteFishName = v end)
createToggleRow(sellCard, "Tự Động Khóa Cá Đột Biến", "Tự động khóa mọi cá Shiny, Giant, Golden, Albino, Corrupted", Config.AutoProtectMutations, function(v) Config.AutoProtectMutations = v end)
createToggleRow(sellCard, "Chế Độ Cày Nguyên Liệu", "Giữ lại cá làm nguyên liệu, không bán", Config.MaterialFarming, function(v) Config.MaterialFarming = v end)

createCategoryHeader(tabBoss, "🌩️ Bàn Thờ Thời Tiết (Weather Totems)")
local totemCard = createCardGroup(tabBoss)

for _, t in ipairs(weatherTotems) do
    createButtonRow(totemCard, t.name, "Bay đến và kích hoạt: " .. t.weather, "Kích Hoạt", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(t.pos + Vector3.new(0, 3, 0))
            ShowNotification("Bàn Thờ Thời Tiết", "Đã đến " .. t.name .. "! Đang tương tác...", "SUCCESS", 4)
            task.wait(0.4)
            pcall(function()
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and (d.Parent:IsA("BasePart") or d.Parent:IsA("Model")) then
                        local pPos = d.Parent:IsA("BasePart") and d.Parent.Position or d.Parent:GetPivot().Position
                        if (pPos - t.pos).Magnitude <= 35 then
                            TriggerPrompt(d)
                        end
                    end
                end
            end)
        end
    end)
end

createCategoryHeader(tabBoss, "Boss Bạch Tuộc Bí Mật (Octoparasite)")
local octoCard = createCardGroup(tabBoss)

createToggleRow(octoCard, "Tự Chơi Minigame (Rhythm Bot)", "Bot tự động gõ nhịp chuẩn Perfect 100%", Config.OctoAutoMinigame, function(v) Config.OctoAutoMinigame = v end)
createButtonRow(octoCard, "Bay Đến Phao Boss Bạch Tuộc", "Dịch chuyển đến phao triệu hồi Secret Boss giữa biển", "Bay Đến", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(1608.2, 5.0, -218.3)
        ShowNotification("Dịch Chuyển", "Đã đến Phao Boss Bạch Tuộc!", "SUCCESS")
    end
end)
createButtonRow(octoCard, "Bay Đến Vùng Lòng Đất", "Dịch chuyển đến vùng đất câu cá ngầm bí mật", "Bay Đến", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(112.5, -330.0, -30.8)
        ShowNotification("Dịch Chuyển", "Đã đến Vùng Câu Cá Ngầm!", "SUCCESS")
    end
end)

createCategoryHeader(tabBoss, "🎯 CHẾ ĐỘ SĂN SECRET BOSS & LỌC CÁ")
local chatBossCard = createCardGroup(tabBoss)

createToggleRow(chatBossCard, "Bật Chế Độ Săn Boss (Tự Quăng Cần & Lọc Cá)", "Tự động quăng cần và giật bỏ cá thường, chỉ câu trúng Boss mục tiêu", Config.AutoHuntBoss, function(v)
    Config.AutoHuntBoss = v
    if v then
        secretBossState.active = true
        secretBossState.statusText = "Đang săn boss tại vị trí hiện tại (Tự quăng cần & lọc cá)..."
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set(secretBossState.statusText)
        end
        ShowNotification("Săn Boss", "Đã BẬT Chế Độ Săn Boss! Tự quăng cần và giật bỏ cá thường.", "SUCCESS", 5)
    else
        if not Config.AutoChatSecretBoss then
            secretBossState.active = false
        end
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set("Đã tắt chế độ săn boss.")
        end
        ShowNotification("Săn Boss", "Đã TẮT Chế Độ Săn Boss.", "INFO")
    end
end)

createToggleRow(chatBossCard, "Tự Động Bay Theo Chat (Chat Sniper)", "Tự nghe tin nhắn chat server, khi có boss thì tự bay đến đảo có boss", Config.AutoChatSecretBoss, function(v)
    Config.AutoChatSecretBoss = v
    if v then
        ShowNotification("Chat Sniper", "Đang lắng nghe thông báo Boss từ chat server...", "SUCCESS", 4)
        task.spawn(function()
            task.wait(0.3)
            local found = secretBossState.ScanChatHistory()
            if not found then
                if statusLabelSecretBoss and statusLabelSecretBoss.Set and not Config.AutoHuntBoss then
                    statusLabelSecretBoss.Set("Đang chờ thông báo Boss mới từ Chat...")
                end
            end
        end)
    else
        if not Config.AutoHuntBoss then
            secretBossState.active = false
            if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                statusLabelSecretBoss.Set("Đã tắt Chat Sniper.")
            end
        end
    end
end)

createToggleRow(chatBossCard, "Bỏ Qua Cá Thường (Fast Skip)", "Nếu cắn câu không phải Secret Boss đã chọn thì lập tức giật cần thả lại", Config.FastSkipNonBoss, function(v)
    Config.FastSkipNonBoss = v
end)

createToggleRow(chatBossCard, "Kiểm Tra Lực Cần (Power Check)", "Cảnh báo nếu cần câu hiện tại không đủ lực yêu cầu của Boss", Config.SecretBossCheckPower, function(v)
    Config.SecretBossCheckPower = v
end)

createToggleRow(chatBossCard, "Tự Đổi Server Khi Hết Boss (Auto-Hop)", "Tự động đổi server khác ngay khi có thông báo tất cả Secret Boss đã despawn", Config.AutoServerHopOnDespawn, function(v)
    Config.AutoServerHopOnDespawn = v
end)

statusLabelSecretBoss = createInfoRow(chatBossCard, "Trạng Thái Săn:", secretBossState.statusText)

createButtonRow(chatBossCard, "Quét Lại Lịch Sử Chat & Boss", "Kiểm tra lại lịch sử chat xem có Boss nào đang hoạt động không", "Quét Chat", function()
    local found = secretBossState.ScanChatHistory()
    if not found then
        ShowNotification("Kết Quả Quét", "Không tìm thấy Secret Boss nào đang hoạt động trong lịch sử chat.", "INFO", 5)
    end
end)

createButtonRow(chatBossCard, "Dò Tìm & Bay Đến Mép Nước", "Tự động quét tia 360 độ tìm vùng nước và đưa nhân vật ra sát mép bờ câu", "Dò Mép Nước", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local standPos, lookTarget, waterY, found = secretBossState.FindWaterSpot(root.Position, root.CFrame.Position + root.CFrame.LookVector * 50)
        if found then
            root.CFrame = CFrame.lookAt(standPos, lookTarget)
            local wp = Workspace:FindFirstChild("IdenticalWaterPlatform")
            if wp then
                wp.CFrame = CFrame.new(standPos.X, (waterY or standPos.Y) - 1.2, standPos.Z)
                wp.CanCollide = true
            end
            ShowNotification("Mép Nước", "Đã tìm thấy vùng nước và bay ra sát mép bờ câu!", "SUCCESS", 5)
            CancelAndRecastRod()
        else
            ShowNotification("Mép Nước", "Không tìm thấy vùng nước trong bán kính 220 studs!", "WARN", 5)
        end
    end
end)

createButtonRow(chatBossCard, "Chọn Tất Cả Secret Boss", "Bật săn toàn bộ các loài Secret Boss trên mọi đảo", "Chọn Hết", function()
    for bName, _ in pairs(Config.SecretBossTargets) do
        Config.SecretBossTargets[bName] = true
        if bossTogglesMap[bName] and bossTogglesMap[bName].Set then
            bossTogglesMap[bName].Set(true)
        end
    end
    ShowNotification("Secret Boss", "Đã chọn tất cả Secret Boss!", "SUCCESS")
end)

createButtonRow(chatBossCard, "Bỏ Chọn Tất Cả", "Tắt săn tất cả Secret Boss", "Bỏ Hết", function()
    for bName, _ in pairs(Config.SecretBossTargets) do
        Config.SecretBossTargets[bName] = false
        if bossTogglesMap[bName] and bossTogglesMap[bName].Set then
            bossTogglesMap[bName].Set(false)
        end
    end
    ShowNotification("Secret Boss", "Đã bỏ chọn tất cả Secret Boss.", "INFO")
end)

do
    -- CÀI ĐẶT VỊ TRÍ CÂU TÙY CHỌN (CUSTOM FISHING SPOTS - HỖ TRỢ 3 ĐIỂM/ĐẢO + XÊ DỊCH)
    createCategoryHeader(tabBoss, "📍 CÀI ĐẶT VỊ TRÍ CÂU TÙY CHỌN (CUSTOM SPOTS)")
    local customSpotCard = createCardGroup(tabBoss)

    local islandNamesList = {}
    for _, entry in ipairs(secretBossDatabase) do
        table.insert(islandNamesList, entry.islandName)
    end

    local function GetSpotStats()
        local islandCount = 0
        local spotCount = 0
        for _, entry in ipairs(secretBossDatabase) do
            local spots = secretBossState.GetIslandSpots(entry.islandName)
            if #spots > 0 then
                islandCount = islandCount + 1
                spotCount = spotCount + #spots
            end
        end
        return islandCount, spotCount
    end

    local function GetSlotStatusText(islandName, slot)
        local spot = secretBossState.GetIslandSlotSpot(islandName, slot)
        if spot and spot.cframe then
            local cf = CFrame.new(unpack(spot.cframe))
            return string.format("ĐÃ LƯU (%s) tại X:%.0f Y:%.0f Z:%.0f", spot.savedAt or "Đã lưu", cf.Position.X, cf.Position.Y, cf.Position.Z)
        end
        return "CHƯA CÀI ĐẶT (Đang trống)"
    end

    local islCount, spCount = GetSpotStats()
    local infoSavedSpots = createInfoRow(customSpotCard, "Tiến Độ Đã Cài:", string.format("%d / %d đảo (Tổng %d vị trí)", islCount, #islandNamesList, spCount))

    local currentIsland = Config.SelectedCustomSpotIsland or islandNamesList[1]
    local currentSlot = Config.SelectedCustomSpotSlot or 1

    local infoCurrentSlot = nil

    local function RefreshSpotUI()
        local ic, sc = GetSpotStats()
        if infoSavedSpots and infoSavedSpots.Set then
            infoSavedSpots.Set(string.format("%d / %d đảo (Tổng %d vị trí)", ic, #islandNamesList, sc))
        end
        if infoCurrentSlot and infoCurrentSlot.Set then
            infoCurrentSlot.Set(GetSlotStatusText(currentIsland, currentSlot))
        end
    end

    local islandDropdown = createDropdownRow(customSpotCard, "Chọn Đảo Cần Cài / Thử", "Chọn hòn đảo mục tiêu để lưu hoặc test vị trí câu", islandNamesList, currentIsland, function(v)
        currentIsland = v
        Config.SelectedCustomSpotIsland = v
        RefreshSpotUI()
    end)

    local slotOptions = {"Vị Trí 1", "Vị Trí 2", "Vị Trí 3"}
    local slotDropdown = createDropdownRow(customSpotCard, "Chọn Vị Trí (Slot 1 - 3)", "Mỗi đảo có thể lưu tối đa 3 vị trí câu khác nhau", slotOptions, "Vị Trí " .. tostring(currentSlot), function(v)
        local num = tonumber(string.match(v, "%d")) or 1
        currentSlot = num
        Config.SelectedCustomSpotSlot = num
        RefreshSpotUI()
    end)

    infoCurrentSlot = createInfoRow(customSpotCard, "Trạng Thái Vị Trí:", GetSlotStatusText(currentIsland, currentSlot))

    local allocOptions = {
        "Tự Động (Theo Acc - Tránh Trùng)",
        "Ngẫu Nhiên (Random Điểm)",
        "Vị Trí 1",
        "Vị Trí 2",
        "Vị Trí 3"
    }
    createDropdownRow(customSpotCard, "Phân Bổ Vị Trí Khi Săn Boss", "Nhiều acc cùng server sẽ tự chia nhau các vị trí khác nhau", allocOptions, Config.BossSpotAllocationMode or allocOptions[1], function(v)
        Config.BossSpotAllocationMode = v
    end)

    createToggleRow(customSpotCard, "Xê Dịch Ngang Tránh Đè Nhau", "Tự động lệch trái/phải 0.5m - 1.2m dọc bờ biển để không ai bị đứng đè lên nhau", Config.BossTeleportJitter, function(v)
        Config.BossTeleportJitter = v
    end)

    local distOptions = {"0.5m (Nhẹ)", "1.0m (Chuẩn)", "1.5m (Rộng)"}
    local initialDistStr = "1.0m (Chuẩn)"
    if Config.BossTeleportJitterDist == 0.5 then initialDistStr = "0.5m (Nhẹ)"
    elseif Config.BossTeleportJitterDist == 1.5 then initialDistStr = "1.5m (Rộng)" end

    createDropdownRow(customSpotCard, "Độ Lệch Xê Dịch Ngang", "Khoảng cách dạt sang trái hoặc phải theo mép nước", distOptions, initialDistStr, function(v)
        if v:find("0.5") then Config.BossTeleportJitterDist = 0.5
        elseif v:find("1.5") then Config.BossTeleportJitterDist = 1.5
        else Config.BossTeleportJitterDist = 1.0 end
    end)

    createButtonRow(customSpotCard, "⚡ TỰ NHẬN DIỆN & LƯU VÀO VỊ TRÍ TRỐNG TIẾP THEO", "Đứng ở mép nước trên đảo, script tự biết đảo và lưu vào vị trí trống (1 -> 2 -> 3)!", "LƯU ĐIỂM TIẾP THEO", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local nearestEntry, dist = secretBossState.GetNearestIsland()
        if nearestEntry then
            local targetIsland = nearestEntry.islandName
            local targetSlot = 1
            for i = 1, 3 do
                local existing = secretBossState.GetIslandSlotSpot(targetIsland, i)
                if not existing then
                    targetSlot = i
                    break
                end
            end
            secretBossState.SaveIslandSlot(targetIsland, targetSlot, {root.CFrame:GetComponents()})
            currentIsland = targetIsland
            currentSlot = targetSlot
            Config.SelectedCustomSpotIsland = targetIsland
            Config.SelectedCustomSpotSlot = targetSlot
            if islandDropdown and islandDropdown.Set then islandDropdown.Set(targetIsland) end
            if slotDropdown and slotDropdown.Set then slotDropdown.Set("Vị Trí " .. tostring(targetSlot)) end
            RefreshSpotUI()
            local totalSaved = #secretBossState.GetIslandSpots(targetIsland)
            ShowNotification("ĐÃ LƯU VỊ TRÍ CÂU!", string.format("Đã lưu [Vị Trí %d] cho %s! (Đảo này đã có %d/3 vị trí)", targetSlot, targetIsland, totalSaved), "SUCCESS", 7)
        else
            ShowNotification("Lỗi Nhận Diện", "Không xác định được đảo gần nhất!", "ERROR", 5)
        end
    end)

    createButtonRow(customSpotCard, "Lưu Vào Đảo & Vị Trí Đang Chọn", "Lưu tọa độ & hướng nhìn hiện tại vào chính xác Slot đang chọn ở trên", "Lưu Vào Slot Này", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        secretBossState.SaveIslandSlot(currentIsland, currentSlot, {root.CFrame:GetComponents()})
        RefreshSpotUI()
        local totalSaved = #secretBossState.GetIslandSpots(currentIsland)
        ShowNotification("ĐÃ LƯU VỊ TRÍ CÂU!", string.format("Đã lưu [Vị Trí %d] cho %s! (Đảo này đã có %d/3 vị trí)", currentSlot, currentIsland, totalSaved), "SUCCESS", 6)
    end)

    createButtonRow(customSpotCard, "Bay Thử Vị Trí Đang Chọn", "Bay đến vị trí đang chọn để kiểm tra (có kèm xê dịch nếu đang bật)", "Bay Thử", function()
        local spot = secretBossState.GetIslandSlotSpot(currentIsland, currentSlot)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and spot and spot.cframe then
            local baseCf = CFrame.new(unpack(spot.cframe))
            local finalCf = secretBossState.ApplyJitter(baseCf)
            root.CFrame = finalCf
            local wp = Workspace:FindFirstChild("IdenticalWaterPlatform")
            if wp then
                wp.CFrame = CFrame.new(root.Position.X, root.Position.Y - 2.5 - 1.2, root.Position.Z)
                wp.CanCollide = true
            end
            local jitterMsg = Config.BossTeleportJitter and " (+ xê dịch né người)" or ""
            ShowNotification("Bay Thử Vị Trí", string.format("Đã bay đến [Vị Trí %d] của [%s]%s!", currentSlot, currentIsland, jitterMsg), "SUCCESS", 5)
        else
            ShowNotification("Chưa Cài Đặt", string.format("Bạn chưa lưu [Vị Trí %d] cho [%s]!", currentSlot, currentIsland), "WARN", 5)
        end
    end)

    createButtonRow(customSpotCard, "Xóa Vị Trí Đang Chọn", "Xóa chỉ riêng vị trí (Slot) đang chọn này của đảo", "Xóa Slot Này", function()
        secretBossState.DeleteIslandSlot(currentIsland, currentSlot)
        RefreshSpotUI()
        ShowNotification("Đã Xóa Vị Trí", string.format("Đã xóa [Vị Trí %d] của [%s].", currentSlot, currentIsland), "INFO", 4)
    end)

    createButtonRow(customSpotCard, "Xóa Hết Cả 3 Vị Trí Của Đảo Này", "Xóa toàn bộ các vị trí đã lưu của đảo đang chọn để dùng dò tìm mép nước gốc", "Xóa Cả Đảo", function()
        secretBossState.DeleteIslandSlot(currentIsland, 0)
        RefreshSpotUI()
        ShowNotification("Đã Xóa Hết", string.format("Đã xóa toàn bộ vị trí tùy chọn của [%s].", currentIsland), "INFO", 4)
    end)

    createButtonRow(customSpotCard, "📋 COPY TOÀN BỘ TỌA ĐỘ (ĐỂ NẠP VÀO SCRIPT GỐC)", "Copy toàn bộ 2-3 vị trí đã cài của tất cả các đảo ra mã Lua để dán vào code gốc cho TẤT CẢ mọi người dùng chung", "COPY TỌA ĐỘ", function()
        local lines = {}
        table.insert(lines, "-- [[ TỌA ĐỘ VỊ TRÍ CÂU SĂN BOSS DO NGƯỜI DÙNG CÀI ĐẶT (ĐA ĐIỂM + HƯỚNG NHÌN) ]]")
        table.insert(lines, "-- Dán bảng này gửi lại cho AI để nhúng thẳng vào script gốc cho TẤT CẢ mọi người dùng chung:")
        table.insert(lines, "local customBossSpotsBake = {")
        local totalIslands = 0
        local totalSpots = 0
        for _, entry in ipairs(secretBossDatabase) do
            local spots = secretBossState.GetIslandSpots(entry.islandName)
            if #spots > 0 then
                totalIslands = totalIslands + 1
                totalSpots = totalSpots + #spots
                table.insert(lines, string.format("    [%q] = {", entry.islandName))
                table.insert(lines, "        spots = {")
                for _, s in ipairs(spots) do
                    local cf = CFrame.new(unpack(s.cframe))
                    local pos = cf.Position
                    local lookAt = pos + (cf.LookVector * 50)
                    table.insert(lines, string.format("            [%d] = {\n                pos = Vector3.new(%.1f, %.1f, %.1f),\n                lookAt = Vector3.new(%.1f, %.1f, %.1f),\n            },", s.slot, pos.X, pos.Y, pos.Z, lookAt.X, lookAt.Y, lookAt.Z))
                end
                table.insert(lines, "        },")
                table.insert(lines, "    },")
            end
        end
        table.insert(lines, "}")
        if totalSpots == 0 then
            ShowNotification("Chưa Có Tọa Độ", "Bạn chưa cài tọa độ cho đảo nào cả! Hãy đi đến các đảo và bấm Lưu trước.", "WARN", 5)
            return
        end
        local fullCode = table.concat(lines, "\n")
        print("\n======== [TỌA ĐỘ VỊ TRÍ CÂU SĂN BOSS EXPORT] ========\n" .. fullCode .. "\n====================================================\n")
        local copied = false
        if setclipboard then
            setclipboard(fullCode)
            copied = true
        elseif toclipboard then
            toclipboard(fullCode)
            copied = true
        end
        if copied then
            ShowNotification("ĐÃ COPY VÀO CLIPBOARD!", string.format("Đã copy tọa độ của %d đảo (%d vị trí)! Dán vào chat với AI để nạp vào script gốc cho tất cả mọi người dùng chung.", totalIslands, totalSpots), "SUCCESS", 8)
        else
            ShowNotification("Xuất Tọa Độ", "Đã in mã tọa độ ra bảng điều khiển Console F9! Hãy mở F9 để copy.", "INFO", 6)
        end
    end)
end

-- Danh sách từng đảo và Secret Boss
for _, entry in ipairs(secretBossDatabase) do
    createCategoryHeader(tabBoss, string.format("📍 %s [%s]", entry.islandName, entry.weather))
    local islandBossCard = createCardGroup(tabBoss)
    for _, b in ipairs(entry.bosses) do
        local isEnabled = Config.SecretBossTargets[b.name] == true
        local toggleObj = createToggleRow(islandBossCard, b.name, "Phần thưởng: " .. b.reward, isEnabled, function(v)
            Config.SecretBossTargets[b.name] = v
        end)
        bossTogglesMap[b.name] = toggleObj
    end
end

createCategoryHeader(tabBoss, "Đấu Trường Boss Enzo")
local bossFarmCard = createCardGroup(tabBoss)
createToggleRow(bossFarmCard, "Tự Động Săn Boss (Enzo)", "Liên tục triệu hồi và đánh bại boss Enzo", Config.AutoFarmBoss, function(v) Config.AutoFarmBoss = v end)
createToggleRow(bossFarmCard, "Tự Săn Secret Boss (Bạch Tuộc)", "Tự chế mồi Nameless Bait, triệu hồi và tiêu diệt", Config.AutoFarmSecretBoss, function(v) Config.AutoFarmSecretBoss = v end)

createButtonRow(bossFarmCard, "Bay Đến Boss Enzo", "Dịch chuyển trực tiếp đến đấu trường Enzo", "Bay Đến", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(-115.3, 9.2, 1349.5)
        ShowNotification("Dịch Chuyển", "Đã đến Đấu trường Boss Enzo!", "SUCCESS")
    end
end)

do
    createCategoryHeader(tabWiki, "⚡ THAO TÁC NHANH TÚI ĐỒ (BAG QUICK ACTIONS)")
    local wikiActionCard = createCardGroup(tabWiki)

    local RefreshWikiBagCounts

    local btnUnlockUnnecessary = createButtonRow(wikiActionCard, "Mở Khóa Toàn Bộ Cá Không Cần Thiết", "Mở khóa tất cả cá thường để AutoSell tự động bán dọn trống balo", "🔓 Mở Khóa", function()
        Wiki.UnlockAllUnnecessaryFish()
        if RefreshWikiBagCounts then RefreshWikiBagCounts() end
    end)
    btnUnlockUnnecessary.Size = UDim2.new(0, 110, 0, 26)
    btnUnlockUnnecessary.Position = UDim2.new(1, -110, 0.5, -13)
    btnUnlockUnnecessary.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
    btnUnlockUnnecessary.TextColor3 = Colors.TextWhite

    local btnLockAllKeep = createButtonRow(wikiActionCard, "Khóa Bảo Vệ Toàn Bộ Cá Cần Giữ", "Khóa bảo vệ tất cả Secret Boss, Cá Nguyên Liệu và Cá Đột Biến", "🔒 Khóa Bảo Vệ", function()
        Wiki.LockAllKeepFish()
        if RefreshWikiBagCounts then RefreshWikiBagCounts() end
    end)
    btnLockAllKeep.Size = UDim2.new(0, 110, 0, 26)
    btnLockAllKeep.Position = UDim2.new(1, -110, 0.5, -13)
    btnLockAllKeep.BackgroundColor3 = Colors.PurpleDark
    btnLockAllKeep.TextColor3 = Colors.TextWhite

    createButtonRow(wikiActionCard, "Đồng Bộ & Làm Mới Balo", "Quét lại toàn bộ túi đồ và cập nhật số lượng từng loại cá", "🔄 Cập Nhật", function()
        if RefreshWikiBagCounts then RefreshWikiBagCounts() end
        ShowNotification("Wiki Balo", "Đã cập nhật số lượng cá mới nhất từ túi đồ!", "SUCCESS", 3)
    end)

    local infoBagSummary = createInfoRow(wikiActionCard, "Sức Chứa Balo & Phân Loại Cá", "Đang kiểm tra...", false)

    createCategoryHeader(tabWiki, "🔍 BỘ LỌC & TÌM KIẾM CÁ")
    local wikiFilterCard = createCardGroup(tabWiki)

    -- Row 1: Search Box
    local searchRow = createBaseRow(wikiFilterCard, "Tìm Kiếm Cá", "Gõ tên loài cá, bản đồ hoặc công dụng để tìm kiếm", false)
    local searchTb = Instance.new("TextBox")
    searchTb.Size = UDim2.new(0, 200, 0, 26)
    searchTb.Position = UDim2.new(1, -200, 0.5, -13)
    searchTb.BackgroundColor3 = Colors.InputBg
    searchTb.Font = Enum.Font.Gotham
    searchTb.PlaceholderText = "Nhập tên cá, map, công dụng..."
    searchTb.PlaceholderColor3 = Colors.TextMuted
    searchTb.Text = ""
    searchTb.TextColor3 = Colors.TextWhite
    searchTb.TextSize = 11
    searchTb.ClearTextOnFocus = false
    searchTb.BorderSizePixel = 0
    searchTb.Parent = searchRow
    Instance.new("UICorner", searchTb).CornerRadius = UDim.new(0, 4)
    local searchStroke = Instance.new("UIStroke", searchTb)
    searchStroke.Color = Colors.BorderSubtle
    searchStroke.Thickness = 1

    -- Row 2: Filter Buttons (All, Keep, Sell, InBag)
    local filterRow = createBaseRow(wikiFilterCard, "Chế Độ Lọc", "Chọn danh mục cá muốn tra cứu", false)
    local filterBtnContainer = Instance.new("Frame")
    filterBtnContainer.Size = UDim2.new(0, 280, 0, 26)
    filterBtnContainer.Position = UDim2.new(1, -280, 0.5, -13)
    filterBtnContainer.BackgroundTransparency = 1
    filterBtnContainer.Parent = filterRow
    local fLayout = Instance.new("UIListLayout")
    fLayout.FillDirection = Enum.FillDirection.Horizontal
    fLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    fLayout.SortOrder = Enum.SortOrder.LayoutOrder
    fLayout.Padding = UDim.new(0, 4)
    fLayout.Parent = filterBtnContainer

    local filterButtons = {}
    local currentWikiFilter = "ALL"
    local currentWikiSearch = ""

    local function makeFilterBtn(name, text, width)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, width or 65, 1, 0)
        b.BackgroundColor3 = (currentWikiFilter == name) and Colors.PurpleAccent or Colors.ControlBg
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.TextColor3 = (currentWikiFilter == name) and Colors.TextWhite or Colors.PurplePrimary
        b.TextSize = 10
        b.BorderSizePixel = 0
        b.Parent = filterBtnContainer
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        filterButtons[name] = b
        return b
    end

    local btnFAll   = makeFilterBtn("ALL", "Tất Cả (51)", 66)
    local btnFKeep  = makeFilterBtn("KEEP", "⭐ Cần Giữ", 70)
    local btnFSell  = makeFilterBtn("SELL", "💰 Nên Bán", 70)
    local btnFInBag = makeFilterBtn("IN_BAG", "🎒 Trong Túi", 70)

    createCategoryHeader(tabWiki, "📖 BÁCH KHOA TOÀN THƯ CÁ (FISH ENCYCLOPEDIA)")
    local wikiListContainer = Instance.new("Frame")
    wikiListContainer.Size = UDim2.new(1, 0, 0, 0)
    wikiListContainer.AutomaticSize = Enum.AutomaticSize.Y
    wikiListContainer.BackgroundTransparency = 1
    wikiListContainer.Parent = tabWiki
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = wikiListContainer

    local cardEntries = {}

    local function UpdateCardFilter()
        local q = currentWikiSearch:lower():gsub("^%s+", ""):gsub("%s+$", "")
        for _, entry in ipairs(cardEntries) do
            local f = entry.fishData
            local matchQ = true
            if #q > 0 then
                local fName = f.name:lower()
                local fOrigin = f.origin:lower()
                local fUse = f.use:lower()
                local fRarity = f.rarity:lower()
                matchQ = fName:find(q, 1, true) or fOrigin:find(q, 1, true) or fUse:find(q, 1, true) or fRarity:find(q, 1, true)
            end

            local matchF = true
            if currentWikiFilter == "KEEP" then
                matchF = (f.keep == true)
            elseif currentWikiFilter == "SELL" then
                matchF = (f.keep == false)
            elseif currentWikiFilter == "IN_BAG" then
                matchF = (entry.currentCount > 0)
            end

            entry.cardFrame.Visible = matchQ and matchF
        end
    end

    local function SetFilterMode(mode)
        currentWikiFilter = mode
        for m, b in pairs(filterButtons) do
            local isActive = (m == mode)
            b.BackgroundColor3 = isActive and Colors.PurpleAccent or Colors.ControlBg
            b.TextColor3 = isActive and Colors.TextWhite or Colors.PurplePrimary
        end
        UpdateCardFilter()
    end

    btnFAll.MouseButton1Click:Connect(function() SetFilterMode("ALL") end)
    btnFKeep.MouseButton1Click:Connect(function() SetFilterMode("KEEP") end)
    btnFSell.MouseButton1Click:Connect(function() SetFilterMode("SELL") end)
    btnFInBag.MouseButton1Click:Connect(function() SetFilterMode("IN_BAG") end)

    searchTb:GetPropertyChangedSignal("Text"):Connect(function()
        currentWikiSearch = searchTb.Text
        UpdateCardFilter()
    end)

    RefreshWikiBagCounts = function()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        local totalItems = 0
        local totalKeepInBag = 0
        local totalSellInBag = 0
        local invLimit = 100

        if pData then
            if pData:FindFirstChild("InventoryLimit") then
                invLimit = tonumber(pData.InventoryLimit.Value) or 100
            end
            local folders = {}
            if pData:FindFirstChild("Inventory") then table.insert(folders, pData.Inventory) end
            if pData:FindFirstChild("Hotbar") then table.insert(folders, pData.Hotbar) end
            for _, folder in ipairs(folders) do
                for _, item in ipairs(folder:GetChildren()) do
                    local qVal = item:FindFirstChild("Quantity") or item:FindFirstChild("Count") or item:FindFirstChild("Amount")
                    local qty = (qVal and tonumber(qVal.Value)) or 1
                    totalItems = totalItems + qty
                    if Wiki.IsEssentialKeepItem(item) then
                        totalKeepInBag = totalKeepInBag + qty
                    else
                        totalSellInBag = totalSellInBag + qty
                    end
                end
            end
        end

        if infoBagSummary and infoBagSummary.Set then
            infoBagSummary.Set(string.format("%d / %d ô (%d cá cần giữ | %d cá nên bán)", totalItems, invLimit, totalKeepInBag, totalSellInBag))
        end

        local typesInBagCount = 0
        for _, entry in ipairs(cardEntries) do
            local f = entry.fishData
            local cnt = Wiki.GetPlayerFishCount(f.name)
            entry.currentCount = cnt
            if cnt > 0 then typesInBagCount = typesInBagCount + 1 end
            if entry.countLabel then
                if cnt > 0 then
                    entry.countLabel.Text = string.format("Đang có: %d con", cnt)
                    entry.countLabel.TextColor3 = f.keep and Colors.AccentYellow or Colors.AccentGreen
                    if entry.countBox then
                        entry.countBox.BackgroundColor3 = Colors.ControlBg
                    end
                else
                    entry.countLabel.Text = "Đang có: 0 con"
                    entry.countLabel.TextColor3 = Colors.TextMuted
                    if entry.countBox then
                        entry.countBox.BackgroundColor3 = Colors.InputBg
                    end
                end
            end
        end

        btnFInBag.Text = string.format("🎒 Trong Túi (%d)", typesInBagCount)
        UpdateCardFilter()
    end

    -- Tạo từng Thẻ Cá (Card) trong Bách Khoa Toàn Thư
    for idx, f in ipairs(Wiki.wikiFishData) do
        local rColor = Wiki.rarityColors[f.rarity] or Colors.PurplePrimary

        local card = Instance.new("Frame")
        card.Name = "FishCard_" .. f.name:gsub("%s+", "_")
        card.Size = UDim2.new(1, 0, 0, 74)
        card.BackgroundColor3 = Colors.RowNormal
        card.BorderSizePixel = 0
        card.LayoutOrder = idx
        card.Parent = wikiListContainer
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        local cardStroke = Instance.new("UIStroke", card)
        cardStroke.Color = Colors.BorderSubtle
        cardStroke.Thickness = 1

        card.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowHover}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowNormal}):Play()
        end)

        -- 1. Icon & Rarity (Trái)
        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(0, 50, 0, 50)
        iconFrame.Position = UDim2.new(0, 10, 0.5, -25)
        iconFrame.BackgroundColor3 = Colors.InputBg
        iconFrame.BorderSizePixel = 0
        iconFrame.Parent = card
        Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 6)
        local iconStroke = Instance.new("UIStroke", iconFrame)
        iconStroke.Color = rColor
        iconStroke.Thickness = 1.2

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -6, 1, -6)
        img.Position = UDim2.new(0, 3, 0, 3)
        img.BackgroundTransparency = 1
        local cardIcon = f.icon or "rbxassetid://10709791437"
        pcall(function()
            cardIcon = Wiki.ResolveFishIcon(f.name, f.icon)
        end)
        img.Image = cardIcon
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = iconFrame

        local rarityTag = Instance.new("TextLabel")
        rarityTag.Size = UDim2.new(1, 0, 0, 12)
        rarityTag.Position = UDim2.new(0, 0, 1, -12)
        rarityTag.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
        rarityTag.BackgroundTransparency = 0.3
        rarityTag.Font = Enum.Font.GothamBold
        rarityTag.Text = f.rarity:upper()
        rarityTag.TextColor3 = rColor
        rarityTag.TextSize = 8
        rarityTag.Parent = iconFrame

        -- 2. Chi Tiết Cá & Công Dụng (Giữa)
        local infoContainer = Instance.new("Frame")
        infoContainer.Size = UDim2.new(1, -195, 1, -12)
        infoContainer.Position = UDim2.new(0, 68, 0, 6)
        infoContainer.BackgroundTransparency = 1
        infoContainer.Parent = card

        local headerLine = Instance.new("Frame")
        headerLine.Size = UDim2.new(1, 0, 0, 18)
        headerLine.BackgroundTransparency = 1
        headerLine.Parent = infoContainer

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -85, 1, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.Text = f.name
        nameLbl.TextColor3 = rColor
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Parent = headerLine

        local badge = Instance.new("Frame")
        badge.Size = UDim2.new(0, 78, 0, 16)
        badge.Position = UDim2.new(1, -78, 0.5, -8)
        badge.BackgroundColor3 = f.keep and Color3.fromRGB(16, 45, 25) or Color3.fromRGB(45, 25, 15)
        badge.BorderSizePixel = 0
        badge.Parent = headerLine
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
        local bStroke = Instance.new("UIStroke", badge)
        bStroke.Color = f.keep and Colors.AccentGreen or Colors.AccentOrange
        bStroke.Thickness = 0.8
        local badgeTxt = Instance.new("TextLabel")
        badgeTxt.Size = UDim2.new(1, 0, 1, 0)
        badgeTxt.BackgroundTransparency = 1
        badgeTxt.Font = Enum.Font.GothamBold
        badgeTxt.Text = f.keep and "⭐ NÊN GIỮ" or "💰 NÊN BÁN"
        badgeTxt.TextColor3 = f.keep and Colors.AccentGreen or Colors.AccentOrange
        badgeTxt.TextSize = 9
        badgeTxt.Parent = badge

        local originLbl = Instance.new("TextLabel")
        originLbl.Size = UDim2.new(1, 0, 0, 14)
        originLbl.Position = UDim2.new(0, 0, 0, 18)
        originLbl.BackgroundTransparency = 1
        originLbl.Font = Enum.Font.Gotham
        originLbl.Text = "📍 " .. f.origin
        originLbl.TextColor3 = Colors.TextMuted
        originLbl.TextSize = 10
        originLbl.TextXAlignment = Enum.TextXAlignment.Left
        originLbl.Parent = infoContainer

        local useLbl = Instance.new("TextLabel")
        useLbl.Size = UDim2.new(1, 0, 0, 26)
        useLbl.Position = UDim2.new(0, 0, 0, 32)
        useLbl.BackgroundTransparency = 1
        useLbl.Font = Enum.Font.Gotham
        useLbl.Text = f.use
        useLbl.TextColor3 = Colors.TextSubtle
        useLbl.TextSize = 10
        useLbl.TextXAlignment = Enum.TextXAlignment.Left
        useLbl.TextWrapped = true
        useLbl.Parent = infoContainer

        -- 3. Số Lượng Balo & Nút Thao Tác (Phải)
        local actionContainer = Instance.new("Frame")
        actionContainer.Size = UDim2.new(0, 110, 1, -12)
        actionContainer.Position = UDim2.new(1, -118, 0, 6)
        actionContainer.BackgroundTransparency = 1
        actionContainer.Parent = card

        local countBox = Instance.new("Frame")
        countBox.Size = UDim2.new(1, 0, 0, 24)
        countBox.Position = UDim2.new(0, 0, 0, 2)
        countBox.BackgroundColor3 = Colors.InputBg
        countBox.BorderSizePixel = 0
        countBox.Parent = actionContainer
        Instance.new("UICorner", countBox).CornerRadius = UDim.new(0, 4)
        local countStroke = Instance.new("UIStroke", countBox)
        countStroke.Color = Colors.BorderSubtle
        countStroke.Thickness = 0.8

        local countLbl = Instance.new("TextLabel")
        countLbl.Size = UDim2.new(1, 0, 1, 0)
        countLbl.BackgroundTransparency = 1
        countLbl.Font = Enum.Font.GothamBold
        countLbl.Text = "Đang có: 0 con"
        countLbl.TextColor3 = Colors.TextMuted
        countLbl.TextSize = 10
        countLbl.Parent = countBox

        local singleBtn = Instance.new("TextButton")
        singleBtn.Size = UDim2.new(1, 0, 0, 24)
        singleBtn.Position = UDim2.new(0, 0, 1, -26)
        singleBtn.BackgroundColor3 = f.keep and Colors.ControlBg or Color3.fromRGB(36, 20, 20)
        singleBtn.Font = Enum.Font.GothamBold
        singleBtn.Text = f.keep and "🔒 Khóa Này" or "🔓 Mở Này"
        singleBtn.TextColor3 = f.keep and Colors.PurplePrimary or Colors.AccentOrange
        singleBtn.TextSize = 10
        singleBtn.BorderSizePixel = 0
        singleBtn.Parent = actionContainer
        Instance.new("UICorner", singleBtn).CornerRadius = UDim.new(0, 4)
        local btnStroke = Instance.new("UIStroke", singleBtn)
        btnStroke.Color = f.keep and Colors.BorderPurple or Colors.AccentOrange
        btnStroke.Thickness = 0.8

        singleBtn.MouseEnter:Connect(function()
            TweenService:Create(singleBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = f.keep and Colors.PurpleDark or Color3.fromRGB(55, 25, 25),
                TextColor3 = Colors.TextWhite
            }):Play()
        end)
        singleBtn.MouseLeave:Connect(function()
            TweenService:Create(singleBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = f.keep and Colors.ControlBg or Color3.fromRGB(36, 20, 20),
                TextColor3 = f.keep and Colors.PurplePrimary or Colors.AccentOrange
            }):Play()
        end)

        singleBtn.MouseButton1Click:Connect(function()
            Wiki.ToggleLockSpecificFish(f.name, f.keep)
            task.delay(0.3, RefreshWikiBagCounts)
        end)

        table.insert(cardEntries, {
            cardFrame = card,
            fishData = f,
            countBox = countBox,
            countLabel = countLbl,
            countStroke = countStroke,
            singleBtn = singleBtn,
            currentCount = 0
        })
    end

    -- Lắng nghe khi mở Tab Wiki thì tự động làm mới số lượng
    if tabButtons and tabButtons["Wiki"] then
        tabButtons["Wiki"].MouseButton1Click:Connect(function()
            task.spawn(RefreshWikiBagCounts)
        end)
    end

    -- Tự động làm mới khi có cá mới thêm vào hoặc bán bớt trong balo
    task.spawn(function()
        local pDataInit = ReplicatedStorage:WaitForChild("Data", 10)
        local userFolder = pDataInit and pDataInit:WaitForChild(tostring(LocalPlayer.UserId), 10)
        local invFolder = userFolder and userFolder:WaitForChild("Inventory", 10)
        if invFolder then
            table.insert(activeConnections, invFolder.ChildAdded:Connect(function()
                task.wait(0.4)
                pcall(RefreshWikiBagCounts)
            end))
            table.insert(activeConnections, invFolder.ChildRemoved:Connect(function()
                task.wait(0.4)
                pcall(RefreshWikiBagCounts)
            end))
        end
    end)

    -- Khởi tạo lần đầu
    task.delay(1.0, function()
        pcall(RefreshWikiBagCounts)
    end)
end

do
createCategoryHeader(tabGod, "Tương Tác Thần Linh (God Spirit)")
local godCard = createCardGroup(tabGod)

createButtonRow(godCard, "Kiểm Tra Thần Linh", "Kiểm tra bùa chú may mắn hiện tại (Vàng / Xanh)", "Kiểm Tra", function()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData and pData:FindFirstChild("GodSpirit") then
        local y = pData.GodSpirit:FindFirstChild("Yellow") and pData.GodSpirit.Yellow.Value or false
        local b = pData.GodSpirit:FindFirstChild("Blue") and pData.GodSpirit.Blue.Value or false
        local g = pData.GodSpirit:FindFirstChild("Green") and pData.GodSpirit.Green.Value or false
        local msg = string.format("Yellow: %s | Blue: %s | Green: %s", y and "ACTIVE" or "OFF", b and "ACTIVE" or "OFF", g and "ACTIVE" or "OFF")
        ShowNotification("Trạng Thái Thần Linh", msg, "SUCCESS", 6)
    else
        ShowNotification("Thần Linh", "Không đọc được dữ liệu Thần Linh.", "WARN")
    end
end)

createToggleRow(godCard, "Tự Động Cầu Nguyện", "Tự cầu nguyện nhận bùa khi đứng gần Đền Thần", Config.AutoPrayGodSpirit, function(v) Config.AutoPrayGodSpirit = v end)

createButtonRow(godCard, "Bay Đến Đền Thần Linh", "Dịch chuyển đến Bàn thờ Thần linh (Battlefield Isle)", "Bay Đến", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local spirit = (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Spirit")) or (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God"))
        if spirit then
            root.CFrame = spirit:GetPivot() + Vector3.new(0, 3, 5)
            ShowNotification("Thần Linh", "Đã dịch chuyển đến Bàn Thờ Thần Linh!", "SUCCESS")
        else
            root.CFrame = CFrame.new(1245.7, 19.3, -133.4)
            ShowNotification("Thần Linh", "Đã dịch chuyển đến Đền Thờ!", "SUCCESS")
        end
    end
end)

createButtonRow(godCard, "Bay Đến Đạo Sĩ (Taoist)", "Dịch chuyển đến vị trí Đạo Sĩ (Taoist / Maoshan) nếu có trong server", "Bay Đến", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tInst, tName = secretBossState.ScanForTaoistNPC()
    if tInst then
        local pivot = (tInst:IsA("Model") and tInst:GetPivot()) or (tInst:IsA("BasePart") and tInst.CFrame)
        if pivot then
            root.CFrame = pivot + Vector3.new(0, 3, 4)
            ShowNotification("Đạo Sĩ (Taoist)", "Đã dịch chuyển đến vị trí " .. tostring(tName) .. "!", "SUCCESS", 5)
        else
            ShowNotification("Đạo Sĩ (Taoist)", "Không lấy được tọa độ Đạo Sĩ.", "WARN")
        end
    else
        ShowNotification("Đạo Sĩ (Taoist)", "Server này hiện chưa xuất hiện Đạo Sĩ! Hãy bật 'Đổi Server Tìm Taoist'.", "WARN", 6)
    end
end)

createButtonRow(godCard, "Cầu Nguyện Ngay Lập Tức", "Tương tác với Bàn thờ Thần linh ngay bây giờ", "Cầu Nguyện", function()
    local sp = (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Spirit")) or (Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God"))
    if sp then
        local found = false
        for _, d in ipairs(sp:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                TriggerPrompt(d)
                found = true
            end
        end
        if found then
            ShowNotification("Thần Linh", "Đã cầu nguyện Thần Linh thành công!", "SUCCESS")
        else
            ShowNotification("Thần Linh", "Không tìm thấy nút bấm tương tác trên Thần.", "WARN")
        end
    else
        ShowNotification("Thần Linh", "Server này hiện chưa xuất hiện Thần Linh.", "WARN")
    end
end)

createCategoryHeader(tabGod, "Tự Động Đổi Server (Server Hop)")
local hopCard = createCardGroup(tabGod)
createToggleRow(hopCard, "Đổi Server Tìm Thần Linh", "Tự động nhảy server liên tục đến khi gặp God Spirit", Config.AutoServerHopGod, function(v) Config.AutoServerHopGod = v end)
createToggleRow(hopCard, "Đổi Server Tìm Maoshan", "Tự động nhảy server liên tục đến khi gặp Maoshan", Config.AutoServerHopMaoshan, function(v) Config.AutoServerHopMaoshan = v end)
createToggleRow(hopCard, "Đổi Server Tìm Taoist", "Tự động nhảy server liên tục đến khi gặp Đạo sĩ Taoist", Config.AutoServerHopTaoist, function(v) Config.AutoServerHopTaoist = v end)
createButtonRow(hopCard, "Đổi Server Ngay", "Chuyển sang một server ngẫu nhiên khác ngay lập tức", "Đổi Server", ServerHop)
end

do
createCategoryHeader(tabQuests, "Trạng Thái & Bật/Tắt Nhiệm Vụ Vé (Ticket Quests)")
local questCard = createCardGroup(tabQuests)

createToggleRow(questCard, "Tự Động Làm Vé Nhiệm Vụ", "Tự động nhận, thực hiện và trả vé nhiệm vụ theo chu kỳ 20p", Config.AutoTicketQuest, function(v)
    Config.AutoTicketQuest = v
    if v then
        ticketQuestState.active = true
        ShowNotification("Nhiệm Vụ Vé", "Đã bật tự động làm vé nhiệm vụ! Script sẽ quét và thực hiện quest.", "SUCCESS", 6)
    else
        ticketQuestState.active = false
        ticketQuestState.statusText = "Đã tắt tự động làm vé."
        ticketQuestState.UpdateUI()
    end
end)

createDropdownRow(questCard, "Độ Khó Nhiệm Vụ", "Chọn độ khó vé nhiệm vụ nhận từ NPC (Mặc định: Hard)", {"Hard", "Easy"}, Config.TicketDifficulty, function(v)
    Config.TicketDifficulty = v
end)

local questModes = {
    "Tự Động (Auto Detect)",
    "Câu 10 Con Cá 1.5M+ (Map 9)",
    "Tiêu Thụ 100 Mồi (Map 1)",
    "Dùng Kỹ Năng 100 Lần",
    "Câu Nhanh 100 Con Cá (Map 1)"
}
createDropdownRow(questCard, "Chế Độ Nhiệm Vụ", "Tự động nhận diện từ game hoặc ép kiểu nhiệm vụ bạn muốn bot làm", questModes, Config.TicketQuestMode, function(v)
    Config.TicketQuestMode = v
    ticketQuestState.currentQuestType = "none"
    ticketQuestState.currentProgress = 0
    ticketQuestState.activeQuestDetected = false
    ticketQuestState.UpdateUI()
end)

ticketQuestState.uiStatus = createInfoRow(questCard, "Nhiệm Vụ Hiện Tại", ticketQuestState.statusText)
ticketQuestState.uiProgress = createInfoRow(questCard, "Tiến Độ Nhiệm Vụ", "0 / 100 (0%)")
ticketQuestState.uiCooldown = createInfoRow(questCard, "Hồi Chiêu 20 Phút", "Sẵn sàng nhận vé!")

createCategoryHeader(tabQuests, "📍 Cài Đặt Vị Trí Câu & NPC Ticket Quest")
local spotCard = createCardGroup(tabQuests)

ticketQuestState.ui100Spot = createInfoRow(spotCard, "Điểm Câu 100 Con (Map 1)", string.format("(%.0f, %.0f, %.0f)", ticketQuestState.spot100Fish.X, ticketQuestState.spot100Fish.Y, ticketQuestState.spot100Fish.Z))
createButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 100 Con", "Gán vị trí bạn đang đứng làm nơi câu 100 con cá nhẹ", "Lấy Vị Trí", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        ticketQuestState.spot100Fish = root.Position
        ticketQuestState.SaveSpots()
        ticketQuestState.UpdateUI()
        ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu điểm câu 100 con: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS")
    end
end)
createButtonRow(spotCard, "Bay Đến Điểm Câu 100 Con", "Dịch chuyển tức thì đến điểm câu 100 con đã cài", "Bay Đến", function()
    ticketQuestState.TeleportTo(ticketQuestState.spot100Fish)
    ShowNotification("Dịch Chuyển", "Đã bay đến điểm câu 100 con!", "SUCCESS")
end)
createButtonRow(spotCard, "Đặt Lại Mặc Định (Map 1 - Spawn)", "Khôi phục tọa độ gốc của Đảo Khởi Đầu", "Đặt Lại", function()
    ticketQuestState.spot100Fish = Vector3.new(-200.7, 11.1, 35.9)
    ticketQuestState.SaveSpots()
    ticketQuestState.UpdateUI()
    ShowNotification("Vị Trí Nhiệm Vụ", "Đã đặt lại điểm câu 100 con về Map 1!", "SUCCESS")
end)

ticketQuestState.ui100BaitSpot = createInfoRow(spotCard, "Điểm Tiêu Thụ 100 Mồi (Map 1)", string.format("(%.0f, %.0f, %.0f)", ticketQuestState.spot100Bait.X, ticketQuestState.spot100Bait.Y, ticketQuestState.spot100Bait.Z))
createButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 100 Mồi", "Gán vị trí bạn đang đứng làm nơi câu tiêu thụ 100 mồi", "Lấy Vị Trí", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        ticketQuestState.spot100Bait = root.Position
        ticketQuestState.SaveSpots()
        ticketQuestState.UpdateUI()
        ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu điểm 100 mồi: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS")
    end
end)
createButtonRow(spotCard, "Bay Đến Điểm 100 Mồi", "Dịch chuyển tức thì đến điểm câu 100 mồi đã cài", "Bay Đến", function()
    ticketQuestState.TeleportTo(ticketQuestState.spot100Bait)
    ShowNotification("Dịch Chuyển", "Đã bay đến điểm 100 mồi!", "SUCCESS")
end)
createButtonRow(spotCard, "Đặt Lại Mặc Định Điểm 100 Mồi", "Khôi phục tọa độ điểm 100 mồi về Đảo Khởi Đầu", "Đặt Lại", function()
    ticketQuestState.spot100Bait = Vector3.new(-200.7, 11.1, 35.9)
    ticketQuestState.SaveSpots()
    ticketQuestState.UpdateUI()
    ShowNotification("Vị Trí Nhiệm Vụ", "Đã đặt lại điểm 100 mồi về Map 1!", "SUCCESS")
end)

ticketQuestState.ui15MSpot = createInfoRow(spotCard, "Điểm Câu 1.5M (Map 9)", string.format("(%.0f, %.0f, %.0f)", ticketQuestState.spot15MFish.X, ticketQuestState.spot15MFish.Y, ticketQuestState.spot15MFish.Z))
createButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 1.5M", "Gán vị trí bạn đang đứng làm nơi câu cá 1.5M+", "Lấy Vị Trí", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        ticketQuestState.spot15MFish = root.Position
        ticketQuestState.SaveSpots()
        ticketQuestState.UpdateUI()
        ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu điểm câu 1.5M: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS")
    end
end)
createButtonRow(spotCard, "Bay Đến Điểm Câu 1.5M", "Dịch chuyển tức thì đến điểm câu cá 1.5M+ đã cài", "Bay Đến", function()
    ticketQuestState.TeleportTo(ticketQuestState.spot15MFish)
    ShowNotification("Dịch Chuyển", "Đã bay đến điểm câu 1.5M!", "SUCCESS")
end)
createButtonRow(spotCard, "Đặt Lại Mặc Định (Map 9 - Battlefield)", "Khôi phục tọa độ gốc của Đảo Chiến Trường", "Đặt Lại", function()
    ticketQuestState.spot15MFish = Vector3.new(1393.5, 11.3, 169.6)
    ticketQuestState.SaveSpots()
    ticketQuestState.UpdateUI()
    ShowNotification("Vị Trí Nhiệm Vụ", "Đã đặt lại điểm câu 1.5M về Map 9!", "SUCCESS")
end)

ticketQuestState.uiNPCSpot = createInfoRow(spotCard, "Vị Trí NPC Ticket Quest (Map 1)", string.format("(%.0f, %.0f, %.0f)", ticketQuestState.spotNPC.X, ticketQuestState.spotNPC.Y, ticketQuestState.spotNPC.Z))
createButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Vị Trí NPC", "Gán vị trí bạn đang đứng cạnh NPC Ticket Quest", "Lấy Vị Trí", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        ticketQuestState.spotNPC = root.Position
        ticketQuestState.SaveSpots()
        ticketQuestState.UpdateUI()
        ShowNotification("Vị Trí NPC", string.format("Đã lưu vị trí NPC Ticket Quest: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS")
    end
end)
createButtonRow(spotCard, "Tìm & Bay Đến NPC Ticket Quest", "Tự động quét và bay thẳng đến NPC Ticket Quest", "Bay Đến NPC", function()
    local npcModel, npcPos = ticketQuestState.FindTicketNPC()
    if npcPos then
        ticketQuestState.spotNPC = npcPos
        ticketQuestState.TeleportTo(npcPos)
        ticketQuestState.SaveSpots()
        ticketQuestState.UpdateUI()
        ShowNotification("Dịch Chuyển", "Đã tìm thấy và bay đến NPC Ticket Quest!", "SUCCESS")
    else
        ticketQuestState.TeleportTo(ticketQuestState.spotNPC)
        ShowNotification("Dịch Chuyển", "Đã bay đến tọa độ lưu của NPC Ticket Quest!", "SUCCESS")
    end
end)

createCategoryHeader(tabQuests, "⚙️ Tùy Chỉnh Mồi & Kỹ Năng Cho Nhiệm Vụ")
local optionCard = createCardGroup(tabQuests)

local ticketBaits = {"Basic Bait", "Crude Mash Bait", "Corrupted Essence Bait", "Elite Bait", "Ancestral Bait"}
createDropdownRow(optionCard, "Mồi Cho Nhiệm Vụ 100 Mồi", "Loại mồi bot sẽ mua và dùng khi nhận nv 100 mồi", ticketBaits, Config.TicketBaitChoice, function(v)
    Config.TicketBaitChoice = v
end)

local skillList = {"Chiêu Z", "Chiêu X", "Chiêu C", "Chiêu V"}
createDropdownRow(optionCard, "Chiêu Dùng Cho Nhiệm Vụ 100 Skill", "Kỹ năng bot dùng sau 3s khóa chiêu rồi cất cần lặp lại", skillList, Config.TicketSkillKey, function(v)
    Config.TicketSkillKey = v
end)

createDropdownRow(optionCard, "Chiêu Giật Nhanh Cho 100 Con Cá", "Chiêu mạnh nhất dùng để kết liễu cá Map 1 trong 1 hit", skillList, Config.TicketQuickSkill, function(v)
    Config.TicketQuickSkill = v
end)

createSliderRow(optionCard, "Thời Gian Hồi Chiêu Giữa Các Vé", "Thời gian chờ từ game sau khi nhận vé (mặc định 20p)", 1, 30, Config.TicketCooldownMinutes, false, "phút", function(v)
    Config.TicketCooldownMinutes = v
end)

createToggleRow(optionCard, "Tự Bán Cá Khi Đầy Balo (Vé NV)", "Tự động bán sạch cá khi balo đạt giới hạn để câu tiếp", Config.TicketAutoSellFull, function(v)
    Config.TicketAutoSellFull = v
end)

createToggleRow(optionCard, "Tự Về Home Spot Khi Xong Nhiệm Vụ", "Khi trả xong vé và vào thời gian chờ 20p, tự bay về Home Spot để câu farm", Config.TicketReturnHomeWhenDone, function(v)
    Config.TicketReturnHomeWhenDone = v
end)

createToggleRow(optionCard, "Tự Quăng Cần & Đánh Combo Tại Home Spot", "Tự quăng cần và dùng Combo đã cài khi đang chờ ở Home Spot (không cần bật Auto Cast chung)", Config.TicketAutoCastAtHome, function(v)
    Config.TicketAutoCastAtHome = v
end)

createToggleRow(optionCard, "Nhận & Nộp Vé Từ Xa (Remote)", "Đứng yên tại chỗ câu để nhận và nộp vé Hard từ xa (không cần bay về NPC)", Config.TicketRemoteClaim, function(v)
    Config.TicketRemoteClaim = v
end)

createCategoryHeader(tabQuests, "⚡ Thao Tác Nhanh Bằng Tay")
local manualCard = createCardGroup(tabQuests)

createButtonRow(manualCard, "Nhận Vé Hard Ngay", "Tương tác NPC, mở hội thoại và bấm nút Quest để nhận vé mới", "Nhận Hard", function()
    task.spawn(function()
        ShowNotification("Nhiệm Vụ Vé", "Đang tương tác NPC nhận vé Hard...", "INFO", 3)
        ticketQuestState.InteractNPC(false)
    end)
end)

createButtonRow(manualCard, "Nộp / Trả Vé Hard Ngay", "Tương tác NPC, mở hội thoại và bấm nút *Leave* để trả vé & nhận quà", "Nộp Hard", function()
    task.spawn(function()
        ShowNotification("Nhiệm Vụ Vé", "Đang tương tác NPC nộp vé Hard...", "INFO", 3)
        ticketQuestState.InteractNPC(true)
    end)
end)

createButtonRow(manualCard, "Đặt Lại Bộ Đếm & Bỏ Hồi Chiêu", "Reset bộ đếm tiến độ và hủy thời gian chờ 20 phút", "Đặt Lại", function()
    ticketQuestState.ResetCooldown()
end)

createCategoryHeader(tabQuests, "Điểm Danh & Nhiệm Vụ Hàng Ngày")
local dailyCard = createCardGroup(tabQuests)
createButtonRow(dailyCard, "Nhận Thưởng Nhiệm Vụ Ngày", "Tự kiểm tra và nhận thưởng các quest đã xong", "Nhận Thưởng", function()
    if Events and Events:FindFirstChild("ClaimQuest") then
        for i = 1, 4 do Events.ClaimQuest:FireServer("Daily", i) end
        ShowNotification("Nhiệm Vụ Ngày", "Đã nhận thưởng tất cả nhiệm vụ ngày hoàn thành!", "SUCCESS")
    end
end)

createToggleRow(dailyCard, "Tự Điểm Danh 7 Ngày", "Tự động nhận quà điểm danh hàng ngày từ ngày 1 - 7", Config.AutoClaimDaily, function(v) Config.AutoClaimDaily = v end)
createSliderRow(dailyCard, "Độ Trễ Nhận Quà", "Thời gian giãn cách giữa các ngày", 0.2, 2.0, Config.DailyClaimDelay, true, "s", function(v) Config.DailyClaimDelay = v end)

createButtonRow(dailyCard, "Nhận Hết Quà 7 Ngày", "Nhận nhanh toàn bộ quà điểm danh 7 ngày cùng lúc", "Nhận Hết", function()
    task.spawn(function()
        if Events and Events:FindFirstChild("DailyReward") then
            for day = 1, 7 do
                Events.DailyReward:FireServer(day)
                task.wait(Config.DailyClaimDelay)
            end
            ShowNotification("Điểm Danh", "Đã nhận trọn bộ quà điểm danh từ ngày 1 - 7!", "SUCCESS")
        end
    end)
end)

createButtonRow(dailyCard, "Nhập Toàn Bộ Mã Code", "Tự động nhập toàn bộ hơn 100 mã giftcode (65KLikes, 41MVisits, PVP, SoTamOrb...)", "Nhập Code", function()
    local codes = {
        -- Mã mới nhất từ thông báo game (Update mới nhất)
        "65KLikes",
        "41MVisits",
        "40MVisits",
        "39MVisits",
        "38MVisits",
        "37MVisits",
        "9KActive",
        "9KActives",
        "SorryForShutdown",
        -- Mã đang hoạt động & hot
        "PVP",
        "19KActives",
        "WaitForPeak",
        "SoTamOrb",
        "36MVisits",
        "35MVisits",
        "34MVisits",
        "60KLikes",
        "55KLikes",
        "50KLikes",
        "AXO",
        "TaijiEvo",
        "NewSeason",
        "33MVisits",
        "32MVisits",
        "31MVisits",
        "30MVisits",
        "Taiji",
        "Balanced",
        "49KLikes",
        "48KLikes",
        "47KLikes",
        "46KLikes",
        "13KActives",
        "17KActives",
        "9KActives",
        "HWF",
        "RELEASE",
        -- Toàn bộ mốc Likes lịch sử
        "45KLikes",
        "44KLikes",
        "43KLikes",
        "42KLikes",
        "41KLikes",
        "40KLikes",
        "39KLikes",
        "38KLikes",
        "37KLikes",
        "36KLikes",
        "35KLikes",
        "34KLikes",
        "31KLikes",
        "30KLikes",
        "29KLikes",
        "28KLikes",
        "26KLikes",
        "25KLikes",
        "22KLikes",
        "21KLikes",
        -- Toàn bộ mốc Visits lịch sử
        "29MVisits",
        "28MVisits",
        "27MVisits",
        "26MVisits",
        "25MVisits",
        "24MVisits",
        "23MVisits",
        "22MVisits",
        "21MVisits",
        "20M5Visits",
        "20MVisits",
        "19M5Visits",
        "19MVisits",
        "18M5Visits",
        "18MVisits",
        "17M5Visits",
        "17MVisits",
        "16M5Visits",
        "16MVisits",
        "15M5Visits",
        "15MVisits",
        "14M5Visits",
        "14MVisits",
        "11MVisits",
        "10M5Visits",
        "10MVisits",
        "9MVisits",
        "8M5Visits",
        "7MVisits",
        "6M5Visits",
        -- Các mã sự kiện, sửa lỗi & đền bù
        "BigUPD",
        "SorryForShutdown",
        "InfnanLOL",
        "367BUG",
        "UIBUG",
        "ThanksForNitroBoost",
        "Enzo",
        "Enzo2",
        "CodeBug",
        "PEAK",
        "FreeReroll",
        "FreeReroll2",
        "BuyAgain",
        "BugAgain",
        "BUGBUGBUG",
        "Golden",
        "Hit5KActives",
        "Hit4KActives",
        "Hit3KActives",
        "Hit2KActives",
        "ORB",
        "FreeTicket",
        "CrystalBugs",
        "April Fools",
        "LunarNewYear"
    }
    if Events and Events:FindFirstChild("RedeemCode") then
        task.spawn(function()
            for _, c in ipairs(codes) do
                Events.RedeemCode:FireServer(c)
                task.wait(0.25)
            end
            ShowNotification("Giftcode", string.format("Đã nạp toàn bộ %d mã code vào game!", #codes), "SUCCESS")
        end)
    end
end)

createInputRow(dailyCard, "Nhập Mã Code Thủ Công", "Gõ mã giftcode riêng hoặc mã mới ra để nạp ngay", "", function(codeTxt)
    if codeTxt and codeTxt:gsub("%s+", "") ~= "" then
        local cleanCode = codeTxt:gsub("%s+", "")
        if Events and Events:FindFirstChild("RedeemCode") then
            Events.RedeemCode:FireServer(cleanCode)
            ShowNotification("Giftcode", "Đã gửi mã: " .. cleanCode, "SUCCESS")
        end
    end
end)
end

createCategoryHeader(tabShop, "Chế Tạo & Mua Mồi Câu")
local baitCard = createCardGroup(tabShop)

local craftBaits = {"Nameless Bait", "Frost Bait", "Rainbow Bait"}
createDropdownRow(baitCard, "Chọn Mồi Cần Chế", "Loại mồi thần thoại muốn chế tạo", craftBaits, Config.CraftBaitName, function(v) Config.CraftBaitName = v end)
createSliderRow(baitCard, "Số Lượng Chế Mỗi Lần", "Số lượng mồi chế trong 1 lượt", 1, 10, Config.CraftAmount, false, "", function(v) Config.CraftAmount = v end)
createToggleRow(baitCard, "Tự Động Chế Mồi", "Liên tục chế mồi khi trong kho đủ nguyên liệu", Config.AutoCraftBait, function(v) Config.AutoCraftBait = v end)

local buyBaits = {"Ancestral Bait", "Elite Bait", "Corrupted Essence Bait", "Crude Mash Bait", "Basic Bait"}
createDropdownRow(baitCard, "Chọn Mồi Cần Mua", "Loại mồi muốn mua từ NPC Ba Chang", buyBaits, Config.BuyBaitName, function(v) Config.BuyBaitName = v end)
createSliderRow(baitCard, "Số Lượng Mua Mỗi Lần", "Số lượng mồi mua mỗi lần giao dịch", 1, 50, Config.BuyBaitAmount, false, "", function(v) Config.BuyBaitAmount = v end)
createSliderRow(baitCard, "Ngưỡng Mua Tự Động", "Tự mua khi số mồi trong kho ít hơn mức này", 5, 50, Config.BuyBaitThreshold, false, "", function(v) Config.BuyBaitThreshold = v end)
createToggleRow(baitCard, "Tự Động Mua Mồi", "Tự động mua thêm mồi khi sắp hết", Config.AutoBuyBait, function(v) Config.AutoBuyBait = v end)

createCategoryHeader(tabShop, "Thương Nhân Kỹ Năng (Sage Yijiu)")
local sageCard = createCardGroup(tabShop)
local sageSkills = {"One-Strike Heaven Gate", "Taijiquan Technique", "Infinite Sky Ascension", "Rolling Chaos", "Sever the Gate", "Phoenix Strike Art", "Skyfall Stomp", "Beastbreaker Cleave", "Demonfall Technique", "Dragon Strike"}
local chosenSageSkill = sageSkills[1]
createDropdownRow(sageCard, "Chọn Kỹ Năng", "Kỹ năng muốn học từ NPC Sage Yijiu", sageSkills, chosenSageSkill, function(v) chosenSageSkill = v end)

createButtonRow(sageCard, "Bay Đến & Mua Kỹ Năng", "Dịch chuyển đến Sage Yijiu và mua chiêu thức", "Mua Chiêu", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(-117.5, 6.8, 41.2)
        task.wait(0.3)
        if Events and Events:FindFirstChild("BuySkill") then
            Events.BuySkill:FireServer(chosenSageSkill)
            ShowNotification("Sage Yijiu", "Đã mua thành công kỹ năng: " .. chosenSageSkill, "SUCCESS")
        end
    end
end)

createCategoryHeader(tabShop, "Vòng Quay May Mắn (Auto Gacha)")
local gachaCard = createCardGroup(tabShop)
createDropdownRow(gachaCard, "Chọn Vòng Quay Gacha", "Vòng quay muốn rút thưởng", {"Taiji Banner", "Egoless Banner"}, Config.GachaBanner, function(v) Config.GachaBanner = v end)
createSliderRow(gachaCard, "Số Vé Mỗi Lần Quay", "Số lượng vé dùng cho mỗi lượt rút thưởng", 1, 10, Config.GachaPullsPerAction, false, "", function(v) Config.GachaPullsPerAction = v end)
createToggleRow(gachaCard, "Vòng Quay May Mắn (Auto Gacha)", "Tự động rút thưởng liên tục từ banner đã chọn", Config.AutoGacha, function(v) Config.AutoGacha = v end)

createCategoryHeader(tabShop, "Danh Sách Cần Câu (Xếp Theo Giá)")
local rodShopCard = createCardGroup(tabShop)

local function formatNumber(n)
    if n == 0 then return "FREE" end
    return FormatWithSpaces(n) .. " Cash"
end

local rodShopUpdaters = {}
local function UpdateAllRodShopUI()
    for _, fn in ipairs(rodShopUpdaters) do
        pcall(fn)
    end
end

-- Nút Làm Mới Trạng Thái Cần Câu
createButtonRow(rodShopCard, "Làm Mới Trạng Thái Cần", "Quét lại túi đồ để cập nhật danh sách cần đã có / chưa có", "Làm Mới", function()
    UpdateAllRodShopUI()
    ShowNotification("Shop Cần", "Đã cập nhật trạng thái sở hữu cần câu!", "INFO")
end)

for _, rod in ipairs(allRods) do
    local pStr = formatNumber(rod.price)
    local baseDesc = string.format("Lực: %d | May mắn: %d%% | Giá: %s", rod.power, rod.luck, pStr)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Colors.RowNormal
    row.BorderSizePixel = 0
    row.Parent = rodShopCard

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = row

    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, -125, 1, 0)
    tf.BackgroundTransparency = 1
    tf.Parent = row

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 0, 20)
    tl.Position = UDim2.new(0, 0, 0, 3)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.Text = rod.name
    tl.TextColor3 = Colors.TextWhite
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = tf

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 16)
    dl.Position = UDim2.new(0, 0, 0, 23)
    dl.BackgroundTransparency = 1
    dl.Font = Enum.Font.Gotham
    dl.Text = baseDesc
    dl.TextColor3 = Colors.TextMuted
    dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = tf

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 105, 0, 26)
    btn.Position = UDim2.new(1, -105, 0.5, -13)
    btn.BackgroundColor3 = Colors.ControlBg
    btn.Font = Enum.Font.GothamBold
    btn.Text = "Mua Cần"
    btn.TextColor3 = Colors.PurplePrimary
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowHover}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowNormal}):Play() end)

    table.insert(rowSearchIndex, {frame = row, query = (rod.name .. " " .. baseDesc):lower()})

    local function updateRowVisuals()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        local curEq = pData and pData:FindFirstChild("FishingRod") and pData.FishingRod.Value
        local isEquipped = (curEq == rod.name)
        local isOwned = isEquipped or IsRodOwned(rod.name)

        if isEquipped then
            tl.Text = string.format("%s  [ĐANG DÙNG]", rod.name)
            tl.TextColor3 = Color3.fromRGB(120, 255, 170)
            dl.Text = string.format("%s • [Trạng thái: Đang Cầm]", baseDesc)
            dl.TextColor3 = Color3.fromRGB(160, 255, 190)

            btn.Text = "Đang Dùng"
            btn.BackgroundColor3 = Color3.fromRGB(30, 65, 45)
            btn.TextColor3 = Color3.fromRGB(120, 255, 170)
        elseif isOwned then
            tl.Text = string.format("%s  [ĐÃ CÓ]", rod.name)
            tl.TextColor3 = Color3.fromRGB(230, 240, 255)
            dl.Text = string.format("%s • [Trạng thái: ĐÃ CÓ - SẴN SÀNG]", baseDesc)
            dl.TextColor3 = Color3.fromRGB(100, 220, 255)

            btn.Text = "Trang Bị"
            btn.BackgroundColor3 = Color3.fromRGB(28, 50, 75)
            btn.TextColor3 = Color3.fromRGB(100, 220, 255)
        else
            tl.Text = string.format("%s  [CHƯA CÓ]", rod.name)
            tl.TextColor3 = Colors.TextWhite
            dl.Text = string.format("%s • [Trạng thái: Chưa có]", baseDesc)
            dl.TextColor3 = Colors.TextMuted

            btn.Text = "Mua Cần"
            btn.BackgroundColor3 = Colors.ControlBg
            btn.TextColor3 = Colors.PurplePrimary
        end
    end

    btn.MouseButton1Click:Connect(function()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
        local curEq = pData and pData:FindFirstChild("FishingRod") and pData.FishingRod.Value
        local isEquipped = (curEq == rod.name)
        local isOwned = isEquipped or IsRodOwned(rod.name)

        if isEquipped then
            ShowNotification("Cần Câu", "Bạn đang cầm cần " .. rod.name .. " rồi!", "INFO")
        elseif isOwned then
            if Events and Events:FindFirstChild("EquipFishingRod") then
                Events.EquipFishingRod:InvokeServer(rod.name)
                ShowNotification("Trang Bị Cần", "Đã trang bị cần: " .. rod.name, "SUCCESS")
                task.delay(0.4, function()
                    if Events and Events:FindFirstChild("ToggleHotbar") then
                        Events.ToggleHotbar:InvokeServer("1")
                    end
                end)
            end
        else
            if Events and Events:FindFirstChild("BuyFishingRod") then
                Events.BuyFishingRod:FireServer(rod.name)
                ShowNotification("Shop Cần", "Đã gửi yêu cầu mua cần: " .. rod.name .. " (" .. pStr .. ")", "SUCCESS")
            end
        end
        task.delay(0.6, UpdateAllRodShopUI)
        task.delay(1.5, UpdateAllRodShopUI)
    end)

    table.insert(rodShopUpdaters, updateRowVisuals)
    updateRowVisuals()
end

local UpdateAllIslandStatus = nil
do
createCategoryHeader(tabTeleports, "Dịch Chuyển Đến Đảo (Đảo 1 - 10)")
local islandCard = createCardGroup(tabTeleports)

local islands = {
    {name = "[1] Đảo Khởi Đầu (Spawn)", pos = Vector3.new(-200.7, 11.1, 35.9), radius = 450},
    {name = "[2] Đảo Tre (Bamboo Isle)", pos = Vector3.new(-1223.0, 7.3, -24.1), radius = 450},
    {name = "[3] Đảo Phóng Xạ (Fallout Isle)", pos = Vector3.new(65.5, 8.8, 1181.3), radius = 450},
    {name = "[4] Đảo Thống Trị (Sovereign Isle)", pos = Vector3.new(-1276.4, 8.8, 1239.7), radius = 450},
    {name = "[5] Đảo Cá Chép (Perch Isle)", pos = Vector3.new(-62.0, 11.9, -1321.4), radius = 450},
    {name = "[6] Đảo Băng Giá (Frost Isle)", pos = Vector3.new(-1366.0, 11.9, -1495.4), radius = 450},
    {name = "[7] Đảo Quả Dừa (Coconut Isle)", pos = Vector3.new(1493.6, 9.1, -1430.6), radius = 450},
    {name = "[8] Đảo Hổ Phách (Amber Isle)", pos = Vector3.new(1259.4, 9.1, 1401.5), radius = 450},
    {name = "[9] Đảo Chiến Trường (Battlefield)", pos = Vector3.new(1393.5, 11.3, 169.6), radius = 450},
    {name = "[10] Đảo Đỉnh Sương Mù (Mistpeak)", pos = Vector3.new(2660.2, 8.8, -86.7), radius = 450},
}

local bossRealms = {
    {name = "Boss Bạch Tuộc (Phao Biển)", pos = Vector3.new(1608.2, 5.0, -218.3), radius = 350},
    {name = "Vùng Câu Cá Ngầm Lòng Đất", pos = Vector3.new(112.5, -330.0, -30.8), radius = 350},
    {name = "Đấu Trường Boss Enzo", pos = Vector3.new(-115.3, 9.2, 1349.5), radius = 350},
}

local function GetCurrentLocationName()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return "Đang tải vị trí...", nil end
    local myPos = root.Position

    if myPos.Y < -150 then
        return "Vùng Câu Cá Ngầm Lòng Đất", "underground"
    end

    local bestName = "Đang ở giữa biển"
    local bestObj = nil
    local minDist = 999999

    for _, isl in ipairs(islands) do
        local dist = (Vector3.new(myPos.X, 0, myPos.Z) - Vector3.new(isl.pos.X, 0, isl.pos.Z)).Magnitude
        if dist < (isl.radius or 450) and dist < minDist then
            minDist = dist
            bestName = isl.name
            bestObj = isl
        end
    end

    for _, br in ipairs(bossRealms) do
        local dist = (myPos - br.pos).Magnitude
        if dist < (br.radius or 350) and dist < minDist then
            minDist = dist
            bestName = br.name
            bestObj = br
        end
    end

    return bestName, bestObj, minDist
end

-- Hiển thị trực tiếp vị trí đảo người chơi đang đứng
local infoCurrentMap = createInfoRow(islandCard, "📍 Vị Trí Bạn Đang Đứng", "Đang nhận diện...")

createButtonRow(islandCard, "📋 Sao Chép Tọa Độ Hiện Tại", "Copy tọa độ đứng hiện tại vào Clipboard để gửi cho AI nạp đảo mới", "Sao Chép", function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position
    local str = string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
    pcall(function()
        if setclipboard then setclipboard(str)
        elseif toclipboard then toclipboard(str) end
    end)
    ShowNotification("TỌA ĐỘ HIỆN TẠI", "Đã copy: " .. str .. " vào Clipboard!", "SUCCESS", 6)
end)

local islandUpdaters = {}
UpdateAllIslandStatus = function()
    local curLocName = GetCurrentLocationName()
    if infoCurrentMap and infoCurrentMap.Set then
        infoCurrentMap.Set(curLocName)
    end
    for _, fn in ipairs(islandUpdaters) do
        pcall(fn, curLocName)
    end
end

for _, isl in ipairs(islands) do
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 42); row.BackgroundColor3 = Colors.RowNormal; row.BorderSizePixel = 0; row.Parent = islandCard
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10); pad.Parent = row
    local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, -125, 1, 0); tf.BackgroundTransparency = 1; tf.Parent = row
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1, 0, 0, 18); tl.Position = UDim2.new(0, 0, 0, 4); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.Text = isl.name; tl.TextColor3 = Colors.TextWhite; tl.TextSize = 12; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = tf
    local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1, 0, 0, 14); dl.Position = UDim2.new(0, 0, 0, 22); dl.BackgroundTransparency = 1; dl.Font = Enum.Font.Gotham; dl.Text = "Dịch chuyển đến " .. isl.name; dl.TextColor3 = Colors.TextMuted; dl.TextSize = 10; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Parent = tf

    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 105, 0, 24); btn.Position = UDim2.new(1, -105, 0.5, -12); btn.BackgroundColor3 = Colors.ControlBg; btn.Font = Enum.Font.GothamBold; btn.Text = "Bay Đến"; btn.TextColor3 = Colors.PurplePrimary; btn.TextSize = 11; btn.BorderSizePixel = 0; btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowHover}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.RowNormal}):Play() end)
    table.insert(rowSearchIndex, {frame = row, query = (isl.name .. " dịch chuyển đến đảo"):lower()})

    local function updateVisuals(curLocName)
        local isHere = (curLocName == isl.name)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local dist = root and math.floor((root.Position - isl.pos).Magnitude) or 0

        if isHere then
            tl.Text = string.format("%s  [BẠN ĐANG Ở ĐÂY]", isl.name)
            tl.TextColor3 = Color3.fromRGB(120, 255, 170)
            dl.Text = "Vị trí hiện tại của bạn • Khoảng cách: 0m (Đã ở đây)"
            dl.TextColor3 = Color3.fromRGB(160, 255, 190)

            btn.Text = "Đang Ở Đây"
            btn.BackgroundColor3 = Color3.fromRGB(30, 65, 45)
            btn.TextColor3 = Color3.fromRGB(120, 255, 170)
        else
            tl.Text = isl.name
            tl.TextColor3 = Colors.TextWhite
            dl.Text = string.format("Dịch chuyển đến %s • Cách bạn: ~%dm", isl.name, dist)
            dl.TextColor3 = Colors.TextMuted

            btn.Text = "Bay Đến"
            btn.BackgroundColor3 = Colors.ControlBg
            btn.TextColor3 = Colors.PurplePrimary
        end
    end

    btn.MouseButton1Click:Connect(function()
        local curLocName = GetCurrentLocationName()
        if curLocName == isl.name then
            ShowNotification("Dịch Chuyển", "Bạn đang ở ngay " .. isl.name .. " rồi!", "INFO")
            return
        end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(isl.pos + Vector3.new(0, 3, 0))
            ShowNotification("Dịch Chuyển", "Đã đến " .. isl.name .. "!", "SUCCESS")
            task.delay(0.4, UpdateAllIslandStatus)
        end
    end)

    table.insert(islandUpdaters, updateVisuals)
    updateVisuals(GetCurrentLocationName())
end

createCategoryHeader(tabTeleports, "Đấu Trường Boss & Vùng Đất Bí Mật")
local bossRealmCard = createCardGroup(tabTeleports)

local bossRealms = {
    {name = "Boss Bạch Tuộc (Phao Biển)", pos = Vector3.new(1608.2, 5.0, -218.3)},
    {name = "Vùng Câu Cá Ngầm Lòng Đất", pos = Vector3.new(112.5, -330.0, -30.8)},
    {name = "Đấu Trường Boss Enzo", pos = Vector3.new(-115.3, 9.2, 1349.5)},
}

for _, br in ipairs(bossRealms) do
    createButtonRow(bossRealmCard, br.name, "Dịch chuyển đến " .. br.name, "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(br.pos + Vector3.new(0, 3, 0))
            ShowNotification("Teleport", "Arrived at " .. br.name .. "!", "SUCCESS")
        end
    end)
end

createCategoryHeader(tabTeleports, "Cửa Hàng Bán Cần (Biao Di)")
local rodDealerCard = createCardGroup(tabTeleports)

local rodDealers = {
    {name = "[1] Shop Đảo Khởi Đầu", pos = Vector3.new(-151.4, 8.7, -49.9)},
    {name = "[2] Shop Đảo Tre", pos = Vector3.new(-1236.8, 7.3, -174.1)},
    {name = "[3] Shop Đảo Phóng Xạ", pos = Vector3.new(138.4, 9.0, 1179.7)},
    {name = "[4] Shop Đảo Thống Trị", pos = Vector3.new(-1262.6, 8.2, 1202.2)},
    {name = "[5] Shop Đảo Cá Chép", pos = Vector3.new(-9.5, 9.2, -1330.0)},
    {name = "[6] Shop Đảo Băng Giá", pos = Vector3.new(-1400.4, 9.2, -1490.6)},
    {name = "[7] Shop Đảo Quả Dừa", pos = Vector3.new(1446.0, 9.3, -1408.0)},
    {name = "[8] Shop Đảo Hổ Phách", pos = Vector3.new(1292.7, 8.2, 1497.4)},
}

for _, rd in ipairs(rodDealers) do
    createButtonRow(rodDealerCard, rd.name, "Bay trực tiếp đến " .. rd.name, "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(rd.pos + Vector3.new(0, 3, 0))
            ShowNotification("Cửa Hàng", "Đã đến " .. rd.name .. "!", "SUCCESS")
        end
    end)
end

createCategoryHeader(tabTeleports, "Vị Trí Cần Câu Bí Mật")
local sRodCard = createCardGroup(tabTeleports)

local secretRods = {
    {name = "Anchorbound Rod", pos = Vector3.new(-1208.5, 56.3, 1646.2)},
    {name = "Blazeshark Rod", pos = Vector3.new(-8.4, 53.9, 6.7)},
    {name = "Kraken Rod", pos = Vector3.new(1543.8, 73.4, 1490.9)},
    {name = "Ascendant Bamboo Rod", pos = Vector3.new(-1360.6, 140.6, 31.0)},
    {name = "Lifebloom Rod", pos = Vector3.new(-114.9, 74.9, -1533.2)},
    {name = "Demonic Rod", pos = Vector3.new(1181.9, 82.9, -1243.8)}
}

for _, sr in ipairs(secretRods) do
    createButtonRow(sRodCard, sr.name, "Bay đến vị trí lấy cần: " .. sr.name, "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(sr.pos + Vector3.new(0, 3, 0))
            ShowNotification("Cần Bí Mật", "Đã bay đến " .. sr.name .. "!", "SUCCESS")
        end
    end)
end

createCategoryHeader(tabTeleports, "👥 Dịch Chuyển Đến Người Chơi Trong Map")
local srvCard = createCardGroup(tabTeleports)

local playerLookup = {}
local selectedPlayerKey = nil

local function BuildPlayerList()
    local list = {}
    table.clear(playerLookup)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local distStr = ""
            if myPos and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = math.floor((p.Character.HumanoidRootPart.Position - myPos).Magnitude)
                distStr = string.format(" [%dm]", d)
            end
            local key = string.format("%s (@%s)%s", p.DisplayName, p.Name, distStr)
            table.insert(list, key)
            playerLookup[key] = p
        end
    end

    if #list == 0 then
        table.insert(list, "Không có người chơi khác")
    end
    return list
end

local initialPlayerList = BuildPlayerList()
selectedPlayerKey = initialPlayerList[1]

local playerDropdown = createDropdownRow(srvCard, "Chọn Người Chơi", "Danh sách người chơi đang có mặt trong server", initialPlayerList, selectedPlayerKey, function(v)
    selectedPlayerKey = v
end)

local function RefreshPlayerDropdown()
    local newList = BuildPlayerList()
    if playerDropdown and playerDropdown.Refresh then
        playerDropdown.Refresh(newList, true)
        selectedPlayerKey = playerDropdown.Get()
    end
end

createButtonRow(srvCard, "Bay Đến Người Chơi Đã Chọn", "Dịch chuyển tức thì đến ngay bên cạnh người chơi đang chọn", "🚀 Bay Đến", function()
    local targetPlayer = playerLookup[selectedPlayerKey]
    if not targetPlayer then
        local uName = selectedPlayerKey and selectedPlayerKey:match("@([%w_]+)")
        if uName then
            targetPlayer = Players:FindFirstChild(uName)
        end
    end

    if not targetPlayer or not targetPlayer.Parent then
        ShowNotification("Dịch Chuyển", "Vui lòng chọn người chơi hợp lệ!", "WARN")
        RefreshPlayerDropdown()
        return
    end

    local tChar = targetPlayer.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if myRoot and tRoot then
        myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 2, 3)
        ShowNotification("Dịch Chuyển", "Đã bay đến người chơi: " .. targetPlayer.DisplayName, "SUCCESS")
        RefreshPlayerDropdown()
    else
        ShowNotification("Dịch Chuyển", "Người chơi này chưa hồi sinh hoặc không có nhân vật!", "WARN")
    end
end)

createButtonRow(srvCard, "Làm Mới Danh Sách Người Chơi", "Cập nhật danh sách người chơi vừa tham gia hoặc rời server", "🔄 Làm Mới", function()
    RefreshPlayerDropdown()
    ShowNotification("Danh Sách", "Đã cập nhật danh sách người chơi trong map!", "INFO")
end)

local lastTpTarget = nil
createButtonRow(srvCard, "Bay Đến Người Chơi Ngẫu Nhiên", "Dịch chuyển tức thì đến vị trí của một người chơi bất kỳ", "🎲 Ngẫu Nhiên", function()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p)
        end
    end
    if #targets == 0 then
        ShowNotification("Dịch Chuyển", "Không tìm thấy người chơi nào khác trong server.", "WARN")
        return
    end
    local pool = {}
    for _, p in ipairs(targets) do
        if not (#targets > 1 and p == lastTpTarget) then
            table.insert(pool, p)
        end
    end
    local selected = (#pool > 0 and pool[math.random(1, #pool)]) or targets[math.random(1, #targets)]
    lastTpTarget = selected
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and selected.Character and selected.Character:FindFirstChild("HumanoidRootPart") then
        root.CFrame = selected.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
        ShowNotification("Dịch Chuyển", "Đã bay đến người chơi: " .. selected.DisplayName, "SUCCESS")
        RefreshPlayerDropdown()
    end
end)

table.insert(activeConnections, Players.PlayerAdded:Connect(function()
    task.wait(1)
    RefreshPlayerDropdown()
end))
table.insert(activeConnections, Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    RefreshPlayerDropdown()
end))
end

createCategoryHeader(tabVisuals, "ESP Nhìn Xuyên Tường")
local espCard = createCardGroup(tabVisuals)

createToggleRow(espCard, "ESP Thần Linh (God Spirit)", "Hiện vị trí Thần linh xuyên bản đồ", Config.ESP_GodSpirit, function(v) Config.ESP_GodSpirit = v end)
createToggleRow(espCard, "ESP Cần Câu Bí Mật", "Hiện vị trí các cần câu ẩn trên bản đồ", Config.ESP_SecretRod, function(v) Config.ESP_SecretRod = v end)
createToggleRow(espCard, "ESP Thuyền Bè", "Hiện vị trí tất cả thuyền xung quanh", Config.ESP_Boats, function(v) Config.ESP_Boats = v end)
createToggleRow(espCard, "ESP Maoshan", "Hiện vị trí NPC hoặc cần Maoshan", Config.ESP_Maoshan, function(v) Config.ESP_Maoshan = v end)
createToggleRow(espCard, "ESP Đạo Sĩ (Taoist)", "Hiện vị trí NPC hoặc cần Taoist", Config.ESP_Taoist, function(v) Config.ESP_Taoist = v end)
createToggleRow(espCard, "ESP Trùm Boss", "Hiện vị trí các Boss đang xuất hiện", Config.ESP_Boss, function(v) Config.ESP_Boss = v end)
createToggleRow(espCard, "ESP Người Chơi", "Hiện khung & khoảng cách đến người chơi khác", Config.ESP_Players, function(v) Config.ESP_Players = v end)
createToggleRow(espCard, "Ẩn Tên Mặc Định Người Chơi", "Ẩn toàn bộ bảng tên, danh hiệu và thanh máu trên đầu của người chơi khác", Config.HideOverheadNames, function(v)
    Config.HideOverheadNames = v
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.DisplayDistanceType = v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
            end
            for _, d in ipairs(p.Character:GetDescendants()) do
                if d:IsA("BillboardGui") and d.Name:sub(1, 4) ~= "ESP_" then
                    d.Enabled = not v
                end
            end
        end
    end
end)
createToggleRow(espCard, "Vòng Tròn Định Vị Cá", "Hiện vòng tròn đỏ dưới nước chỉ đúng con cá cắn câu", Config.FishRedRing, function(v) Config.FishRedRing = v end)
createToggleRow(espCard, "Hiện Cân Nặng & Đột Biến Trên Vòng Đỏ", "Hiển thị tên cá, cân nặng (kg) và loại đột biến trực tiếp trên vòng định vị", Config.ShowFishWeightRing, function(v) Config.ShowFishWeightRing = v end)

createCategoryHeader(tabVisuals, "Ánh Sáng & Tối Ưu Giảm Lag")
local perfCard = createCardGroup(tabVisuals)

createToggleRow(perfCard, "Xóa Sương Mù & Mưa Bão", "Xóa sạch sương mù, khói mờ, hạt mưa và sấm sét", Config.NoFog, function(v)
    Config.NoFog = v
    if v then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo then
            atmo.Density = 0
            atmo.Haze = 0
            atmo.Glare = 0
        end
        for _, d in ipairs(Camera:GetDescendants()) do
            if d:IsA("ParticleEmitter") then d.Enabled = false end
        end
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo then
            atmo.Density = 0.3
            atmo.Haze = 0.5
        end
    end
end)

createToggleRow(perfCard, "Sáng Màn Hình (Fullbright)", "Tăng độ sáng tối đa, nhìn rõ mọi thứ trong đêm", Config.Fullbright, function(v)
    Config.Fullbright = v
    if not v then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
    end
end)

createToggleRow(perfCard, "Chế Độ Giảm Lag (Low GFX)", "Tắt bóng đổ và giảm tải đồ họa giúp game siêu mượt", Config.PerformanceMode, function(v)
    Config.PerformanceMode = v
    Lighting.GlobalShadows = not v
end)




createToggleRow(perfCard, "Ẩn Giao Diện Gốc Của Game", "Ẩn các nút bấm của Roblox để nhìn thông thoáng", Config.HideGameUI, function(v)
    Config.HideGameUI = v
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        if pg:FindFirstChild("MainGui") then pg.MainGui.Enabled = not v end
        if pg:FindFirstChild("Fisher_GUI") then pg.Fisher_GUI.Enabled = not v end
    end
end)

createButtonRow(perfCard, "Mở Khóa Toàn Bộ Sách Cá (Index)", "Mở khóa khám phá đủ 109 loài cá và vật phẩm trong Index", "Mở Khóa Index", function()
    local count = 0
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData and pData:FindFirstChild("Index") then
        for _, b in ipairs(pData.Index:GetChildren()) do
            if b:IsA("BoolValue") then b.Value = true end
        end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Menu") and pg.MainGui.Menu:FindFirstChild("Index") then
        local indexList = pg.MainGui.Menu.Index:FindFirstChild("IndexFrame") and pg.MainGui.Menu.Index.IndexFrame:FindFirstChild("Indexlist")
        if indexList then
            for _, f in ipairs(indexList:GetChildren()) do
                if f:IsA("Frame") then
                    count = count + 1
                    local btn = f:FindFirstChild("Button")
                    if btn then
                        local title = btn:FindFirstChild("Title")
                        if title and title:IsA("TextLabel") then title.Text = f.Name end
                        local detail = btn:FindFirstChild("Detail")
                        if detail then
                            detail.Visible = true
                            for _, img in ipairs(detail:GetDescendants()) do
                                if img:IsA("ImageLabel") then img.ImageColor3 = Color3.new(1, 1, 1) end
                            end
                        end
                    end
                end
            end
        end
    end
    ShowNotification("Mở Khóa Index", string.format("Đã mở khóa %d loài cá trong Sách Cá Index!", count > 0 and count or 109), "SUCCESS")
end)

createCategoryHeader(tabPlayer, "📜 Trích Xuất Dữ Liệu Kỹ Năng (Skill Info Exporter)")
local exportSkillCard = createCardGroup(tabPlayer)
local infoSkillCount = createInfoRow(exportSkillCard, "Kỹ Năng Đã Quét", "Chưa quét dữ liệu")

createButtonRow(exportSkillCard, "Quét Kỹ Năng Đang Sở Hữu (Chỉ Của Bạn)", "Chỉ quét các kỹ năng bạn thực sự sở hữu trong túi đồ & phím Z,X,C,V", "👤 Skill Của Bạn", function()
    ExportAllPlayerSkills(infoSkillCount, true)
end)

createButtonRow(exportSkillCard, "Quét Bách Khoa Toàn Bộ Kỹ Năng Game", "Quét toàn bộ từ điển kỹ năng có trong game (Codex/Shop/Tất cả)", "📚 Toàn Bộ Game", function()
    ExportAllPlayerSkills(infoSkillCount, false)
end)

createButtonRow(exportSkillCard, "Mở Bảng Xem Danh Sách Skill", "Mở khung văn bản cuộn trên màn hình để xem và copy", "📜 Mở Bảng Xem", function()
    ShowSkillTextWindow()
end)

createCategoryHeader(tabPlayer, "Di Chuyển Nhân Vật")
local moveCard = createCardGroup(tabPlayer)

createToggleRow(moveCard, "Tăng Tốc Độ Chạy (Speed)", "Chạy nhanh hơn tốc độ mặc định", Config.WalkSpeedEnabled, function(v)
    Config.WalkSpeedEnabled = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v and Config.WalkSpeedValue or 16 end
end)
createSliderRow(moveCard, "Chỉnh Tốc Độ", "Tốc độ chạy mong muốn", 16, 120, Config.WalkSpeedValue, false, "", function(v)
    Config.WalkSpeedValue = v
    if Config.WalkSpeedEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

createToggleRow(moveCard, "Bay Lượn Tự Do (Fly)", "Bay tự do trên không bằng phím WASD & Cách/Shift", Config.FlyEnabled, function(v) Config.FlyEnabled = v end)
createSliderRow(moveCard, "Tốc Độ Bay", "Tốc độ di chuyển khi bay", 20, 150, Config.FlySpeed, false, "", function(v) Config.FlySpeed = v end)
createToggleRow(moveCard, "Nhảy Vô Hạn (Infinite Jump)", "Nhảy liên tục trên không trung không giới hạn", Config.InfiniteJump, function(v) Config.InfiniteJump = v end)
createToggleRow(moveCard, "Đi Trên Mặt Nước", "Đi bộ trên mặt biển như trên đất liền", Config.WalkOnWater, function(v) Config.WalkOnWater = v end)
createToggleRow(moveCard, "Khiên Nước Axit (Acid Shield)", "Tạo sàn nổi kháng sát thương độc/axit tại Đảo Fallout", Config.AcidWaterShield, function(v) Config.AcidWaterShield = v end)
createToggleRow(moveCard, "Đi Xuyên Tường (Noclip)", "Đi xuyên qua vách núi, tường rào và vật cản", Config.Noclip, function(v) Config.Noclip = v end)

createCategoryHeader(tabPlayer, "Chống Văng Game & Ổn Định")
local stabCard = createCardGroup(tabPlayer)
createToggleRow(stabCard, "Chống Văng Game (Anti-AFK)", "Chống bị Roblox kick sau 20 phút treo máy", Config.AntiAFK, function(v) Config.AntiAFK = v end)
createToggleRow(stabCard, "Tự Động Kết Nối Lại", "Tự động vào lại server nếu bị mất kết nối", Config.AutoRejoin, function(v) Config.AutoRejoin = v end)

do
    createCategoryHeader(tabProfiles, "Quản Lý Cấu Hình (Profile)")
    local profCard = createCardGroup(tabProfiles)

    local curAccName = (LocalPlayer and LocalPlayer.Name) or "DefaultUser"
    createInfoRow(profCard, "Tài Khoản Hiện Tại", curAccName)
    createInfoRow(profCard, "Khởi Động Script", "Mặc Định (Luôn Default)")

    local initialConfigs = GetSavedConfigList()
    local selectedConfigName = initialConfigs[1] or ""
    local newConfigInputName = ""

    local configDropdown = createDropdownRow(profCard, "Chọn Cấu Hình Đã Lưu", "Danh sách toàn bộ cấu hình riêng của tài khoản " .. curAccName, #initialConfigs > 0 and initialConfigs or {"(Chưa có cấu hình)"}, function(val)
        selectedConfigName = val
    end)

    local function RefreshProfileDropdown(preferredSelect)
        local updatedList = GetSavedConfigList()
        if #updatedList == 0 then
            configDropdown.Refresh({"(Chưa có cấu hình)"})
            selectedConfigName = ""
        else
            configDropdown.Refresh(updatedList)
            if preferredSelect and table.find(updatedList, preferredSelect) then
                configDropdown.Set(preferredSelect)
                selectedConfigName = preferredSelect
            else
                selectedConfigName = configDropdown.Get()
            end
        end
    end

    createInputRow(profCard, "Đặt Tên Cấu Hình Mới", "Nhập tên bất kỳ để lưu không giới hạn cấu hình", "", function(txt)
        newConfigInputName = txt
    end)

    createButtonRow(profCard, "Lưu Cấu Hình Mới", "Lưu toàn bộ cài đặt hiện tại thành một file cấu hình mới", "💾 Lưu Config", function()
        local targetName = newConfigInputName:gsub("^%s+", ""):gsub("%s+$", "")
        if #targetName == 0 then
            ShowNotification("Lưu Config", "Vui lòng nhập tên cấu hình mới vào ô phía trên!", "WARN")
            return
        end
        local ok, res = SaveAccountConfig(targetName)
        if ok then
            ShowNotification("Lưu Config", "Đã lưu cấu hình [" .. res .. "] cho tài khoản " .. curAccName .. "!", "SUCCESS")
            RefreshProfileDropdown(res)
        else
            ShowNotification("Lưu Thất Bại", tostring(res), "ERROR")
        end
    end)

    createButtonRow(profCard, "Áp Dụng Cấu Hình (Load)", "Tải và đồng bộ hóa toàn bộ cài đặt từ cấu hình đã chọn", "🚀 Nạp Config", function()
        local curSel = configDropdown.Get() or selectedConfigName
        if not curSel or curSel == "" or curSel == "(Chưa có cấu hình)" then
            ShowNotification("Nạp Config", "Tài khoản " .. curAccName .. " chưa chọn hoặc chưa có cấu hình nào!", "WARN")
            return
        end
        local ok, res = LoadAccountConfig(curSel)
        if ok then
            ShowNotification("Nạp Config", "Đã nạp và đồng bộ giao diện cấu hình [" .. res .. "]!", "SUCCESS")
        else
            ShowNotification("Nạp Thất Bại", tostring(res), "ERROR")
        end
    end)

    createButtonRow(profCard, "Làm Mới Danh Sách", "Quét lại tất cả các file cấu hình hiện có của tài khoản", "🔄 Làm Mới", function()
        RefreshProfileDropdown()
        ShowNotification("Danh Sách Config", "Đã cập nhật lại danh sách cấu hình của " .. curAccName .. "!", "INFO")
    end)

    createButtonRow(profCard, "Xóa Cấu Hình Đã Chọn", "Xóa vĩnh viễn file cấu hình đang được chọn khỏi máy", "🗑️ Xóa Config", function()
        local curSel = configDropdown.Get() or selectedConfigName
        if not curSel or curSel == "" or curSel == "(Chưa có cấu hình)" then
            ShowNotification("Xóa Config", "Chưa chọn file cấu hình hợp lệ để xóa!", "WARN")
            return
        end
        local ok, res = DeleteAccountConfig(curSel)
        if ok then
            ShowNotification("Xóa Config", "Đã xóa cấu hình [" .. res .. "] thành công!", "SUCCESS")
            RefreshProfileDropdown()
        else
            ShowNotification("Xóa Thất Bại", tostring(res), "ERROR")
        end
    end)
end

createCategoryHeader(tabProfiles, "📢 Discord Webhook Báo Cáo Từ Xa")
local hookCard = createCardGroup(tabProfiles)

createInputRow(hookCard, "Webhook URL", "Dán URL Webhook từ máy chủ Discord của bạn vào đây", Config.WebhookUrl or "", function(txt)
    Config.WebhookUrl = txt
end)

createToggleRow(hookCard, "Bật Webhook", "Kích hoạt gửi thông báo về Discord", Config.WebhookEnabled, function(v)
    Config.WebhookEnabled = v
end)

createToggleRow(hookCard, "Thông Báo Bắt Được Boss", "Gửi tin nhắn khi câu trúng hoặc bắt thành công Boss / Cá Thần Thoại", Config.WebhookNotifyBoss, function(v)
    Config.WebhookNotifyBoss = v
end)

createToggleRow(hookCard, "Báo Cáo Định Kỳ (Mỗi 30 Phút)", "Gửi bảng tổng kết thời gian treo máy, số cá và tiền kiếm được", Config.WebhookHourlyStats, function(v)
    Config.WebhookHourlyStats = v
end)

createButtonRow(hookCard, "Kiểm Tra Webhook (Test)", "Gửi thử 1 thông báo mẫu về Discord ngay lập tức", "Gửi Test", function()
    if not Config.WebhookUrl or Config.WebhookUrl == "" then
        ShowNotification("Webhook", "Vui lòng nhập Webhook URL trước!", "WARN")
        return
    end
    ShowNotification("Webhook", "Đang gửi tin nhắn test...", "INFO")
    task.spawn(function()
        local ok = pcall(function()
            SendDiscordWebhook(
                "🔔 Test Webhook - Heavyweight Fishing",
                "Kết nối Webhook thành công từ tài khoản: **" .. (LocalPlayer and LocalPlayer.Name or "Unknown") .. "**!",
                3066993,
                {
                    { name = "Trạng Thái", value = "✅ Hoạt Động Tốt", inline = true },
                    { name = "Thời Gian", value = os.date("%H:%M:%S - %d/%m/%Y"), inline = true }
                }
            )
        end)
        if ok then
            ShowNotification("Webhook", "Đã gửi lệnh test đến Discord!", "SUCCESS")
        else
            ShowNotification("Webhook", "Gửi thất bại! Kiểm tra lại URL Webhook.", "ERROR")
        end
    end)
end)

createCategoryHeader(tabProfiles, "Tùy Chọn Khác")
local credCard = createCardGroup(tabProfiles)
createButtonRow(credCard, "🔴 Diệt Toàn Bộ Script (Kill Script)", "Ngắt kết nối mọi vòng lặp, xóa sạch giao diện và giải phóng bộ nhớ", "KILL SCRIPT", function()
    ShowNotification("Diệt Script", "Đang ngắt kết nối và đóng script hoàn toàn...", "WARN", 2)
    task.wait(0.2)
    UnloadScript()
end)

local lastCastTime = 0
local lastSellTime = 0
local lastSkillTime = 0
local lastTrainSkillTime = 0
local isTrainingBusy = false
local lastGlobalSkillCastTime = 0
local comboState = {
    openerUsedCount = 0,
    openerDone = false,
    loopTargetIndex = 1,
    loopIndex = 1,
    lastCastTime = 0,
    minigameStartTime = 0,
    usedTimes = {
        ["Z"] = 0,
        ["X"] = 0,
        ["C"] = 0,
        ["V"] = 0
    },
    defaultCooldowns = {
        ["Z"] = 2.5,
        ["X"] = 3.0,
        ["C"] = 5.0,
        ["V"] = 4.0
    }
}

local function CheckSkillReady(sk, fUI, minCooldown)
    if not sk or sk == "" or sk == "Tắt" then return false end
    local cleanKey = sk:match("([ZXCVzxcv])") or sk
    cleanKey = cleanKey:upper()

    local now = tick()
    local lastUsed = comboState.usedTimes[cleanKey] or 0
    local minCd = minCooldown or 0.8
    if (now - lastUsed < minCd) then
        return false
    end

    -- Nếu đã trôi qua hơn cooldown ước tính kể từ lần cuối cast chiêu này, đảm bảo chiêu đã hồi xong
    local baseCd = comboState.defaultCooldowns[cleanKey] or 3.5
    if (now - lastUsed >= baseCd) then
        return true
    end

    if fUI then
        for _, desc in ipairs(fUI:GetDescendants()) do
            local nameUpper = desc.Name:upper()
            if nameUpper == cleanKey or (nameUpper:find("SKILL") and nameUpper:find(cleanKey)) or (nameUpper:find("SLOT") and nameUpper:find(cleanKey)) then
                if desc:GetAttribute("OnCooldown") == true or desc:GetAttribute("CD") == true then
                    return false
                end
                for _, child in ipairs(desc:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Visible and child.Text ~= "" then
                        local cName = child.Name:lower()
                        local isCdLabel = cName:find("cd") or cName:find("cooldown") or cName:find("timer") or cName:find("time")
                        local txt = child.Text
                        -- Bỏ qua label hiển thị Damage / Power / Level / Name
                        if not cName:find("dmg") and not cName:find("damage") and not cName:find("power") and not cName:find("level") and not cName:find("title") and not cName:find("name") then
                            -- Chỉ nhận diện là cooldown nếu có chữ 's' (ví dụ 3.5s, 10s) hoặc nếu tên label là cooldown/timer
                            local cdWithS = txt:match("^%s*(%d+%.?%d*)%s*[sS]%s*$") or txt:match("^%s*(%d+%.?%d*)%s*sec%s*$")
                            if cdWithS then
                                local num = tonumber(cdWithS)
                                if num and num > 0 and num <= 30 then
                                    return false
                                end
                            elseif isCdLabel then
                                local numStr = txt:match("^%s*(%d+%.?%d*)%s*$")
                                local num = tonumber(numStr)
                                -- Bỏ qua các số nguyên 1, 2, 3, 4 nếu đó là phím tắt
                                if num and num > 0 and num <= 30 and not (num >= 1 and num <= 4 and not txt:find("%.%")) then
                                    return false
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return true
end

local function IsSkillOnCooldown(sk, fUI)
    if not sk or sk == "" or sk == "Tắt" then return false end
    local cleanKey = sk:match("([ZXCVzxcv])") or sk
    cleanKey = cleanKey:upper()

    if fUI then
        for _, desc in ipairs(fUI:GetDescendants()) do
            local nameUpper = desc.Name:upper()
            if nameUpper == cleanKey or (nameUpper:find("SKILL") and nameUpper:find(cleanKey)) or (nameUpper:find("SLOT") and nameUpper:find(cleanKey)) then
                if desc:GetAttribute("OnCooldown") == true or desc:GetAttribute("CD") == true then
                    return true
                end
                for _, child in ipairs(desc:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Visible and child.Text ~= "" then
                        local cName = child.Name:lower()
                        local isCdLabel = cName:find("cd") or cName:find("cooldown") or cName:find("timer") or cName:find("time")
                        local txt = child.Text
                        if not cName:find("dmg") and not cName:find("damage") and not cName:find("power") and not cName:find("level") and not cName:find("title") and not cName:find("name") then
                            local cdWithS = txt:match("^%s*(%d+%.?%d*)%s*[sS]%s*$") or txt:match("^%s*(%d+%.?%d*)%s*sec%s*$")
                            if cdWithS then
                                local num = tonumber(cdWithS)
                                if num and num > 0 and num <= 999 then
                                    return true
                                end
                            elseif isCdLabel then
                                local numStr = txt:match("^%s*(%d+%.?%d*)%s*$")
                                local num = tonumber(numStr)
                                if num and num > 0 and num <= 999 and not (num >= 1 and num <= 4 and not txt:find("%.%")) then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local function GetFishHealth(fUI)
    -- 1. Kiểm tra Workspace.Fishes
    local fishID = LocalPlayer:GetAttribute("FishID")
    if fishID and Workspace:FindFirstChild("Fishes") then
        local f = Workspace.Fishes:FindFirstChild(fishID)
        if f then
            local hpVal = f:FindFirstChild("FishHealth") or f:FindFirstChild("Health")
            if hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) and hpVal.Value > 0 then
                return hpVal.Value
            end
            for _, child in ipairs(f:GetChildren()) do
                if (child.Name:find("FishHealth") or child.Name:find("Health")) and not child.Name:find("Player") then
                    if (child:IsA("NumberValue") or child:IsA("IntValue")) and child.Value > 0 then
                        return child.Value
                    end
                end
            end
        end
    end

    -- 2. Kiểm tra Attribute trên Character (TUYỆT ĐỐI KHÔNG KIỂM TRA "HP" VÌ ĐÓ LÀ MÁU NGƯỜI CHƠI)
    local char = LocalPlayer.Character
    if char then
        for _, att in ipairs({"FishHealth", "FishHP", "TargetHealth", "BossHP", "TargetHP"}) do
            local val = char:GetAttribute(att)
            if val and tonumber(val) and tonumber(val) > 0 then
                return tonumber(val)
            end
        end
    end

    -- 3. Quét trong fUI (PlayerGui.MainGui.Fishing)
    if fUI then
        -- Kiểm tra BossFightBar (Thanh máu Boss chính thức)
        local bossBar = fUI:FindFirstChild("BossFightBar")
        if bossBar and bossBar.Visible and bossBar.Size.X.Scale > 0 then
            for _, d in ipairs(bossBar:GetDescendants()) do
                if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                    local txt = d.Text
                    local kMatch = txt:match("([%d%.]+)%s*[kK]")
                    if kMatch and tonumber(kMatch) then return tonumber(kMatch) * 1000 end
                    local mMatch = txt:match("([%d%.]+)%s*[mM]")
                    if mMatch and tonumber(mMatch) then return tonumber(mMatch) * 1000000 end

                    local slashMatch = txt:match("([%d,%.]+)%s*/")
                    if slashMatch then
                        local n = tonumber(slashMatch:gsub("[,]", ""))
                        if n and n > 0 then return n end
                    end

                    local numOnly = txt:match("^%s*([%d,%.]+)%s*$")
                    if numOnly then
                        local n = tonumber(numOnly:gsub("[,]", ""))
                        if n and n > 0 and n ~= 100 then return n end
                    end
                end
            end
            -- Nếu BossFightBar đang hiện nhưng chưa kịp đọc số -> Coi như máu to (> threshold)
            return 999999
        end

        -- Quét các TextLabel hiển thị máu cá khác, LOẠI BỎ TRIỆT ĐỂ HPPlayer và mọi khung của người chơi
        for _, d in ipairs(fUI:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                local isPlayer = false
                local p = d
                while p and p ~= fUI do
                    local pName = p.Name:lower()
                    if pName:find("player") or pName == "hpplayer" then
                        isPlayer = true
                        break
                    end
                    p = p.Parent
                end

                if not isPlayer then
                    local dName = d.Name:lower()
                    local txt = d.Text
                    local isFishContext = dName:find("fish") or dName:find("target") or dName:find("boss") or dName:find("enemy")

                    if isFishContext then
                        local kMatch = txt:match("([%d%.]+)%s*[kK]")
                        if kMatch and tonumber(kMatch) then return tonumber(kMatch) * 1000 end
                        local mMatch = txt:match("([%d%.]+)%s*[mM]")
                        if mMatch and tonumber(mMatch) then return tonumber(mMatch) * 1000000 end

                        local slashMatch = txt:match("([%d,%.]+)%s*/")
                        if slashMatch then
                            local n = tonumber(slashMatch:gsub("[,]", ""))
                            if n and n > 0 then return n end
                        end

                        local hpSuffixMatch = txt:match("([%d,%.]+)%s*[hH][pP]") or txt:match("[hH][pP]%s*:?%s*([%d,%.]+)")
                        if hpSuffixMatch then
                            local n = tonumber(hpSuffixMatch:gsub("[,]", ""))
                            if n and n > 0 then return n end
                        end

                        local numOnly = txt:match("^%s*([%d,%.]+)%s*$")
                        if numOnly then
                            local n = tonumber(numOnly:gsub("[,]", ""))
                            if n and n > 0 and n ~= 100 then return n end
                        end
                    end
                end
            end
        end
    end

    -- Nếu không có BossFightBar và không có nhãn máu đặc biệt -> Đây là cá thông thường (10 HP)
    return 10
end

local function GetPlayerHealth(fUI)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.MaxHealth > 0 then
        return (hum.Health / hum.MaxHealth) * 100
    end

    if fUI and fUI:FindFirstChild("HPPlayer") then
        local hpP = fUI.HPPlayer
        local pBar = hpP:FindFirstChild("ProgressionBar")
        if pBar and pBar:FindFirstChild("Bar") then
            return pBar.Bar.Size.X.Scale * 100
        end
        for _, d in ipairs(hpP:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                local cur, max = d.Text:match("(%d+)%s*/%s*(%d+)")
                if cur and max and tonumber(max) > 0 then
                    return (tonumber(cur) / tonumber(max)) * 100
                end
            end
        end
    end

    return 100
end

local function IsCharacterCastingSkill()
    local now = tick()
    -- Chỉ coi là animation skill trong tối đa 0.7s kể từ khi tung chiêu, tránh bị kẹt vĩnh viễn
    if (now - comboState.lastCastTime > 0.7) then
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end

    -- Bỏ qua "Casting" vì đó là trạng thái quăng cần câu của game
    for _, att in ipairs({"UsingSkill", "SkillActive", "IsAttacking", "CastingSkill"}) do
        if char:GetAttribute(att) == true then
            return true
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local anim = hum and hum:FindFirstChildOfClass("Animator")
    if anim then
        local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, tr in ipairs(tracks) do
                if tr.IsPlaying and (tr.Priority == Enum.AnimationPriority.Action or tr.Priority == Enum.AnimationPriority.Action2 or tr.Priority == Enum.AnimationPriority.Action3 or tr.Priority == Enum.AnimationPriority.Action4) then
                    local animName = tr.Name:lower()
                    -- Loại bỏ các animation câu cá / quăng cần / cuộn dây / chạy bộ (tránh nhận nhầm làm kẹt combo)
                    if not animName:find("fish") and not animName:find("rod") and not animName:find("reel") and not animName:find("cast") and not animName:find("idle") and not animName:find("hold") and not animName:find("walk") and not animName:find("run") then
                        if animName:find("skill") or animName:find("attack") or animName:find("special") or animName:find("slash") then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

local function CastSkill(sk)
    if not sk or sk == "" or sk == "Tắt" then return false end
    local cleanKey = sk:match("([ZXCVzxcv])") or sk
    cleanKey = cleanKey:upper()

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
    comboState.usedTimes[cleanKey] = tick()
    comboState.lastCastTime = tick()
    return true
end
local lastGachaTime = 0
local lastBaitBuyTime = 0
local lastQuestTime = 0
local lastGodPrayTime = 0
local lastEquipTime = 0
local lastEquipRodTime = 0
local lastProgressionTime = 0
local lastProtectTime = 0
local fishingStartTime = 0
local wasFishing = false
local minigameDurationTracker = 0
local wasMinigame = false



local function ProtectInventoryItem(item, showNotify)
    if not item or Wiki.IsItemFavorited(item) then return false end
    local itemName = item.Name
    local shouldProtect = false
    local reason = ""

    if Config.AutoProtectMutations and Wiki.IsMutatedFish(item) then
        shouldProtect = true
        reason = "Cá Đột Biến"
    elseif Config.MaterialFarming and Wiki.craftMaterialFish[itemName] then
        shouldProtect = true
        reason = "Nguyên Liệu"
    elseif Config.AutoFavouriteFish and itemName == Config.FavouriteFishName then
        shouldProtect = true
        reason = "Cá Quý Chỉ Định"
    end

    if shouldProtect and Events and Events:FindFirstChild("FavoriteItem") then
        Events.FavoriteItem:FireServer(item)
        if showNotify and reason == "Cá Quý Chỉ Định" then
            ShowNotification("Khóa Cá", "Đã tự động KHÓA bảo vệ [" .. itemName .. "]!", "SUCCESS", 6)
        end
        return true
    end
    return false
end

local function ProtectAllInventoryItems(showNotify)
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
    if pData and pData:FindFirstChild("Inventory") then
        for _, item in ipairs(pData.Inventory:GetChildren()) do
            ProtectInventoryItem(item, showNotify)
        end
    end
end

-- Lắng nghe khi nhận được cá mới vào balo -> Khóa ngay lập tức nếu là Secret Boss
task.spawn(function()
    local pDataInit = ReplicatedStorage:WaitForChild("Data", 10)
    local userFolder = pDataInit and pDataInit:WaitForChild(tostring(LocalPlayer.UserId), 10)
    local invFolder = userFolder and userFolder:WaitForChild("Inventory", 10)
    if invFolder then
        table.insert(activeConnections, invFolder.ChildAdded:Connect(function(child)
            task.wait(0.3)
            ProtectInventoryItem(child, true)
        end))
    end
end)

local waterPlatform = Instance.new("Part")
waterPlatform.Name = "IdenticalWaterPlatform"
waterPlatform.Size = Vector3.new(60, 2, 60)
waterPlatform.Anchored = true
waterPlatform.CanCollide = false
waterPlatform.CanQuery = false
waterPlatform.CanTouch = false
waterPlatform.Transparency = 1
waterPlatform.Parent = Workspace
table.insert(cleanUpInstances, waterPlatform)

table.insert(activeConnections, RunService.Heartbeat:Connect(function(dt)
    if not isRunning then return end
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local now = tick()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)

        if Config.WalkSpeedEnabled then
            hum.WalkSpeed = Config.WalkSpeedValue
        end

        if Config.WalkOnWater or Config.AcidWaterShield then
            local yLevel = 0
            if Config.AcidWaterShield then
                yLevel = 3.5
            end
            waterPlatform.CFrame = CFrame.new(root.Position.X, yLevel, root.Position.Z)
            waterPlatform.CanCollide = (root.Position.Y >= yLevel - 2)
        else
            waterPlatform.CanCollide = false
        end

        if Config.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        local isFishing = char:GetAttribute("Fishing") == true
        local isMinigame = char:GetAttribute("Minigame") == true or (pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing") and pg.MainGui.Fishing.Visible)
        local isCD = char:GetAttribute("CDForTheNextThrow") == true
        local isSwimming = char:GetAttribute("Swimming") == true

        local isBossActive = secretBossState and secretBossState.active
        local isTicketActive = IsTicketQuestFishingActive()
        local shouldAutoFish = Config.AutoCast or Config.AutoTrainSkill or isTicketActive or ((Config.AutoHuntBoss or Config.AutoChatSecretBoss) and isBossActive)

        if shouldAutoFish and char:GetAttribute("Type") ~= "Fishing Rod" and (now - lastEquipRodTime >= 1.0) and not isTrainingBusy then
            lastEquipRodTime = now
            local rodSlot = "1"
            if pData and pData:FindFirstChild("Hotbar") then
                for _, item in ipairs(pData.Hotbar:GetChildren()) do
                    local vName = item:FindFirstChild("ValueName")
                    if vName and tostring(vName.Value):lower():find("rod") and not tostring(vName.Value):lower():find("inventory") then
                        rodSlot = item.Name
                        break
                    end
                end
            end
            if Events and Events:FindFirstChild("ToggleHotbar") then
                Events.ToggleHotbar:InvokeServer(rodSlot)
            end
        end

        if isFishing and not wasFishing then
            fishingStartTime = now
        elseif not isFishing then
            fishingStartTime = 0
        end
        wasFishing = isFishing

        if isMinigame and not wasMinigame then
            minigameDurationTracker = now
            comboState.openerUsedCount = 0
            comboState.openerDone = false
            comboState.loopTargetIndex = 1
            comboState.loopIndex = 1
            comboState.minigameStartTime = now
            secretBossState.webhookSentForCurrent = false
        elseif not isMinigame then
            minigameDurationTracker = 0
            secretBossState.webhookSentForCurrent = false
            secretBossState.isCatchingTarget = false
            secretBossState.minigameStartTime = 0
        end
        wasMinigame = isMinigame

        if isFishing and not isMinigame and fishingStartTime > 0 and (now - fishingStartTime >= 15.0) then
            fishingStartTime = now
            if Config.AntiStuckEnabled then
                CancelAndRecastRod()
            elseif Events and Events:FindFirstChild("Fishing") then
                Events.Fishing:FireServer(root.CFrame)
            end
        end

        if isMinigame and Config.AntiStuckEnabled and not Config.AutoTrainSkill and minigameDurationTracker > 0 and (now - minigameDurationTracker >= 22.0) then
            minigameDurationTracker = now
            CancelAndRecastRod()
        end

        if isMinigame then
            local fUI = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
            
            -- XỬ LÝ FAST SKIP KHI SĂN SECRET BOSS (NẾU KHÔNG PHẢI BOSS MỤC TIÊU THÌ GIẬT CẦN THẢ LẠI)
            local skipTriggered = false
            local isHunting = (Config.AutoHuntBoss or Config.AutoChatSecretBoss) and secretBossState.active

            if isHunting and Config.FastSkipNonBoss and not Config.AutoTrainSkill then
                if secretBossState.minigameStartTime == 0 then
                    secretBossState.minigameStartTime = now
                end

                local hookedFish = GetCurrentHookedFishName()
                local curFishHp = GetFishHealth(fUI)
                local isTargetBoss = false
                local bossDisplay = nil

                if hookedFish then
                    if Config.SecretBossTargets[hookedFish] == true or (secretBossLookup[hookedFish:lower()] and Config.SecretBossTargets[secretBossLookup[hookedFish:lower()]] == true) then
                        isTargetBoss = true
                        bossDisplay = hookedFish
                    end
                end

                if not isTargetBoss and fUI then
                    for _, bName in ipairs({"BossFightBar", "BossBar", "BossUI", "BossFrame", "BossProgress", "BossHealth"}) do
                        local bBar = fUI:FindFirstChild(bName, true)
                        if bBar and bBar.Visible then
                            isTargetBoss = true
                            bossDisplay = hookedFish or "Secret Boss"
                            break
                        end
                    end
                end

                if isTargetBoss then
                    secretBossState.isCatchingTarget = true
                    local displayBossName = bossDisplay or hookedFish or "Secret Boss"
                    if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                        statusLabelSecretBoss.Set("🎯 ĐANG CÂU BOSS: " .. tostring(displayBossName) .. "!")
                    end
                    if Config.WebhookEnabled and Config.WebhookNotifyBoss and not secretBossState.webhookSentForCurrent then
                        secretBossState.webhookSentForCurrent = true
                        SendDiscordWebhook(
                            "🚨 PHÁT HIỆN SECRET BOSS!",
                            "Tài khoản **" .. LocalPlayer.Name .. "** đang câu trúng: **" .. tostring(displayBossName) .. "** tại " .. (secretBossState.currentMap or "Đảo hiện tại") .. "!",
                            15158332,
                            {
                                { name = "🐟 Boss Mục Tiêu", value = tostring(displayBossName), inline = true },
                                { name = "📍 Bản Đồ", value = tostring(secretBossState.currentMap or "Đảo Hiện Tại"), inline = true },
                                { name = "⏰ Thời Gian", value = os.date("%H:%M:%S - %d/%m/%Y"), inline = true }
                            }
                        )
                    end
                else
                    -- Không phải Secret Boss mục tiêu -> Fast Skip giật cần bỏ cá thường
                    local timeInMinigame = now - secretBossState.minigameStartTime
                    local canSkipNow = (now - secretBossState.lastSkipTime >= 0.8)

                    if canSkipNow and ((hookedFish and timeInMinigame >= 0.25) or (timeInMinigame >= 0.7)) then
                        secretBossState.lastSkipTime = now
                        secretBossState.minigameStartTime = 0
                        skipTriggered = true
                        local skipFishName = hookedFish or "Cá thường"
                        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                            statusLabelSecretBoss.Set("Bỏ qua [" .. skipFishName .. (curFishHp and (" - " .. tostring(curFishHp) .. " HP") or "") .. "], đang giật cần thả lại...")
                        end
                        CancelAndRecastRod()
                    end
                end
            else
                secretBossState.minigameStartTime = 0
            end

            if not skipTriggered then
                if Config.AutoTrainSkill then
                    if not isTrainingBusy then
                        isTrainingBusy = true
                        task.spawn(function()
                            local chosenSkill = Config.TrainSkill or "Z"
                            local cleanKey = chosenSkill:match("([ZXCVzxcv])") or chosenSkill
                            cleanKey = cleanKey:upper()

                            local initialFishHp = GetFishHealth(fUI)
                            local startTime = tick()

                            -- 1. GIỮ THĂNG BẰNG THANH BAR VÀ CHỜ QUA 3 GIÂY KHÓA CHIÊU CỦA GAME (BẮN SKILL LIÊN TỤC ĐỂ BẮT ĐÚNG NHỊP MỞ)
                            while isRunning and (fUI and fUI.Visible) do
                                -- Giữ thăng bằng thanh bar ở giữa để cá không bao giờ bị tuột
                                local barFrame = fUI:FindFirstChild("BarFrame")
                                if barFrame and barFrame:FindFirstChild("Bar") then
                                    barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                                end

                                -- Bắn skill liên tục để kích hoạt ngay khoảnh khắc game mở khóa
                                CastSkill(cleanKey)

                                task.wait(0.08)

                                local elapsed = tick() - startTime

                                -- TUYỆT ĐỐI KHÔNG ĐƯỢC THOÁT TRƯỚC 3 GIÂY VÌ GAME ĐANG KHÓA CHIÊU
                                if elapsed >= 3.05 then
                                    local curHp = GetFishHealth(fUI)
                                    local hpDropped = (initialFishHp and curHp and curHp < initialFishHp)
                                    local nowOnCd = IsSkillOnCooldown(cleanKey, fUI)

                                    -- Sau khi qua 3s: nếu đã tung chiêu thành công hoặc sau thêm 0.8s nữa thì ngắt để cất cần
                                    if nowOnCd or hpDropped or (elapsed >= 3.8) then
                                        break
                                    end
                                end
                            end

                            -- 2. Đợi 0.35s cho nhân vật chém đòn / tung chiêu xong để server ghi nhận
                            local waitFinish = tick()
                            while isRunning and (tick() - waitFinish) < 0.35 do
                                if fUI and fUI.Visible then
                                    local barFrame = fUI:FindFirstChild("BarFrame")
                                    if barFrame and barFrame:FindFirstChild("Bar") then
                                        barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                                    end
                                end
                                task.wait(0.05)
                            end

                            -- 3. Cập nhật số lần đã luyện
                            Config.TrainCurrentCount = Config.TrainCurrentCount + 1
                            if infoTrainProgress and infoTrainProgress.Set then
                                infoTrainProgress.Set(string.format("%d / %d lần (Vừa cast: %s)", Config.TrainCurrentCount, Config.TrainTargetCount, cleanKey))
                            end

                            if Config.TrainCurrentCount >= Config.TrainTargetCount then
                                Config.AutoTrainSkill = false
                                ShowNotification("Luyện Chiêu Hoàn Tất", string.format("Đã luyện đủ %d/%d lần cho chiêu %s!", Config.TrainCurrentCount, Config.TrainTargetCount, cleanKey), "SUCCESS", 7)
                                pcall(function()
                                    local c = LocalPlayer.Character
                                    local h = c and c:FindFirstChildOfClass("Humanoid")
                                    if h then h:UnequipTools() end
                                end)
                                isTrainingBusy = false
                                return
                            end

                            -- 4. BẤM THÁO CẦN (UnequipTools) ĐỂ HỦY CÁ
                            local rodSlot = "1"
                            local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
                            if pData and pData:FindFirstChild("Hotbar") then
                                for _, item in ipairs(pData.Hotbar:GetChildren()) do
                                    local vName = item:FindFirstChild("ValueName")
                                    if vName and tostring(vName.Value):lower():find("rod") and not tostring(vName.Value):lower():find("inventory") then
                                        rodSlot = item.Name
                                        break
                                    end
                                end
                            end

                            pcall(function()
                                local c = LocalPlayer.Character
                                local h = c and c:FindFirstChildOfClass("Humanoid")
                                if h then h:UnequipTools() end
                            end)

                            -- 5. LẤY CẦN RA LẠI
                            task.wait(0.25)
                            pcall(function()
                                if Events and Events:FindFirstChild("ToggleHotbar") then
                                    Events.ToggleHotbar:InvokeServer(rodSlot)
                                else
                                    local vim = game:GetService("VirtualInputManager")
                                    if vim then
                                        vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                        task.wait(0.02)
                                        vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                                    end
                                end
                            end)

                            -- 6. CÂU TIẾP (Quăng cần câu lại ngay)
                            task.wait(0.25)
                            local c2 = LocalPlayer.Character
                            local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                            if r2 and Events and Events:FindFirstChild("Fishing") then
                                Events.Fishing:FireServer(r2.CFrame)
                                lastCastTime = tick()
                            end

                            task.wait(0.3)
                            isTrainingBusy = false
                        end)
                    end
                elseif Config.AutoTicketQuest and ticketQuestState and ticketQuestState.active and not ticketQuestState.isCooldown and ticketQuestState.currentQuestType ~= "none" then
                    local qType = ticketQuestState.currentQuestType
                    if qType == "bait_100" then
                        if not ticketQuestState.isBusyRoutine then
                            ticketQuestState.isBusyRoutine = true
                            task.spawn(function()
                                pcall(function()
                                    local c = LocalPlayer.Character
                                    local h = c and c:FindFirstChildOfClass("Humanoid")
                                    if h then h:UnequipTools() end
                                end)
                                ticketQuestState.currentProgress = ticketQuestState.currentProgress + 1
                                ticketQuestState.UpdateUI()
                                if ticketQuestState.currentProgress >= 100 then
                                    ticketQuestState.isCompleted = true
                                end

                                task.wait(0.25)
                                local rodSlot = "1"
                                local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
                                if pData and pData:FindFirstChild("Hotbar") then
                                    for _, item in ipairs(pData.Hotbar:GetChildren()) do
                                        local vName = item:FindFirstChild("ValueName")
                                        if vName and tostring(vName.Value):lower():find("rod") and not tostring(vName.Value):lower():find("inventory") then
                                            rodSlot = item.Name
                                            break
                                        end
                                    end
                                end
                                pcall(function()
                                    if Events and Events:FindFirstChild("ToggleHotbar") then
                                        Events.ToggleHotbar:InvokeServer(rodSlot)
                                    end
                                end)

                                task.wait(0.25)
                                local c2 = LocalPlayer.Character
                                local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                                if r2 and Events and Events:FindFirstChild("Fishing") then
                                    Events.Fishing:FireServer(r2.CFrame)
                                    lastCastTime = tick()
                                end

                                task.wait(0.3)
                                ticketQuestState.isBusyRoutine = false
                            end)
                        end
                    elseif qType == "skill_100" then
                        if not ticketQuestState.isBusyRoutine then
                            ticketQuestState.isBusyRoutine = true
                            task.spawn(function()
                                local chosenSkill = Config.TicketSkillKey or "Z"
                                local cleanKey = chosenSkill:match("([ZXCVzxcv])") or chosenSkill
                                cleanKey = cleanKey:upper()

                                local initialFishHp = GetFishHealth(fUI)
                                local startTime = tick()

                                while isRunning and (fUI and fUI.Visible) do
                                    local barFrame = fUI:FindFirstChild("BarFrame")
                                    if barFrame and barFrame:FindFirstChild("Bar") then
                                        barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                                    end

                                    CastSkill(cleanKey)
                                    task.wait(0.08)

                                    local elapsed = tick() - startTime
                                    if elapsed >= 3.05 then
                                        local curHp = GetFishHealth(fUI)
                                        local hpDropped = (initialFishHp and curHp and curHp < initialFishHp)
                                        local nowOnCd = IsSkillOnCooldown(cleanKey, fUI)
                                        if nowOnCd or hpDropped or (elapsed >= 3.8) then
                                            break
                                        end
                                    end
                                end

                                local waitFinish = tick()
                                while isRunning and (tick() - waitFinish) < 0.35 do
                                    if fUI and fUI.Visible then
                                        local barFrame = fUI:FindFirstChild("BarFrame")
                                        if barFrame and barFrame:FindFirstChild("Bar") then
                                            barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                                        end
                                    end
                                    task.wait(0.05)
                                end

                                ticketQuestState.currentProgress = ticketQuestState.currentProgress + 1
                                ticketQuestState.UpdateUI()
                                if ticketQuestState.currentProgress >= 100 then
                                    ticketQuestState.isCompleted = true
                                end

                                local rodSlot = "1"
                                local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(LocalPlayer.UserId)
                                if pData and pData:FindFirstChild("Hotbar") then
                                    for _, item in ipairs(pData.Hotbar:GetChildren()) do
                                        local vName = item:FindFirstChild("ValueName")
                                        if vName and tostring(vName.Value):lower():find("rod") and not tostring(vName.Value):lower():find("inventory") then
                                            rodSlot = item.Name
                                            break
                                        end
                                    end
                                end
                                pcall(function()
                                    local c = LocalPlayer.Character
                                    local h = c and c:FindFirstChildOfClass("Humanoid")
                                    if h then h:UnequipTools() end
                                end)

                                task.wait(0.25)
                                pcall(function()
                                    if Events and Events:FindFirstChild("ToggleHotbar") then
                                        Events.ToggleHotbar:InvokeServer(rodSlot)
                                    end
                                end)

                                task.wait(0.25)
                                local c2 = LocalPlayer.Character
                                local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                                if r2 and Events and Events:FindFirstChild("Fishing") then
                                    Events.Fishing:FireServer(r2.CFrame)
                                    lastCastTime = tick()
                                end

                                task.wait(0.3)
                                ticketQuestState.isBusyRoutine = false
                            end)
                        end
                    elseif qType == "fish_100" and fUI and fUI.Visible then
                        local barFrame = fUI:FindFirstChild("BarFrame")
                        if barFrame and barFrame:FindFirstChild("Bar") then
                            barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                        end
                        local quickSkill = Config.TicketQuickSkill or "V"
                        local cleanKey = quickSkill:match("([ZXCVzxcv])") or quickSkill
                        cleanKey = cleanKey:upper()
                        CastSkill(cleanKey)
                        if Events and Events:FindFirstChild("Slam") then Events.Slam:FireServer("Perfect") end
                        if Events and Events:FindFirstChild("Charge") then Events.Charge:FireServer(100) end
                        if Events and Events:FindFirstChild("UpdateFishProgression") then Events.UpdateFishProgression:FireServer() end
                    elseif qType == "fish_15m" and fUI and fUI.Visible then
                        local barFrame = fUI:FindFirstChild("BarFrame")
                        if barFrame and barFrame:FindFirstChild("Bar") then
                            barFrame.Bar:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
                            barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                        end
                        if Events and Events:FindFirstChild("Slam") then Events.Slam:FireServer("Perfect") end
                        if Events and Events:FindFirstChild("Charge") then Events.Charge:FireServer(100) end
                        if Events and Events:FindFirstChild("UpdateFishProgression") then Events.UpdateFishProgression:FireServer() end
                    end
                elseif fUI and fUI.Visible then
                    -- Tự động giữ thanh cân bằng minigame (Anchor Bar)
                    local isHomeFishing = Config.AutoTicketQuest and ticketQuestState and ticketQuestState.isCooldown and ticketQuestState.isAtHomeSpot and Config.TicketAutoCastAtHome
                    if (Config.AnchorBar or (Config.AutoChatSecretBoss and secretBossState.active) or Config.AutoHuntBoss or isHomeFishing) then
                        local barFrame = fUI:FindFirstChild("BarFrame")
                        if barFrame and barFrame:FindFirstChild("Bar") then
                            barFrame.Bar:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
                            barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                        end
                    end

                    if Config.AutoSlam and fUI:FindFirstChild("PerfectButton") and fUI.PerfectButton.Visible then
                        if Events:FindFirstChild("Slam") then
                            Events.Slam:FireServer()
                        end
                    end

                    if Config.AutoCharge and fUI:FindFirstChild("Charge") and fUI.Charge.Visible then
                        if Events:FindFirstChild("Charge") then
                            Events.Charge:FireServer()
                        end
                    end

                    if Config.AnchorBar and (now - lastProgressionTime >= 0.08) then
                        if Events and Events:FindFirstChild("UpdateFishProgression") then
                            Events.UpdateFishProgression:FireServer()
                        end
                        lastProgressionTime = now
                    end

                    if Config.SmartComboEnabled and (now - lastSkillTime >= 0.15) then
                        local playerHp = GetPlayerHealth(fUI)

                        -- BƯỚC 1: CỨU NGUY HỒI MÁU (Khi máu người chơi <= EmergencyHealHp, ví dụ <= 31%)
                        local isHealing = false
                        if Config.EmergencyHealSkill and Config.EmergencyHealSkill ~= "Tắt" and playerHp <= (Config.EmergencyHealHp or 31) then
                            local hKey = Config.EmergencyHealSkill:match("([ZXCVzxcv])")
                            if hKey then
                                CastSkill(hKey)
                                isHealing = true
                            end
                        end

                        if not isHealing then
                            -- BƯỚC 2: PHÂN LOẠI THEO MÁU CÁ
                            local fishHp = GetFishHealth(fUI)
                            local threshold = Config.FishHpThreshold or 500

                            if fishHp <= threshold then
                                -- Máu cá <= Ngưỡng (Cá thường / Cá yếu): Tung DUY NHẤT chiêu Bắt Nhanh (V)
                                if Config.QuickCatchSkill and Config.QuickCatchSkill ~= "Tắt" then
                                    local qKey = Config.QuickCatchSkill:match("([ZXCVzxcv])")
                                    if qKey then
                                        CastSkill(qKey)
                                    end
                                else
                                    for k in string.gmatch(Config.LoopSkills or "X, V", "([ZXCVzxcv])") do
                                        local lk = k:upper()
                                        CastSkill(lk)
                                    end
                                end
                            else
                                -- Máu cá > Ngưỡng (Cá to / Boss):
                                local minigameElapsed = now - (comboState.minigameStartTime or now)

                                -- 1. GIAI ĐOẠN CHIÊU MỞ MÀN (Opener Skill):
                                local opKey = Config.OpenerSkill and Config.OpenerSkill ~= "Tắt" and Config.OpenerSkill:match("([ZXCVzxcv])")
                                if opKey then opKey = opKey:upper() end

                                if opKey and not comboState.openerDone then
                                    CastSkill(opKey)

                                    -- Khi icon chiêu mở màn đã vào Cooldown hoặc sau 0.4s đầu -> Hoàn tất Opener
                                    if IsSkillOnCooldown(opKey, fUI) or minigameElapsed >= 0.4 then
                                        comboState.openerDone = true
                                    end
                                else
                                    -- 2. GIAI ĐOẠN ĐẢO CHIÊU TUẦN TỰ (Loop Skills State Machine):
                                    local loopKeys = {}
                                    for k in string.gmatch(Config.LoopSkills or "X, V", "([ZXCVzxcv])") do
                                        table.insert(loopKeys, k:upper())
                                    end

                                    if #loopKeys > 0 then
                                        if comboState.loopTargetIndex < 1 or comboState.loopTargetIndex > #loopKeys then
                                            comboState.loopTargetIndex = 1
                                        end

                                        -- Kiểm tra chiêu mục tiêu: Nếu Server đã nuốt và chiêu này đang Cooldown -> Dịch sang chiêu kế tiếp!
                                        local checkCount = 0
                                        while checkCount < #loopKeys and IsSkillOnCooldown(loopKeys[comboState.loopTargetIndex], fUI) do
                                            comboState.loopTargetIndex = (comboState.loopTargetIndex % #loopKeys) + 1
                                            checkCount = checkCount + 1
                                        end

                                        -- Bắn xung nhịp chiêu mục tiêu đang sẵn sàng
                                        local targetSkill = loopKeys[comboState.loopTargetIndex]
                                        if targetSkill then
                                            if not IsSkillOnCooldown(targetSkill, fUI) then
                                                CastSkill(targetSkill)
                                            elseif checkCount >= #loopKeys then
                                                -- Nếu tất cả các chiêu đều báo cooldown, vẫn bắn để tránh bị đứng im do giao diện game nhận nhầm số
                                                CastSkill(targetSkill)
                                                comboState.loopTargetIndex = (comboState.loopTargetIndex % #loopKeys) + 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        lastSkillTime = now
                    elseif Config.AutoSkills and (now - lastSkillTime >= 0.15) then
                        for _, sk in ipairs({"Z", "X", "C", "V"}) do
                            if Events:FindFirstChild("UseSkill") then Events.UseSkill:FireServer(sk) end
                            if Events:FindFirstChild("TriggerMinigameSkill") then Events.TriggerMinigameSkill:FireServer(sk) end
                        end
                        lastSkillTime = now
                    end
            end
            end -- Kết thúc check not skipTriggered
        elseif isFishing then
            secretBossState.minigameStartTime = 0
            lastCastTime = now
        else
            local isBossActive = secretBossState and secretBossState.active
            local isTicketActive = IsTicketQuestFishingActive()
            local shouldAutoCast = Config.AutoCast or Config.AutoTrainSkill or isTicketActive or ((Config.AutoHuntBoss or Config.AutoChatSecretBoss) and isBossActive)
            if shouldAutoCast and not isCD and not isSwimming and (char:GetAttribute("Type") == "Fishing Rod") and (now - lastCastTime >= Config.CastDelay) and not isTrainingBusy then
                local canCast = true
                if pData and pData:FindFirstChild("InventoryLimit") then
                    local invCount = 0
                    if pData:FindFirstChild("Inventory") then invCount = invCount + #pData.Inventory:GetChildren() end
                    if pData:FindFirstChild("Hotbar") then
                        for _, item in ipairs(pData.Hotbar:GetChildren()) do
                            if item:FindFirstChild("Quantity") then invCount = invCount + item.Quantity.Value else invCount = invCount + 1 end
                        end
                    end
                    if invCount >= pData.InventoryLimit.Value then
                        canCast = false
                        if Config.AutoSell and (now - lastSellTime >= 5.0) and Events:FindFirstChild("SellFish") then
                            ProtectAllInventoryItems(false)
                            Events.SellFish:FireServer("All")
                            lastSellTime = now
                        end
                    end
                end

                if Config.AutoSell and (now - lastSellTime >= Config.SellInterval) and Events:FindFirstChild("SellFish") then
                    ProtectAllInventoryItems(false)
                    Events.SellFish:FireServer("All")
                    lastSellTime = now
                end

                if (Config.MaterialFarming or Config.AutoFavouriteFish or Config.AutoProtectMutations) and (now - lastProtectTime >= 1.5) then
                    lastProtectTime = now
                    ProtectAllInventoryItems(false)
                end

                if canCast and Events and Events:FindFirstChild("Fishing") then
                    Events.Fishing:FireServer(root.CFrame)
                    lastCastTime = now
                end
            end
        end

        if (now - lastEquipTime >= 2.5) and pData then
            lastEquipTime = now
            if pData:FindFirstChild("Bait") and pData:FindFirstChild("EquippedBait") and Events:FindFirstChild("EquipBait") then
                local isHuntingBoss = (Config.AutoHuntBoss or Config.AutoChatSecretBoss) and secretBossState.active
                local isTicketFish100 = Config.AutoTicketQuest and ticketQuestState and ticketQuestState.active and not ticketQuestState.isCooldown and ticketQuestState.currentQuestType == "fish_100"
                local targetBaitChoice = nil

                if not isTicketFish100 then
                    if isHuntingBoss and Config.AutoEquipBossBait then
                        targetBaitChoice = Config.BaitChoiceBoss or "Mồi Tốt Nhất (Cao Nhất)"
                    elseif Config.AutoEquipBestBait then
                        targetBaitChoice = Config.BaitChoiceNormal or "Mồi Tốt Nhất (Cao Nhất)"
                    end
                end

                if targetBaitChoice then
                    local baitTiers = {
                        "Nameless Bait",
                        "Rainbow Bait",
                        "Frost Bait",
                        "Ancestral Bait",
                        "Elite Bait",
                        "Corrupted Essence Bait",
                        "Crude Mash Bait",
                        "Basic Bait"
                    }
                    local desiredBait = nil

                    if targetBaitChoice == "Mồi Tốt Nhất (Cao Nhất)" then
                        for _, bName in ipairs(baitTiers) do
                            local bVal = pData.Bait:FindFirstChild(bName)
                            if bVal and bVal.Value > 0 then
                                desiredBait = bName
                                break
                            end
                        end
                    elseif targetBaitChoice == "Mồi Thấp Nhất (Tiết Kiệm)" then
                        for i = #baitTiers, 1, -1 do
                            local bName = baitTiers[i]
                            local bVal = pData.Bait:FindFirstChild(bName)
                            if bVal and bVal.Value > 0 then
                                desiredBait = bName
                                break
                            end
                        end
                    else
                        local bVal = pData.Bait:FindFirstChild(targetBaitChoice)
                        if bVal and bVal.Value > 0 then
                            desiredBait = targetBaitChoice
                        else
                            for _, bName in ipairs(baitTiers) do
                                local bv = pData.Bait:FindFirstChild(bName)
                                if bv and bv.Value > 0 then
                                    desiredBait = bName
                                    break
                                end
                            end
                        end
                    end

                    if desiredBait and pData.EquippedBait.Value ~= desiredBait then
                        Events.EquipBait:InvokeServer(desiredBait)
                    end
                end
            end

            if Config.AutoEquipBestRod and pData:FindFirstChild("FishingRod") and Events:FindFirstChild("EquipFishingRod") then
                local bestRod = nil
                local bestPower = -1
                for _, r in ipairs(allRods) do
                    local isOwned = IsRodOwned(r.name)
                    if isOwned and r.power > bestPower then
                        bestPower = r.power
                        bestRod = r.name
                    end
                end
                if bestRod and pData.FishingRod.Value ~= bestRod then
                    Events.EquipFishingRod:InvokeServer(bestRod)
                    task.delay(0.5, function()
                        if Events and Events:FindFirstChild("ToggleHotbar") then
                            Events.ToggleHotbar:InvokeServer("1")
                        end
                    end)
                end
            end

            if Config.AutoEquipBestOrb and pData:FindFirstChild("Orb") and Events:FindFirstChild("EquipOrb") then
                local orbs = pData.Orb:GetChildren()
                if #orbs > 0 then
                    local bestOrb = orbs[#orbs].Name
                    Events.EquipOrb:InvokeServer(bestOrb)
                end
            end

            if pData:FindFirstChild("FishingRod") and pData.FishingRod.Value ~= "" then infoEquippedRod.Set(pData.FishingRod.Value) end
            if pData:FindFirstChild("EquippedBait") and pData.EquippedBait.Value ~= "" then infoEquippedBait.Set(pData.EquippedBait.Value) end

            -- Đồng bộ trạng thái danh sách cần câu trong Shop mỗi 3 giây
            if not lastRodShopSync or (tick() - lastRodShopSync >= 3) then
                lastRodShopSync = tick()
                if UpdateAllRodShopUI then
                    UpdateAllRodShopUI()
                end
            end

            -- Tự động nhận diện map/đảo hiện tại của người chơi mỗi 2 giây
            if not lastIslandCheck or (tick() - lastIslandCheck >= 2) then
                lastIslandCheck = tick()
                if UpdateAllIslandStatus then
                    pcall(UpdateAllIslandStatus)
                end
            end

            -- Tự động hook túi đồ để phát hiện cá thưởng Gems khi câu trúng
            if not gemTracker.inventoryHooked and pData then
                local inv = pData:FindFirstChild("Inventory")
                if inv then
                    gemTracker.inventoryHooked = true
                    table.insert(activeConnections, inv.ChildAdded:Connect(TrackCaughtFishForGems))
                end
                local hotbar = pData:FindFirstChild("Hotbar")
                if hotbar then
                    table.insert(activeConnections, hotbar.ChildAdded:Connect(TrackCaughtFishForGems))
                end
            end

            -- Đọc Gems từ game (pData / leaderstats / PlayerGui / v.v.)
            local liveGems = GetPlayerCurrentGems()
            if liveGems ~= nil then
                if gemTracker.lastKnown == nil then
                    gemTracker.lastKnown = liveGems
                elseif liveGems > gemTracker.lastKnown then
                    local delta = liveGems - gemTracker.lastKnown
                    gemTracker.lastKnown = liveGems
                    if not (tick() - gemTracker.lastFishAwardTime <= 2.5 and delta == gemTracker.lastFishAwardAmount) then
                        gemTracker.gained = gemTracker.gained + delta
                    end
                elseif liveGems < gemTracker.lastKnown then
                    gemTracker.lastKnown = liveGems
                end
            end

            local curFish = pData:FindFirstChild("FishCaught") and tonumber(pData.FishCaught.Value) or 0
            local curCash = pData:FindFirstChild("Cash") and tonumber(pData.Cash.Value) or 0

            if infoFishCaught and infoFishCaught.Set then
                infoFishCaught.Set(FormatWithSpaces(curFish) .. " con")
            end
            if infoCash and infoCash.Set then
                infoCash.Set("$" .. FormatWithSpaces(curCash))
            end

            if not initialFishCaught then initialFishCaught = curFish end
            if not initialCash then initialCash = curCash end

            local elapsedSec = math.max(1, tick() - sessionStartTime)
            local elapsedHours = elapsedSec / 3600

            local h = math.floor(elapsedSec / 3600)
            local m = math.floor((elapsedSec % 3600) / 60)
            local s = math.floor(elapsedSec % 60)
            if infoUptime and infoUptime.Set then
                infoUptime.Set(string.format("%02d:%02d:%02d", h, m, s))
            end

            local gainedFish = math.max(0, curFish - initialFishCaught)
            local gainedCash = math.max(0, curCash - initialCash)
            local gainedGems = gemTracker.gained

            local fishRate = math.floor(gainedFish / math.max(elapsedHours, 1/3600))
            local cashRate = math.floor(gainedCash / math.max(elapsedHours, 1/3600))

            if infoFishPerHour and infoFishPerHour.Set then
                infoFishPerHour.Set(FormatWithSpaces(fishRate) .. " con/h")
            end
            if infoCashPerHour and infoCashPerHour.Set then
                infoCashPerHour.Set("$" .. FormatWithSpaces(cashRate) .. " /h")
            end
            if infoGemsGained and infoGemsGained.Set then
                infoGemsGained.Set("+" .. FormatWithSpaces(gainedGems) .. " Gems")
            end

            if Config.WebhookEnabled and Config.WebhookHourlyStats and (tick() - lastWebhookStatsTime >= (Config.WebhookStatsInterval or 1800)) then
                lastWebhookStatsTime = tick()
                SendDiscordWebhook(
                    "📊 Báo Cáo Định Kỳ - Farm Tracker",
                    "Báo cáo tiến độ tự động câu cá của tài khoản **" .. LocalPlayer.Name .. "**",
                    3447003,
                    {
                        { name = "⏳ Thời Gian Treo", value = string.format("%02d:%02d:%02d", h, m, s), inline = true },
                        { name = "🐟 Tổng Cá Đã Bắt", value = FormatWithSpaces(curFish) .. " (+" .. FormatWithSpaces(gainedFish) .. ")", inline = true },
                        { name = "⚡ Tốc Độ Câu", value = FormatWithSpaces(fishRate) .. " con/giờ", inline = true },
                        { name = "💰 Tổng Tiền Hiện Tại", value = "$" .. FormatWithSpaces(curCash) .. " (+$" .. FormatWithSpaces(gainedCash) .. ")", inline = true },
                        { name = "📈 Tốc Độ Kiếm Tiền", value = "$" .. FormatWithSpaces(cashRate) .. " /giờ", inline = true },
                        { name = "💎 Gems Thu Được", value = "+" .. FormatWithSpaces(gainedGems) .. " Gems", inline = true }
                    }
                )
            end
        end

        if Config.AutoSell and (now - lastSellTime >= Config.SellInterval) then
            if Events and Events:FindFirstChild("SellFish") then
                Events.SellFish:FireServer("All")
                lastSellTime = now
            end
        end

        if Config.AutoPrayGodSpirit and (now - lastGodPrayTime >= 3.0) then
            if Workspace:FindFirstChild("NPC") then
                local sp = Workspace.NPC:FindFirstChild("Spirit") or Workspace.NPC:FindFirstChild("God")
                if sp then
                    for _, d in ipairs(sp:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            TriggerPrompt(d)
                            lastGodPrayTime = now
                        end
                    end
                end
            end
        end


        if Config.AutoClaimDaily and (now - lastCastTime >= 2.0) then
            if Events and Events:FindFirstChild("DailyReward") then
                for day = 1, 7 do Events.DailyReward:FireServer(day) end
            end
        end

        if Config.AutoGacha and (now - lastGachaTime >= 1.5) then
            if Events and Events:FindFirstChild("Gacha") then
                Events.Gacha:FireServer(Config.GachaBanner, Config.GachaPullsPerAction)
                lastGachaTime = now
            end
        end

        if Config.AutoCraftBait and (now - lastCastTime >= 2.0) then
            if Events and Events:FindFirstChild("CraftBait") then
                Events.CraftBait:FireServer(Config.CraftBaitName, Config.CraftAmount)
            end
        end

        if Config.AutoBuyBait and (now - lastBaitBuyTime >= Config.BuyBaitDelay) then
            if Events and Events:FindFirstChild("BuyBait") then
                Events.BuyBait:FireServer(Config.BuyBaitName, Config.BuyBaitAmount)
                lastBaitBuyTime = now
            end
        end

        if Config.OctoAutoMinigame then
            if Events and Events:FindFirstChild("RhythmHit") then
                Events.RhythmHit:FireServer(true, 100)
            end
        end
    end)
end))

local flyBV, flyBG = nil, nil
table.insert(activeConnections, RunService.RenderStepped:Connect(function()
    if not isRunning then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Config.FlyEnabled then
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Parent = root
            table.insert(cleanUpInstances, flyBV)

            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.Parent = root
            table.insert(cleanUpInstances, flyBG)
        end

        local camCF = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        flyBG.CFrame = camCF
        flyBV.Velocity = dir.Unit * Config.FlySpeed
        if dir.Magnitude == 0 then flyBV.Velocity = Vector3.zero end
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end
end))

table.insert(activeConnections, RunService.RenderStepped:Connect(function()
    if not isRunning then return end
    pcall(function()
        if Config.AnchorBar then
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing") and pg.MainGui.Fishing.Visible then
                local fUI = pg.MainGui.Fishing
                local barFrame = fUI:FindFirstChild("BarFrame")
                if barFrame and barFrame:FindFirstChild("Bar") then
                    barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                end
                local bossBar = fUI:FindFirstChild("BossFightBar")
                if bossBar and bossBar.Visible and bossBar:FindFirstChild("Bar") and bossBar:FindFirstChild("Hitbox") then
                    bossBar.Bar.Position = bossBar.Hitbox.Position
                end
                local hpPlayer = fUI:FindFirstChild("HPPlayer")
                if hpPlayer and hpPlayer:FindFirstChild("ProgressionBar") then
                    local pBar = hpPlayer.ProgressionBar
                    if pBar:FindFirstChild("Bar") then
                        pBar.Bar.Size = UDim2.new(1, 0, 1, 0)
                    end
                end
                if fUI:FindFirstChild("PerfectButton") and fUI.PerfectButton.Visible then
                    if Events and Events:FindFirstChild("Slam") then Events.Slam:FireServer("Perfect") end
                end
                if fUI:FindFirstChild("Charge") and fUI.Charge.Visible then
                    if Events and Events:FindFirstChild("Charge") then Events.Charge:FireServer(100) end
                end
                local cutscene = pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Cutscene")
                if cutscene and cutscene:FindFirstChild("Hurt") then
                    cutscene.Hurt.ImageTransparency = 1
                end
                local impactCutscene = pg:FindFirstChild("Impact") and pg.Impact:FindFirstChild("Cutscene")
                if impactCutscene and impactCutscene:FindFirstChild("Hurt") then
                    impactCutscene.Hurt.ImageTransparency = 1
                end
            end
        end
    end)
end))

if Events and Events:FindFirstChild("Slam") then
    table.insert(activeConnections, Events.Slam.OnClientEvent:Connect(function(slamEvent)
        if isRunning and Config.AnchorBar and typeof(slamEvent) == "Instance" then
            pcall(function() slamEvent:FireServer("Perfect") end)
        end
    end))
end

if Events and Events:FindFirstChild("Charge") then
    table.insert(activeConnections, Events.Charge.OnClientEvent:Connect(function(chargeEvent)
        if isRunning and Config.AnchorBar and typeof(chargeEvent) == "Instance" then
            pcall(function() chargeEvent:FireServer(100) end)
        end
    end))
end

-- LẮNG NGHE CHAT SERVER TỰ ĐỘNG SĂN SECRET BOSS
pcall(function()
    local TextChatService = game:GetService("TextChatService")
    if TextChatService and TextChatService:FindFirstChild("MessageReceived") then
        local conn = TextChatService.MessageReceived:Connect(function(textChatMessage)
            if not isRunning then return end
            if textChatMessage and textChatMessage.Text then
                secretBossState.HandleChatMessage(textChatMessage.Text)
            end
        end)
        table.insert(activeConnections, conn)
    end
end)

pcall(function()
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering") then
        local conn = chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
            if not isRunning then return end
            if data and data.Message then
                secretBossState.HandleChatMessage(tostring(data.Message))
            end
        end)
        table.insert(activeConnections, conn)
    end
end)

-- TỰ ĐỘNG QUÉT THỜI TIẾT & CHAT ĐỊNH KỲ (MỖI 2 GIÂY) ĐỂ SĂN BOSS
task.spawn(function()
    while isRunning do
        task.wait(2.0)
        if (Config.AutoChatSecretBoss or Config.AutoHuntBoss) and isRunning then
            pcall(function()
                -- 1. Ưu tiên quét Thời tiết thực tế trong Game (Workspace, ReplicatedStorage, UI)
                local wIsland, wName = secretBossState.DetectWeather()
                local isWeatherClear = (wIsland == nil) or (wName == "Clear")

                local targetBossInWeather = false
                if wIsland and not isWeatherClear then
                    for _, b in ipairs(wIsland.bosses) do
                        if Config.SecretBossTargets[b.name] then
                            targetBossInWeather = true
                            break
                        end
                    end
                end

                if wIsland and targetBossInWeather and not isWeatherClear then
                    -- Có Boss mục tiêu đang diễn ra theo thời tiết -> Bay qua đảo săn boss
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetPos = secretBossState.standPos or wIsland.pos
                    local dist = root and (root.Position - targetPos).Magnitude or 9999
                    if secretBossState.currentMap ~= wIsland.islandName or dist > 150 then
                        secretBossState.Teleport(wIsland, wName)
                    end
                else
                    -- Không có thời tiết boss mục tiêu (Thời tiết Clear, hoặc thời tiết đảo đó không chọn săn)
                    -- 2. Kiểm tra xem có Boss Chat nào còn trong thời gian hiệu lực không (tối đa 300 giây)
                    local chatSpawn = nil
                    if secretBossState.activeChatBoss then
                        if (tick() - (secretBossState.activeChatBoss.time or 0)) < 300 then
                            local isTarget = false
                            if secretBossState.activeChatBoss.island then
                                for _, b in ipairs(secretBossState.activeChatBoss.island.bosses) do
                                    if Config.SecretBossTargets[b.name] then
                                        isTarget = true
                                        break
                                    end
                                end
                            end
                            if isTarget then
                                chatSpawn = secretBossState.activeChatBoss
                            else
                                secretBossState.activeChatBoss = nil
                            end
                        else
                            secretBossState.activeChatBoss = nil
                        end
                    end

                    if chatSpawn and chatSpawn.island then
                        -- Có boss xuất hiện theo thông báo chat còn hiệu lực
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetPos = secretBossState.standPos or chatSpawn.island.pos
                        local dist = root and (root.Position - targetPos).Magnitude or 9999
                        if secretBossState.currentMap ~= chatSpawn.island.islandName or dist > 150 then
                            secretBossState.Teleport(chatSpawn.island, chatSpawn.bossName)
                        end
                    else
                        -- Hoàn toàn KHÔNG CÓ BOSS MỤC TIÊU NÀO ĐANG HOẠT ĐỘNG (Thời tiết Clear / Hết Boss)
                        if secretBossState.active then
                            secretBossState.active = false
                            secretBossState.currentMap = nil
                            secretBossState.targetIsland = nil
                            secretBossState.standPos = nil
                            if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                                statusLabelSecretBoss.Set("Thời tiết Clear / Hết Boss. Đang ở vị trí Farm...")
                            end
                        end

                        -- Nếu có bật tự động về Home Farm Spot
                        if Config.ReturnToHomeWhenClear and Config.HomeFarmSpot then
                            secretBossState.ReturnToHome()
                        end
                    end
                end
            end)
        end
    end
end)


table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and isRunning then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- ===============================================================
-- 🛡️ HỆ THỐNG CHỐNG VĂNG GAME ĐA TẦNG (ANTI-AFK & AUTO-REJOIN)
-- ===============================================================

-- Tầng 1: Vô hiệu hóa bộ đếm Idled 20 phút mặc định của Roblox bằng getconnections
pcall(function()
    if getconnections then
        for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
            if conn.Disable then
                conn:Disable()
            elseif conn.Disconnect then
                conn:Disconnect()
            end
        end
    end
end)

-- Tầng 2: Bắt sự kiện Idled dự phòng và giả lập thao tác chuột ảo
pcall(function()
    table.insert(activeConnections, LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK and isRunning then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new(0, 0))
                    vu:Button2Down(Vector2.new(0, 0))
                    task.wait(0.05)
                    vu:Button2Up(Vector2.new(0, 0))
                end
            end)
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                if vim then
                    vim:SendMouseButtonEvent(15, 15, 0, true, game, 1)
                    task.wait(0.02)
                    vim:SendMouseButtonEvent(15, 15, 0, false, game, 1)
                end
            end)
        end
    end))
end)

-- Tầng 3: Nhịp tim chủ động (Active Keep-Alive Pulse) cứ mỗi 5 phút gửi micro-action để reset thời gian idle của Roblox
task.spawn(function()
    while isRunning do
        task.wait(300)
        if isRunning and Config.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                if vu then
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new(50, 50))
                end
            end)
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                if vim then
                    vim:SendMouseButtonEvent(20, 20, 0, true, game, 1)
                    task.wait(0.02)
                    vim:SendMouseButtonEvent(20, 20, 0, false, game, 1)
                end
            end)
        end
    end
end)

-- TỰ ĐỘNG ĐỔI SERVER TÌM TAOIST / GOD SPIRIT / MAOSHAN
task.spawn(function()
    task.wait(6)
    local lastHopAttempt = 0
    while isRunning do
        task.wait(3.0)
        if isRunning and (Config.AutoServerHopTaoist or Config.AutoServerHopGod or Config.AutoServerHopMaoshan) then
            pcall(function()
                local now = tick()
                if (now - lastHopAttempt) < 12 then return end

                local shouldHop = false
                local hopReason = ""

                if Config.AutoServerHopTaoist then
                    local tInst, tName = secretBossState.ScanForTaoistNPC()
                    if tInst then
                        ShowNotification("Đạo Sĩ (Taoist)", "Đã tìm thấy " .. tostring(tName) .. " trong server này! Đang dừng đổi server.", "SUCCESS", 6)
                    else
                        shouldHop = true
                        hopReason = "Không tìm thấy Đạo Sĩ (Taoist) trong server này. Đang đổi server khác..."
                    end
                elseif Config.AutoServerHopMaoshan then
                    local tInst, tName, tCat = secretBossState.ScanForTaoistNPC()
                    if tInst and tCat == "Maoshan" then
                        ShowNotification("Đạo Sĩ Maoshan", "Đã tìm thấy " .. tostring(tName) .. " trong server này! Đang dừng đổi server.", "SUCCESS", 6)
                    else
                        shouldHop = true
                        hopReason = "Không tìm thấy Đạo Sĩ Maoshan trong server này. Đang đổi server khác..."
                    end
                elseif Config.AutoServerHopGod then
                    local sp = secretBossState.ScanForGodSpirit()
                    if sp then
                        ShowNotification("Thần Linh", "Đã tìm thấy God Spirit trong server này! Đang dừng đổi server.", "SUCCESS", 6)
                    else
                        shouldHop = true
                        hopReason = "Không tìm thấy Thần Linh trong server này. Đang đổi server khác..."
                    end
                end

                if shouldHop then
                    lastHopAttempt = now
                    ShowNotification("Đổi Server Tìm NPC", hopReason, "WARN", 4)
                    task.wait(1.5)
                    if secretBossState.ServerHop then
                        secretBossState.ServerHop()
                    end
                end
            end)
        end
    end
end)

do
    local espFolder = Instance.new("Folder")
    espFolder.Name = "IdenticalESP"
    espFolder.Parent = Workspace
    table.insert(cleanUpInstances, espFolder)

local activeESP = {}

local fishRingAnchor = Instance.new("Part")
fishRingAnchor.Name = "FishRingAnchor"
fishRingAnchor.Size = Vector3.new(0.5, 0.5, 0.5)
fishRingAnchor.Transparency = 1
fishRingAnchor.CanCollide = false
fishRingAnchor.Anchored = true
fishRingAnchor.Parent = Workspace
table.insert(cleanUpInstances, fishRingAnchor)

local fishRingAdornment = Instance.new("CylinderHandleAdornment")
fishRingAdornment.Name = "FishRingAdornment"
fishRingAdornment.Adornee = fishRingAnchor
fishRingAdornment.AlwaysOnTop = true
fishRingAdornment.ZIndex = 5
fishRingAdornment.Radius = 6
fishRingAdornment.InnerRadius = 5.2
fishRingAdornment.Height = 0.2
fishRingAdornment.Color3 = Color3.fromRGB(255, 45, 45)
fishRingAdornment.Transparency = 0.2
fishRingAdornment.CFrame = CFrame.Angles(math.rad(90), 0, 0)
fishRingAdornment.Visible = false
fishRingAdornment.Parent = fishRingAnchor

local fishRingBillboard = Instance.new("BillboardGui")
fishRingBillboard.Name = "FishRingBillboard"
fishRingBillboard.Size = UDim2.new(0, 220, 0, 30)
fishRingBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
fishRingBillboard.AlwaysOnTop = true
fishRingBillboard.Adornee = fishRingAnchor
fishRingBillboard.Parent = fishRingAnchor

local fishRingText = Instance.new("TextLabel", fishRingBillboard)
fishRingText.Size = UDim2.new(1, 0, 1, 0)
fishRingText.BackgroundTransparency = 1
fishRingText.TextColor3 = Color3.fromRGB(255, 230, 90)
fishRingText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
fishRingText.TextStrokeTransparency = 0.2
fishRingText.Font = Enum.Font.GothamBold
fishRingText.TextSize = 13
fishRingText.Text = ""
fishRingText.Visible = false

local function AddESP(instance, name, espCategory, color, icon)
    if not instance or activeESP[instance] then return end
    local isEnabled = Config["ESP_" .. espCategory]
    if not isEnabled then return end

    local part = instance:IsA("BasePart") and instance or (instance.PrimaryPart or instance:FindFirstChild("HumanoidRootPart") or instance:FindFirstChild("Head") or instance:FindFirstChildWhichIsA("BasePart", true))
    if not part then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_" .. name
    bb.Size = UDim2.new(0, 150, 0, 24)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = part
    bb.Enabled = true
    bb.Parent = espFolder

    local f = Instance.new("Frame", bb)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundColor3 = Colors.Background
    f.BackgroundTransparency = 0.2
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Color = color or Colors.PurpleAccent
    s.Thickness = 1

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = (icon or "") .. " " .. name
    lbl.TextColor3 = color or Colors.TextWhite
    lbl.TextSize = 10

    activeESP[instance] = {gui = bb, label = lbl, part = part, espCategory = espCategory, name = name, icon = icon or ""}
end

local function RemoveESP(instance)
    local data = activeESP[instance]
    if data then
        if data.gui and data.gui.Parent then data.gui:Destroy() end
        activeESP[instance] = nil
    end
end

table.insert(activeConnections, RunService.RenderStepped:Connect(function()
    if not isRunning then return end

    if Config.Fullbright then
        Lighting.Brightness = 2.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    end
    if Config.NoFog then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 1000000
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo and (atmo.Density > 0 or atmo.Haze > 0) then
            atmo.Density = 0
            atmo.Haze = 0
            atmo.Glare = 0
        end
        for _, d in ipairs(Camera:GetDescendants()) do
            if d:IsA("ParticleEmitter") and d.Enabled then
                d.Enabled = false
            end
        end
    end

    if Config.ESP_Players then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    AddESP(p.Character, p.DisplayName, "Players", Colors.PurpleAccent, "👤")
                end
            end
        end
    end

    if Config.ESP_SecretRod and Workspace:FindFirstChild("SecretRod") then
        for _, r in ipairs(Workspace.SecretRod:GetChildren()) do
            AddESP(r, r.Name, "SecretRod", Colors.AccentYellow, "🌟")
        end
    end

    if Config.ESP_GodSpirit then
        local sp = secretBossState.GetGodSpirit()
        if sp then
            AddESP(sp, "God Spirit", "GodSpirit", Colors.AccentGreen, "⛩️")
        end
    end

    if Config.ESP_Boats and Workspace:FindFirstChild("Boat") then
        for _, b in ipairs(Workspace.Boat:GetChildren()) do
            AddESP(b, b.Name, "Boats", Colors.AccentBlue, "⛵")
        end
    end

    if Config.ESP_Boss and Workspace:FindFirstChild("BossSetUp") then
        for _, b in ipairs(Workspace.BossSetUp:GetChildren()) do
            AddESP(b, b.Name, "Boss", Colors.AccentRed, "👹")
        end
    end

    if Config.ESP_Taoist or Config.ESP_Maoshan then
        local tInst, tName, tCat, tCol, tIcon = secretBossState.GetTaoist()
        if tInst then
            AddESP(tInst, tName, tCat or "Taoist", tCol or Colors.AccentOrange, tIcon or "📜")
        end
    end

    local camPos = Camera.CFrame.Position
    for inst, data in pairs(activeESP) do
        local isEnabled = Config["ESP_" .. data.espCategory]
        if not inst.Parent or not data.part.Parent or not isEnabled then
            RemoveESP(inst)
        else
            data.gui.Enabled = true
            local dist = math.floor((camPos - data.part.Position).Magnitude)
            data.label.Text = data.icon .. " " .. data.name .. " [" .. dist .. "m]"
        end
    end

    if Config.HideOverheadNames then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
                    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
                for _, d in ipairs(p.Character:GetDescendants()) do
                    if d:IsA("BillboardGui") and d.Name:sub(1, 4) ~= "ESP_" then
                        if d.Enabled then d.Enabled = false end
                    end
                end
            end
        end
    end

    if Config.FishRedRing then
        local fishPos = nil
        local char = LocalPlayer.Character
        local fishID = LocalPlayer:GetAttribute("FishID")
        
        if fishID and Workspace:FindFirstChild("Fishes") then
            local f = Workspace.Fishes:FindFirstChild(fishID)
            if f then
                if f:FindFirstChild("Model") and f.Model:IsA("Model") then
                    fishPos = f.Model:GetPivot().Position
                elseif f:FindFirstChild("Buoy") and f.Buoy:IsA("BasePart") then
                    fishPos = f.Buoy.Position
                end
            end
        end
        
        if not fishPos and Workspace:FindFirstChild("Fishes") then
            local uid = tostring(LocalPlayer.UserId)
            for _, f in ipairs(Workspace.Fishes:GetChildren()) do
                if f:FindFirstChild(uid .. "_PlayerHealth") then
                    if f:FindFirstChild("Model") and f.Model:IsA("Model") then
                        fishPos = f.Model:GetPivot().Position
                    elseif f:FindFirstChild("Buoy") and f.Buoy:IsA("BasePart") then
                        fishPos = f.Buoy.Position
                    end
                    break
                end
            end
        end

        if not fishPos and char then
            local buoy = char:FindFirstChild("Buoy")
            if buoy and buoy:IsA("BasePart") then
                fishPos = buoy.Position
            else
                for _, d in ipairs(char:GetDescendants()) do
                    if d:IsA("Beam") and d.Attachment1 and d.Attachment0 then
                        local p0 = d.Attachment0.Parent
                        local p1 = d.Attachment1.Parent
                        if (p1 and p1.Name == "Buoy") or (p0 and p0.Name == "Buoy") then
                            local buoyAtt = (p1 and p1.Name == "Buoy") and d.Attachment1 or d.Attachment0
                            fishPos = buoyAtt.WorldPosition
                            break
                        end
                    end
                end
            end
        end

        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local isHooked = char and (char:GetAttribute("Fishing") == true or char:GetAttribute("Minigame") == true)
        local fUI = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
        if (isHooked or (fUI and fUI.Visible)) and fishPos then
            fishRingAnchor.Position = fishPos
            fishRingAdornment.Visible = true

            if Config.ShowFishWeightRing then
                local fName = GetCurrentHookedFishName()
                local fWeight = char:GetAttribute("FishWeight") or char:GetAttribute("Weight")
                local fMutation = char:GetAttribute("FishMutation") or char:GetAttribute("Mutation")

                if not fWeight and fUI then
                    local wLabel = fUI:FindFirstChild("Weight", true) or fUI:FindFirstChild("FishWeight", true)
                    if wLabel and wLabel:IsA("TextLabel") and wLabel.Text ~= "" then
                        fWeight = wLabel.Text
                    end
                end

                local displayStr = ""
                if fName then displayStr = tostring(fName) end
                if fMutation and tostring(fMutation) ~= "" then
                    displayStr = displayStr .. " [" .. tostring(fMutation) .. "]"
                end
                if fWeight then
                    local wStr = tostring(fWeight)
                    if tonumber(wStr) then wStr = string.format("%.1f kg", tonumber(wStr)) end
                    displayStr = displayStr .. " (" .. wStr .. ")"
                end

                if displayStr ~= "" then
                    fishRingText.Text = displayStr
                    fishRingText.Visible = true
                else
                    fishRingText.Text = "🎣 Đang Cắn Câu"
                    fishRingText.Visible = true
                end
            else
                fishRingText.Visible = false
            end
        else
            fishRingAdornment.Visible = false
            fishRingText.Visible = false
        end
    else
        if fishRingAdornment.Visible then fishRingAdornment.Visible = false end
        if fishRingText.Visible then fishRingText.Visible = false end
    end
end))
end

table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Config.UIKeybind then
        if ToggleUiVisibility then ToggleUiVisibility() end
    elseif input.KeyCode == Enum.KeyCode.End or input.KeyCode == Config.StopKeybind then
        UnloadScript()
    end
end))

ShowNotification("VIỆT HOÁ V1.4", "Heavyweight Fishing đã cập nhật: Totem Thời Tiết, Discord Webhook, Farm Tracker, Khóa Đột Biến & Khiên Nước Axit!", "SUCCESS", 6)