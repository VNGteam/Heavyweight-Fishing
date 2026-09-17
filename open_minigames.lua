--[[
    ==================================================================
    🎮 BỘ MÔ PHỎNG & GỌI TOÀN BỘ 5 MINI GAME TRONG HEAVYWEIGHT FISHING
    ==================================================================
    Chạy đoạn script này trong Executor (Xeno, Delta, Fluxus, Codex...):
    - Nó sẽ BẬT hiển thị toàn bộ 5 mini game câu cá lên màn hình cùng lúc!
    - Đồng thời kiểm tra bot có tự động giữ thanh, tự đập cần, tự sạc dây,
      tự bắt nốt nhịp điệu A-S-D của Boss Bạch Tuộc hay không!
    ==================================================================
--]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Mini Game Simulator",
            Text = text or "",
            Duration = duration or 4
        })
    end)
    print(string.format("[Simulator] %s: %s", tostring(title), tostring(text)))
end

Notify("🚀 Đang Khởi Chạy", "Đang mở toàn bộ 5 Mini Game ảo...", 3)

local pg = LocalPlayer:FindFirstChild("PlayerGui")
if not pg then
    Notify("❌ Lỗi", "Không tìm thấy PlayerGui!", 4)
    return
end

local mainGui = pg:FindFirstChild("MainGui")
local fUI = mainGui and mainGui:FindFirstChild("Fishing")

if not fUI then
    Notify("❌ Lỗi", "Không tìm thấy PlayerGui.MainGui.Fishing!", 4)
    return
end

-- 1. Mở hiển thị giao diện Fishing tổng
fUI.Visible = true

-- Lưu lại trạng thái ban đầu để đóng sau khi test xong
local origStates = {}

local function ForceShow(obj, name)
    if obj then
        origStates[obj] = obj.Visible
        obj.Visible = true
        print("  ✅ Đã bật Mini Game:", name, "->", obj:GetFullName())
        return true
    else
        warn("  ⚠️ Không tìm thấy đối tượng:", name)
        return false
    end
end

print("------------------------------------------------------------------")
print("🎮 BẮT ĐẦU HIỂN THỊ CẢ 5 GIAO DIỆN MINI GAME ĐỂ KIỂM TRA TRỰC TIẾP:")
print("------------------------------------------------------------------")

-- 1. Mini game giữ thanh kéo cân bằng (BarFrame / Anchor Bar)
local barFrame = fUI:FindFirstChild("BarFrame")
ForceShow(barFrame, "1. Thanh Kéo Cân Bằng (BarFrame)")

-- 2. Mini game đập cần (PerfectButton / Slam)
local perfectBtn = fUI:FindFirstChild("PerfectButton")
ForceShow(perfectBtn, "2. Nút Đập Cần (Perfect Slam)")

-- 3. Mini game sạc dây câu (Charge)
local chargeBtn = fUI:FindFirstChild("Charge")
ForceShow(chargeBtn, "3. Nút Sạc Dây Câu (Charge)")

-- 4. Mini game thanh máu giằng co Boss (BossFightBar)
local bossBar = fUI:FindFirstChild("BossFightBar")
ForceShow(bossBar, "4. Thanh Máu Săn Boss (BossFightBar)")

-- 5. Mini game nhịp điệu 3 làn A - S - D (Rhythm - Boss Bạch Tuộc Nameless Octoparasite)
local rhythmGui = fUI:FindFirstChild("Rhythm")
ForceShow(rhythmGui, "5. Nhịp Điệu 3 Làn A-S-D (Rhythm)")

Notify("✨ ĐÃ HIỆN ĐỦ 5 MINI GAME!", "Cả 5 giao diện ảo đã mở ngay trên màn hình của bạn!", 5)

-- 🎯 TẠO CÁC NỐT RƠI ẢO Ở CẢ 3 LÀN A - S - D ĐỂ BẠN THẤY BOT TỰ BẤM
if rhythmGui and rhythmGui.Visible then
    task.spawn(function()
        local lanes = {
            { name = "ProgressionA", key = "A" },
            { name = "ProgressionS", key = "S" },
            { name = "ProgressionD", key = "D" }
        }

        for round = 1, 2 do
            for _, laneData in ipairs(lanes) do
                local prog = rhythmGui:FindFirstChild(laneData.name)
                if prog and prog.Visible then
                    local bFrame = prog:FindFirstChild("BarFrame")
                    local btn = prog:FindFirstChild("Button")
                    local nFrame = prog:FindFirstChild("NoteFrame")

                    local testNote = Instance.new("Frame")
                    testNote.Name = "TestNote_" .. laneData.key
                    testNote.Size = (nFrame and nFrame.Size) or UDim2.new(0.8, 0, 0, 24)
                    testNote.Position = UDim2.new(0.1, 0, 0, 0)
                    testNote.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    testNote.BorderSizePixel = 0
                    testNote.ZIndex = 200
                    testNote.Parent = prog
                    Instance.new("UICorner", testNote).CornerRadius = UDim.new(0, 4)

                    local targetPos = (bFrame and bFrame.Position) or UDim2.new(0.1, 0, 0.8, 0)
                    local tween = TweenService:Create(testNote, TweenInfo.new(1.3, Enum.EasingStyle.Linear), { Position = targetPos })
                    tween:Play()

                    -- Tự dọn sau khi rơi xong
                    task.delay(1.5, function()
                        if testNote and testNote.Parent then
                            testNote:Destroy()
                        end
                    end)
                end
                task.wait(0.4)
            end
            task.wait(0.8)
        end
    end)
end

-- TẠO 1 NÚT ĐÓNG GIAO DIỆN TEST TRÊN MÀN HÌNH ĐỂ KHI BẠN XEM XONG CÓ THỂ TẮT ĐI DỄ DÀNG
local closeGui = Instance.new("ScreenGui")
closeGui.Name = "MiniGameTestControlGui"
closeGui.ResetOnSpawn = false
pcall(function()
    if gethui then
        closeGui.Parent = gethui()
    else
        closeGui.Parent = pg
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 220, 0, 46)
closeBtn.Position = UDim2.new(0.5, -110, 0.15, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "❌ ĐÓNG 5 MINI GAME ẢO"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 9999
closeBtn.Parent = closeGui
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", closeBtn)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5

closeBtn.MouseButton1Click:Connect(function()
    for obj, origVis in pairs(origStates) do
        pcall(function() obj.Visible = origVis end)
    end
    pcall(function() fUI.Visible = false end)
    closeGui:Destroy()
    Notify("Đã Đóng", "Đã khôi phục lại trạng thái ban đầu!", 3)
end)
