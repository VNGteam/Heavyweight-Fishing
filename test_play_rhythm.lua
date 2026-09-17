--[[
    ==================================================================
    🎮 TEST VÀ CHẠY THẬT MINIGAME RHYTHM A-S-D (GAME GỐC 100%)
    Dựa trên mã nguồn trích xuất từ ReplicatedStorage.ClientModule.Fishing
    ==================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 })
    end)
    print(string.format("[%s] %s", title, text))
end

-- 1. Chuẩn bị dữ liệu môi trường để vượt qua kiểm tra của game gốc:
local testFishID = "TestBoss_Octo"
LocalPlayer:SetAttribute("FishID", testFishID)

local fishesFolder = workspace:FindFirstChild("Fishes")
if not fishesFolder then
    fishesFolder = Instance.new("Folder")
    fishesFolder.Name = "Fishes"
    fishesFolder.Parent = workspace
end

local fishModel = fishesFolder:FindFirstChild(testFishID)
if not fishModel then
    fishModel = Instance.new("Model")
    fishModel.Name = testFishID
    fishModel.Parent = fishesFolder
end

local healthVal = fishModel:FindFirstChild(LocalPlayer.UserId .. "_PlayerHealth")
if not healthVal then
    healthVal = Instance.new("NumberValue")
    healthVal.Name = LocalPlayer.UserId .. "_PlayerHealth"
    healthVal.Value = 1000
    healthVal.Parent = fishModel
end

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
if char and not char:GetAttribute("Type") then
    char:SetAttribute("Type", "Fishing Rod")
end

-- 2. Đảm bảo giao diện Fishing hiển thị
local pg = LocalPlayer:WaitForChild("PlayerGui")
local mainGui = pg:WaitForChild("MainGui")
local fishingGui = mainGui:WaitForChild("Fishing")
fishingGui.Visible = true

Notify("Minigame Đang Chạy!", "Nốt A, S, D đang rơi! Bot Auto Minigame sẽ tự động bấm Perfect 100%!")

-- 3. Gọi hàm listener thật của Events.RhythmStart trong game gốc
local events = ReplicatedStorage:WaitForChild("Events")
local rhythmStart = events:WaitForChild("RhythmStart")

local fired = false
if getconnections then
    local conns = getconnections(rhythmStart.OnClientEvent)
    for _, c in ipairs(conns) do
        fired = true
        task.spawn(function()
            if c.Function then
                c.Function({ MiniGameTime = 40 })
            elseif c.Fire then
                c:Fire({ MiniGameTime = 40 })
            end
        end)
    end
end

if not fired and firesignal then
    pcall(function()
        firesignal(rhythmStart.OnClientEvent, { MiniGameTime = 40 })
        fired = true
    end)
end

if not fired then
    Notify("Lưu ý", "Không tìm thấy getconnections/firesignal, đang mô phỏng nốt rơi...")
end
