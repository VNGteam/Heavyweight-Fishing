--[[
    ==================================================================
    🎯 TÌM CHÍNH XÁC SCRIPT ĐIỀU KHIỂN RHYTHM (MINIGAME A-S-D)
    ==================================================================
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local StarterGui = game:GetService("StarterGui")

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 })
    end)
    print(string.format("[%s] %s", title, text))
end

local targetScript = nil

-- 1. Tìm qua Events.RhythmStart
if Events:FindFirstChild("RhythmStart") then
    local conns = getconnections(Events.RhythmStart.OnClientEvent)
    print("Số lượng listener kết nối vào RhythmStart:", #conns)
    for i, c in ipairs(conns) do
        local env = getfenv(c.Function)
        local scr = env and rawget(env, "script")
        if scr then
            print("🎯 TÌM THẤY SCRIPT ĐIỀU KHIỂN RHYTHM:", scr:GetFullName())
            targetScript = scr
            break
        end
    end
end

-- 2. Nếu chưa thấy, tìm qua RhythmHit
if not targetScript and Events:FindFirstChild("RhythmHit") then
    local conns = getconnections(Events.RhythmHit.OnClientEvent)
    for i, c in ipairs(conns) do
        local env = getfenv(c.Function)
        local scr = env and rawget(env, "script")
        if scr then
            print("🎯 TÌM THẤY QUA RHYTHMHIT:", scr:GetFullName())
            targetScript = scr
            break
        end
    end
end

-- 3. Decompile script tìm được và copy vào clipboard
if targetScript then
    Notify("Đã Tìm Thấy!", targetScript.Name)
    local decompileFunc = decompile or (getgenv and getgenv().decompile) or disassemble
    if decompileFunc then
        local src = decompileFunc(targetScript)
        if setclipboard then
            setclipboard(src)
            Notify("🎉 ĐÃ COPY VÀO CLIPBOARD!", "Hãy bấm Ctrl+V để gửi mã script " .. targetScript.Name)
        end
        if writefile then
            writefile("RhythmController_" .. targetScript.Name .. ".lua", src)
        end
    end
else
    -- Nếu không có listener vào RhythmStart, tìm trong MainClient
    local mc = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("MainClient")
    if mc then
        Notify("Đang Decompile MainClient", "Đang trích xuất MainClient...")
        local decompileFunc = decompile or (getgenv and getgenv().decompile) or disassemble
        if decompileFunc then
            local src = decompileFunc(mc)
            if setclipboard then
                setclipboard(src)
                Notify("🎉 ĐÃ COPY MAINCLIENT!", "Đã copy mã MainClient vào clipboard!")
            end
        end
    end
end
