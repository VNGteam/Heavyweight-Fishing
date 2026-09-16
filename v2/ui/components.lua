--[[
    v2/ui/components.lua
    Exact UI Toolkit from backup.lua (Category headers, cards, base rows, toggles, sliders, dropdowns, buttons, inputs)
--]]

local Services = require(script.Parent.Parent.core.services)
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local Theme = require(script.Parent.theme)
local State = require(script.Parent.Parent.core.state)
local Utils = require(script.Parent.Parent.core.utils)

local Components = {}
Components.rowSearchIndex = {}
Components.ShowNotification = function(...)
    return Utils.ShowNotification(...)
end

function Components.CreateCategoryHeader(parent, text)
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 22)
    hdr.BackgroundTransparency = 1
    hdr.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Theme.PurplePrimary
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = hdr

    return hdr
end

function Components.CreateCardGroup(parent)
    local group = Instance.new("Frame")
    group.Size = UDim2.new(1, 0, 0, 0)
    group.AutomaticSize = Enum.AutomaticSize.Y
    group.BackgroundColor3 = Theme.RowNormal
    group.BorderSizePixel = 0
    group.Parent = parent

    local s = Instance.new("UIStroke")
    s.Color = Theme.BorderSubtle
    s.Thickness = 1
    s.Parent = group

    Instance.new("UICorner", group).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 0)
    l.Parent = group

    return group
end

function Components.CreateCollapsibleCardGroup(parent, text, defaultOpen)
    local isOpen = (defaultOpen == true)
    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 26)
    hdr.BackgroundTransparency = 1
    hdr.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = hdr

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -95, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Theme.PurplePrimary
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = hdr

    local badge = Instance.new("TextButton")
    badge.Size = UDim2.new(0, 85, 0, 20)
    badge.Position = UDim2.new(1, -85, 0.5, -10)
    badge.BackgroundColor3 = Theme.ControlBg
    badge.BorderSizePixel = 0
    badge.Font = Enum.Font.GothamBold
    badge.Text = isOpen and "▼ Thu Gọn" or "▶ Mở Rộng"
    badge.TextColor3 = isOpen and Theme.TextMuted or Theme.PurpleAccent
    badge.TextSize = 10
    badge.Parent = hdr
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)

    local group = Components.CreateCardGroup(parent)
    group.Visible = isOpen

    local function toggle()
        isOpen = not isOpen
        group.Visible = isOpen
        badge.Text = isOpen and "▼ Thu Gọn" or "▶ Mở Rộng"
        badge.TextColor3 = isOpen and Theme.TextMuted or Theme.PurpleAccent
    end

    btn.MouseButton1Click:Connect(toggle)
    badge.MouseButton1Click:Connect(toggle)

    return group, toggle
end

function Components.CreateBaseRow(parent, labelText, descText, indexSearch)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = Theme.RowNormal
    row.BorderSizePixel = 0
    row.Parent = parent

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = row

    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, -190, 1, 0)
    tf.BackgroundTransparency = 1
    tf.Parent = row

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 0, 18)
    tl.Position = UDim2.new(0, 0, 0, 4)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.Text = labelText
    tl.TextColor3 = Theme.TextWhite
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = tf

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 14)
    dl.Position = UDim2.new(0, 0, 0, 22)
    dl.BackgroundTransparency = 1
    dl.Font = Enum.Font.Gotham
    dl.Text = descText or ""
    dl.TextColor3 = Theme.TextMuted
    dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = tf

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.RowHover}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.RowNormal}):Play()
    end)

    if indexSearch ~= false then
        table.insert(Components.rowSearchIndex, {frame = row, query = (labelText .. " " .. (descText or "")):lower()})
    end
    return row
end

function Components.CreateToggleRow(parent, labelText, descText, initialVal, callback, indexSearch)
    if type(initialVal) == "function" then
        indexSearch = callback
        callback = initialVal
        initialVal = false
    end
    local row = Components.CreateBaseRow(parent, labelText, descText, indexSearch)
    local state = initialVal or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = state and Theme.PurpleAccent or Theme.ControlBg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Theme.TextWhite
    knob.BorderSizePixel = 0
    knob.Parent = btn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function updateVisuals()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.PurpleAccent or Theme.ControlBg}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals()
        if type(callback) == "function" then callback(state) end
    end)

    local ret = {
        frame = row,
        Set = function(val, skipCallback)
            state = val == true
            updateVisuals()
            if not skipCallback and type(callback) == "function" then
                callback(state)
            end
        end,
        Get = function() return state end
    }

    local key = State.ConfigLabelMap[labelText]
    if key then State.UIControllers[key] = ret end
    return ret
end

