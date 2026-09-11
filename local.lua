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
        local esp = ws:FindFirstChild("IdenticalESP")
        if esp then esp:Destroy() end
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
    AntiStuckEnabled = true,
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
    Train_Z = false,
    Train_X = false,
    Train_C = true,
    Train_V = true,
    TrainTargetCount = 100,
    TrainCurrentCount = 0,
    TrainSkillCooldown = 6.0,
    TrainDelayCatch = true,
    
    AutoEquipBestBait = false,
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
    
    -- TỰ ĐỘNG SĂN SECRET BOSS THEO CHAT
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
    
    AutoGodSpiritCheck = false,
    AutoPrayGodSpirit = false,
    AutoServerHopGod = false,
    AutoServerHopMaoshan = false,
    AutoServerHopTaoist = false,
    
    AutoTicketQuest = false,
    TicketDifficulty = "Easy",
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
    
    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    InfiniteJump = false,
    WalkOnWater = false,
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
    Fullbright = false,
    PerformanceMode = false,
    HideGameUI = false,
    
    AntiAFK = true,
    AutoRejoin = false,
    AutoExecuteOnJoin = false,
    UIKeybind = Enum.KeyCode.RightControl,
    StopKeybind = Enum.KeyCode.End,
    ActiveProfile = "default",
    AutoLoadProfile = true
}

local PROFILE_DIR = "Identical/HeavyweightFishing"

local function EnsureProfileDir()
    if makefolder then
        pcall(function()
            if not isfolder("Identical") then makefolder("Identical") end
            if not isfolder(PROFILE_DIR) then makefolder(PROFILE_DIR) end
        end)
    end
end

local function SaveProfile(name)
    EnsureProfileDir()
    local path = PROFILE_DIR .. "/" .. (name or Config.ActiveProfile) .. ".json"
    local data = {}
    for k, v in pairs(Config) do
        if typeof(v) == "EnumItem" then
            data[k] = {__enum = tostring(v)}
        else
            data[k] = v
        end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and writefile then
        pcall(function() writefile(path, encoded) end)
        return true
    end
    return false
end

local function LoadProfile(name)
    local path = PROFILE_DIR .. "/" .. (name or Config.ActiveProfile) .. ".json"
    if readfile then
        local ok, content = pcall(function() return readfile(path) end)
        if ok and content and #content > 0 then
            local decOk, decoded = pcall(function() return HttpService:JSONDecode(content) end)
            if decOk and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if type(v) == "table" and v.__enum then
                        local enumType, enumName = v.__enum:match("Enum%.(%w+)%.(%w+)")
                        if enumType and enumName and Enum[enumType] and Enum[enumType][enumName] then
                            Config[k] = Enum[enumType][enumName]
                        end
                    elseif Config[k] ~= nil then
                        Config[k] = v
                    end
                end
                return true
            end
        end
    end
    return false
end

if Config.AutoLoadProfile then pcall(LoadProfile, "default") end

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
brandTitle.Size = UDim2.new(0, 150, 1, 0); brandTitle.Position = UDim2.new(0, 36, 0, 0)
brandTitle.BackgroundTransparency = 1; brandTitle.Font = Enum.Font.GothamBold
brandTitle.Text = "CÂU CÁ PRO"; brandTitle.TextColor3 = Colors.PurplePrimary
brandTitle.TextSize = 14; brandTitle.TextXAlignment = Enum.TextXAlignment.Left
brandTitle.Parent = titleBar

