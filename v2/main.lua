--[[
    v2/main.lua
    Identical Hub V2 - Heavyweight Fishing
    100% Feature Parity with Modular V2 Architecture • Strict Sequential Combo
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
local BossDps = require(script.features.boss_dps)
local Quest = require(script.features.quest)
local Spirits = require(script.features.spirits)
local Shop = require(script.features.shop)
local Weather = require(script.features.weather)
local Spoof = require(script.features.spoof)
local Teleport = require(script.features.teleport)
local Visuals = require(script.features.visuals)
local Character = require(script.features.character)

-- UI Tabs
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

-- 2. Khởi tạo Giao diện chính
Window.Init(ConfigModule.SCRIPT_BUILD_COMMIT, function()
    Utils.ShowNotification("Diệt Script", "Đang đóng script hoàn toàn...", "WARN", 2)
    task.wait(0.2)
    State.UnloadScript()
end)

-- Khởi tạo Widget Sát Thương Boss (% HP)
BossDps.Init(Window.screenGui)

-- 3. Tạo các Tab chức năng
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

-- 5. Nạp cấu hình đã lưu
ConfigModule.LoadSmartComboAndSyncUI(State.UIControllers)
ConfigModule.LoadBossTargetsAndSyncUI(State.bossTogglesMap)

-- 6. Khởi động các Watcher & Trình nạp phục hồi khi chuyển server (Hop Recovery)
Shop.InitInventoryWatcher(Config)
Weather.CheckWeatherHopOnJoin(Config)
Spirits.CheckNPCHopOnJoin(Config)

-- Lắng nghe tin nhắn chat để săn Secret Boss
pcall(function()
    local TextChatService = game:GetService("TextChatService")
    if TextChatService and TextChatService:FindFirstChild("MessageReceived") then
        local conn = TextChatService.MessageReceived:Connect(function(textChatMessage)
            if not State.isRunning then return end
            if textChatMessage and textChatMessage.Text then
                Boss.HandleChatMessage(textChatMessage.Text, Config)
            end
        end)
        State.AddConnection(conn)
    end
end)

pcall(function()
    local chatEvents = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering") then
        local conn = chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
            if not State.isRunning then return end
            if data and data.Message then
                Boss.HandleChatMessage(tostring(data.Message), Config)
            end
        end)
        State.AddConnection(conn)
    end
end)

-- Vòng lặp cập nhật Widget Sát Thương Boss (% HP)
task.spawn(function()
    while State.isRunning do
        pcall(function() BossDps.Update(Config) end)
        task.wait(0.15)
    end
end)

-- Vòng lặp kiểm tra định kỳ (Spirits, Weather, Quests, Auto-Hop)
task.spawn(function()
    while State.isRunning do
        task.wait(1.5)
        pcall(function() Spirits.Tick(Config) end)
        pcall(function() Weather.Tick(Config) end)
    end
end)

-- 7. Core Heartbeat Runtime Loop
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
        Shop.HandleGacha(Config)
        Spirits.HandleGodPray(Config)
        Quest.Tick(Config)
    end

    -- Nhân Vật
    Character.ApplyNoclip(Config)
    Character.ApplyWalkOnWater(Config)
end)

State.AddConnection(heartbeatConn)

-- 8. Keybinds & Anti-AFK
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

-- 9. Global Unload Hooks
local gEnv = (getgenv and getgenv()) or _G or shared
if gEnv then
    gEnv.HeavyweightFishingKill = function() State.UnloadScript() end
    gEnv.IdenticalHeavyweightFishingUnload = function() State.UnloadScript() end
end

Utils.ShowNotification("CÂU CÁ PRO", "Khởi động thành công V2! Nhấn [Right-Control] hoặc Avatar để ẩn/hiện menu.", "SUCCESS", 4)
