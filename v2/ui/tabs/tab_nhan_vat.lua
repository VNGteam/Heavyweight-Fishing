--[[
    v2/ui/tabs/tab_nhan_vat.lua
    Exact Tab Nhân Vật from backup.lua (Speed, Fly, Noclip, Walk on water, Anti-AFK)
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Character = require(script.Parent.Parent.Parent.features.character)

local TabNhanVat = {}

function TabNhanVat.Render(parent)
    Components.CreateCategoryHeader(parent, "Di Chuyển & Thể Chất")
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

    Components.CreateCategoryHeader(parent, "Hệ Thống & Chống Treo")
    local cardSystem = Components.CreateCardGroup(parent)
    Components.CreateToggleRow(cardSystem, "Chống Văng Game (Anti-AFK)", "Ngăn chặn bị kick khi treo máy qua đêm", Config.AntiAFK, function(v)
        Config.AntiAFK = v
    end)
    Components.CreateToggleRow(cardSystem, "Tự Động Kết Nối Lại", "Tự động rejoin nếu bị ngắt kết nối mạng", Config.AutoRejoin, function(v)
        Config.AutoRejoin = v
    end)
end

return TabNhanVat
