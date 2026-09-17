--[[
    ==================================================================
    🎮 TRÌNH GIẢ LẬP & CHẠY THẬT 100% MINIGAME RHYTHM A-S-D (GAME GỐC)
    Sử dụng chính xác 100% logic nốt rơi và bắt nốt từ ClientModule.Fishing
    ==================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 4 })
    end)
    print(string.format("[%s] %s", title, text))
end

local pg = LocalPlayer:WaitForChild("PlayerGui")
local mainGui = pg:WaitForChild("MainGui")
local fishingGui = mainGui:WaitForChild("Fishing")
local rhythm = fishingGui:FindFirstChild("Rhythm")

if not rhythm then
    Notify("Lỗi", "Không tìm thấy giao diện Rhythm trong MainGui.Fishing!")
    return
end

-- Bật hiển thị Fishing và Rhythm
fishingGui.Visible = true
rhythm.Visible = true

Notify("🎮 Minigame A-S-D Bắt Đầu!", "Nốt Note_FX đang rơi liên tục! Bot Auto Minigame sẽ tự gõ 100%!", 5)

local t4 = { "A", "S", "D" }
local t5 = {
    A = Enum.KeyCode.A,
    S = Enum.KeyCode.S,
    D = Enum.KeyCode.D
}

local notesTable = { A = {}, S = {}, D = {} }
local connections = {}
local isRunning = true

local function GetLaneFrame(lane)
    return rhythm:FindFirstChild("Progression" .. lane)
end

local targetYMap = {}
for _, lane in ipairs(t4) do
    local prog = rhythm:FindFirstChild("Progression" .. lane)
    local bFrame = prog and prog:FindFirstChild("BarFrame")
    targetYMap[lane] = (bFrame and bFrame.Position.Y.Scale) or 0.85

    local nFrame = prog and prog:FindFirstChild("NoteFrame")
    if nFrame then
        nFrame.Visible = false
    end

    -- Xóa các nốt cũ còn sót lại
    if prog then
        for _, child in ipairs(prog:GetChildren()) do
            if child.Name == "Note_FX" or child.Name == "EXP_FX" then
                child:Destroy()
            end
        end
    end
end

local function TweenExpEffect(laneProg)
    local v1 = laneProg and laneProg:FindFirstChild("EXP")
    if not v1 then return end

    local EXP_FX = v1:Clone()
    EXP_FX.Name = "EXP_FX"
    EXP_FX.Visible = true
    EXP_FX.Parent = laneProg

    local Scale = v1.Size.X.Scale
    local Scale2 = v1.Size.Y.Scale
    pcall(function() EXP_FX.Size = UDim2.fromScale(Scale * 0.6, Scale2 * 0.6) end)

    local tweenGoal = { Size = UDim2.fromScale(Scale * 1.6, Scale2 * 1.6) }
    if EXP_FX:IsA("ImageLabel") or EXP_FX:IsA("ImageButton") then
        tweenGoal.ImageTransparency = 1
    end

    local tw = TweenService:Create(EXP_FX, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), tweenGoal)
    tw:Play()
    tw.Completed:Once(function()
        pcall(function() EXP_FX:Destroy() end)
    end)
end

local function SpawnNote(lane)
    if not isRunning then return end
    local prog = rhythm:FindFirstChild("Progression" .. lane)
    local nFrame = prog and prog:FindFirstChild("NoteFrame")
    if nFrame then
        local Note_FX = nFrame:Clone()
        Note_FX.Name = "Note_FX"
        Note_FX.Visible = true
        Note_FX.Position = UDim2.new(nFrame.Position.X.Scale, nFrame.Position.X.Offset, -0.05, 0)
        Note_FX.Parent = prog
        table.insert(notesTable[lane], {
            t = 0,
            gui = Note_FX
        })
    end
end

