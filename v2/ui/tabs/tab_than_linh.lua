--[[
    v2/ui/tabs/tab_than_linh.lua
    Exact Tab Thần Linh from backup.lua (God Spirit, Taoist, Maoshan Pray & Server Hop)
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config

local TabThanLinh = {}

function TabThanLinh.Render(parent)
    Components.CreateCategoryHeader(parent, "Cúng Bái & Đổi Server Thần Linh")
    local cardGod = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardGod, "Tự Động Quét Trạng Thái Thần Linh", "Liên tục kiểm tra Thần Linh xuất hiện trong game", Config.AutoGodSpiritCheck, function(v) Config.AutoGodSpiritCheck = v end)
    Components.CreateToggleRow(cardGod, "Tự Động Cầu Nguyện Thần Linh", "Tự động gửi yêu cầu cầu nguyện khi đứng gần", Config.AutoPrayGodSpirit, function(v) Config.AutoPrayGodSpirit = v end)
    Components.CreateToggleRow(cardGod, "Đổi Server Tìm Thần Linh", "Tự động đổi máy chủ nếu chưa có Thần Linh", Config.AutoServerHopGod, function(v) Config.AutoServerHopGod = v end)
    Components.CreateToggleRow(cardGod, "Đổi Server Tìm Maoshan", "Tự đổi máy chủ săn NPC Mao Sơn", Config.AutoServerHopMaoshan, function(v) Config.AutoServerHopMaoshan = v end)
    Components.CreateToggleRow(cardGod, "Đổi Server Tìm Đạo Sĩ (Taoist)", "Tự đổi máy chủ săn NPC Đạo Sĩ", Config.AutoServerHopTaoist, function(v) Config.AutoServerHopTaoist = v end)
end

return TabThanLinh