function Components.CreateSliderRow(parent, labelText, descText, minVal, maxVal, initialVal, isFloat, suffix, callback, indexSearch)
    local row = Components.CreateBaseRow(parent, labelText, descText, indexSearch)
    local currentVal = initialVal or minVal
    suffix = suffix or ""

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 180, 0, 24)
    container.Position = UDim2.new(1, -180, 0.5, -12)
    container.BackgroundTransparency = 1
    container.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 68, 1, 0)
    valLabel.Position = UDim2.new(1, -68, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextColor3 = Theme.PurplePrimary
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = container
    valLabel.Text = isFloat and string.format("%.2f", currentVal)..suffix or tostring(math.floor(currentVal))..suffix

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -74, 0, 6)
    track.Position = UDim2.new(0, 0, 0.5, -3)
    track.BackgroundColor3 = Theme.ControlBg
    track.BorderSizePixel = 0
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.PurpleAccent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliding = false
    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        currentVal = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLabel.Text = isFloat and string.format("%.2f", val)..suffix or tostring(val)..suffix
        if type(callback) == "function" then callback(val) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    State.AddConnection(UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end))

    local ret = {
        frame = row,
        Set = function(val, skipCallback)
            currentVal = math.clamp(tonumber(val) or minVal, minVal, maxVal)
            local p2 = (currentVal - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(p2, 0, 1, 0)
            valLabel.Text = isFloat and string.format("%.2f", currentVal)..suffix or tostring(math.floor(currentVal))..suffix
            if not skipCallback and type(callback) == "function" then callback(currentVal) end
        end,
        Get = function() return currentVal end
    }

    local key = State.ConfigLabelMap[labelText]
    if key then State.UIControllers[key] = ret end
    return ret
end

function Components.CreateDropdownRow(parent, labelText, descText, options, initialVal, callback, indexSearch)
    if type(options) == "table" and type(initialVal) == "function" then
        indexSearch = callback
        callback = initialVal
        initialVal = options[1]
    end
    local selected = initialVal or options[1]
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = Theme.RowNormal
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.Parent = parent

    local rl = Instance.new("UIListLayout")
    rl.SortOrder = Enum.SortOrder.LayoutOrder
    rl.Padding = UDim.new(0, 4)
    rl.Parent = row

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundTransparency = 1
    header.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = header

    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, -145, 1, 0)
    tf.BackgroundTransparency = 1
    tf.Parent = header

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 0, 18)
    tl.Position = UDim2.new(0, 0, 0, 4)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.Text = labelText
    tl.TextColor3 = Theme.TextWhite
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = tf

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 14)
    dl.Position = UDim2.new(0, 0, 0, 22)
    dl.BackgroundTransparency = 1
    dl.Font = Enum.Font.Gotham
    dl.Text = descText or ""
    dl.TextColor3 = Theme.TextMuted
    dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = tf

    local ddBtn = Instance.new("TextButton")
    ddBtn.Size = UDim2.new(0, 130, 0, 24)
    ddBtn.Position = UDim2.new(1, -130, 0.5, -12)
    ddBtn.BackgroundColor3 = Theme.ControlBg
    ddBtn.Font = Enum.Font.GothamBold
    ddBtn.Text = tostring(selected) .. "  v"
    ddBtn.TextColor3 = Theme.PurplePrimary
    ddBtn.TextSize = 11
    ddBtn.BorderSizePixel = 0
    ddBtn.Parent = header
    Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0, 4)

    local optC = Instance.new("Frame")
    optC.Size = UDim2.new(1, 0, 0, 0)
    optC.AutomaticSize = Enum.AutomaticSize.Y
    optC.BackgroundTransparency = 1
    optC.Visible = false
    optC.Parent = row

    do
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, 10)
        p.PaddingRight = UDim.new(0, 10)
        p.PaddingBottom = UDim.new(0, 8)
        p.Parent = optC
    end
    Instance.new("UIListLayout", optC).SortOrder = Enum.SortOrder.LayoutOrder

    local optButtons = {}
    local function populate(opts)
        for _, c in ipairs(optC:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        table.clear(optButtons)
        for _, opt in ipairs(opts) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 26)
            ob.BackgroundColor3 = (opt == selected) and Theme.DropdownSelected or Theme.InputBg
            ob.Font = Enum.Font.Gotham
            ob.Text = (opt == selected and "> " or "   ") .. tostring(opt)
            ob.TextColor3 = (opt == selected) and Theme.PurplePrimary or Theme.TextWhite
            ob.TextSize = 11
            ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.BorderSizePixel = 0
            ob.Parent = optC
            Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)

            do
                local p = Instance.new("UIPadding")
                p.PaddingLeft = UDim.new(0, 10)
                p.Parent = ob
            end
            optButtons[opt] = ob

            ob.MouseEnter:Connect(function()
                if opt ~= selected then
                    TweenService:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Theme.RowHover}):Play()
                end
            end)
            ob.MouseLeave:Connect(function()
                if opt ~= selected then
                    TweenService:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Theme.InputBg}):Play()
                end
            end)
            ob.MouseButton1Click:Connect(function()
                selected = opt
                ddBtn.Text = tostring(opt) .. "  v"
                optC.Visible = false
                for oN, b in pairs(optButtons) do
                    b.BackgroundColor3 = (oN == opt) and Theme.DropdownSelected or Theme.InputBg
                    b.TextColor3 = (oN == opt) and Theme.PurplePrimary or Theme.TextWhite
                    b.Text = (oN == opt and "> " or "   ") .. tostring(oN)
                end
                if type(callback) == "function" then callback(opt) end
            end)
        end
    end
    populate(options)

    ddBtn.MouseButton1Click:Connect(function()
        optC.Visible = not optC.Visible
        ddBtn.Text = tostring(selected) .. (optC.Visible and "  ^" or "  v")
    end)
    header.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.RowHover}):Play()
    end)
    header.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Theme.RowNormal}):Play()
    end)

    if indexSearch ~= false then
        table.insert(Components.rowSearchIndex, {frame = row, query = (labelText .. " " .. (descText or "")):lower()})
    end

    local ret = {
        frame = row,
        Set = function(opt, skipCallback)
            selected = opt
            ddBtn.Text = tostring(opt) .. "  v"
            for oN, b in pairs(optButtons) do
                b.BackgroundColor3 = (oN == opt) and Theme.DropdownSelected or Theme.InputBg
                b.TextColor3 = (oN == opt) and Theme.PurplePrimary or Theme.TextWhite
                b.Text = (oN == opt and "> " or "   ") .. tostring(oN)
            end
            if not skipCallback and type(callback) == "function" then pcall(callback, opt) end
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

    local mappedKey = State.ConfigLabelMap[labelText]
    if mappedKey then
        State.UIControllers[mappedKey] = ret
    end
    return ret
end

function Components.CreateButtonRow(parent, labelText, descText, btnText, callback, indexSearch)
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
    local row = Components.CreateBaseRow(parent, labelText, descText, indexSearch)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 24)
    btn.Position = UDim2.new(1, -90, 0.5, -12)
    btn.BackgroundColor3 = Theme.ControlBg
    btn.Font = Enum.Font.GothamBold
    btn.Text = btnText or "Execute"
    btn.TextColor3 = Theme.PurplePrimary
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.PurpleDark, TextColor3 = Theme.TextWhite}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ControlBg, TextColor3 = Theme.PurplePrimary}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if type(callback) == "function" then pcall(callback) end
    end)
    return btn