local function TryHit(lane)
    if not isRunning then return end
    local list = notesTable[lane]
    local targetY = targetYMap[lane] or 0.85
    local bestDiff = math.huge
    local bestIdx = nil

    for i, item in ipairs(list) do
        if item.gui and item.gui.Parent then
            local diff = math.abs(item.gui.Position.Y.Scale - targetY)
            if diff <= 0.22 and diff < bestDiff then
                bestDiff = diff
                bestIdx = i
            end
        end
    end

    if bestIdx then
        local hitItem = list[bestIdx]
        pcall(function() hitItem.gui:Destroy() end)
        table.remove(list, bestIdx)
        TweenExpEffect(GetLaneFrame(lane))
        print("✨ [Rhythm Simulator] HIT PERFECT phím " .. lane .. "!")
    end
end

-- Vòng lặp di chuyển nốt rơi theo nhịp Heartbeat chuẩn 100% của game
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    if not isRunning then return end
    for _, lane in ipairs(t4) do
        local list = notesTable[lane]
        local targetY = targetYMap[lane] or 0.85
        for i = #list, 1, -1 do
            local item = list[i]
            if item.gui and item.gui.Parent then
                item.t = item.t + dt / 1.4
                local posY = -0.05 + 1.15 * item.t
                item.gui.Position = UDim2.new(item.gui.Position.X.Scale, item.gui.Position.X.Offset, posY, 0)

                -- Nếu rơi quá vạch đích quá xa mà không bấm -> Hủy nốt
                if targetY + 0.22 < posY then
                    pcall(function() item.gui:Destroy() end)
                    table.remove(list, i)
                end
            else
                table.remove(list, i)
            end
        end
    end
end))

-- Lắng nghe bấm phím A, S, D
table.insert(connections, UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe or not isRunning then return end
    for _, lane in ipairs(t4) do
        if inp.KeyCode == t5[lane] then
            TryHit(lane)
        end
    end
end))

-- Lắng nghe click chuột vào Button từng làn
for _, lane in ipairs(t4) do
    local prog = rhythm:FindFirstChild("Progression" .. lane)
    local btn = prog and prog:FindFirstChild("Button")
    if btn and (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
        table.insert(connections, btn.MouseButton1Click:Connect(function()
            TryHit(lane)
        end))
    end
end

-- Vòng lặp sinh nốt ngẫu nhiên rơi liên tục
task.spawn(function()
    task.wait(1)
    local sum = 0
    while isRunning do
        SpawnNote(t4[math.random(1, #t4)])
        local delayTime = math.clamp(sum / 40, 0, 1) * -0.2 + 0.6
        task.wait(delayTime)
        sum = sum + delayTime
    end
end)

-- Tạo nút bấm ĐÓNG / DỪNG TEST trên màn hình
local closeGui = Instance.new("ScreenGui")
closeGui.Name = "StopRhythmTestGui"
closeGui.ResetOnSpawn = false
pcall(function()
    if gethui then closeGui.Parent = gethui() else closeGui.Parent = pg end
end)

local stopBtn = Instance.new("TextButton")
stopBtn.Name = "StopButton"
stopBtn.Size = UDim2.new(0, 220, 0, 44)
stopBtn.Position = UDim2.new(0.5, -110, 0.18, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "❌ DỪNG TEST RHYTHM"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.ZIndex = 9999
stopBtn.Parent = closeGui
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", stopBtn)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5

local function Cleanup()
    isRunning = false
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, lane in ipairs(t4) do
        for _, item in ipairs(notesTable[lane]) do
            pcall(function() item.gui:Destroy() end)
        end
    end
    pcall(function() rhythm.Visible = false end)
    pcall(function() closeGui:Destroy() end)
    Notify("Đã Dừng", "Đã dừng minigame test!", 3)
end

stopBtn.MouseButton1Click:Connect(Cleanup)

-- Tự động dừng sau 60 giây nếu quên bấm tắt
task.delay(60, function()
    if isRunning then
        Cleanup()
    end
end)
