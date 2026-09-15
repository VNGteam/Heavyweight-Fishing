--[[
    v2/ui/window.lua
    Exact Main Window, Floating Avatar, Floating Crescent, TitleBar & Sidebar from backup.lua
--]]

local Services = require(script.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local Theme = require(script.Parent.theme)
local State = require(script.Parent.Parent.core.state)
local Components = require(script.Parent.components)

local Window = {}

Window.tabFrames = {}
Window.tabButtons = {}
Window.screenGui = nil
Window.mainFrame = nil
Window.floatingAvatar = nil
Window.ToggleUiVisibility = nil

function Window.Init(scriptBuildCommit, onKill)
    -- 1. ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "IdenticalHeavyweightFishing"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
        end
    end)

    screenGui.Parent = Services.GetGuiParent()
    State.AddInstance(screenGui)
    Window.screenGui = screenGui

    -- 2. Floating Avatar (Draggable headshot with status dot)
    local floatingAvatar = Instance.new("ImageButton")
    floatingAvatar.Name = "FloatingAvatar"
    floatingAvatar.Size = UDim2.new(0, 48, 0, 48)
    floatingAvatar.Position = UDim2.new(0, 20, 0.4, 0)
    floatingAvatar.BackgroundColor3 = Theme.Background
    floatingAvatar.BorderSizePixel = 0
    floatingAvatar.Visible = false
    floatingAvatar.ZIndex = 2000
    floatingAvatar.Active = true
    floatingAvatar.AutoButtonColor = false
    floatingAvatar.Parent = screenGui
    State.AddInstance(floatingAvatar)
    Window.floatingAvatar = floatingAvatar

    do
        local faCorner = Instance.new("UICorner"); faCorner.CornerRadius = UDim.new(1, 0); faCorner.Parent = floatingAvatar
        local faStroke = Instance.new("UIStroke"); faStroke.Color = Theme.PurpleAccent; faStroke.Thickness = 2.2; faStroke.Parent = floatingAvatar

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Name = "AvatarImage"
        avatarImg.Size = UDim2.new(1, -6, 1, -6)
        avatarImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        avatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
        avatarImg.Parent = floatingAvatar
        Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 11, 0, 11)
        dot.Position = UDim2.new(1, -11, 1, -11)
        dot.BackgroundColor3 = Theme.AccentGreen
        dot.BorderSizePixel = 0
        dot.Parent = floatingAvatar
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local dotStroke = Instance.new("UIStroke"); dotStroke.Color = Theme.Background; dotStroke.Thickness = 1.5; dotStroke.Parent = dot

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

        State.AddConnection(UserInputService.InputChanged:Connect(function(input)
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
            TweenService:Create(faStroke, TweenInfo.new(0.15), {Color = Theme.PurpleGlow, Thickness = 2.8}):Play()
        end)
        floatingAvatar.MouseLeave:Connect(function()
            TweenService:Create(floatingAvatar, TweenInfo.new(0.15), {Size = UDim2.new(0, 48, 0, 48)}):Play()
            TweenService:Create(faStroke, TweenInfo.new(0.15), {Color = Theme.PurpleAccent, Thickness = 2.2}):Play()
        end)

        floatingAvatar.MouseButton1Click:Connect(function()
            if not dragMoved and Window.ToggleUiVisibility then
                Window.ToggleUiVisibility()
            end
        end)
    end

    -- 3. Main Window
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    State.AddInstance(mainFrame)
    Window.mainFrame = mainFrame

    do
        local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
        local ms = Instance.new("UIStroke"); ms.Color = Theme.BorderPurple; ms.Thickness = 1.5; ms.Parent = mainFrame
    end

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Theme.SidebarBg
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    do
        local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 8); tc.Parent = titleBar
        local tbf = Instance.new("Frame"); tbf.Size = UDim2.new(1, 0, 0, 10); tbf.Position = UDim2.new(0, 0, 1, -10); tbf.BackgroundColor3 = Theme.SidebarBg; tbf.BorderSizePixel = 0; tbf.Parent = titleBar
        local tdiv = Instance.new("Frame"); tdiv.Size = UDim2.new(1, 0, 0, 1); tdiv.Position = UDim2.new(0, 0, 1, -1); tdiv.BackgroundColor3 = Theme.Divider; tdiv.BorderSizePixel = 0; tdiv.Parent = titleBar
    end

    -- Crescent Icon
    do
        local cc = Instance.new("Frame"); cc.Size = UDim2.new(0, 16, 0, 16); cc.Position = UDim2.new(0, 14, 0.5, -8); cc.BackgroundTransparency = 1; cc.ClipsDescendants = true; cc.Parent = titleBar
        local co = Instance.new("Frame"); co.Size = UDim2.new(0, 16, 0, 16); co.BackgroundColor3 = Theme.PurpleAccent; co.BorderSizePixel = 0; co.Parent = cc
        Instance.new("UICorner", co).CornerRadius = UDim.new(1, 0)
        local cut = Instance.new("Frame"); cut.Size = UDim2.new(0, 13, 0, 13); cut.Position = UDim2.new(0, 4, 0, -2); cut.BackgroundColor3 = Theme.SidebarBg; cut.BorderSizePixel = 0; cut.Parent = co
        Instance.new("UICorner", cut).CornerRadius = UDim.new(1, 0)
    end

    local brandTitle = Instance.new("TextLabel")
    brandTitle.Size = UDim2.new(0, 92, 1, 0); brandTitle.Position = UDim2.new(0, 36, 0, 0)
    brandTitle.BackgroundTransparency = 1; brandTitle.Font = Enum.Font.GothamBold
    brandTitle.Text = "CÂU CÁ PRO"; brandTitle.TextColor3 = Theme.PurplePrimary
    brandTitle.TextSize = 14; brandTitle.TextXAlignment = Enum.TextXAlignment.Left
    brandTitle.Parent = titleBar

    local commitBadge = Instance.new("TextLabel")
    commitBadge.Size = UDim2.new(0, 68, 0, 18); commitBadge.Position = UDim2.new(0, 132, 0.5, -9)
    commitBadge.BackgroundColor3 = Color3.fromRGB(30, 22, 48)
    commitBadge.Font = Enum.Font.Code
    commitBadge.Text = "#" .. tostring(scriptBuildCommit or "v2.0")
    commitBadge.TextColor3 = Color3.fromRGB(190, 150, 255)
    commitBadge.TextSize = 10
    commitBadge.Parent = titleBar
    Instance.new("UICorner", commitBadge).CornerRadius = UDim.new(0, 4)
    local cStroke = Instance.new("UIStroke", commitBadge)
    cStroke.Color = Theme.PurpleAccent
    cStroke.Thickness = 1

    local gameSubtitle = Instance.new("TextLabel")
    gameSubtitle.Size = UDim2.new(0, 220, 1, 0); gameSubtitle.Position = UDim2.new(0, 208, 0, 0)
    gameSubtitle.BackgroundTransparency = 1; gameSubtitle.Font = Enum.Font.Gotham
    gameSubtitle.Text = "HEAVYWEIGHT FISHING | BẢN VIỆT HOÁ"; gameSubtitle.TextColor3 = Theme.PurpleMuted
    gameSubtitle.TextSize = 10; gameSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    gameSubtitle.Parent = titleBar

    local winControls = Instance.new("Frame"); winControls.Size = UDim2.new(0, 95, 1, 0); winControls.Position = UDim2.new(1, -100, 0, 0); winControls.BackgroundTransparency = 1; winControls.Parent = titleBar
    local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(0, 4, 0.5, -12); minBtn.BackgroundColor3 = Theme.ControlBg; minBtn.Font = Enum.Font.GothamBold; minBtn.Text = "[-]"; minBtn.TextColor3 = Theme.PurplePrimary; minBtn.TextSize = 11; minBtn.BorderSizePixel = 0; minBtn.Parent = winControls
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(0, 32, 0.5, -12); closeBtn.BackgroundColor3 = Theme.ControlBg; closeBtn.Font = Enum.Font.GothamBold; closeBtn.Text = "[X]"; closeBtn.TextColor3 = Theme.TextWhite; closeBtn.TextSize = 11; closeBtn.BorderSizePixel = 0; closeBtn.Parent = winControls
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    local killBtn = Instance.new("TextButton"); killBtn.Size = UDim2.new(0, 32, 0, 24); killBtn.Position = UDim2.new(0, 60, 0.5, -12); killBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 25); killBtn.Font = Enum.Font.GothamBold; killBtn.Text = "KILL"; killBtn.TextColor3 = Theme.AccentRed; killBtn.TextSize = 9; killBtn.BorderSizePixel = 0; killBtn.Parent = winControls
    Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0, 4)
    local killStroke = Instance.new("UIStroke"); killStroke.Color = Theme.AccentRed; killStroke.Thickness = 1; killStroke.Parent = killBtn

    -- Window Dragging
    do
        local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = mainFrame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        titleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
        State.AddConnection(UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end))
    end

    local bodyFrame = Instance.new("Frame"); bodyFrame.Name = "Body"; bodyFrame.Size = UDim2.new(1, 0, 1, -62); bodyFrame.Position = UDim2.new(0, 0, 0, 38); bodyFrame.BackgroundTransparency = 1; bodyFrame.Parent = mainFrame

    -- Sidebar
    local sidebar = Instance.new("Frame"); sidebar.Name = "Sidebar"; sidebar.Size = UDim2.new(0, 140, 1, 0); sidebar.BackgroundColor3 = Theme.SidebarBg; sidebar.BorderSizePixel = 0; sidebar.Parent = bodyFrame
    do
        local d = Instance.new("Frame"); d.Size = UDim2.new(0, 1, 1, 0); d.Position = UDim2.new(1, -1, 0, 0); d.BackgroundColor3 = Theme.Divider; d.BorderSizePixel = 0; d.Parent = sidebar
    end

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBar"; searchBox.Size = UDim2.new(1, -16, 0, 26); searchBox.Position = UDim2.new(0, 8, 0, 8)
    searchBox.BackgroundColor3 = Theme.InputBg; searchBox.Font = Enum.Font.Gotham; searchBox.PlaceholderText = "Tìm kiếm tính năng..."
    searchBox.PlaceholderColor3 = Theme.TextMuted; searchBox.Text = ""; searchBox.TextColor3 = Theme.TextWhite
    searchBox.TextSize = 11; searchBox.TextXAlignment = Enum.TextXAlignment.Left; searchBox.BorderSizePixel = 0; searchBox.ClearTextOnFocus = false; searchBox.Parent = sidebar
    do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = searchBox end
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower()
        for _, item in ipairs(Components.rowSearchIndex) do
            if q == "" or item.query:find(q, 1, true) then
                item.frame.Visible = true
            else
                item.frame.Visible = false
            end
        end
    end)

    local navList = Instance.new("ScrollingFrame"); navList.Name = "NavList"; navList.Size = UDim2.new(1, 0, 1, -44); navList.Position = UDim2.new(0, 0, 0, 42); navList.BackgroundTransparency = 1; navList.BorderSizePixel = 0; navList.ScrollBarThickness = 2; navList.ScrollBarImageColor3 = Theme.BorderSubtle; navList.CanvasSize = UDim2.new(0, 0, 0, 0); navList.AutomaticCanvasSize = Enum.AutomaticSize.Y; navList.Parent = sidebar
    do
        local nl = Instance.new("UIListLayout"); nl.SortOrder = Enum.SortOrder.LayoutOrder; nl.Padding = UDim.new(0, 4); nl.Parent = navList
        local np = Instance.new("UIPadding"); np.PaddingTop = UDim.new(0, 6); np.PaddingLeft = UDim.new(0, 8); np.PaddingRight = UDim.new(0, 8); np.Parent = navList
    end

    local contentArea = Instance.new("Frame"); contentArea.Name = "ContentArea"; contentArea.Size = UDim2.new(1, -140, 1, 0); contentArea.Position = UDim2.new(0, 140, 0, 0); contentArea.BackgroundTransparency = 1; contentArea.Parent = bodyFrame

    -- Footer Bar
    local footerBar = Instance.new("Frame"); footerBar.Name = "FooterBar"; footerBar.Size = UDim2.new(1, 0, 0, 24); footerBar.Position = UDim2.new(0, 0, 1, -24); footerBar.BackgroundColor3 = Theme.SidebarBg; footerBar.BorderSizePixel = 0; footerBar.Parent = mainFrame
    Instance.new("UICorner", footerBar).CornerRadius = UDim.new(0, 8)
    do
        local tf = Instance.new("Frame"); tf.Size = UDim2.new(1, 0, 0, 10); tf.BackgroundColor3 = Theme.SidebarBg; tf.BorderSizePixel = 0; tf.Parent = footerBar
        local fd = Instance.new("Frame"); fd.Size = UDim2.new(1, 0, 0, 1); fd.BackgroundColor3 = Theme.Divider; fd.BorderSizePixel = 0; fd.Parent = footerBar
    end
    local footerBrand = Instance.new("TextLabel"); footerBrand.Size = UDim2.new(0, 260, 1, 0); footerBrand.Position = UDim2.new(0, 12, 0, 0); footerBrand.BackgroundTransparency = 1; footerBrand.Font = Enum.Font.Gotham; footerBrand.Text = "Heavyweight Fishing | Việt Hoá V2.0"; footerBrand.TextColor3 = Theme.TextMuted; footerBrand.TextSize = 10; footerBrand.TextXAlignment = Enum.TextXAlignment.Left; footerBrand.Parent = footerBar
    local footerKey = Instance.new("TextLabel"); footerKey.Size = UDim2.new(0, 280, 1, 0); footerKey.Position = UDim2.new(1, -292, 0, 0); footerKey.BackgroundTransparency = 1; footerKey.Font = Enum.Font.Gotham; footerKey.Text = "[R-CTRL] Menu | [END] Tắt Script"; footerKey.TextColor3 = Theme.TextMuted; footerKey.TextSize = 10; footerKey.TextXAlignment = Enum.TextXAlignment.Right; footerKey.Parent = footerBar

    -- Toggle UI visibility
    Window.ToggleUiVisibility = function()
        mainFrame.Visible = not mainFrame.Visible
        floatingAvatar.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        end
    end

    minBtn.MouseButton1Click:Connect(Window.ToggleUiVisibility)
    closeBtn.MouseButton1Click:Connect(Window.ToggleUiVisibility)
    killBtn.MouseButton1Click:Connect(function()
        if onKill then onKill() end
    end)

    -- Tab Switcher
    function Window.SwitchTab(tabName)
        for name, frame in pairs(Window.tabFrames) do
            frame.Visible = (name == tabName)
        end
        for name, btn in pairs(Window.tabButtons) do
            if name == tabName then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.PurpleDark, TextColor3 = Theme.TextWhite}):Play()
                local pill = btn:FindFirstChild("ActivePill"); if pill then pill.Visible = true end
            else
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SidebarBg, TextColor3 = Theme.TextSubtle}):Play()
                local pill = btn:FindFirstChild("ActivePill"); if pill then pill.Visible = false end
            end
        end
    end

    -- Tab Creator
    function Window.CreateTab(name)
        local btn = Instance.new("TextButton"); btn.Name = "TabBtn_" .. name; btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Theme.SidebarBg; btn.Font = Enum.Font.GothamBold; btn.Text = name; btn.TextColor3 = Theme.TextSubtle; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0; btn.Parent = navList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        do local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 12); p.Parent = btn end
        local pill = Instance.new("Frame"); pill.Name = "ActivePill"; pill.Size = UDim2.new(0, 3, 0, 16); pill.Position = UDim2.new(0, -9, 0.5, -8); pill.BackgroundColor3 = Theme.PurpleAccent; pill.BorderSizePixel = 0; pill.Visible = false; pill.Parent = btn
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 2)
        btn.MouseButton1Click:Connect(function() Window.SwitchTab(name) end)

        local page = Instance.new("ScrollingFrame"); page.Name = "TabPage_" .. name; page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = Theme.BorderPurple; page.CanvasSize = UDim2.new(0, 0, 0, 0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.Visible = false; page.Parent = contentArea
        do
            local pl = Instance.new("UIListLayout"); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Padding = UDim.new(0, 10); pl.Parent = page
            local pp = Instance.new("UIPadding"); pp.PaddingTop = UDim.new(0, 12); pp.PaddingBottom = UDim.new(0, 16); pp.PaddingLeft = UDim.new(0, 14); pp.PaddingRight = UDim.new(0, 14); pp.Parent = page
        end
        Window.tabFrames[name] = page
        Window.tabButtons[name] = btn
        return page
    end

    return Window
end

return Window
