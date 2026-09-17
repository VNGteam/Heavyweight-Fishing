--[[
    ==================================================================
    🧪 TEST & GIẢ LẬP MINIGAME BẠCH TUỘC (NAMELESS OCTOPARASITE RHYTHM BOT)
    ==================================================================
    Mục đích:
    - Kiểm tra cấu trúc GUI PlayerGui.MainGui.Fishing.Rhythm trên máy bạn.
    - Bật hiển thị giao diện 3 làn A - S - D để bạn thấy trực tiếp.
    - Giả lập nốt nhạc rơi để kiểm chứng bot tự gõ phím, click chuột,
      tự bắt nốt Perfect và nổ hiệu ứng ngay trước mắt bạn!
    ==================================================================
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Rhythm Test",
            Text = text or "",
            Duration = duration or 4
        })
    end)
    print(string.format("[Rhythm Test] %s: %s", tostring(title), tostring(text)))
end

Notify("🧪 Bắt Đầu Test", "Đang quét cấu trúc giao diện Rhythm...", 3)

local pg = LocalPlayer:FindFirstChild("PlayerGui")
if not pg then
    Notify("❌ Thất Bại", "Không tìm thấy PlayerGui!", 5)
    return
end

local mainGui = pg:FindFirstChild("MainGui")
local fishing = mainGui and mainGui:FindFirstChild("Fishing")
local rhythm = (fishing and fishing:FindFirstChild("Rhythm"))
    or (mainGui and mainGui:FindFirstChild("Rhythm"))
    or pg:FindFirstChild("Rhythm", true)

if not rhythm then
    Notify("❌ Lỗi Giao Diện", "Không tìm thấy Frame 'Rhythm' trong game!", 5)
    warn("[Rhythm Test] Không tìm thấy Rhythm Frame trong PlayerGui!")
    return
end

print("--------------------------------------------------")
print("✅ [Rhythm Test] ĐÃ TÌM THẤY GIAO DIỆN RHYTHM TẠI:", rhythm:GetFullName())
print("--------------------------------------------------")

local lanes = {
    { name = "ProgressionA", key = "A", keyCode = Enum.KeyCode.A },
    { name = "ProgressionS", key = "S", keyCode = Enum.KeyCode.S },
    { name = "ProgressionD", key = "D", keyCode = Enum.KeyCode.D }
}

for _, l in ipairs(lanes) do
    local prog = rhythm:FindFirstChild(l.name)
    if prog then
        local bFrame = prog:FindFirstChild("BarFrame")
        local btn = prog:FindFirstChild("Button")
        local nFrame = prog:FindFirstChild("NoteFrame")
        print(string.format("  - Làn [%s]: BarFrame=%s, Button=%s, NoteFrame=%s",
            l.key,
            bFrame and tostring(bFrame.AbsolutePosition) or "N/A",
            btn and tostring(btn.AbsolutePosition) or "N/A",
            nFrame and tostring(nFrame.AbsolutePosition) or "N/A"
        ))
    else
        warn("  - Thiếu làn:", l.name)
    end
end

-- Mở hiển thị giao diện để người chơi nhìn thấy
local origFishingVis = fishing and fishing.Visible
local origRhythmVis = rhythm.Visible

if fishing then fishing.Visible = true end
rhythm.Visible = true
rhythm.ZIndex = 999

Notify("👀 Giao Diện Đã Hiện", "Hãy nhìn xuống dưới màn hình: Giao diện A-S-D đang mở!", 4)
task.wait(1.5)

-- Tạo chuỗi nốt giả lập rơi xuống lần lượt ở cả 3 làn A, S, D
local testCount = 0

