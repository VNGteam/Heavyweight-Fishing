--[[
    ================================================================
    🧪 COMBO DEBUG LOGGER — GUI On-Screen (không cần F9)
    ================================================================
    Chạy sau khi loader đã load xong.
    Sẽ tạo 1 panel nhỏ góc trái màn hình hiển thị log chiêu real-time.
    Bấm nút [X] để đóng log khi không cần nữa.
    ================================================================
--]]

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ── Tạo GUI overlay ──────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ComboDebugOverlay"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 260)
frame.Position = UDim2.new(0, 8, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -36, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🧪 COMBO DEBUG LOG"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Build info row
local buildLabel = Instance.new("TextLabel")
buildLabel.Size = UDim2.new(1, -8, 0, 18)
buildLabel.Position = UDim2.new(0, 4, 0, 30)
buildLabel.BackgroundTransparency = 1
buildLabel.Text = "Build: đang kiểm tra..."
buildLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
buildLabel.Font = Enum.Font.Gotham
buildLabel.TextSize = 11
buildLabel.TextXAlignment = Enum.TextXAlignment.Left
buildLabel.Parent = frame

-- Log scroll area
local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -8, 1, -52)
logScroll.Position = UDim2.new(0, 4, 0, 50)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 4
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
logScroll.ScrollingDirection = Enum.ScrollingDirection.Y
logScroll.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 1)
listLayout.Parent = logScroll

-- ── Hàm thêm dòng log ────────────────────────────────────────────
local logCount = 0
local MAX_LINES = 30

local function addLog(text, color)
    logCount = logCount + 1
    -- Xóa dòng cũ nếu quá nhiều
    local children = logScroll:GetChildren()
    local textLines = {}
    for _, c in ipairs(children) do
        if c:IsA("TextLabel") then
            table.insert(textLines, c)
        end
    end
    if #textLines >= MAX_LINES then
        textLines[1]:Destroy()
    end

    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, -4, 0, 14)
    row.BackgroundTransparency = 1
    row.Text = text
    row.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    row.Font = Enum.Font.Code
    row.TextSize = 11
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextTruncate = Enum.TextTruncate.AtEnd
    row.LayoutOrder = logCount
    row.Parent = logScroll

    -- Auto-scroll xuống cuối
    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

addLog("⏳ Đang chờ comboState...", Color3.fromRGB(255, 200, 80))

-- ── Gắn vào comboState ────────────────────────────────────────────
local env = getgenv and getgenv() or {}

task.spawn(function()
    local timeout = tick() + 10
    while tick() < timeout do
        if env.comboState and env.comboState.CastSkill then break end
        task.wait(0.2)
    end

    local cs  = env.comboState
    local tqs = env.ticketQuestState
    local cfg = env.Config

    if not cs then
        addLog("❌ Không thấy comboState! Chạy loader trước.", Color3.fromRGB(255, 80, 80))
        return
    end

    -- Tránh patch 2 lần
    if cs._debugPatched then
        addLog("⚠️  Đã patch rồi.", Color3.fromRGB(255, 200, 80))
        return
    end
    cs._debugPatched = true

    -- Kiểm tra build version
    local buildVer = env.SCRIPT_BUILD_COMMIT or "unknown"
    if buildVer == "fix-combo-hotpath-loopindex" then
        buildLabel.Text = "✅ Build: " .. buildVer .. " (ĐÃ VÁ)"
        buildLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        addLog("✅ Build đúng — 3 lỗi combo đã được vá!", Color3.fromRGB(80, 255, 120))
    else
        buildLabel.Text = "⚠️  Build: " .. buildVer .. " (CŨ!)"
        buildLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
        addLog("⚠️  Build cũ! Reload loader để lấy bản mới.", Color3.fromRGB(255, 120, 80))
    end

    -- Wrap CastSkill
    local origCast = cs.CastSkill
    cs.CastSkill = function(sk)
        local result = origCast(sk)
        local questType = (tqs and tqs.currentQuestType) or "none"
        local targetIdx  = cs.loopTargetIndex or "?"
        local loopStr    = (cfg and cfg.LoopSkills) or "?"

        if result then
            addLog(
                string.format("✅ %s | next:%s | quest:%s | [%s]",
                    tostring(sk), tostring(targetIdx), tostring(questType), tostring(loopStr)),
                Color3.fromRGB(100, 255, 140)
            )
        else
            addLog(
                string.format("❌ BLOCK:%s | quest:%s", tostring(sk), tostring(questType)),
                Color3.fromRGB(255, 100, 100)
            )
        end
        return result
    end

    -- Theo dõi questType nhảy loạn (dấu hiệu Bug #2 còn sót)
    local lastQ = (tqs and tqs.currentQuestType) or "none"
    task.spawn(function()
        while screenGui.Parent do
            task.wait(0.1)
            local cur = (tqs and tqs.currentQuestType) or "none"
            if cur ~= lastQ then
                addLog(
                    string.format("⚡ questType: [%s]→[%s]", lastQ, cur),
                    Color3.fromRGB(255, 220, 60)
                )
                lastQ = cur
            end
        end
    end)

    addLog("▶️  Bắt đầu câu cá để xem log chiêu...", Color3.fromRGB(180, 180, 255))
    addLog("Thứ tự đúng: Z→X→V→Z→X→V (đều nhau)", Color3.fromRGB(150, 150, 200))
end)