local gameSubtitle = Instance.new("TextLabel")
gameSubtitle.Size = UDim2.new(0, 200, 1, 0); gameSubtitle.Position = UDim2.new(0, 118, 0, 0)
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
    return {frame = row, Set = function(val) state = val; updateVisuals() end, Get = function() return state end}
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
    return {
        frame = row,
        Set = function(val)
            currentVal = math.clamp(val, minVal, maxVal)
            local p2 = (currentVal - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(p2, 0, 1, 0)
            valLabel.Text = isFloat and string.format("%.2f", currentVal)..suffix or tostring(math.floor(currentVal))..suffix
        end
    }
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
    return {
        frame = row,
        Set = function(opt)
            selected = opt; ddBtn.Text = tostring(opt) .. "  v"
            for oN, b in pairs(optButtons) do b.BackgroundColor3 = (oN == opt) and Colors.DropdownSelected or Colors.InputBg; b.TextColor3 = (oN == opt) and Colors.PurplePrimary or Colors.TextWhite; b.Text = (oN == opt and "> " or "   ") .. tostring(oN) end
        end,
        Get = function() return selected end
    }
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

local secretBossDatabase = {
    {
        islandName = "Đảo Tre (Bamboo Isle)",
        weather = "Thunderstorm (Bão Sấm)",
        patterns = {"bamboo", "tre", "thunderstorm"},
        pos = Vector3.new(-1223.0, 7.3, -24.1),
        bosses = {
            {name = "Scarlet Fish", reward = "+3 Gems"},
            {name = "Elder Scarlet Fish", reward = "+5 Gems"},
            {name = "Crimson Electric Eel", reward = "+5 Gems"},
        }
    },
    {
        islandName = "Đảo Phóng Xạ (Fallout Isle)",
        weather = "Rainy (Trời Mưa)",
        patterns = {"fallout", "phóng xạ", "rainy"},
        pos = Vector3.new(65.5, 8.8, 1181.3),
        bosses = {
            {name = "Verdant Alligator Gar", reward = "+3 Gems | Skill 25%"},
            {name = "Verdant Grouper", reward = "+3 Gems | Skill 25%"},
            {name = "Verdant Bonefang", reward = "+5 Gems | Skill 5%"},
        }
    },
    {
        islandName = "Đảo Cá Chép (Perch Isle)",
        weather = "Windy (Trời Gió)",
        patterns = {"perch", "cá chép", "windy"},
        pos = Vector3.new(-62.0, 11.9, -1321.4),
        bosses = {
            {name = "Flying Fish Empress", reward = "+10 Gems | Skill 10%"},
            {name = "Flying Fish Emperor", reward = "+10 Gems | Skill 10%"},
        }
    },
    {
        islandName = "Đảo Băng Giá (Frost Isle)",
        weather = "Snowy (Bão Tuyết)",
        patterns = {"frost", "băng", "snowy"},
        pos = Vector3.new(-1366.0, 11.9, -1495.4),
        bosses = {
            {name = "Reborn Puffer Beast", reward = "+10 Gems"},
            {name = "Frost Kingfish", reward = "+10 Gems | Skill Drop"},
        }
    },
    {
        islandName = "Đảo Quả Dừa (Coconut Isle)",
        weather = "Foggy (Sương Mù)",
        patterns = {"coconut", "dừa", "foggy"},
        pos = Vector3.new(1493.6, 9.1, -1430.6),
        bosses = {
            {name = "Tigerfang Whale", reward = "+5 Gems | Skill Drop"},
            {name = "Heaven Piercer Turtle", reward = "+5 Gems"},
        }
    },
    {
        islandName = "Đảo Hổ Phách (Amber Isle)",
        weather = "Blazing Sun (Nắng Gắt)",
        patterns = {"amber", "hổ phách", "blazing sun", "blazing"},
        pos = Vector3.new(1259.4, 9.1, 1401.5),
        bosses = {
            {name = "Draconic Koi", reward = "+5 Gems"},
            {name = "Sanguine Fish", reward = "+20 Gems | Skill 10%"},
        }
    },
    {
        islandName = "Đảo Chiến Trường (Battlefield)",
        weather = "Boss Realm",
        patterns = {"battlefield", "chiến trường"},
        pos = Vector3.new(1393.5, 11.3, 169.6),
        bosses = {
            {name = "Primordial Kunfish Overlord", reward = "+30 Gems"},
            {name = "Warbringer Shark", reward = "+25 Gems"},
        }
    },
    {
        islandName = "Đảo Đỉnh Sương Mù (Mistpeak)",
        weather = "Mountain Peak",
        patterns = {"mistpeak", "sương mù"},
        pos = Vector3.new(2660.2, 8.8, -86.7),
        bosses = {
            {name = "Mountain Fish", reward = "+20 Gems | Skill 5%"},
        }
    },
    {
        islandName = "Vùng Biển Sâu (Secret Ocean)",
        weather = "Special Event",
        patterns = {"octo", "bạch tuộc", "octoparasite", "buoy"},
        pos = Vector3.new(1608.2, 5.0, -218.3),
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

    -- 1. Check Character attributes
    for _, attName in ipairs({"FishName", "TargetFish", "Boss", "Fish", "CurrentFish", "HookedFish"}) do
        local val = char:GetAttribute(attName)
        if val and tostring(val) ~= "" then
            local valLower = tostring(val):lower()
            if secretBossLookup[valLower] then return secretBossLookup[valLower] end
            return tostring(val)
        end
    end

    -- 2. Check PlayerGui.MainGui.Fishing
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local fUI = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
    if fUI and fUI.Visible then
        for _, lblName in ipairs({"FishName", "Title", "Name", "Fish", "BossName", "Target"}) do
            local label = fUI:FindFirstChild(lblName, true)
            if label and label:IsA("TextLabel") and label.Text ~= "" then
                local txt = label.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if secretBossLookup[txt:lower()] then return secretBossLookup[txt:lower()] end
                return txt
            end
        end

        local bossBar = fUI:FindFirstChild("BossFightBar")
        if bossBar and bossBar.Visible then
            for _, d in ipairs(bossBar:GetDescendants()) do
                if d:IsA("TextLabel") and d.Visible and d.Text ~= "" and not tonumber(d.Text) and not d.Text:find("%%") then
                    local txt = d.Text:gsub("^%s+", ""):gsub("%s+$", "")
                    if secretBossLookup[txt:lower()] then return secretBossLookup[txt:lower()] end
                    if #txt > 3 then return txt end
                end
            end
        end

        -- Scan any visible TextLabel in fUI matching a known secret boss
        for _, d in ipairs(fUI:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" and not tonumber(d.Text) and not d.Text:find("%%") then
                local txt = d.Text:gsub("^%s+", ""):gsub("%s+$", "")
                if secretBossLookup[txt:lower()] then return secretBossLookup[txt:lower()] end
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

local function CancelAndRecastRod()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:UnequipTools()
    end
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

local function HandleIncomingChatMessage(msg)
    if not Config.AutoChatSecretBoss then return end
    if typeof(msg) ~= "string" or #msg == 0 then return end
    local lower = msg:lower()

    -- 1. Check for Despawn Announcement: "all secret bosses have been despawned"
    if (lower:find("all secret bosses") and (lower:find("despawn") or lower:find("gone") or lower:find("disappear")))
       or lower:find("secret bosses have been despawned")
       or lower:find("secret bosses have despawned") then
        secretBossState.active = false
        secretBossState.currentMap = nil
        secretBossState.targetIsland = nil
        secretBossState.statusText = "Tất cả Secret Boss đã despawn. Chờ đợt mới..."
        ShowNotification("Secret Boss Despawn", "Tất cả Secret Boss đã biến mất! Hệ thống đang chờ đợt xuất hiện tiếp theo.", "WARN", 7)
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set("Tất cả Secret Boss đã despawn. Chờ đợt mới...")
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

    -- 2. Check for Spawn Announcement: Contains secret / boss / map name
    if lower:find("secret") or lower:find("boss") or lower:find("spawned") or lower:find("appeared") then
        local matchedIsland = nil
        for _, entry in ipairs(secretBossDatabase) do
            for _, pat in ipairs(entry.patterns) do
                if lower:find(pat) then
                    matchedIsland = entry
                    break
                end
            end
            if matchedIsland then break end
        end

        if matchedIsland then
            -- Check if user selected any boss from this island
            local hasTargetInIsland = false
            for _, b in ipairs(matchedIsland.bosses) do
                if Config.SecretBossTargets[b.name] then
                    hasTargetInIsland = true
                    break
                end
            end

            if not hasTargetInIsland then
                ShowNotification("Bỏ Qua Boss", string.format("Boss xuất hiện tại %s nhưng bạn không chọn săn boss ở đảo này.", matchedIsland.islandName), "INFO", 4)
                return
            end

            -- Parse required power
            local reqPower = 0
            local powMatch = lower:match("power%s*[:=]?%s*(%d+)") or lower:match("(%d+)%s*power")
            if powMatch then
                reqPower = tonumber(powMatch) or 0
            end

            local curPower = GetPlayerRodPower()
            if Config.SecretBossCheckPower and reqPower > 0 and curPower < reqPower then
                ShowNotification("CẢNH BÁO LỰC CẦN", string.format("Boss yêu cầu %d Power! Cần của bạn chỉ có %d Power.", reqPower, curPower), "WARN", 8)
            end

            -- Set state
            secretBossState.active = true
            secretBossState.currentMap = matchedIsland.islandName
            secretBossState.targetIsland = matchedIsland
            secretBossState.requiredPower = reqPower
            secretBossState.statusText = string.format("Đang săn tại %s (Y/c Power: %d)", matchedIsland.islandName, reqPower)
            
            ShowNotification("PHÁT HIỆN SECRET BOSS!", string.format("Boss xuất hiện tại %s (Y/c: %d Power)! Đang bay đến câu...", matchedIsland.islandName, reqPower), "SUCCESS", 7)
            
            if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                statusLabelSecretBoss.Set(secretBossState.statusText)
            end

            -- Teleport to island fishing area
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and matchedIsland.pos then
                root.CFrame = CFrame.new(matchedIsland.pos + Vector3.new(0, 3, 0))
            end
        end
    end
end

local function ScanExistingChatHistory()
    local foundMessages = {}
    local pg = LocalPlayer:FindFirstChild("PlayerGui")

    -- 1. Quét giao diện Chat hiện đại (TextChatService / ExperienceChat)
    if pg and pg:FindFirstChild("ExperienceChat") then
        for _, d in ipairs(pg.ExperienceChat:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text ~= "" and #d.Text > 5 then
                table.insert(foundMessages, d.Text)
            end
        end
    end

    -- 2. Quét giao diện Chat cổ điển (Legacy Chat)
    if pg and pg:FindFirstChild("Chat") then
        for _, d in ipairs(pg.Chat:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text ~= "" and #d.Text > 5 then
                table.insert(foundMessages, d.Text)
            end
        end
    end

    -- 3. Quét các thông báo Banner / Pop-up trên màn hình
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "IdenticalHeavyweightFishing" and gui.Name ~= "ExperienceChat" and gui.Name ~= "Chat" then
                for _, d in ipairs(gui:GetDescendants()) do
                    if d:IsA("TextLabel") and d.Visible and d.Text ~= "" and #d.Text > 5 then
                        local lower = d.Text:lower()
                        if lower:find("secret") or lower:find("boss") or lower:find("spawn") or lower:find("despawn") then
                            table.insert(foundMessages, d.Text)
                        end
                    end
                end
            end
        end
    end

    -- 4. Quét thực tế trong Workspace (BossSetUp)
    if Workspace:FindFirstChild("BossSetUp") then
        for _, b in ipairs(Workspace.BossSetUp:GetChildren()) do
            local bLower = b.Name:lower()
            for _, entry in ipairs(secretBossDatabase) do
                for _, boss in ipairs(entry.bosses) do
                    if bLower:find(boss.name:lower()) or boss.name:lower():find(bLower) then
                        table.insert(foundMessages, string.format("Secret boss %s spawned at %s", boss.name, entry.islandName))
                    end
                end
            end
        end
    end

    -- Phân tích thứ tự thời gian tin nhắn
    local latestSpawn = nil
    local latestDespawnIndex = -1
    local latestSpawnIndex = -1

    for idx, msg in ipairs(foundMessages) do
        local lower = msg:lower()
        if (lower:find("all secret bosses") and (lower:find("despawn") or lower:find("gone") or lower:find("disappear")))
           or lower:find("secret bosses have been despawned")
           or lower:find("secret bosses have despawned") then
            latestDespawnIndex = idx
        elseif lower:find("secret") or lower:find("boss") or lower:find("spawned") or lower:find("appeared") then
            for _, entry in ipairs(secretBossDatabase) do
                for _, pat in ipairs(entry.patterns) do
                    if lower:find(pat) then
                        latestSpawn = {msg = msg, island = entry, index = idx}
                        latestSpawnIndex = idx
                        break
                    end
                end
                if latestSpawn and latestSpawn.index == idx then break end
            end
        end
    end

    -- Nếu có tin nhắn Boss xuất hiện và CHƯA BỊ tin nhắn Despawn đè lên
    if latestSpawn and (latestDespawnIndex < latestSpawnIndex) then
        ShowNotification("Phát Hiện Boss Đang Hoạt Động", "Tìm thấy thông báo Boss trong lịch sử chat! Đang tiến hành bay đến săn...", "SUCCESS", 6)
        HandleIncomingChatMessage(latestSpawn.msg)
        return true
    elseif latestDespawnIndex > latestSpawnIndex and latestDespawnIndex ~= -1 then
        secretBossState.statusText = "Boss gần nhất đã despawn. Đang chờ đợt mới..."
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set(secretBossState.statusText)
        end
    end
    return false
end


local tabFishing   = CreateTab("Câu Cá")
local tabBoss      = CreateTab("Săn Boss")
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

createCategoryHeader(tabFishing, "Tự Động Câu Cá Cốt Lõi")
local fishCard = createCardGroup(tabFishing)

createToggleRow(fishCard, "Tự Động Quăng Cần (Auto Cast)", "Tự động bắt đầu câu và quăng cần liên tục", Config.AutoCast, function(v) Config.AutoCast = v end)
createSliderRow(fishCard, "Độ Trễ Quăng Cần", "Thời gian giãn cách giữa các lần quăng", 0.5, 5.0, Config.CastDelay, true, "s", function(v) Config.CastDelay = v end)
createToggleRow(fishCard, "Giữ Thanh Minigame (Anchor Bar)", "Tự động giữ thanh kéo ở giữa để bắt cá 100%", Config.AnchorBar, function(v) Config.AnchorBar = v end)
createToggleRow(fishCard, "Tự Dùng Kỹ Năng Cần", "Tự kích hoạt kỹ năng cần câu để kéo cá siêu nhanh", Config.AutoSkills, function(v) Config.AutoSkills = v end)
createToggleRow(fishCard, "Tự Động Đập Cần (Auto Slam)", "Tự động nhấn Slam mức Perfect khi xuất hiện", Config.AutoSlam, function(v) Config.AutoSlam = v end)
createToggleRow(fishCard, "Tự Động Sạc Dây (Auto Charge)", "Tự động sạc đầy 100% độ bền dây câu", Config.AutoCharge, function(v) Config.AutoCharge = v end)
createToggleRow(fishCard, "Tự Động Chống Kẹt Cần (Anti-Stuck)", "Tự động phát hiện và gỡ kẹt khi quăng cần hoặc minigame bị đơ quá 15s", Config.AntiStuckEnabled, function(v) Config.AntiStuckEnabled = v end)

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

local loopOptions = {"X, C", "X, C, V", "Z, X, C", "Z, X, C, V", "C, V", "Z, X"}
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

createCategoryHeader(tabFishing, "🎯 Auto Luyện Chiêu Thức (Skill Mastery Evo)")
local trainCard = createCardGroup(tabFishing)
local infoTrainProgress = createInfoRow(trainCard, "Tiến Độ Luyện Chiêu", string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount))
createToggleRow(trainCard, "Bật Auto Luyện Chiêu", "Tự động dùng các chiêu đã bật khi hết hồi chiêu lúc kéo cá", Config.AutoTrainSkill, function(v) Config.AutoTrainSkill = v end)

-- Chọn riêng từng chiêu (có thể bật cùng lúc C và V, Z và X, v.v.)
createToggleRow(trainCard, "⚡ Luyện Chiêu Z", "Bật tự dùng chiêu phím Z khi hồi xong", Config.Train_Z, function(v) Config.Train_Z = v end)
createToggleRow(trainCard, "⚡ Luyện Chiêu X", "Bật tự dùng chiêu phím X khi hồi xong", Config.Train_X, function(v) Config.Train_X = v end)
createToggleRow(trainCard, "⚡ Luyện Chiêu C", "Bật tự dùng chiêu phím C khi hồi xong", Config.Train_C, function(v) Config.Train_C = v end)
createToggleRow(trainCard, "⚡ Luyện Chiêu V", "Bật tự dùng chiêu phím V khi hồi xong", Config.Train_V, function(v) Config.Train_V = v end)

createSliderRow(trainCard, "Mục Tiêu Số Lần Dùng", "Số lần cần dùng để đạt yêu cầu tiến hóa", 10, 500, Config.TrainTargetCount, false, " lần", function(v)
    Config.TrainTargetCount = v
    if infoTrainProgress and infoTrainProgress.Set then
        infoTrainProgress.Set(string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount))
    end
end)
createSliderRow(trainCard, "Thời Gian Hồi Chiêu (Cooldown)", "Chỉ tính 1 lần dùng khi chiêu đã thực sự hồi xong", 2.0, 25.0, Config.TrainSkillCooldown, true, "s", function(v) Config.TrainSkillCooldown = v end)
createToggleRow(trainCard, "Kéo Dài Trận Câu (Giữ Cá Lâu)", "Không kết liễu nhanh để giữ cá trên dây spam chiêu nhiều nhất", Config.TrainDelayCatch, function(v) Config.TrainDelayCatch = v end)
createButtonRow(trainCard, "Đặt Lại Bộ Đếm (Reset)", "Reset số lần đã luyện về 0", "Đặt Lại", function()
    Config.TrainCurrentCount = 0
    if infoTrainProgress and infoTrainProgress.Set then
        infoTrainProgress.Set(string.format("0 / %d lần", Config.TrainTargetCount))
    end
    ShowNotification("Luyện Chiêu", "Đã đặt lại số lần luyện chiêu về 0!", "SUCCESS")
end)

createCategoryHeader(tabFishing, "Tự Động Trang Bị Tối Ưu")
local equipCard = createCardGroup(tabFishing)
createToggleRow(equipCard, "Tự Dùng Mồi Tốt Nhất", "Tự động móc loại mồi có may mắn cao nhất trong kho", Config.AutoEquipBestBait, function(v) Config.AutoEquipBestBait = v end)
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
        local rFolder = pData.FishingRodInventory:FindFirstChild(Config.Loadout1_Rod)
        local isOwned = rFolder and rFolder:FindFirstChild("Owned") and rFolder.Owned.Value == true
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
        local rFolder = pData.FishingRodInventory:FindFirstChild(Config.Loadout2_Rod)
        local isOwned = rFolder and rFolder:FindFirstChild("Owned") and rFolder.Owned.Value == true
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
createToggleRow(sellCard, "Chế Độ Cày Nguyên Liệu", "Giữ lại cá làm nguyên liệu, không bán", Config.MaterialFarming, function(v) Config.MaterialFarming = v end)

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

createCategoryHeader(tabBoss, "🎯 TỰ ĐỘNG SĂN SECRET BOSS THEO CHAT")
local chatBossCard = createCardGroup(tabBoss)

createToggleRow(chatBossCard, "Bật Săn Secret Boss (Chat Sniper)", "Tự nghe tin nhắn chat server, bay đến đảo và săn boss", Config.AutoChatSecretBoss, function(v)
    Config.AutoChatSecretBoss = v
    if v then
        ShowNotification("Săn Secret Boss", "Đang kiểm tra lịch sử chat và lắng nghe thông báo Server...", "SUCCESS", 5)
        -- TỰ ĐỘNG KIỂM TRA LỊCH SỬ CHAT TRƯỚC ĐÓ XEM BOSS CÒN KHÔNG
        task.spawn(function()
            task.wait(0.3)
            local found = ScanExistingChatHistory()
            if not found then
                if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                    statusLabelSecretBoss.Set("Đang chờ thông báo Boss mới...")
                end
            end
        end)
    else
        secretBossState.active = false
        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
            statusLabelSecretBoss.Set("Đã tắt chế độ săn.")
        end
    end
end)

createButtonRow(chatBossCard, "Quét Lại Lịch Sử Chat & Boss", "Kiểm tra lại lịch sử chat xem có Boss nào đang hoạt động không", "Quét Ngay", function()
    local found = ScanExistingChatHistory()
    if not found then
        ShowNotification("Kết Quả Quét", "Không tìm thấy Secret Boss nào đang hoạt động trong lịch sử chat.", "INFO", 5)
    end
end)

createToggleRow(chatBossCard, "Giật Cần Thả Lại (Fast Skip Cá Thường)", "Nếu cắn câu không phải Secret Boss đã chọn thì lập tức giật cần thả lại", Config.FastSkipNonBoss, function(v)
    Config.FastSkipNonBoss = v
end)

createToggleRow(chatBossCard, "Kiểm Tra Lực Cần (Power Check)", "Cảnh báo nếu cần câu hiện tại không đủ lực yêu cầu của Boss", Config.SecretBossCheckPower, function(v)
    Config.SecretBossCheckPower = v
end)

createToggleRow(chatBossCard, "Tự Đổi Server Khi Hết Boss (Auto-Hop)", "Tự động đổi server khác ngay khi có thông báo tất cả Secret Boss đã despawn", Config.AutoServerHopOnDespawn, function(v)
    Config.AutoServerHopOnDespawn = v
end)

statusLabelSecretBoss = createInfoRow(chatBossCard, "Trạng Thái Săn:", secretBossState.statusText)

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

createButtonRow(chatBossCard, "Test Săn Thử Tại Đảo Hiện Tại", "Giả lập bắt đầu săn Secret Boss ngay tại vị trí bạn đang đứng", "Test Ngay", function()
    secretBossState.active = true
    secretBossState.currentMap = "Đảo Hiện Tại (Test)"
    secretBossState.statusText = "Đang săn thử nghiệm tại Đảo Hiện Tại..."
    if statusLabelSecretBoss and statusLabelSecretBoss.Set then
        statusLabelSecretBoss.Set(secretBossState.statusText)
    end
    ShowNotification("Test Săn Boss", "Đã kích hoạt chế độ săn tại đảo hiện tại! Hãy thả cần thử.", "SUCCESS", 5)
end)

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

local function TriggerPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.05)
            prompt:InputHoldEnd()
        end)
    end
end

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

createCategoryHeader(tabQuests, "Nhiệm Vụ Vé (Ticket Quests)")
local questCard = createCardGroup(tabQuests)

createToggleRow(questCard, "Tự Động Làm Vé Nhiệm Vụ", "Tự động nhận và trả nhiệm vụ vé liên tục", Config.AutoTicketQuest, function(v) Config.AutoTicketQuest = v end)
createDropdownRow(questCard, "Độ Khó Nhiệm Vụ", "Chọn độ khó vé nhiệm vụ (Easy / Hard)", {"Easy", "Hard"}, Config.TicketDifficulty, function(v) Config.TicketDifficulty = v end)

createButtonRow(questCard, "Nộp Nhanh Vé Easy", "Nộp vé nhiệm vụ Easy ngay lập tức", "Nộp Easy", function()
    if Events and Events:FindFirstChild("ClaimQuest") then
        Events.ClaimQuest:FireServer("Ticket", "Easy")
        ShowNotification("Nhiệm Vụ", "Đã nộp vé nhiệm vụ Easy!", "SUCCESS")
    end
end)

createButtonRow(questCard, "Nộp Nhanh Vé Hard", "Nộp vé nhiệm vụ Hard ngay lập tức", "Nộp Hard", function()
    if Events and Events:FindFirstChild("ClaimQuest") then
        Events.ClaimQuest:FireServer("Ticket", "Hard")
        ShowNotification("Nhiệm Vụ", "Đã nộp vé nhiệm vụ Hard!", "SUCCESS")
    end
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

createButtonRow(dailyCard, "Nhập Toàn Bộ Mã Code", "Tự động nhập tất cả mã giftcode còn hạn", "Nhập Code", function()
    local codes = {"60KLikes", "55KLikes", "50KLikes", "40MVisits", "35MVisits", "TaijiEvo", "NewSeason", "33MVisits", "32MVisits", "31MVisits", "30MVisits", "Taiji", "49KLikes", "48KLikes", "47KLikes", "46KLikes", "13KActives", "HWF", "RELEASE"}
    if Events and Events:FindFirstChild("RedeemCode") then
        for _, c in ipairs(codes) do
            Events.RedeemCode:FireServer(c)
            task.wait(0.2)
        end
        ShowNotification("Giftcode", "Đã nhập tất cả các mã code còn hạn!", "SUCCESS")
    end
end)

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
    local formatted = tostring(n)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted .. " Cash"
end

for _, rod in ipairs(allRods) do
    local pStr = formatNumber(rod.price)
    local desc = string.format("Lực: %d | May mắn: %d%% | Giá: %s", rod.power, rod.luck, pStr)
    createButtonRow(rodShopCard, rod.name, desc, "Mua Cần", function()
        if Events and Events:FindFirstChild("BuyFishingRod") then
            Events.BuyFishingRod:FireServer(rod.name)
            ShowNotification("Shop Cần", "Đã gửi yêu cầu mua cần: " .. rod.name, "SUCCESS")
        end
    end)
end

createCategoryHeader(tabTeleports, "Dịch Chuyển Đến Đảo (Đảo 1 - 10)")
local islandCard = createCardGroup(tabTeleports)

local islands = {
    {name = "[1] Đảo Khởi Đầu (Spawn)", pos = Vector3.new(-200.7, 11.1, 35.9)},
    {name = "[2] Đảo Tre (Bamboo Isle)", pos = Vector3.new(-1223.0, 7.3, -24.1)},
    {name = "[3] Đảo Phóng Xạ (Fallout Isle)", pos = Vector3.new(65.5, 8.8, 1181.3)},
    {name = "[4] Đảo Thống Trị (Sovereign Isle)", pos = Vector3.new(-1276.4, 8.8, 1239.7)},
    {name = "[5] Đảo Cá Chép (Perch Isle)", pos = Vector3.new(-62.0, 11.9, -1321.4)},
    {name = "[6] Đảo Băng Giá (Frost Isle)", pos = Vector3.new(-1366.0, 11.9, -1495.4)},
    {name = "[7] Đảo Quả Dừa (Coconut Isle)", pos = Vector3.new(1493.6, 9.1, -1430.6)},
    {name = "[8] Đảo Hổ Phách (Amber Isle)", pos = Vector3.new(1259.4, 9.1, 1401.5)},
    {name = "[9] Đảo Chiến Trường (Battlefield)", pos = Vector3.new(1393.5, 11.3, 169.6)},
    {name = "[10] Đảo Đỉnh Sương Mù (Mistpeak)", pos = Vector3.new(2660.2, 8.8, -86.7)},
}

for _, isl in ipairs(islands) do
    createButtonRow(islandCard, isl.name, "Dịch chuyển đến " .. isl.name, "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(isl.pos + Vector3.new(0, 3, 0))
            ShowNotification("Teleport", "Arrived at " .. isl.name .. "!", "SUCCESS")
        end
    end)
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

createCategoryHeader(tabTeleports, "Dịch Chuyển Người Chơi & Server")
local srvCard = createCardGroup(tabTeleports)

local lastTpTarget = nil
createButtonRow(srvCard, "Bay Đến Người Chơi Ngẫu Nhiên", "Dịch chuyển tức thì đến vị trí của một người chơi khác", "Bay Đến", function()
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
    end
end)

createCategoryHeader(tabVisuals, "ESP Nhìn Xuyên Tường")
local espCard = createCardGroup(tabVisuals)

createToggleRow(espCard, "ESP Thần Linh (God Spirit)", "Hiện vị trí Thần linh xuyên bản đồ", Config.ESP_GodSpirit, function(v) Config.ESP_GodSpirit = v end)
createToggleRow(espCard, "ESP Cần Câu Bí Mật", "Hiện vị trí các cần câu ẩn trên bản đồ", Config.ESP_SecretRod, function(v) Config.ESP_SecretRod = v end)
createToggleRow(espCard, "ESP Thuyền Bè", "Hiện vị trí tất cả thuyền xung quanh", Config.ESP_Boats, function(v) Config.ESP_Boats = v end)
createToggleRow(espCard, "ESP Maoshan", "Hiện vị trí NPC hoặc cần Maoshan", Config.ESP_Maoshan, function(v) Config.ESP_Maoshan = v end)
createToggleRow(espCard, "ESP Đạo Sĩ (Taoist)", "Hiện vị trí NPC hoặc cần Taoist", Config.ESP_Taoist, function(v) Config.ESP_Taoist = v end)
createToggleRow(espCard, "ESP Trùm Boss", "Hiện vị trí các Boss đang xuất hiện", Config.ESP_Boss, function(v) Config.ESP_Boss = v end)
createToggleRow(espCard, "ESP Người Chơi", "Hiện khung & khoảng cách đến người chơi khác", Config.ESP_Players, function(v) Config.ESP_Players = v end)
createToggleRow(espCard, "Vòng Tròn Định Vị Cá", "Hiện vòng tròn đỏ dưới nước chỉ đúng con cá cắn câu", Config.FishRedRing, function(v) Config.FishRedRing = v end)

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
createToggleRow(moveCard, "Đi Xuyên Tường (Noclip)", "Đi xuyên qua vách núi, tường rào và vật cản", Config.Noclip, function(v) Config.Noclip = v end)

createCategoryHeader(tabPlayer, "Chống Văng Game & Ổn Định")
local stabCard = createCardGroup(tabPlayer)
createToggleRow(stabCard, "Chống Văng Game (Anti-AFK)", "Chống bị Roblox kick sau 20 phút treo máy", Config.AntiAFK, function(v) Config.AntiAFK = v end)
createToggleRow(stabCard, "Tự Động Kết Nối Lại", "Tự động vào lại server nếu bị mất kết nối", Config.AutoRejoin, function(v) Config.AutoRejoin = v end)

createCategoryHeader(tabProfiles, "Quản Lý Cấu Hình (Profile)")
local profCard = createCardGroup(tabProfiles)

createButtonRow(profCard, "Lưu Cấu Hình (Save)", "Lưu lại toàn bộ cài đặt vào file JSON", "Lưu Cấu Hình", function()
    if SaveProfile() then
        ShowNotification("Cài Đặt", "Đã lưu cấu hình thành công!", "SUCCESS")
    else
        ShowNotification("Lỗi", "Không thể lưu file cấu hình.", "ERROR")
    end
end)

createButtonRow(profCard, "Nạp Cấu Hình (Load)", "Tải lại các cài đặt đã lưu trước đó", "Nạp Cấu Hình", function()
    if LoadProfile() then
        ShowNotification("Cài Đặt", "Đã nạp cấu hình thành công!", "SUCCESS")
    else
        ShowNotification("Cảnh Báo", "Chưa có file cấu hình nào được lưu trước đó.", "WARN")
    end
end)

createToggleRow(profCard, "Tự Nạp Khi Chạy Script", "Tự động nạp cài đặt đã lưu khi mở script", Config.AutoLoadProfile, function(v) Config.AutoLoadProfile = v end)

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
local lastGlobalSkillCastTime = 0
local lastSkillUsedTimes = {
    ["Z"] = 0,
    ["X"] = 0,
    ["C"] = 0,
    ["V"] = 0
}

local openerUsedCount = 0
local lastComboSkillCastTime = 0

local function CheckSkillReady(sk, fUI, minCooldown)
    if not sk or sk == "" or sk == "Tắt" then return false end
    local cleanKey = sk:match("([ZXCVzxcv])") or sk
    cleanKey = cleanKey:upper()

    local now = tick()
    local lastUsed = lastSkillUsedTimes[cleanKey] or 0
    local minCd = minCooldown or Config.TrainSkillCooldown or 5.0
    if (now - lastUsed < minCd) then
        return false
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
                        if tonumber(child.Text:match("^%s*(%d+)")) then
                            return false
                        end
                    end
                end
            end
        end
    end

    return true
end

local function GetFishHealth(fUI)
    local fishID = LocalPlayer:GetAttribute("FishID")
    if fishID and Workspace:FindFirstChild("Fishes") then
        local f = Workspace.Fishes:FindFirstChild(fishID)
        if f then
            local hpVal = f:FindFirstChild("Health") or f:FindFirstChild("HP") or f:FindFirstChild("FishHealth")
            if hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) then
                return hpVal.Value
            end
            for _, child in ipairs(f:GetChildren()) do
                if child.Name:find("Health") or child.Name:find("HP") then
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        return child.Value
                    end
                end
            end
        end
    end

    local char = LocalPlayer.Character
    if char then
        for _, att in ipairs({"FishHealth", "FishHP", "TargetHealth", "BossHP", "TargetHP", "HP"}) do
            local val = char:GetAttribute(att)
            if val and tonumber(val) then return tonumber(val) end
        end
    end

    if fUI then
        for _, lblName in ipairs({"FishHP", "HPFish", "Health", "HP", "BossHP", "TargetHP"}) do
            local d = fUI:FindFirstChild(lblName, true)
            if d and d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                local num = d.Text:match("(%d+[,%d*]*)%s*/") or d.Text:match("(%d+[,%d*]*)")
                if num then
                    local cleanNum = num:gsub(",", "")
                    if tonumber(cleanNum) then return tonumber(cleanNum) end
                end
            end
        end
    end

    return 999999
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
    local char = LocalPlayer.Character
    if not char then return false end

    for _, att in ipairs({"Casting", "UsingSkill", "SkillActive", "IsAttacking", "CastingSkill"}) do
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
                    if animName:find("skill") or animName:find("attack") or animName:find("cast") or animName:find("strike") or animName:find("special") then
                        return true
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

    if Events:FindFirstChild("UseSkill") then
        Events.UseSkill:FireServer(cleanKey)
    end
    if Events:FindFirstChild("TriggerMinigameSkill") then
        Events.TriggerMinigameSkill:FireServer(cleanKey)
    end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        local kCode = Enum.KeyCode[cleanKey]
        if vim and kCode then
            vim:SendKeyEvent(true, kCode, false, game)
            task.wait(0.02)
            vim:SendKeyEvent(false, kCode, false, game)
        end
    end)
    lastSkillUsedTimes[cleanKey] = tick()
    lastComboSkillCastTime = tick()
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

local craftMaterialFish = {
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
}

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

        if Config.WalkOnWater then
            waterPlatform.CFrame = CFrame.new(root.Position.X, 0, root.Position.Z)
            waterPlatform.CanCollide = (root.Position.Y >= -1)
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

        if (Config.AutoCast or (Config.AutoChatSecretBoss and secretBossState.active)) and char:GetAttribute("Type") ~= "Fishing Rod" and (now - lastEquipRodTime >= 1.0) then
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
            openerUsedCount = 0
        elseif not isMinigame then
            minigameDurationTracker = 0
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
            if Config.AutoChatSecretBoss and secretBossState.active and Config.FastSkipNonBoss then
                if secretBossState.minigameStartTime == 0 then
                    secretBossState.minigameStartTime = now
                end
                
                local hookedFish = GetCurrentHookedFishName()
                if (now - secretBossState.minigameStartTime >= 0.25) and (now - secretBossState.lastSkipTime >= 1.0) then
                    if hookedFish then
                        if Config.SecretBossTargets[hookedFish] == true then
                            -- Đúng Secret Boss mục tiêu!
                            secretBossState.isCatchingTarget = true
                            if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                                statusLabelSecretBoss.Set("🎯 ĐANG CÂU BOSS: " .. hookedFish .. "!")
                            end
                        else
                            -- Không phải Secret Boss -> Giật cần thả lại ngay!
                            secretBossState.lastSkipTime = now
                            secretBossState.minigameStartTime = 0
                            skipTriggered = true
                            if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                                statusLabelSecretBoss.Set("Bỏ qua cá thường (" .. hookedFish .. "), đang giật cần thả lại...")
                            end
                            CancelAndRecastRod()
                        end
                    elseif (now - secretBossState.minigameStartTime >= 0.8) then
                        -- Sau 0.8s vẫn không phát hiện Secret Boss nào -> Cá thường, giật cần thả lại!
                        secretBossState.lastSkipTime = now
                        secretBossState.minigameStartTime = 0
                        skipTriggered = true
                        if statusLabelSecretBoss and statusLabelSecretBoss.Set then
                            statusLabelSecretBoss.Set("Không phải Boss, đang giật cần thả lại...")
                        end
                        CancelAndRecastRod()
                    end
                end
            else
                secretBossState.minigameStartTime = 0
            end

            if not skipTriggered then
            if fUI and fUI.Visible then
                -- Tự động giữ thanh cân bằng minigame (Anchor Bar)
                if (Config.AnchorBar or Config.AutoTrainSkill or (Config.AutoChatSecretBoss and secretBossState.active)) then
                    local barFrame = fUI:FindFirstChild("BarFrame")
                    if barFrame and barFrame:FindFirstChild("Bar") then
                        barFrame.Bar:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
                        barFrame.Bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end

                local delayCatch = Config.AutoTrainSkill and Config.TrainDelayCatch

                if not delayCatch then
                    if Config.AutoSlam and fUI:FindFirstChild("PerfectButton") and fUI.PerfectButton.Visible then
                        if Events:FindFirstChild("Slam") then
                            Events.Slam:FireServer()
                        end
                    end
                end

                if Config.AutoCharge and fUI:FindFirstChild("Charge") and fUI.Charge.Visible then
                    if Events:FindFirstChild("Charge") then
                        Events.Charge:FireServer()
                    end
                end

                if not delayCatch then
                    if Config.AnchorBar and (now - lastProgressionTime >= 0.08) then
                        if Events and Events:FindFirstChild("UpdateFishProgression") then
                            Events.UpdateFishProgression:FireServer()
                        end
                        lastProgressionTime = now
                    end
                else
                    -- Giữ cá lâu trên dây: chỉ gửi cập nhật rất chậm để cá không đứt dây mà không kéo cá lên nhanh
                    if (now - lastProgressionTime >= 1.2) then
                        if Events and Events:FindFirstChild("UpdateFishProgression") then
                            Events.UpdateFishProgression:FireServer()
                        end
                        lastProgressionTime = now
                    end
                end

                -- XỬ LÝ AUTO LUYỆN CHIÊU THỨC (SKILL MASTERY CHUẨN XÁC)
                if Config.AutoTrainSkill then
                    if (now - lastGlobalSkillCastTime >= 0.4) then
                        if Config.TrainCurrentCount < Config.TrainTargetCount then
                            local activeSkills = {}
                            if Config.Train_Z then table.insert(activeSkills, "Z") end
                            if Config.Train_X then table.insert(activeSkills, "X") end
                            if Config.Train_C then table.insert(activeSkills, "C") end
                            if Config.Train_V then table.insert(activeSkills, "V") end

                            for _, sk in ipairs(activeSkills) do
                                if CheckSkillReady(sk, fUI) then
                                    -- Kích hoạt chiêu thức
                                    if Events:FindFirstChild("UseSkill") then Events.UseSkill:FireServer(sk) end
                                    if Events:FindFirstChild("TriggerMinigameSkill") then Events.TriggerMinigameSkill:FireServer(sk) end
                                    pcall(function()
                                        local vim = game:GetService("VirtualInputManager")
                                        local kCode = Enum.KeyCode[sk]
                                        if vim and kCode then
                                            vim:SendKeyEvent(true, kCode, false, game)
                                            task.wait(0.02)
                                            vim:SendKeyEvent(false, kCode, false, game)
                                        end
                                    end)

                                    -- Đánh dấu thời gian đã dùng và cộng số lần THỰC TẾ
                                    lastSkillUsedTimes[sk] = now
                                    lastGlobalSkillCastTime = now
                                    Config.TrainCurrentCount = Config.TrainCurrentCount + 1

                                    if infoTrainProgress and infoTrainProgress.Set then
                                        infoTrainProgress.Set(string.format("%d / %d lần (Vừa cast: %s)", Config.TrainCurrentCount, Config.TrainTargetCount, sk))
                                    end

                                    if Config.TrainCurrentCount >= Config.TrainTargetCount then
                                        Config.AutoTrainSkill = false
                                        ShowNotification("Luyện Chiêu Thành Công", string.format("Đã luyện đủ %d lần kỹ năng!", Config.TrainTargetCount), "SUCCESS", 7)
                                    end

                                    -- Đợi 0.4s trước khi cast chiêu tiếp theo để không bị nuốt animation
                                    break
                                end
                            end
                        end
                    end
                elseif Config.SmartComboEnabled then
                    local isBusy = false
                    if (now - lastComboSkillCastTime < (Config.SkillEffectDelay or 1.2)) then
                        isBusy = true
                    elseif Config.SmartEffectAutoDetect and IsCharacterCastingSkill() then
                        isBusy = true
                    end

                    if not isBusy then
                        -- BƯỚC 1: CỨU NGUY HỒI MÁU KHI HP NGƯỜI CHƠI THẤP
                        local healTriggered = false
                        if Config.EmergencyHealSkill and Config.EmergencyHealSkill ~= "Tắt" then
                            local playerHp = GetPlayerHealth(fUI)
                            if playerHp <= (Config.EmergencyHealHp or 40) then
                                if CheckSkillReady(Config.EmergencyHealSkill, fUI, 1.0) then
                                    CastSkill(Config.EmergencyHealSkill)
                                    healTriggered = true
                                end
                            end
                        end

                        if not healTriggered then
                            -- BƯỚC 2: PHÂN LOẠI THEO MÁU CÁ
                            local fishHp = GetFishHealth(fUI)
                            local threshold = Config.FishHpThreshold or 500

                            if fishHp <= threshold then
                                -- Máu cá <= 500 HP: Cá nhỏ/thường/yếu -> Tung ngay chiêu dứt điểm nhanh (Quick Catch)
                                if Config.QuickCatchSkill and Config.QuickCatchSkill ~= "Tắt" then
                                    if CheckSkillReady(Config.QuickCatchSkill, fUI, 1.0) then
                                        CastSkill(Config.QuickCatchSkill)
                                    end
                                end
                            else
                                -- Máu cá > 500 HP: Cá to/Boss -> Bật chuỗi Combo chiến thuật
                                local openerTriggered = false
                                if Config.OpenerSkill and Config.OpenerSkill ~= "Tắt" and (openerUsedCount < (Config.OpenerMaxCount or 1)) then
                                    if CheckSkillReady(Config.OpenerSkill, fUI, 1.0) then
                                        CastSkill(Config.OpenerSkill)
                                        openerUsedCount = openerUsedCount + 1
                                        openerTriggered = true
                                    end
                                end

                                if not openerTriggered then
                                    -- Chuỗi đảo chiêu luân phiên (Core Loop)
                                    local loopKeys = {}
                                    for k in string.gmatch(Config.LoopSkills or "X, C", "([ZXCVzxcv])") do
                                        table.insert(loopKeys, k:upper())
                                    end
                                    if #loopKeys == 0 then loopKeys = {"X", "C"} end

                                    for _, sk in ipairs(loopKeys) do
                                        if CheckSkillReady(sk, fUI, 1.0) then
                                            CastSkill(sk)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
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
            if (Config.AutoCast or (Config.AutoChatSecretBoss and secretBossState.active)) and not isCD and not isSwimming and (char:GetAttribute("Type") == "Fishing Rod") and (now - lastCastTime >= Config.CastDelay) then
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
                            if (Config.MaterialFarming or Config.AutoFavouriteFish) and pData:FindFirstChild("Inventory") then
                                for _, item in ipairs(pData.Inventory:GetChildren()) do
                                    local itemName = item.Name
                                    local isFav = item:FindFirstChild("Favorite") and item.Favorite.Value == true
                                    if not isFav and ((Config.MaterialFarming and craftMaterialFish[itemName]) or (Config.AutoFavouriteFish and itemName == Config.FavouriteFishName)) then
                                        if Events:FindFirstChild("FavoriteItem") then Events.FavoriteItem:FireServer(item) end
                                    end
                                end
                            end
                            Events.SellFish:FireServer("All")
                            lastSellTime = now
                        end
                    end
                end

                if Config.AutoSell and (now - lastSellTime >= Config.SellInterval) and Events:FindFirstChild("SellFish") then
                    if (Config.MaterialFarming or Config.AutoFavouriteFish) and pData and pData:FindFirstChild("Inventory") then
                        for _, item in ipairs(pData.Inventory:GetChildren()) do
                            local itemName = item.Name
                            local isFav = item:FindFirstChild("Favorite") and item.Favorite.Value == true
                            if not isFav and ((Config.MaterialFarming and craftMaterialFish[itemName]) or (Config.AutoFavouriteFish and itemName == Config.FavouriteFishName)) then
                                if Events:FindFirstChild("FavoriteItem") then Events.FavoriteItem:FireServer(item) end
                            end
                        end
                    end
                    Events.SellFish:FireServer("All")
                    lastSellTime = now
                end

                if (Config.MaterialFarming or Config.AutoFavouriteFish) and (now - lastProtectTime >= 1.5) and pData and pData:FindFirstChild("Inventory") then
                    lastProtectTime = now
                    for _, item in ipairs(pData.Inventory:GetChildren()) do
                        local itemName = item.Name
                        local isFav = item:FindFirstChild("Favorite") and item.Favorite.Value == true
                        if not isFav then
                            local shouldProtect = false
                            if Config.MaterialFarming and craftMaterialFish[itemName] then shouldProtect = true end
                            if Config.AutoFavouriteFish and itemName == Config.FavouriteFishName then shouldProtect = true end
                            if shouldProtect and Events:FindFirstChild("FavoriteItem") then
                                Events.FavoriteItem:FireServer(item)
                            end
                        end
                    end
                end

                if canCast and Events and Events:FindFirstChild("Fishing") then
                    Events.Fishing:FireServer(root.CFrame)
                    lastCastTime = now
                end
            end
        end

        if (now - lastEquipTime >= 5.0) and pData then
            lastEquipTime = now
            if Config.AutoEquipBestBait and pData:FindFirstChild("Bait") and pData:FindFirstChild("EquippedBait") and Events:FindFirstChild("EquipBait") then
                local bestBait = nil
                local bestLuck = -1
                local baitLuckMap = {
                    ["Nameless Bait"] = 100,
                    ["Rainbow Bait"] = 80,
                    ["Frost Bait"] = 65,
                    ["Ancestral Bait"] = 50,
                    ["Elite Bait"] = 30,
                    ["Corrupted Essence Bait"] = 18,
                    ["Crude Mash Bait"] = 8,
                    ["Basic Bait"] = 3
                }
                for bName, bLuck in pairs(baitLuckMap) do
                    local bVal = pData.Bait:FindFirstChild(bName)
                    if bVal and bVal.Value > 0 and bLuck > bestLuck then
                        bestLuck = bLuck
                        bestBait = bName
                    end
                end
                if bestBait and pData.EquippedBait.Value ~= bestBait then
                    Events.EquipBait:InvokeServer(bestBait)
                end
            end

            if Config.AutoEquipBestRod and pData:FindFirstChild("FishingRodInventory") and pData:FindFirstChild("FishingRod") and Events:FindFirstChild("EquipFishingRod") then
                local bestRod = nil
                local bestPower = -1
                for _, r in ipairs(allRods) do
                    local rFolder = pData.FishingRodInventory:FindFirstChild(r.name)
                    local isOwned = rFolder and rFolder:FindFirstChild("Owned") and rFolder.Owned.Value == true
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
            if pData:FindFirstChild("FishCaught") then infoFishCaught.Set(tostring(pData.FishCaught.Value)) end
            if pData:FindFirstChild("Cash") then infoCash.Set("$" .. tostring(pData.Cash.Value)) end
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

        if Config.AutoTicketQuest and (now - lastQuestTime >= 2.0) then
            if Events and Events:FindFirstChild("ClaimQuest") then
                Events.ClaimQuest:FireServer("Ticket", Config.TicketDifficulty)
                lastQuestTime = now
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
                HandleIncomingChatMessage(textChatMessage.Text)
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
                HandleIncomingChatMessage(tostring(data.Message))
            end
        end)
        table.insert(activeConnections, conn)
    end
