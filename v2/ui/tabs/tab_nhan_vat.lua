--[[
    v2/ui/tabs/tab_nhan_vat.lua
    Character Physics, Fly, Noclip, Walk on Water, Anti-AFK & Visual Spoofing
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Character = require(script.Parent.Parent.Parent.features.character)
local Spoof = require(script.Parent.Parent.Parent.features.spoof)
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabNhanVat = {}

function TabNhanVat.Render(parent)
    Components.CreateCategoryHeader(parent, "🏃 Di Chuyển & Thể Chất")
    local cardMove = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardMove, "Tăng Tốc Độ Chạy (Speed)", "Tăng tốc độ di chuyển của nhân vật", Config.WalkSpeedEnabled, function(v)
        Config.WalkSpeedEnabled = v
        Character.ApplySpeed(Config)
    end)
    Components.CreateSliderRow(cardMove, "Chỉnh Tốc Độ", "Tốc độ chạy mong muốn", 16, 120, Config.WalkSpeedValue or 16, false, "", function(v)
        Config.WalkSpeedValue = v
        Character.ApplySpeed(Config)
    end)

    Components.CreateToggleRow(cardMove, "Bay Lượn Tự Do (Fly)", "Bay lượn tự do phím WASD + Space/Shift", Config.FlyEnabled, function(v)
        Config.FlyEnabled = v
    end)
    Components.CreateSliderRow(cardMove, "Tốc Độ Bay", "Tốc độ bay trên không trung", 20, 150, Config.FlySpeed or 50, false, "", function(v)
        Config.FlySpeed = v
    end)

    Components.CreateToggleRow(cardMove, "Đi Xuyên Tường (Noclip)", "Đi xuyên qua mọi vật cản và địa hình", Config.Noclip, function(v)
        Config.Noclip = v
    end)
    Components.CreateToggleRow(cardMove, "Đi Trên Mặt Nước", "Tạo bệ vô hình để đứng trên mặt biển", Config.WalkOnWater, function(v)
        Config.WalkOnWater = v
        Character.ApplyWalkOnWater(Config)
    end)
    Components.CreateToggleRow(cardMove, "Nhảy Vô Hạn (Infinite Jump)", "Nhảy liên tục trên không", Config.InfiniteJump, function(v)
        Config.InfiniteJump = v
    end)

    Components.CreateCategoryHeader(parent, "🎭 Ảo Hoá Tài Sản (Visual Spoof)")
    local cardSpoof = Components.CreateCardGroup(parent)

    local targetGems = Spoof.fakeGems or 0
    local targetTickets = Spoof.fakeTicket or 0

    Components.CreateInputRow(cardSpoof, "Số Gems Ảo", "Nhập số lượng Gems muốn hiển thị trên màn hình", tostring(targetGems), function(v)
        local n = tonumber(v)
        if n and n >= 0 then targetGems = n end
    end, nil, "VD: 9999999")

    Components.CreateButtonRow(cardSpoof, "Áp Dụng Gems Ảo", "Đổi giao diện hiển thị Gems sang con số trên", "Đổi Gems", function()
        Spoof.fakeGems = targetGems
        Spoof.Save()
        Spoof.Apply(false)
        Utils.ShowNotification("Visual Spoof", "Đã ảo hóa Gems thành: " .. Spoof.FormatWithSpaces(targetGems), "SUCCESS", 4)
    end)

    Components.CreateInputRow(cardSpoof, "Số Vé Ảo (Tickets)", "Nhập số lượng vé muốn hiển thị", tostring(targetTickets), function(v)
        local n = tonumber(v)
        if n and n >= 0 then targetTickets = n end
    end, nil, "VD: 100")

    Components.CreateButtonRow(cardSpoof, "Áp Dụng Vé Ảo", "Đổi giao diện hiển thị Vé sang con số trên", "Đổi Vé", function()
        Spoof.fakeTicket = targetTickets
        Spoof.Save()
        Spoof.Apply(false)
        Utils.ShowNotification("Visual Spoof", "Đã ảo hóa Vé thành: " .. tostring(targetTickets), "SUCCESS", 4)
    end)

    Components.CreateButtonRow(cardSpoof, "Khôi Phục Thực Tế (Reset)", "Trả lại số Gems và Vé thật của tài khoản", "Reset", function()
        Spoof.fakeGems = 0
        Spoof.fakeTicket = 0
        Spoof.Save()
        Spoof.Apply(true)
        Utils.ShowNotification("Visual Spoof", "Đã khôi phục số dư thật!", "INFO", 4)
    end)

    Components.CreateCategoryHeader(parent, "🛡️ Hệ Thống & Chống Treo")
    local cardSystem = Components.CreateCardGroup(parent)
    Components.CreateToggleRow(cardSystem, "Chống Văng Game (Anti-AFK)", "Ngăn chặn bị kick khi treo máy qua đêm", Config.AntiAFK, function(v)
        Config.AntiAFK = v
    end)
    Components.CreateToggleRow(cardSystem, "Tự Động Kết Nối Lại", "Tự động rejoin nếu bị ngắt kết nối mạng", Config.AutoRejoin, function(v)
        Config.AutoRejoin = v
    end)
end

return TabNhanVat
