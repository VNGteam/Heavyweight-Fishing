--[[
    v2/ui/tabs/tab_visuals.lua
    Tab 8: ESP & Đồ Họa (Fish ESP, Player ESP, Fullbright)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local Visuals = require(script.Parent.Parent.Parent.features.visuals)

local TabVisuals = {}

function TabVisuals.Render(parent, config)
    Components.CreateCategoryHeader(parent, "ESP Định Vị Mục Tiêu")
    local cardEsp = Components.CreateCardGroup(parent)

    State.UIControllers["ESP_Fish"] = Components.CreateToggleRow(cardEsp, "ESP Vòng Cá (Fish Ring ESP)", "Hiển thị vòng tròn dưới nước quanh vị trí cá", config.ESP_Fish, function(v)
        config.ESP_Fish = v
    end)

    State.UIControllers["ESP_Players"] = Components.CreateToggleRow(cardEsp, "ESP Người Chơi (Player ESP)", "Hiển thị tên và khoảng cách người chơi khác", config.ESP_Players, function(v)
        config.ESP_Players = v
    end)

    State.UIControllers["ESP_Bosses"] = Components.CreateToggleRow(cardEsp, "ESP Boss Bí Mật (Boss ESP)", "Đánh dấu nổi bật Boss trên màn hình", config.ESP_Bosses, function(v)
        config.ESP_Bosses = v
    end)

    Components.CreateCategoryHeader(parent, "Ánh Sáng & Tối Ưu Màn Hình")
    local cardLighting = Components.CreateCardGroup(parent)

    State.UIControllers["Fullbright"] = Components.CreateToggleRow(cardLighting, "Làm Sáng Toàn Bản Đồ (Fullbright)", "Tối đa độ sáng, nhìn rõ dưới đáy biển sâu", config.Fullbright, function(v)
        config.Fullbright = v
        Visuals.ApplyFullbright(v)
    end)
end

return TabVisuals