end)


table.insert(activeConnections, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and isRunning then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

pcall(function()
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK and isRunning then
            local vu = game:GetService("VirtualUser")
            if vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end
        end
    end)
end)

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

local function AddESP(instance, name, espCategory, color, icon)
    if not instance or activeESP[instance] then return end
    local part = instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_" .. name
    bb.Size = UDim2.new(0, 150, 0, 24)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = part
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

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                AddESP(p.Character, p.DisplayName, "Players", Colors.PurpleAccent, "👤")
            end
        end
    end

    if Workspace:FindFirstChild("SecretRod") then
        for _, r in ipairs(Workspace.SecretRod:GetChildren()) do
            AddESP(r, r.Name, "SecretRod", Colors.AccentYellow, "🌟")
        end
    end

    if Workspace:FindFirstChild("NPC") then
        local sp = Workspace.NPC:FindFirstChild("Spirit") or Workspace.NPC:FindFirstChild("God")
        if sp then
            AddESP(sp, "God Spirit", "GodSpirit", Colors.AccentGreen, "⛩️")
        end
    end

    if Workspace:FindFirstChild("Boat") then
        for _, b in ipairs(Workspace.Boat:GetChildren()) do
            AddESP(b, b.Name, "Boats", Colors.AccentBlue, "⛵")
        end
    end

    if Workspace:FindFirstChild("BossSetUp") then
        for _, b in ipairs(Workspace.BossSetUp:GetChildren()) do
            AddESP(b, b.Name, "Boss", Colors.AccentRed, "👹")
        end
    end

    if Workspace:FindFirstChild("NPC") then
        for _, n in ipairs(Workspace.NPC:GetChildren()) do
            if n.Name:find("Taoist") or n.Name:find("Grand Angler") then
                AddESP(n, n.Name, "Taoist", Colors.AccentOrange, "📜")
            elseif n.Name:find("Maoshan") then
                AddESP(n, n.Name, "Maoshan", Colors.PurplePrimary, "✨")
            end
        end
    end

    local camPos = Camera.CFrame.Position
    for inst, data in pairs(activeESP) do
        if not inst.Parent or not data.part.Parent then
            RemoveESP(inst)
        else
            local isEnabled = Config["ESP_" .. data.espCategory]
            data.gui.Enabled = isEnabled and true or false
            if isEnabled then
                local dist = math.floor((camPos - data.part.Position).Magnitude)
                data.label.Text = data.icon .. " " .. data.name .. " [" .. dist .. "m]"
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
        else
            fishRingAdornment.Visible = false
        end
    else
        if fishRingAdornment.Visible then fishRingAdornment.Visible = false end
    end
end))

table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Config.UIKeybind then
        if ToggleUiVisibility then ToggleUiVisibility() end
    elseif input.KeyCode == Enum.KeyCode.End or input.KeyCode == Config.StopKeybind then
        UnloadScript()
    end
end))

ShowNotification("VIỆT HOÁ V1.3", "Heavyweight Fishing đã cập nhật Hệ Thống Smart Combo Chiến Thuật!", "SUCCESS", 6)