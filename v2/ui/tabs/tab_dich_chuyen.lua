--[[
    v2/ui/tabs/tab_dich_chuyen.lua
    Tab 7: Dịch Chuyển (Islands, Players, Server Hop)
--]]

local Components = require(script.Parent.Parent.components)
local Teleport = require(script.Parent.Parent.Parent.features.teleport)

local TabDichChuyen = {}

function TabDichChuyen.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Dịch Chuyển Đến Các Đảo")
    local cardIslands = Components.CreateCardGroup(parent)

    for islandName, pos in pairs(Teleport.islands) do
        Components.CreateButtonRow(cardIslands, islandName, "Bay đến đảo ngay lập tức", "Bay Tới", function()
            Teleport.To(pos)
        end)
    end

    Components.CreateCategoryHeader(parent, "Chuyển Server (Server Hop)")
    local cardHop = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardHop, "Chuyển Server Khác (Hop Server)", "Tìm server ngẫu nhiên còn chỗ và chuyển vào", "Đổi Server", function()
        Teleport.ServerHop()
    end)
end

return TabDichChuyen
