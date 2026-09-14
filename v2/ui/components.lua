--[[
    v2/ui/components.lua
    Modular UI Toolkit: Cards, Toggles, Sliders, Dropdowns, Buttons, Inputs
--]]

local Services = require(script.Parent.Parent.core.services)
local TweenService = Services.TweenService
local Theme = require(script.Parent.theme)
local State = require(script.Parent.Parent.core.state)

local Components = {}

-- 1. Category Header
function Components.CreateCategoryHeader(parent, text)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Text = string.upper(text or "")
    header.TextColor3 = Theme.Accent
    header.Font = Theme.FontBold
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = parent
    return header
end

-- 2. Card Group
function Components.CreateCardGroup(parent)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Theme.CardBg
    card.BorderSizePixel = 0

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 8)
    uic.Parent = card

    local uis = Instance.new("UIStroke")
    uis.Color = Theme.Border
    uis.Thickness = 1
    uis.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = card

    card.Parent = parent
    return card
end

-- 3. Collapsible Card Group
function Components.CreateCollapsibleCardGroup(parent, text, defaultOpen)
    local isOpen = defaultOpen ~= false

    local outer = Instance.new("Frame")
    outer.Size = UDim2.new(1, 0, 0, 0)
    outer.AutomaticSize = Enum.AutomaticSize.Y
    outer.BackgroundColor3 = Theme.CardBg
    outer.BorderSizePixel = 0

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 8)
    uic.Parent = outer

    local uis = Instance.new("UIStroke")
    uis.Color = Theme.Border
    uis.Thickness = 1
    uis.Parent = outer

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = outer

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = text or ""
    titleLbl.TextColor3 = Theme.TextPrimary
    titleLbl.Font = Theme.FontBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local arrowLbl = Instance.new("TextLabel")
    arrowLbl.Size = UDim2.new(0, 24, 1, 0)
    arrowLbl.Position = UDim2.new(1, -30, 0, 0)
    arrowLbl.BackgroundTransparency = 1
    arrowLbl.Text = isOpen and "▼" or "▶"
    arrowLbl.TextColor3 = Theme.Accent
    arrowLbl.Font = Theme.FontBold
    arrowLbl.TextSize = 12
    arrowLbl.Parent = headerBtn

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 36)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = isOpen

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = contentFrame

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop = UDim.new(0, 4)
    contentPad.PaddingBottom = UDim.new(0, 8)
    contentPad.PaddingLeft = UDim.new(0, 10)
    contentPad.PaddingRight = UDim.new(0, 10)
    contentPad.Parent = contentFrame

    contentFrame.Parent = outer

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        contentFrame.Visible = isOpen
        arrowLbl.Text = isOpen and "▼" or "▶"
    end)

    outer.Parent = parent
    return contentFrame
end

-- 4. Toggle Row
function Components.CreateToggleRow(parent, labelText, descText, initialVal, callback)
    local stateVal = initialVal == true

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, descText and 44 or 34)
    row.BackgroundColor3 = Theme.RowBg
    row.BorderSizePixel = 0

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 6)
    uic.Parent = row

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -60, 0, 20)
    tLabel.Position = UDim2.new(0, 8, 0, descText and 4 or 7)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText or ""
    tLabel.TextColor3 = Theme.TextPrimary
    tLabel.Font = Theme.FontMedium
    tLabel.TextSize = 13
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = row

    if descText then
        local tDesc = Instance.new("TextLabel")
        tDesc.Size = UDim2.new(1, -60, 0, 16)
        tDesc.Position = UDim2.new(0, 8, 0, 24)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = descText
        tDesc.TextColor3 = Theme.TextMuted
        tDesc.Font = Theme.FontRegular
        tDesc.TextSize = 11
        tDesc.TextXAlignment = Enum.TextXAlignment.Left
        tDesc.Parent = row
    end

    local switchBox = Instance.new("TextButton")
    switchBox.Size = UDim2.new(0, 42, 0, 22)
    switchBox.Position = UDim2.new(1, -50, 0.5, -11)
    switchBox.BackgroundColor3 = stateVal and Theme.Accent or Theme.CardBg
    switchBox.Text = ""
    switchBox.Parent = row

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = switchBox

    local sKnob = Instance.new("Frame")
    sKnob.Size = UDim2.new(0, 16, 0, 16)
    sKnob.Position = stateVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    sKnob.BackgroundColor3 = Theme.TextPrimary
    sKnob.BorderSizePixel = 0
    sKnob.Parent = switchBox

    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1, 0)
    kCorner.Parent = sKnob

    local function updateVisual(val)
        stateVal = val
        switchBox.BackgroundColor3 = stateVal and Theme.Accent or Theme.CardBg
        sKnob.Position = stateVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    end

    switchBox.MouseButton1Click:Connect(function()
        stateVal = not stateVal
        updateVisual(stateVal)
        if callback then callback(stateVal) end
    end)

    row.Parent = parent

    local controller = {
        frame = row,
        Set = function(val, skipCallback)
            updateVisual(val == true)
            if not skipCallback and callback then callback(stateVal) end
        end,
        Get = function()
            return stateVal
        end
    }

    return controller
