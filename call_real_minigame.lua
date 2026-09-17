--[[
    ==================================================================
    🔥 GỌI HÀM KÍCH HOẠT THẬT CỦA MINIGAME BẠCH TUỘC TRONG GAME
    ==================================================================
    Script này sử dụng quyền Executor (Xeno) để:
    1. Quét môi trường của LocalScript "MinigamePhase2" trong PlayerScripts qua getsenv().
    2. Kích hoạt trực tiếp OnClientEvent của RemoteEvent "RhythmStart" & "BossPhase2Setup".
    3. Tự động tìm và gọi hàm bắt đầu minigame nhịp điệu thật của game!
    ==================================================================
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Minigame Caller",
            Text = text or "",
            Duration = duration or 4
        })
    end)
    print(string.format("[Minigame Caller] %s: %s", tostring(title), tostring(text)))
end

Notify("🔍 Đang Tìm Hàm", "Đang quét môi trường mã nguồn MinigamePhase2...", 3)

local Events = ReplicatedStorage:FindFirstChild("Events")
local called = false

-- CÁCH 1: BẮN SỰ KIỆN CLIENT QUA getconnections (RhythmStart & BossPhase2Setup)
if getconnections and Events then
    -- 1. RhythmStart OnClientEvent
    local rStart = Events:FindFirstChild("RhythmStart")
    if rStart and rStart:IsA("RemoteEvent") then
        local conns = getconnections(rStart.OnClientEvent)
        if #conns > 0 then
            print("✅ Tìm thấy", #conns, "hàm kết nối vào Events.RhythmStart.OnClientEvent!")
            for idx, c in ipairs(conns) do
                pcall(function()
                    print("  -> Đang gọi hàm listener #" .. idx .. "...")
                    c:Fire("Nameless Octoparasite", 100, 20000)
                    called = true
                end)
            end
        end
    end

    -- 2. BossPhase2Setup OnClientEvent
    local p2Setup = Events:FindFirstChild("BossPhase2Setup")
    if p2Setup and p2Setup:IsA("RemoteEvent") then
        local conns = getconnections(p2Setup.OnClientEvent)
        if #conns > 0 then
            print("✅ Tìm thấy", #conns, "hàm kết nối vào Events.BossPhase2Setup.OnClientEvent!")
            for idx, c in ipairs(conns) do
                pcall(function()
                    print("  -> Đang gọi hàm listener #" .. idx .. "...")
                    c:Fire("Nameless Octoparasite")
                    called = true
                end)
            end
        end
    end
end

-- CÁCH 2: DÙNG getsenv ĐỂ TRUY CẬP VÀ GỌI TRỰC TIẾP HÀM BÊN TRONG LocalScript MinigamePhase2
if getsenv then
    local pScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    local mgScript = pScripts and (pScripts:FindFirstChild("MinigamePhase2") or pScripts:FindFirstChild("BossUI"))
    if mgScript then
        local ok, env = pcall(function() return getsenv(mgScript) end)
        if ok and type(env) == "table" then
            print("✅ Đã đọc thành công biến môi trường của MinigamePhase2:")
            for key, val in pairs(env) do
                print("   🔹 Biến/Hàm:", key, type(val))
                if type(val) == "function" then
                    local lowerKey = tostring(key):lower()
                    if lowerKey:find("start") or lowerKey:find("play") or lowerKey:find("rhythm") or lowerKey:find("init") or lowerKey:find("open") or lowerKey:find("spawn") then
                        print("   🎯 ĐANG GỌI HÀM:", key)
                        local callOk, callErr = pcall(function()
                            val("Nameless Octoparasite", 100)
                        end)
                        if callOk then
                            called = true
                            print("   🎉 Gọi hàm", key, "thành công!")
                        else
                            warn("   ⚠️ Lỗi khi gọi", key, ":", callErr)
                        end
                    end
                end
            end
        end
    end
end

-- CÁCH 3: NẾU GAME ĐÒI HỎI ATTRIBUTE HOẶC GUI FISHING
pcall(function()
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("Minigame", true)
        char:SetAttribute("Fishing", true)
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local fUI = pg and pg:FindFirstChild("MainGui") and pg.MainGui:FindFirstChild("Fishing")
    if fUI then
        fUI.Visible = true
        local rhythm = fUI:FindFirstChild("Rhythm")
        if rhythm then
            rhythm.Visible = true
        end
    end
end)

if called then
    Notify("🎉 ĐÃ GỌI HÀM THÀNH CÔNG!", "Minigame của game đã được kích hoạt!", 5)
else
    Notify("⚠️ Đã Kích Hoạt GUI", "Đã bật GUI & Set Attribute Minigame!", 4)
end