end

function Components.CreateInfoRow(parent, labelText, valueText, indexSearch)
    local row = Components.CreateBaseRow(parent, labelText, "", indexSearch)
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 180, 1, 0)
    vl.Position = UDim2.new(1, -180, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Font = Enum.Font.GothamBold
    vl.Text = valueText or ""
    vl.TextColor3 = Theme.PurplePrimary
    vl.TextSize = 11
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = row
    return {frame = row, Set = function(nv) vl.Text = tostring(nv or "") end}
end

Components.CreateStatusRow = Components.CreateInfoRow

function Components.CreateStatGridTile(parent, titleText, defaultValue, valueColor, layoutOrder)
    local tile = Instance.new("Frame")
    tile.BackgroundColor3 = Theme.ControlBg
    tile.BorderSizePixel = 0
    tile.LayoutOrder = layoutOrder or 1
    tile.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = tile

    local s = Instance.new("UIStroke")
    s.Color = Theme.BorderSubtle
    s.Thickness = 1
    s.Parent = tile

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = tile

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 14)
    titleLbl.Position = UDim2.new(0, 0, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.Gotham
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Theme.TextMuted
    titleLbl.TextSize = 10
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.Parent = tile

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, 0, 0, 18)
    valLbl.Position = UDim2.new(0, 0, 0, 15)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = defaultValue or "---"
    valLbl.TextColor3 = valueColor or Theme.PurplePrimary
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Left
    valLbl.TextTruncate = Enum.TextTruncate.AtEnd
    valLbl.Parent = tile

    tile.MouseEnter:Connect(function()
        Services.TweenService:Create(s, TweenInfo.new(0.15), {Color = Theme.BorderPurple}):Play()
        Services.TweenService:Create(tile, TweenInfo.new(0.15), {BackgroundColor3 = Theme.RowHover}):Play()
    end)
    tile.MouseLeave:Connect(function()
        Services.TweenService:Create(s, TweenInfo.new(0.15), {Color = Theme.BorderSubtle}):Play()
        Services.TweenService:Create(tile, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ControlBg}):Play()
    end)

    return {
        frame = tile,
        Set = function(nv)
            valLbl.Text = tostring(nv or "")
        end
    }
end

function Components.CreateInputRow(parent, labelText, descText, initialVal, callback, indexSearch, placeholder)
    local row = Components.CreateBaseRow(parent, labelText, descText, indexSearch)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0, 160, 0, 24)
    tb.Position = UDim2.new(1, -160, 0.5, -12)
    tb.BackgroundColor3 = Theme.InputBg
    tb.Font = Enum.Font.Gotham
    tb.Text = initialVal or ""
    tb.PlaceholderText = placeholder or "Nhập tại đây..."
    tb.PlaceholderColor3 = Theme.TextMuted
    tb.TextColor3 = Theme.TextWhite
    tb.TextSize = 11
    tb.ClearTextOnFocus = false
    tb.BorderSizePixel = 0
    tb.Parent = row
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)

    local s = Instance.new("UIStroke", tb)
    s.Color = Theme.BorderSubtle
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

    local mappedKey = State.ConfigLabelMap[labelText]
    if mappedKey then
        State.UIControllers[mappedKey] = ret
    end
    return ret
end

return Components
