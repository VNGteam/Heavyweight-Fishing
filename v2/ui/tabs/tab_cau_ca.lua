--[[
    v2/ui/tabs/tab_cau_ca.lua
    Exact Tab Câu Cá from backup.lua (Stats, Core AutoCast, Home Spot, Smart Combo, Train Skill, Bait/Rod, Sell, Octo)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local StateMachine = require(script.Parent.Parent.Parent.combo.state_machine)
local Theme = require(script.Parent.Parent.theme)
local Utils = require(script.Parent.Parent.Parent.core.utils)

local Services = require(script.Parent.Parent.Parent.core.services)

local TabCauCa = {}

function TabCauCa.Render(parent)
    -- Section 1: Thống Kê Tài Khoản (Lưới 3 cột x 4 hàng)
    Components.CreateCategoryHeader(parent, "Thông Tin Tài Khoản & Thống Kê")
    local statsCard = Components.CreateCardGroup(parent)

    local statsGridContainer = Instance.new("Frame")
    statsGridContainer.Name = "StatsGridContainer"
    statsGridContainer.Size = UDim2.new(1, 0, 0, 0)
    statsGridContainer.AutomaticSize = Enum.AutomaticSize.Y
    statsGridContainer.BackgroundTransparency = 1
    statsGridContainer.BorderSizePixel = 0
    statsGridContainer.Parent = statsCard

    local gridPadding = Instance.new("UIPadding")
    gridPadding.PaddingTop = UDim.new(0, 8)
    gridPadding.PaddingBottom = UDim.new(0, 8)
    gridPadding.PaddingLeft = UDim.new(0, 8)
    gridPadding.PaddingRight = UDim.new(0, 8)
    gridPadding.Parent = statsGridContainer

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.CellSize = UDim2.new(1/3, -4, 0, 46)
    gridLayout.Parent = statsGridContainer

    local infoEquippedRod        = Components.CreateStatGridTile(statsGridContainer, "🎣 Cần Đang Dùng", "Chưa có", Theme.TextWhite, 1)
    local infoEquippedBait       = Components.CreateStatGridTile(statsGridContainer, "🪱 Mồi Đang Dùng", "Chưa có", Theme.TextWhite, 2)
    local infoCurrentLocation    = Components.CreateStatGridTile(statsGridContainer, "📍 Map Đang Đứng", "Đang nhận diện...", Theme.AccentBlue, 3)

    local infoUptime             = Components.CreateStatGridTile(statsGridContainer, "⏳ Thời Gian Treo", "00:00:00", Theme.AccentYellow, 4)
    local infoFishCaught         = Components.CreateStatGridTile(statsGridContainer, "🐟 Tổng Cá Đã Câu", "0 con", Theme.PurplePrimary, 5)
    local infoFishPerHour        = Components.CreateStatGridTile(statsGridContainer, "⚡ Tốc Độ Câu", "0 con/h", Theme.AccentGreen, 6)

    local infoCash               = Components.CreateStatGridTile(statsGridContainer, "💰 Tiền Hiện Tại", "$0", Theme.AccentGreen, 7)
    local infoCashPerHour        = Components.CreateStatGridTile(statsGridContainer, "📈 Tốc Độ Tiền", "$0 /h", Theme.AccentGreen, 8)
    local infoGemsGained         = Components.CreateStatGridTile(statsGridContainer, "💎 Gems Đã Kiếm", "+0 Gems", Theme.AccentBlue, 9)

    local infoTickets            = Components.CreateStatGridTile(statsGridContainer, "🎫 Vé Nhiệm Vụ", "0 Vé", Theme.AccentOrange, 10)
    local infoEssenceOrbs        = Components.CreateStatGridTile(statsGridContainer, "🔮 Essence Orb", "0 Viên", Theme.PurpleAccent, 11)
    local infoTraitRerolls       = Components.CreateStatGridTile(statsGridContainer, "🎲 Trait Reroll", "0 Vé", Theme.AccentYellow, 12)

    local infoTicketQuestsToday  = Components.CreateStatGridTile(statsGridContainer, "📜 Vé Xong Hôm Nay", "0 NV", Theme.AccentOrange, 13)
    local infoBackpack           = Components.CreateStatGridTile(statsGridContainer, "🎒 Sức Chứa Balo", "0 / 100", Theme.TextWhite, 14)
    local infoTicketCooldown     = Components.CreateStatGridTile(statsGridContainer, "⏳ Chờ Vé Mới", "Sẵn sàng", Theme.AccentYellow, 15)

    Components.CreateButtonRow(statsCard, "Đặt Lại Thông Số Treo (Reset AFK)", "Đặt lại giờ treo và tính lại tốc độ cá/tiền chính xác từ mốc này", "🔄 Reset Thông Số", function()
        local pData = Services.ReplicatedStorage:FindFirstChild("Data") and Services.ReplicatedStorage.Data:FindFirstChild(Services.LocalPlayer.UserId)
        local curFish = pData and pData:FindFirstChild("FishCaught") and tonumber(pData.FishCaught.Value) or 0
        local curCash = pData and pData:FindFirstChild("Cash") and tonumber(pData.Cash.Value) or 0

        State.sessionStartTime = tick()
        State.initialFishCaught = curFish
        State.initialCash = curCash
        State.gemTracker.gained = 0

        if infoUptime and infoUptime.Set then infoUptime.Set("00:00:00") end
        if infoFishPerHour and infoFishPerHour.Set then infoFishPerHour.Set("0 con/h") end
        if infoCashPerHour and infoCashPerHour.Set then infoCashPerHour.Set("$0 /h") end
        if infoGemsGained and infoGemsGained.Set then infoGemsGained.Set("+0 Gems") end

        Components.ShowNotification("Thống Kê Treo", "Đã đặt lại mốc thời gian và tính lại tốc độ câu/tiền từ thời điểm này!", "SUCCESS", 4)
    end)

    -- Section 2: Tự Động Câu Cá Cốt Lõi
    Components.CreateCategoryHeader(parent, "Tự Động Câu Cá Cốt Lõi")
    local fishCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(fishCard, "Tự Động Quăng Cần (Auto Cast)", "Tự động bắt đầu câu và quăng cần liên tục", Config.AutoCast, function(v) Config.AutoCast = v end)
    Components.CreateSliderRow(fishCard, "Độ Trễ Quăng Cần", "Thời gian giãn cách giữa các lần quăng", 0.0, 5.0, Config.CastDelay, true, "s", function(v) Config.CastDelay = v end)
    Components.CreateToggleRow(fishCard, "Giữ Thanh Minigame (Anchor Bar)", "Tự động giữ thanh kéo ở giữa để bắt cá 100%", Config.AnchorBar, function(v) Config.AnchorBar = v end)
    Components.CreateToggleRow(fishCard, "Tự Dùng Kỹ Năng Cần", "Tự kích hoạt kỹ năng cần câu để kéo cá siêu nhanh", Config.AutoSkills, function(v) Config.AutoSkills = v end)
    Components.CreateToggleRow(fishCard, "Tự Động Đập Cần (Auto Slam)", "Tự động nhấn Slam mức Perfect khi xuất hiện", Config.AutoSlam, function(v) Config.AutoSlam = v end)
    Components.CreateToggleRow(fishCard, "Tự Động Sạc Dây (Auto Charge)", "Tự động sạc đầy 100% độ bền dây câu", Config.AutoCharge, function(v) Config.AutoCharge = v end)
    Components.CreateToggleRow(fishCard, "Tự Động Chống Kẹt Cần (Anti-Stuck)", "Tự động phát hiện và gỡ kẹt khi quăng cần hoặc minigame bị đơ quá 15s", Config.AntiStuckEnabled, function(v) Config.AntiStuckEnabled = v end)

    -- Section 3: Vị Trí Trở Về (Home Spot)
    Components.CreateCategoryHeader(parent, "🏠 Vị Trí Trở Về Nếu Săn Boss (Home Spot)")
    local returnSpotCard = Components.CreateCardGroup(parent)
    local infoHomeSpot = Components.CreateInfoRow(returnSpotCard, "Vị Trí Đã Lưu", "Chưa lưu vị trí nào")

    Components.CreateButtonRow(returnSpotCard, "Lưu Vị Trí Đang Đứng", "Lưu tọa độ hiện tại làm điểm quay về", "Lưu Vị Trí", function()
        local char = Services.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Config.HomeFarmSpot = {
                x = root.Position.X,
                y = root.Position.Y,
                z = root.Position.Z,
                cframe = { root.CFrame:GetComponents() },
                savedAt = os.date("%H:%M:%S")
            }
            infoHomeSpot.Set(string.format("Đã lưu: X:%.1f, Y:%.1f, Z:%.1f (%s)", root.Position.X, root.Position.Y, root.Position.Z, Config.HomeFarmSpot.savedAt))
            Utils.ShowNotification("Vị Trí Trở Về", "Đã lưu vị trí trở về thành công!", "SUCCESS", 4)
        end
    end)

    Components.CreateButtonRow(returnSpotCard, "Bay Về Điểm Trở Về Ngay", "Dịch chuyển tức thì về vị trí đã lưu", "Bay Về", function()
        if Config.HomeFarmSpot and Config.HomeFarmSpot.cframe then
            local char = Services.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(table.unpack(Config.HomeFarmSpot.cframe))
                Utils.ShowNotification("Vị Trí Trở Về", "Đã bay về vị trí trở về!", "SUCCESS", 3)
            end
        else
            Utils.ShowNotification("Chưa Lưu Vị Trí", "Vui lòng bấm [Lưu Vị Trí] trước!", "WARN", 4)
        end
    end)

    -- Section 4: Smart Combos V2 (Rebuilt from Scratch)
    Components.CreateCategoryHeader(parent, "⚔️ Combo Kỹ Năng Thông Minh (Smart Combos V2)")
    local comboCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(comboCard, "Bật Combo Kỹ Năng Tự Động", "Tự động kích hoạt chiêu theo đúng thứ tự khi câu cá", Config.SmartComboEnabled, function(v)
        Config.SmartComboEnabled = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateSliderRow(comboCard, "Ngưỡng Máu Cá Phân Loại", "Máu cá <= mức này sẽ kết liễu nhanh; > mức này bật combo", 100, 3000, Config.FishHpThreshold, false, " HP", function(v)
        Config.FishHpThreshold = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateDropdownRow(comboCard, "Chiêu Bắt Nhanh (<= Ngưỡng HP)", "Tung 1 hit kết liễu khi cá yếu / cá thường", {"Tắt", "Z", "X", "C", "V"}, Config.QuickCatchSkill, function(v)
        Config.QuickCatchSkill = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateDropdownRow(comboCard, "Chiêu Mở Màn (> Ngưỡng HP)", "Chiêu tung đầu trận khi gặp cá to / boss", {"Tắt", "Z", "X", "C", "V"}, Config.OpenerSkill, function(v)
        Config.OpenerSkill = v
        ConfigModule.SaveSmartCombo()
    end)

    local loopPresets = {
        "Tùy Biến (Tự Do)",
        "Z, X, V (Chuẩn)",
        "Z, X (2 Chiêu Nhanh)",
        "X, C, Z (Đảo Chiêu)",
        "Z, X, C, V (Chuỗi Đầy Đủ)",
        "X, C, V (Dồn Sát Thương)",
        "C, V (Bộ Chiêu Cuối)"
    }

    local customInput = nil
    local presetDropdown = nil
    local infoPreview = nil

    local function applyComboChange(newVal, source)
        local keys = {}
        for k in string.gmatch(newVal or "", "([ZXCVzxcv])") do
            table.insert(keys, k:upper())
        end
        local cleanStr = table.concat(keys, ", ")
        Config.LoopSkills = cleanStr
        ConfigModule.SaveSmartCombo()

        if source ~= "input" and customInput and customInput.Set then
            customInput.Set(cleanStr)
        end
        if infoPreview and infoPreview.Set then
            infoPreview.Set(StateMachine.GetComboPreview(cleanStr))
        end
    end

    presetDropdown = Components.CreateDropdownRow(comboCard, "Mẫu Chuỗi Chiêu (Preset)", "Chọn nhanh chuỗi phổ biến hoặc tùy biến ở dưới", loopPresets, "Z, X, V (Chuẩn)", function(v)
        local raw = v:match("^([ZXCVzxcv,%s]+)")
        if raw and raw ~= "Tùy Biến (Tự Do)" then
            applyComboChange(raw, "dropdown")
        end
    end)

    customInput = Components.CreateInputRow(comboCard, "Tùy Biến Chuỗi Đảo Chiêu", "Gõ bất kỳ chiêu nào (VD: Z, X, V hoặc X, C, Z...)", Config.LoopSkills or "Z, X, V", function(v)
        applyComboChange(v, "input")
    end, nil, "VD: Z, X, V")

    -- Bàn phím tạo combo nhanh 1 chạm (+Z, +X, +C, +V, ⌫, 🗑)
    local quickRow = Components.CreateBaseRow(comboCard, "Bộ Phím Ghép Combo Nhanh", "Chạm các nút để thêm hoặc xóa nhanh chiêu vào chuỗi combo")
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 190, 0, 24)
    btnContainer.Position = UDim2.new(1, -190, 0.5, -12)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = quickRow

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = btnContainer

    local function makeQuickBtn(text, bgColor, textColor, onClick)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 28, 0, 24)
        btn.BackgroundColor3 = bgColor
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextColor3 = textColor
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = btnContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() pcall(onClick) end)
        return btn
    end

    local function appendKey(k)
        local current = Config.LoopSkills or ""
        local keys = {}
        for char in string.gmatch(current, "([ZXCVzxcv])") do table.insert(keys, char:upper()) end
        table.insert(keys, k:upper())
        applyComboChange(table.concat(keys, ", "), "quickbtn")
    end

    makeQuickBtn("+Z", Theme.ControlBg, Theme.PurplePrimary, function() appendKey("Z") end)
    makeQuickBtn("+X", Theme.ControlBg, Theme.PurplePrimary, function() appendKey("X") end)
    makeQuickBtn("+C", Theme.ControlBg, Theme.PurplePrimary, function() appendKey("C") end)
    makeQuickBtn("+V", Theme.ControlBg, Theme.PurplePrimary, function() appendKey("V") end)
    makeQuickBtn("⌫", Color3.fromRGB(45, 25, 30), Color3.fromRGB(255, 120, 120), function()
        local current = Config.LoopSkills or ""
        local keys = {}
        for char in string.gmatch(current, "([ZXCVzxcv])") do table.insert(keys, char:upper()) end
        if #keys > 0 then table.remove(keys, #keys) end
        applyComboChange(table.concat(keys, ", "), "quickbtn")
    end)
    makeQuickBtn("🗑", Color3.fromRGB(35, 35, 40), Theme.TextMuted, function()
        applyComboChange("", "quickbtn")
    end)

    infoPreview = Components.CreateInfoRow(comboCard, "Thứ Tự Thi Triển Thực Tế", StateMachine.GetComboPreview(Config.LoopSkills))

    Components.CreateToggleRow(comboCard, "Giữ Đúng Thứ Tự Combo (Strict Order)", "Chờ chiêu hồi theo đúng nhịp thứ tự, không nhảy cóc qua chiêu khác", Config.LoopStrictOrder, function(v)
        Config.LoopStrictOrder = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateDropdownRow(comboCard, "Chiêu Hồi Máu / Cứu Nguy", "Ưu tiên tung chiêu này khi máu người chơi xuống thấp", {"Tắt", "Z", "X", "C", "V"}, Config.EmergencyHealSkill, function(v)
        Config.EmergencyHealSkill = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateSliderRow(comboCard, "Kích Hoạt Hồi Máu Khi HP Dưới", "Ngưỡng máu người chơi cần cứu nguy", 10, 80, Config.EmergencyHealHp, false, "%", function(v)
        Config.EmergencyHealHp = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateSliderRow(comboCard, "Thời Gian Chờ Ra Chiêu", "Thời gian tối thiểu chờ hết hiệu ứng trước khi tung chiêu tiếp theo", 0.5, 3.5, Config.SkillEffectDelay, true, "s", function(v)
        Config.SkillEffectDelay = v
        ConfigModule.SaveSmartCombo()
    end)

    Components.CreateToggleRow(comboCard, "Tự Động Nhận Diện Hết Hiệu Ứng", "Quan sát hoạt ảnh đòn đánh trên nhân vật để chống nuốt chiêu", Config.SmartEffectAutoDetect, function(v)
        Config.SmartEffectAutoDetect = v
        ConfigModule.SaveSmartCombo()
    end)

    -- Section 5: Auto Luyện Chiêu
    Components.CreateCategoryHeader(parent, "🎯 Auto Luyện Chiêu Nhanh (Fast Cancel)")
    local trainCard = Components.CreateCardGroup(parent)
    local infoTrainProgress = Components.CreateInfoRow(trainCard, "Tiến Độ Luyện Chiêu", string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount))

    Components.CreateToggleRow(trainCard, "Bật Auto Luyện Chiêu", "Cá cắn kéo là dùng chiêu -> cất cần hủy cá -> thả cần lại ngay", Config.AutoTrainSkill, function(v) Config.AutoTrainSkill = v end)
    Components.CreateDropdownRow(trainCard, "Chọn Chiêu Cần Luyện", "Chọn 1 chiêu duy nhất muốn luyện", {"Z", "X", "C", "V"}, Config.TrainSkill or "Z", function(v) Config.TrainSkill = v end)
    Components.CreateSliderRow(trainCard, "Nhịp Chờ Xuất Chiêu (Cancel Delay)", "Thời gian chờ nhân vật bắt đầu xuất chiêu trước khi cất cần", 0.2, 1.2, Config.TrainCancelDelay or 0.45, true, "s", function(v) Config.TrainCancelDelay = v end)
    Components.CreateSliderRow(trainCard, "Mục Tiêu Số Lần Dùng", "Số lần cần dùng để đạt yêu cầu tiến hóa", 10, 500, Config.TrainTargetCount, false, " lần", function(v)
        Config.TrainTargetCount = v
        if infoTrainProgress and infoTrainProgress.Set then
            infoTrainProgress.Set(string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount))
        end
    end)

    -- Section 6: Trang Bị Mồi & Cần
    Components.CreateCategoryHeader(parent, "Trang Bị Mồi & Cần Câu")
    local loadoutCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(loadoutCard, "Tự Động Trang Bị Cần Tốt Nhất", "Tự động cầm cần câu có lực kéo lớn nhất trong túi", Config.AutoEquipBestRod, function(v) Config.AutoEquipBestRod = v end)
    Components.CreateToggleRow(loadoutCard, "Tự Động Trang Bị Mồi", "Tự động lắp mồi khi câu", Config.AutoEquipBestBait, function(v) Config.AutoEquipBestBait = v end)
    Components.CreateToggleRow(loadoutCard, "Tự Đổi Mồi Khi Săn Boss", "Tự động đổi mồi đặc biệt khi phát hiện Boss", Config.AutoEquipBossBait, function(v) Config.AutoEquipBossBait = v end)
    Components.CreateToggleRow(loadoutCard, "Tự Động Trang Bị Pháp Bảo Tốt Nhất", "Tự động trang bị ngọc/pháp bảo tốt nhất", Config.AutoEquipBestOrb, function(v) Config.AutoEquipBestOrb = v end)

    -- Section 7: Bán Cá & Minigame
    Components.CreateCategoryHeader(parent, "Bán Cá & Minigame Phụ")
    local miscCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(miscCard, "Tự Động Bán Cá Khi Đầy Túi", "Tự động bán cá theo chu kỳ", Config.AutoSell, function(v) Config.AutoSell = v end)
    Components.CreateSliderRow(miscCard, "Giãn Cách Bán Cá Tự Động", "Khoảng thời gian giữa 2 lần bán", 10, 120, Config.SellInterval, false, "s", function(v) Config.SellInterval = v end)
    Components.CreateToggleRow(miscCard, "Tự Đánh Nhịp Octo (Rhythm Hit)", "Tự hoàn thành minigame nhịp điệu của bạch tuộc", Config.OctoAutoMinigame, function(v) Config.OctoAutoMinigame = v end)
end

return TabCauCa
