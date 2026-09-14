--[[
    v2/ui/tabs/tab_combo.lua
    Tab 2: Combo Chiêu (Smart Combo Engine V2 - Dedicated Tab)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local StateMachine = require(script.Parent.Parent.Parent.combo.state_machine)
local Theme = require(script.Parent.Parent.theme)

local TabCombo = {}

function TabCombo.Render(parent, config)
    -- Section 1: Kích Hoạt & Cài Đặt Chuỗi Chiêu
    Components.CreateCategoryHeader(parent, "Chuỗi Combo Tuần Tự Nghiêm Ngặt (Strict Rotation)")
    local cardCombo = Components.CreateCardGroup(parent)

    State.UIControllers["SmartComboEnabled"] = Components.CreateToggleRow(cardCombo, "Kích Hoạt Smart Combo V2", "Tự động xả chiêu theo đúng 100% thứ tự đã cài đặt khi minigame bắt đầu", config.SmartComboEnabled, function(v)
        config.SmartComboEnabled = v
    end)

    -- Hiển thị xem trước chuỗi chiêu
    local previewInfo = Components.CreateInfoRow(cardCombo, "Chuỗi Chiêu Hiện Tại", StateMachine.GetComboPreview(config.LoopSkills))
    local statusInfo = Components.CreateInfoRow(cardCombo, "Trạng Thái Ra Chiêu", StateMachine.GetCurrentStatus(config))

    local function updatePreview()
        previewInfo.Set(StateMachine.GetComboPreview(config.LoopSkills))
        statusInfo.Set(StateMachine.GetCurrentStatus(config))
    end

    -- Section 2: Chọn Nhanh Các Preset Combo Phổ Biến
    Components.CreateCategoryHeader(parent, "Cài Đặt Nhanh Chuỗi Chiêu (Preset)")
    local cardPresets = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardPresets, "Combo Chuẩn [Z, X, V]", "Đánh Z ➔ X ➔ V lặp lại", "Chọn [Z, X, V]", function()
        config.LoopSkills = "Z, X, V"
        updatePreview()
    end)

    Components.CreateButtonRow(cardPresets, "Combo 2 Chiêu [Z, X]", "Đánh Z ➔ X lặp lại", "Chọn [Z, X]", function()
        config.LoopSkills = "Z, X"
        updatePreview()
    end)

    Components.CreateButtonRow(cardPresets, "Combo Đảo Chiêu [X, C, Z]", "Đánh X ➔ C ➔ Z lặp lại", "Chọn [X, C, Z]", function()
        config.LoopSkills = "X, C, Z"
        updatePreview()
    end)

    Components.CreateButtonRow(cardPresets, "Combo Toàn Diện [Z, X, C, V]", "Đánh đủ 4 chiêu Z ➔ X ➔ C ➔ V", "Chọn [Z, X, C, V]", function()
        config.LoopSkills = "Z, X, C, V"
        updatePreview()
    end)

    -- Phím ghép chiêu thủ công
    local quickBox = Instance.new("Frame")
    quickBox.Size = UDim2.new(1, 0, 0, 36)
    quickBox.BackgroundColor3 = Theme.RowBg
    quickBox.BorderSizePixel = 0

    local qCorner = Instance.new("UICorner")
    qCorner.CornerRadius = UDim.new(0, 6)
    qCorner.Parent = quickBox

    local qLayout = Instance.new("UIListLayout")
    qLayout.FillDirection = Enum.FillDirection.Horizontal
    qLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    qLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    qLayout.Padding = UDim.new(0, 8)
    qLayout.Parent = quickBox

    local function makeKeyBtn(txt, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 52, 0, 26)
        btn.BackgroundColor3 = Theme.CardBg
        btn.Text = txt
        btn.TextColor3 = Theme.Accent
        btn.Font = Theme.FontBold
        btn.TextSize = 12
        btn.Parent = quickBox

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 4)
        bc.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if key == "CLEAR" then
                config.LoopSkills = ""
            else
                local current = config.LoopSkills or ""
                if current == "" then
                    config.LoopSkills = key
                else
                    config.LoopSkills = current .. ", " .. key
                end
            end
            updatePreview()
        end)
    end

    makeKeyBtn("+ Z", "Z")
    makeKeyBtn("+ X", "X")
    makeKeyBtn("+ C", "C")
    makeKeyBtn("+ V", "V")
    makeKeyBtn("XÓA", "CLEAR")

    quickBox.Parent = cardPresets

    -- Section 3: Tinh Chỉnh Nhịp Trễ & Cứu Nguy
    Components.CreateCategoryHeader(parent, "Tinh Chỉnh Nhịp Trễ & Cứu Nguy")
    local cardTiming = Components.CreateCardGroup(parent)

    State.UIControllers["SkillEffectDelay"] = Components.CreateSliderRow(cardTiming, "Khoảng Cách Ra Chiêu (Delay)", "Thời gian chờ giữa 2 chiêu liên tiếp (tránh nuốt chiêu)", 0.5, 3.0, config.SkillEffectDelay, true, "s", function(v)
        config.SkillEffectDelay = v
    end)

    State.UIControllers["SmartEffectAutoDetect"] = Components.CreateToggleRow(cardTiming, "Chờ Hoạt Ảnh Nhân Vật Hoàn Tất", "Tự động phát hiện chiêu đang thi triển và chờ xong mới ra chiêu tiếp", config.SmartEffectAutoDetect, function(v)
        config.SmartEffectAutoDetect = v
    end)

    State.UIControllers["EmergencyHealHp"] = Components.CreateSliderRow(cardTiming, "Ngưỡng Máu Cứu Nguy Khẩn Cấp", "Máu tụt dưới mức này sẽ ưu tiên tung chiêu hồi máu", 10, 90, config.EmergencyHealHp, false, "%", function(v)
        config.EmergencyHealHp = v
    end)

    -- Section 4: Luyện Chiêu (Train Skill)
    Components.CreateCategoryHeader(parent, "Luyện Chiêu Độc Lập (Train Skill)")
    local cardTrain = Components.CreateCardGroup(parent)

    State.UIControllers["AutoTrainSkill"] = Components.CreateToggleRow(cardTrain, "Tự Động Luyện Chiêu", "Spam chiêu chọn sẵn và tự hủy cần để cày điểm chiêu thức", config.AutoTrainSkill, function(v)
        config.AutoTrainSkill = v
    end)

    State.UIControllers["TrainTargetCount"] = Components.CreateSliderRow(cardTrain, "Mục Tiêu Số Lần Dùng", "Tự động tắt khi đạt đủ số lần", 10, 500, config.TrainTargetCount, false, " lần", function(v)
        config.TrainTargetCount = v
    end)
end

return TabCombo
