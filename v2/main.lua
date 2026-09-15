--[[
    v2/main.lua
    Identical Hub V2 - Heavyweight Fishing
    Rebuilt from backup.lua • 100% Original UI • Modular Architecture • Strict Sequential Combo
--]]

local Services = require(script.core.services)
local ConfigModule = require(script.core.config)
local Config = ConfigModule.Config
local State = require(script.core.state)
local Utils = require(script.core.utils)
local Theme = require(script.ui.theme)
local Window = require(script.ui.window)

-- Features & Combo
local StateMachine = require(script.combo.state_machine)
local Fishing = require(script.features.fishing)
local Boss = require(script.features.boss)
local Quest = require(script.features.quest)
local Spirits = require(script.features.spirits)
local Shop = require(script.features.shop)
local Teleport = require(script.features.teleport)
local Visuals = require(script.features.visuals)
local Character = require(script.features.character)

-- UI Tabs (Exact tabs from backup.lua - Wiki Tab Omitted!)
local TabCauCa = require(script.ui.tabs.tab_cau_ca)
local TabSanBoss = require(script.ui.tabs.tab_san_boss)
local TabThanLinh = require(script.ui.tabs.tab_than_linh)
local TabNhiemVu = require(script.ui.tabs.tab_nhiem_vu)
local TabShop = require(script.ui.tabs.tab_shop)
local TabDichChuyen = require(script.ui.tabs.tab_dich_chuyen)
local TabVisuals = require(script.ui.tabs.tab_visuals)
local TabNhanVat = require(script.ui.tabs.tab_nhan_vat)
local TabCaiDat = require(script.ui.tabs.tab_cai_dat)
local TabThuNghiem = require(script.ui.tabs.tab_thu_nghiem)

-- 1. Dọn dẹp bản cũ
Services.CleanOldInstances()

-- 2. Khởi tạo Giao diện chính (Exact Floating Avatar, TitleBar, Sidebar from backup.lua)
Window.Init(ConfigModule.SCRIPT_BUILD_COMMIT, function()
    Utils.ShowNotification("Diệt Script", "Đang đóng script hoàn toàn...", "WARN", 2)
    task.wait(0.2)
    State.UnloadScript()
end)

-- 3. Tạo các Tab chức năng (Không có Tab Wiki!)
local tabFishing      = Window.CreateTab("Câu Cá")
local tabBoss         = Window.CreateTab("Săn Boss")
local tabGod          = Window.CreateTab("Thần Linh")
local tabQuests       = Window.CreateTab("Nhiệm Vụ")
local tabShop         = Window.CreateTab("Shop & Chế Mồi")
local tabTeleports    = Window.CreateTab("Dịch Chuyển")
local tabVisuals      = Window.CreateTab("ESP & Đồ Hoạ")
local tabPlayer       = Window.CreateTab("Nhân Vật")
local tabProfiles     = Window.CreateTab("Cài Đặt")
local tabExperimental = Window.CreateTab("Thử Nghiệm")

-- 4. Render nội dung từng Tab
TabCauCa.Render(tabFishing)
TabSanBoss.Render(tabBoss)
TabThanLinh.Render(tabGod)
TabNhiemVu.Render(tabQuests)
TabShop.Render(tabShop)
TabDichChuyen.Render(tabTeleports)
TabVisuals.Render(tabVisuals)
TabNhanVat.Render(tabPlayer)
TabCaiDat.Render(tabProfiles)
TabThuNghiem.Render(tabExperimental)

-- Mặc định hiển thị Tab Câu Cá
Window.SwitchTab("Câu Cá")

-- 5. Nạp cấu hình đã lưu (SmartCombo & Boss Targets)
ConfigModule.LoadSmartComboAndSyncUI(State.UIControllers)
ConfigModule.LoadBossTargetsAndSyncUI(State.bossTogglesMap)

-- 6. Core Heartbeat Runtime Loop
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
        StateMachine.Step(Config, fUI, playerHp, State.ticketQuestState)
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

    -- Nhân Vật
    Character.ApplyNoclip(Config)
    Character.ApplyWalkOnWater(Config)
end)

State.AddConnection(heartbeatConn)

-- 7. Keybinds & Anti-AFK
Character.SetupAntiAFK()

local inputConn = Services.UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Config.UIKeybind then
        if Window.ToggleUiVisibility then Window.ToggleUiVisibility() end
    elseif input.KeyCode == Config.StopKeybind then
        State.UnloadScript()
    end
end)
State.AddConnection(inputConn)

-- 8. Global Unload Hooks
local gEnv = (getgenv and getgenv()) or _G or shared
if gEnv then
    gEnv.HeavyweightFishingKill = function() State.UnloadScript() end
    gEnv.IdenticalHeavyweightFishingUnload = function() State.UnloadScript() end
end

Utils.ShowNotification("CÂU CÁ PRO", "Khởi động thành công! Nhấn [Right-Control] hoặc Avatar để ẩn/hiện menu.", "SUCCESS", 4)
