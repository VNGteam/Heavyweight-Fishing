--[[
    v2/ui/tabs/tab_nhan_vat.lua
    Tab 9: Nhân Vật & Tiện Ích (Speed, Fly, Noclip, Walk on Water, Anti-AFK)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local Character = require(script.Parent.Parent.Parent.features.character)

local TabNhanVat = {}

function TabNhanVat.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Di Chuyển & Thể Chất")
    local cardMove = Components.CreateCardGroup(parent)

    State.UIControllers["CustomSpeedEnabled"] = Components.CreateToggleRow(cardMove, "Bật Tốc Độ Tùy Chỉnh", "Tăng tốc độ chạy của nhân vật", config.CustomSpeedEnabled, function(v)
        config.CustomSpeedEnabled = v
        Character.ApplySpeed(config)
    end)

    State.UIControllers["WalkSpeed"] = Components.CreateSliderRow(cardMove, "Tốc Độ Chạy (WalkSpeed)", "Tốc độ chạy mong muốn", 16, 120, config.WalkSpeed, false, "", function(v)
        config.WalkSpeed = v
        Character.ApplySpeed(config)
    end)

    State.UIControllers["NoclipEnabled"] = Components.CreateToggleRow(cardMove, "Đi Xuyên Tường (Noclip)", "Đi xuyên qua mọi vật thể và địa hình", config.NoclipEnabled, function(v)
        config.NoclipEnabled = v
    end)

    State.UIControllers["WalkOnWater"] = Components.CreateToggleRow(cardMove, "Đi Trên Mặt Nước (Walk On Water)", "Tạo bệ đỡ vô hình để đứng trên mặt biển câu cá", config.WalkOnWater, function(v)
        config.WalkOnWater = v
        Character.ApplyWalkOnWater(config)
    end)

    Components.CreateCategoryHeader(parent, "Hệ Thống & Chống Treo")
    local cardSystem = Components.CreateCardGroup(parent)

    State.UIControllers["AntiAFK"] = Components.CreateToggleRow(cardSystem, "Chống Treo Game (Anti-AFK)", "Ngăn chặn bị Roblox kick khi treo máy quá 20 phút", config.AntiAFK, function(v)
        config.AntiAFK = v
    end)
end

return TabNhanVat
