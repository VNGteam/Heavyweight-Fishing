--[[
    v2/main.lua
    Identical Hub V2 - Heavyweight Fishing
    Modular Architecture • Strict Sequential Combo • Clean Optimized Core
--]]

local Services = require(script.core.services)
local ConfigModule = require(script.core.config)
local Config = ConfigModule.Config
local State = require(script.core.state)
local Utils = require(script.core.utils)
local Theme = require(script.ui.theme)

-- Features & Combo Modules
local StateMachine = require(script.combo.state_machine)
local Fishing = require(script.features.fishing)
local Boss = require(script.features.boss)
local Quest = require(script.features.quest)
local Spirits = require(script.features.spirits)
local Shop = require(script.features.shop)
local Teleport = require(script.features.teleport)
local Visuals = require(script.features.visuals)
local Character = require(script.features.character)

-- UI Tabs (No Wiki Tab!)
local TabCauCa = require(script.ui.tabs.tab_cau_ca)
local TabCombo = require(script.ui.tabs.tab_combo)
local TabSanBoss = require(script.ui.tabs.tab_san_boss)
local TabNhiemVu = require(script.ui.tabs.tab_nhiem_vu)
local TabThanLinh = require(script.ui.tabs.tab_than_linh)
local TabShop = require(script.ui.tabs.tab_shop)
local TabDichChuyen = require(script.ui.tabs.tab_dich_chuyen)
local TabVisuals = require(script.ui.tabs.tab_visuals)
local TabNhanVat = require(script.ui.tabs.tab_nhan_vat)
local TabCaiDat = require(script.ui.tabs.tab_cai_dat)
local TabThuNghiem = require(script.ui.tabs.tab_thu_nghiem)

-- 1. Dọn dẹp bản cũ
Services.CleanOldInstances()

-- 2. Tạo GUI Gốc
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IdenticalHeavyweightFishing"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = Services.GetGuiParent()
State.AddInstance(screenGui)

-- Notification Container
local notifFrame = Instance.new("Frame")
notifFrame.Name = "Notifications"
notifFrame.Size = UDim2.new(0, 260, 1, -40)
notifFrame.Position = UDim2.new(1, -270, 0, 20)
notifFrame.BackgroundTransparency = 1
notifFrame.Parent = screenGui

local nLayout = Instance.new("UIListLayout")
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
nLayout.Padding = UDim.new(0, 6)
nLayout.Parent = notifFrame

Utils.SetNotifContainer(notifFrame)

-- Khung Chính (Main Window)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 720, 0, 460)
mainFrame.Position = UDim2.new(0.5, -360, 0.5, -230)
mainFrame.BackgroundColor3 = Theme.MainBg
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 10)
mCorner.Parent = mainFrame

local mStroke = Instance.new("UIStroke")
mStroke.Color = Theme.Border
mStroke.Thickness = 1.2
mStroke.Parent = mainFrame

-- Topbar
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 38)
topbar.BackgroundColor3 = Theme.SidebarBg
topbar.BorderSizePixel = 0
topbar.Parent = mainFrame

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -60, 1, 0)
titleLbl.Position = UDim2.new(0, 14, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "IDENTICAL HUB • HEAVYWEIGHT FISHING V2"
titleLbl.TextColor3 = Theme.Accent
titleLbl.Font = Theme.FontBold
titleLbl.TextSize = 13
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topbar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
closeBtn.BackgroundColor3 = Theme.CardBg
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.TextSecondary
closeBtn.Font = Theme.FontBold
closeBtn.TextSize = 12
closeBtn.Parent = topbar

local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 6)
cbCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Sidebar Tabs
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 170, 1, -38)
sidebar.Position = UDim2.new(0, 0, 0, 38)
sidebar.BackgroundColor3 = Theme.SidebarBg
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 2
sidebar.CanvasSize = UDim2.new(0, 0, 0, 480)
sidebar.Parent = mainFrame

local sbLayout = Instance.new("UIListLayout")
sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
sbLayout.Padding = UDim.new(0, 3)
sbLayout.Parent = sidebar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingTop = UDim.new(0, 6)
sbPad.PaddingBottom = UDim.new(0, 6)
sbPad.PaddingLeft = UDim.new(0, 8)
sbPad.PaddingRight = UDim.new(0, 8)
sbPad.Parent = sidebar

