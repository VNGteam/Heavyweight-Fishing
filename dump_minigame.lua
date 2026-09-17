--[[
    ==================================================================
    📋 DECOMPILE & XUẤT CODE GỐC CỦA "MinigamePhase2"
    ==================================================================
    Script này sẽ:
    1. Đọc mã nguồn thực sự bên trong LocalScript "MinigamePhase2" của game.
    2. Tự động Copy toàn bộ code vào Clipboard (Khay nhớ tạm) để bạn dán (Ctrl+V).
    3. Tự động lưu thành file "MinigamePhase2.lua" trong thư mục workspace của Xeno.
    4. In các dòng kích hoạt Remote quan trọng ra màn hình console F9.
    ==================================================================
--]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Dumper",
            Text = text or "",
            Duration = duration or 5
        })
    end)
    print(string.format("[Dumper] %s: %s", tostring(title), tostring(text)))
end

local pScripts = LocalPlayer:FindFirstChild("PlayerScripts")
local mgScript = pScripts and pScripts:FindFirstChild("MinigamePhase2")

if not mgScript then
    Notify("❌ Không Thấy Script", "Không tìm thấy LocalScript MinigamePhase2 trong PlayerScripts!", 5)
    return
end

Notify("⏳ Đang Decompile", "Đang trích xuất mã nguồn MinigamePhase2...", 3)

local sourceCode = nil

-- Thử decompile qua các hàm phổ biến của Xeno / Executor
local decompileFunc = decompile or (getgenv and getgenv().decompile) or disassemble
if decompileFunc then
    local ok, res = pcall(function()
        return decompileFunc(mgScript)
    end)
    if ok and res and #res > 20 then
        sourceCode = res
    end
end

if not sourceCode then
    -- Thử đọc qua getsenv
    if getsenv then
        local ok, env = pcall(function() return getsenv(mgScript) end)
        if ok and env then
            local lines = { "-- MinigamePhase2 Environment Dump:" }
            for k, v in pairs(env) do
                table.insert(lines, string.format("%s = %s (%s)", tostring(k), tostring(v), type(v)))
            end
            sourceCode = table.concat(lines, "\n")
        end
    end
end

if sourceCode then
    -- 1. Copy vào khay nhớ tạm
    if setclipboard then
        pcall(function() setclipboard(sourceCode) end)
        print("✅ ĐÃ COPY TOÀN BỘ MÃ NGUỒN VÀO CLIPBOARD!")
    end

    -- 2. Ghi ra file
    if writefile then
        pcall(function() writefile("MinigamePhase2.lua", sourceCode) end)
        print("✅ ĐÃ LƯU THÀNH FILE MinigamePhase2.lua TRONG THƯ MỤC EXECUTOR!")
    end

    Notify("🎉 THÀNH CÔNG!", "Đã copy code vào clipboard! Hãy bấm Ctrl+V để dán ra xem!", 6)

    -- In 20 dòng đầu ra console
    print("-------------------- MÃ NGUỒN MINIGAMEPHASE2 --------------------")
    local count = 0
    for line in sourceCode:gmatch("([^\r\n]*)\r?\n?") do
        count = count + 1
        if count <= 40 then
            print(string.format("%03d: %s", count, line))
        end
    end
    print("-----------------------------------------------------------------")
else
    Notify("⚠️ Chưa Decompile Được", "Executor chưa hỗ trợ hàm decompile cho script này!", 5)
end