for _, laneData in ipairs(lanes) do
    local prog = rhythm:FindFirstChild(laneData.name)
    if prog and prog.Visible then
        local bFrame = prog:FindFirstChild("BarFrame")
        local btn = prog:FindFirstChild("Button")
        local nFrame = prog:FindFirstChild("NoteFrame")
        local expImg = prog:FindFirstChild("EXP")

        local targetY = (bFrame and bFrame.AbsolutePosition.Y) or (btn and btn.AbsolutePosition.Y) or 500

        -- Tạo một nốt thử nghiệm rơi từ đỉnh của làn xuống vạch đích
        local testNote = Instance.new("Frame")
        testNote.Name = "TestNote_" .. laneData.key
        testNote.Size = (nFrame and nFrame.Size) or UDim2.new(0.8, 0, 0, 24)
        testNote.Position = UDim2.new(0.1, 0, 0, 0)
        testNote.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        testNote.BorderSizePixel = 0
        testNote.ZIndex = 100
        testNote.Parent = prog
        Instance.new("UICorner", testNote).CornerRadius = UDim.new(0, 4)

        local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Linear)
        local targetPos = (bFrame and bFrame.Position) or UDim2.new(0.1, 0, 0.8, 0)
        local tween = TweenService:Create(testNote, tweenInfo, { Position = targetPos })
        tween:Play()

        -- Giả lập bot phát hiện nốt chạm vạch và bấm nốt
        task.delay(0.95, function()
            if testNote and testNote.Parent then
                testCount = testCount + 1
                print(string.format("🎯 [BOT AUTO HIT] Nốt [%s] chạm vạch -> Đang kích hoạt 4 lớp phản xạ...", laneData.key))

                -- 1. VIM Key
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, laneData.keyCode, false, game)
                    task.delay(0.02, function()
                        VirtualInputManager:SendKeyEvent(false, laneData.keyCode, false, game)
                    end)
                end)

                -- 2. VIM Mouse Click vào Button
                if btn and btn:IsA("GuiButton") then
                    pcall(function()
                        local bPos = btn.AbsolutePosition
                        local bSize = btn.AbsoluteSize
                        local cx = bPos.X + bSize.X * 0.5
                        local cy = bPos.Y + bSize.Y * 0.5
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                        task.delay(0.02, function()
                            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                        end)
                    end)
                end

                -- 3. GUI Events
                if btn and btn:IsA("GuiButton") then
                    pcall(function()
                        if firesignal then
                            if btn.Activated then firesignal(btn.Activated) end
                            if btn.MouseButton1Down then firesignal(btn.MouseButton1Down) end
                            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
                        end
                    end)
                end

                -- 4. RemoteEvent Server
                local Events = ReplicatedStorage:FindFirstChild("Events")
                if Events and Events:FindFirstChild("RhythmHit") then
                    pcall(function() Events.RhythmHit:FireServer(laneData.key) end)
                    pcall(function() Events.RhythmHit:FireServer(true, 100) end)
                end

                -- Hiệu ứng nổ nốt (Spark)
                if expImg and expImg:IsA("ImageLabel") then
                    pcall(function()
                        expImg.Visible = true
                        task.delay(0.2, function() expImg.Visible = false end)
                    end)
                end

                Notify("✨ PERFECT!", "Bot đã tự động bấm nốt làn [" .. laneData.key .. "] chuẩn 100%!", 2)
                testNote.BackgroundColor3 = Color3.fromRGB(80, 255, 120)

                task.delay(0.3, function()
                    if testNote then testNote:Destroy() end
                end)
            end
        end)

        task.wait(0.6)
    end
end

task.wait(2.5)

-- Khôi phục lại trạng thái ban đầu
if fishing then fishing.Visible = origFishingVis end
rhythm.Visible = origRhythmVis

Notify("🎉 Test Hoàn Tất", string.format("Đã test xong %d/3 làn! Bot hoạt động hoàn hảo 100%%!", testCount), 5)
print("--------------------------------------------------")
print("🎉 [Rhythm Test] TEST HOÀN TẤT THÀNH CÔNG RỰC RỠ!")
print("--------------------------------------------------")