-- Content Area
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -170, 1, -38)
contentContainer.Position = UDim2.new(0, 170, 0, 38)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local tabs = {
    { id = "cau_ca", label = "🎣 Câu Cá", module = TabCauCa },
    { id = "combo", label = "⚡ Combo Chiêu", module = TabCombo },
    { id = "san_boss", label = "🐉 Săn Boss", module = TabSanBoss },
    { id = "nhiem_vu", label = "📜 Nhiệm Vụ", module = TabNhiemVu },
    { id = "than_linh", label = "✨ Thần Linh", module = TabThanLinh },
    { id = "shop", label = "🛒 Cửa Hàng", module = TabShop },
    { id = "dich_chuyen", label = "🌀 Dịch Chuyển", module = TabDichChuyen },
    { id = "visuals", label = "👁️ ESP & Đồ Họa", module = TabVisuals },
    { id = "nhan_vat", label = "🏃 Nhân Vật", module = TabNhanVat },
    { id = "cai_dat", label = "⚙️ Cài Đặt", module = TabCaiDat },
    { id = "thu_nghiem", label = "🧪 Thử Nghiệm", module = TabThuNghiem }
}

local tabFrames = {}
local tabButtons = {}

local function switchTab(targetId)
    for id, frame in pairs(tabFrames) do
        frame.Visible = (id == targetId)
    end
    for id, btn in pairs(tabButtons) do
        if id == targetId then
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Theme.TextPrimary
        else
            btn.BackgroundColor3 = Theme.SidebarBg
            btn.TextColor3 = Theme.TextSecondary
        end
    end
end

for _, tabInfo in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.SidebarBg
    btn.Text = "  " .. tabInfo.label
    btn.TextColor3 = Theme.TextSecondary
    btn.Font = Theme.FontMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = contentContainer

    local pLayout = Instance.new("UIListLayout")
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 8)
    pLayout.Parent = page

    local pPad = Instance.new("UIPadding")
    pPad.PaddingTop = UDim.new(0, 10)
    pPad.PaddingBottom = UDim.new(0, 14)
    pPad.PaddingLeft = UDim.new(0, 14)
    pPad.PaddingRight = UDim.new(0, 14)
    pPad.Parent = page

    -- Render nội dung của tab
    pcall(function()
        tabInfo.module.Render(page, Config)
    end)

    tabFrames[tabInfo.id] = page
    tabButtons[tabInfo.id] = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(tabInfo.id)
    end)
end

-- Mặc định hiển thị tab Câu Cá
switchTab("cau_ca")

-- 3. Core Runtime Heartbeat Loop
local wasMinigame = false
local wasFishing = false

local heartbeatConn = Services.RunService.Heartbeat:Connect(function()
    if not State.isRunning then return end

    local char = Services.LocalPlayer.Character
    if not char then return end

    local pGui = Services.LocalPlayer:FindFirstChild("PlayerGui")
    local mGui = pGui and pGui:FindFirstChild("MainGui")
    local fUI = mGui and mGui:FindFirstChild("Fishing")

    local isFishing = char:GetAttribute("Fishing") == true or (fUI and fUI.Visible)
    local isMinigame = fUI and fUI.Visible

    -- Hooks chuyển đổi trạng thái Minigame
    if isMinigame and not wasMinigame then
        StateMachine.OnMinigameStart()
        Fishing.minigameStartTime = tick()
    elseif not isMinigame and wasMinigame then
        StateMachine.OnMinigameEnd()
        Fishing.minigameStartTime = 0
    end
    wasMinigame = isMinigame

    -- Mechanics Trong Minigame
    if isMinigame then
        Fishing.HandleMinigame(Config, fUI)
        local playerHp = Utils.GetPlayerHealth(fUI)
        StateMachine.Step(Config, fUI, playerHp, Quest.state)
        Boss.HandleFastSkip(Config, fUI, isMinigame)
    else
        -- Mechanics Ngoài Minigame
        Fishing.CheckAntiStuck(Config, isFishing, isMinigame)
        Fishing.HandleAutoCast(Config, isFishing, isMinigame)
        Fishing.HandleAutoBait(Config)
        Fishing.HandleTrainSkill(Config, isMinigame)
        Shop.HandleAutoSell(Config)
        Shop.HandleBuyBait(Config)
        Shop.HandleCraftBait(Config)
        Shop.HandleDailyClaim(Config)
        Spirits.HandleGodPray(Config)
        Quest.Tick(Config)
    end

    -- Character Cheats
    Character.ApplyNoclip(Config)
    Character.ApplyWalkOnWater(Config)
end)

State.AddConnection(heartbeatConn)

-- 4. Keybinds & Anti-AFK
Character.SetupAntiAFK()

local inputConn = Services.UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.UIKeybind then
        mainFrame.Visible = not mainFrame.Visible
    elseif input.KeyCode == Config.StopKeybind then
        State.UnloadScript()
    end
end)
State.AddConnection(inputConn)

-- 5. Đăng ký Global Unload hooks
local gEnv = (getgenv and getgenv()) or _G or shared
if gEnv then
    gEnv.HeavyweightFishingKill = function() State.UnloadScript() end
    gEnv.IdenticalHeavyweightFishingUnload = function() State.UnloadScript() end
end

Utils.ShowNotification("Identical Hub V2", "Khởi động thành công! Nhấn [RightControl] để ẩn/hiện menu.", "SUCCESS", 4)