end

-- 5. Button Row
function Components.CreateButtonRow(parent, labelText, descText, btnText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, descText and 44 or 34)
    row.BackgroundColor3 = Theme.RowBg
    row.BorderSizePixel = 0

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 6)
    uic.Parent = row

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -110, 0, 20)
    tLabel.Position = UDim2.new(0, 8, 0, descText and 4 or 7)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText or ""
    tLabel.TextColor3 = Theme.TextPrimary
    tLabel.Font = Theme.FontMedium
    tLabel.TextSize = 13
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = row

    if descText then
        local tDesc = Instance.new("TextLabel")
        tDesc.Size = UDim2.new(1, -110, 0, 16)
        tDesc.Position = UDim2.new(0, 8, 0, 24)
        tDesc.BackgroundTransparency = 1
        tDesc.Text = descText
        tDesc.TextColor3 = Theme.TextMuted
        tDesc.Font = Theme.FontRegular
        tDesc.TextSize = 11
        tDesc.TextXAlignment = Enum.TextXAlignment.Left
        tDesc.Parent = row
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 95, 0, 24)
    btn.Position = UDim2.new(1, -103, 0.5, -12)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = btnText or "Thực Hiện"
    btn.TextColor3 = Theme.TextPrimary
    btn.Font = Theme.FontBold
    btn.TextSize = 12
    btn.Parent = row

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    row.Parent = parent
    return { frame = row, button = btn }
end

-- 6. Info Row
function Components.CreateInfoRow(parent, labelText, valueText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Theme.RowBg
    row.BorderSizePixel = 0

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 6)
    uic.Parent = row

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(0.5, -8, 1, 0)
    tLabel.Position = UDim2.new(0, 8, 0, 0)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText or ""
    tLabel.TextColor3 = Theme.TextSecondary
    tLabel.Font = Theme.FontMedium
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = row

    local vLabel = Instance.new("TextLabel")
    vLabel.Size = UDim2.new(0.5, -8, 1, 0)
    vLabel.Position = UDim2.new(0.5, 0, 0, 0)
    vLabel.BackgroundTransparency = 1
    vLabel.Text = valueText or ""
    vLabel.TextColor3 = Theme.Accent
    vLabel.Font = Theme.FontBold
    vLabel.TextSize = 12
    vLabel.TextXAlignment = Enum.TextXAlignment.Right
    vLabel.Parent = row

    row.Parent = parent

    return {
        frame = row,
        Set = function(newVal)
            vLabel.Text = tostring(newVal or "")
        end
    }
end

-- 7. Slider Row
function Components.CreateSliderRow(parent, labelText, descText, minVal, maxVal, initialVal, isFloat, suffix, callback)
    local currentVal = initialVal or minVal
    suffix = suffix or ""

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Theme.RowBg
    row.BorderSizePixel = 0

    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 6)
    uic.Parent = row

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(0.7, 0, 0, 18)
    tLabel.Position = UDim2.new(0, 8, 0, 4)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = labelText or ""
    tLabel.TextColor3 = Theme.TextPrimary
    tLabel.Font = Theme.FontMedium
    tLabel.TextSize = 12
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, -16, 0, 18)
    valLabel.Position = UDim2.new(0.7, 0, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(currentVal) .. suffix
    valLabel.TextColor3 = Theme.Accent
    valLabel.Font = Theme.FontBold
    valLabel.TextSize = 12
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -16, 0, 8)
    track.Position = UDim2.new(0, 8, 0, 32)
    track.BackgroundColor3 = Theme.CardBg
    track.Text = ""
    track.Parent = row

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = track

    local fill = Instance.new("Frame")
    local ratio = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fill

    local function updateValueFromInput(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        local raw = minVal + (maxVal - minVal) * relX
        currentVal = isFloat and math.floor(raw * 10) / 10 or math.floor(raw)
        valLabel.Text = tostring(currentVal) .. suffix
        if callback then callback(currentVal) end
    end

    local isDragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateValueFromInput(input)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValueFromInput(input)
        end
    end)

    row.Parent = parent

    return {
        frame = row,
        Set = function(val, skipCallback)
            currentVal = math.clamp(tonumber(val) or minVal, minVal, maxVal)
            local r = (currentVal - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(r, 0, 1, 0)
            valLabel.Text = tostring(currentVal) .. suffix
            if not skipCallback and callback then callback(currentVal) end
        end,
        Get = function()
            return currentVal
        end
    }
end

return Components
