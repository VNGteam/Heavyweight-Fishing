--[[
    ========================================================================
    🎣 HEAVYWEIGHT FISHING - TOÀN DIỆN DATA DUMPER & WIKI EXPORTER
    ========================================================================
    Công dụng:
    - Chạy trực tiếp trên Executor (Delta, Codex, Arceus, Wave, Synapse...)
    - Tự động require() toàn bộ ModuleScript trong ReplicatedStorage.Info
    - Trích xuất 100% dữ liệu gốc: 14 Hệ, 14 Nhân Vật, 93 Kỹ Năng, Cần Câu & Thiên Phú
    - Xuất file JSON "Heavyweight_Fishing_Full_Wiki_Data.json" vào thư mục workspace
    ========================================================================
--]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Wiki Dumper",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

Notify("Wiki Dumper", "Bắt đầu trích xuất toàn bộ dữ liệu Game...", 3)

local function safeRequire(mod)
    if not mod or not mod:IsA("ModuleScript") then return nil end
    local ok, res = pcall(require, mod)
    if ok then
        if type(res) == "table" then
            return res
        else
            return { Value = tostring(res) }
        end
    end
    return nil
end

local dumpResult = {
    ExportTime = os.date("%Y-%m-%d %H:%M:%S"),
    Elements = {},
    Characters = {},
    Skills = {},
    Traits = {},
    SupportSkills = {},
    Skins = {},
    Baits = {}
}

local Info = ReplicatedStorage:FindFirstChild("Info")
if not Info then
    Notify("Lỗi Dumper", "Không tìm thấy thư mục ReplicatedStorage.Info!", 5)
    return
end

-- 1. Elements (14 Hệ)
if Info:FindFirstChild("Element") then
    for _, mod in ipairs(Info.Element:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local data = safeRequire(mod)
            dumpResult.Elements[mod.Name] = data or { Name = mod.Name }
        end
    end
end

-- 2. Characters (14 Nhân Vật)
if Info:FindFirstChild("Character") then
    for _, mod in ipairs(Info.Character:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local data = safeRequire(mod)
            dumpResult.Characters[mod.Name] = data or { Name = mod.Name }
        end
    end
end

-- 3. Skills (93 Tuyệt Kỹ)
if Info:FindFirstChild("Skill") then
    for _, mod in ipairs(Info.Skill:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local data = safeRequire(mod)
            dumpResult.Skills[mod.Name] = data or { Name = mod.Name }
        end
    end
end

-- 4. Traits (13 Thiên Phú)
if Info:FindFirstChild("Trait") then
    for _, mod in ipairs(Info.Trait:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local data = safeRequire(mod)
            dumpResult.Traits[mod.Name] = data or { Name = mod.Name }
        end
    end
end

-- 5. Support Skills
if Info:FindFirstChild("SupportSkill") then
    for _, mod in ipairs(Info.SupportSkill:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local data = safeRequire(mod)
            dumpResult.SupportSkills[mod.Name] = data or { Name = mod.Name }
        end
    end
end

-- 6. Rod Skins & Rods
if Info:FindFirstChild("Skin") then
    for _, mod in ipairs(Info.Skin:GetChildren()) do
        if mod:IsA("ModuleScript") then
            local data = safeRequire(mod)
            dumpResult.Skins[mod.Name] = data or { Name = mod.Name }
        end
    end
end

-- Xuất ra JSON
local jsonStr = ""
local encodeOk, encoded = pcall(function()
    return HttpService:JSONEncode(dumpResult)
end)

if encodeOk and encoded then
    jsonStr = encoded
    if writefile then
        writefile("Heavyweight_Fishing_Full_Wiki_Data.json", jsonStr)
        print("✅ [Wiki Dumper] Đã ghi thành công vào: Heavyweight_Fishing_Full_Wiki_Data.json")
        Notify("Thành Công!", "Đã xuất dữ liệu vào Heavyweight_Fishing_Full_Wiki_Data.json!", 7)
    else
        print(jsonStr)
        Notify("Thông Báo", "Executor không có writefile. Dữ liệu đã in ra Console F9!", 7)
    end
else
    Notify("Lỗi Dumper", "Không thể mã hoá JSON dữ liệu!", 5)
end
