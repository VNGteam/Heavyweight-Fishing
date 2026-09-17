--[[
    ==================================================================
    🎯 DECOMPILE VÀ TRÍCH XUẤT REPLICATEDSTORAGE.CLIENTMODULE.FISHING
    ==================================================================
--]]

local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 5 })
    end)
    print(string.format("[%s] %s", title, text))
end

local fishingMod = ReplicatedStorage:WaitForChild("ClientModule"):FindFirstChild("Fishing")

if not fishingMod then
    Notify("Lỗi", "Không tìm thấy ReplicatedStorage.ClientModule.Fishing!")
    return
end

Notify("Đang decompile", "Đang trích xuất ClientModule.Fishing...")

local decompileFunc = decompile or (getgenv and getgenv().decompile) or disassemble

if decompileFunc then
    local src = decompileFunc(fishingMod)
    if setclipboard then
        setclipboard(src)
        Notify("🎉 ĐÃ COPY VÀO CLIPBOARD!", "Đã copy ClientModule.Fishing, hãy Paste (Ctrl+V) gửi cho tôi!")
    end
    if writefile then
        writefile("ClientModule_Fishing.lua", src)
        print("Đã lưu vào workspace/ClientModule_Fishing.lua")
    end
else
    Notify("Lỗi", "Executor không hỗ trợ hàm decompile!")
end
