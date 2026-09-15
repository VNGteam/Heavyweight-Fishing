--[[
    v2/ui/tabs/tab_dich_chuyen.lua
    Exact Tab Dịch Chuyển from backup.lua (Islands, Boss Realms, Players, NPCs, Server Hop)
--]]

local Components = require(script.Parent.Parent.components)
local Teleport = require(script.Parent.Parent.Parent.features.teleport)
local Services = require(script.Parent.Parent.Parent.core.services)

local TabDichChuyen = {}

function TabDichChuyen.Render(parent)
    Components.CreateCategoryHeader(parent, "Dịch Chuyển Đến Các Đảo")
    local cardIslands = Components.CreateCardGroup(parent)

    local islandList = {
        { name = "Đảo Khởi Đầu (Starter Isle)", pos = Vector3.new(0, 15, 0) },
        { name = "Đảo Tre (Bamboo Isle)", pos = Vector3.new(-1187.8, 7.5, -22.5) },
        { name = "Đảo Phóng Xạ (Fallout Isle)", pos = Vector3.new(12.0, 19.0, 1413.0) },
        { name = "Đảo Cá Chép (Perch Isle)", pos = Vector3.new(-85.3, 9.3, -1340.8) },
        { name = "Đảo Băng Tuyết (Glacier Isle)", pos = Vector3.new(650, 20, -1200) },
        { name = "Đảo Núi Lửa (Volcano Isle)", pos = Vector3.new(-1400, 25, 800) },
        { name = "Đại Dương Sâu (Deep Ocean)", pos = Vector3.new(2000, 10, 2000) },
        { name = "Vực Thẳm (Abyssal Trench)", pos = Vector3.new(-2500, 5, -3000) }
    }

    for _, isl in ipairs(islandList) do
        Components.CreateButtonRow(cardIslands, isl.name, "Bay đến đảo ngay lập tức", "Bay Tới", function()
            Teleport.To(isl.pos)
        end)
    end

    Components.CreateCategoryHeader(parent, "Dịch Chuyển Tới Người Chơi")
    local cardPlr = Components.CreateCardGroup(parent)
    local plrNames = {}
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Services.LocalPlayer then table.insert(plrNames, p.Name) end
    end
    if #plrNames == 0 then table.insert(plrNames, "Không có ai khác") end

    local selectedPlr = plrNames[1]
    Components.CreateDropdownRow(cardPlr, "Chọn Người Chơi", "Danh sách người chơi trong phòng", plrNames, selectedPlr, function(v)
        selectedPlr = v
    end)
    Components.CreateButtonRow(cardPlr, "Bay Tới Người Chơi Đã Chọn", "Dịch chuyển tức thời đến tọa độ người chơi", "Bay Tới", function()
        if selectedPlr and selectedPlr ~= "Không có ai khác" then
            Teleport.ToPlayer(selectedPlr)
        end
    end)

    Components.CreateCategoryHeader(parent, "Chuyển Server (Server Hop)")
    local cardHop = Components.CreateCardGroup(parent)
    Components.CreateButtonRow(cardHop, "Chuyển Server Khác (Hop Server)", "Tìm server ngẫu nhiên còn chỗ và chuyển vào", "Đổi Server", function()
        Teleport.ServerHop()
    end)
end

return TabDichChuyen
