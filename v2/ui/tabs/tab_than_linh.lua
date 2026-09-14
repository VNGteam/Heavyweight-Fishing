--[[
    v2/ui/tabs/tab_than_linh.lua
    Tab 5: Thần Linh & NPC (God Spirit & Taoist / Maoshan)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)

local TabThanLinh = {}

function TabThanLinh.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Bái Thần & NPC Đạo Sĩ")
    local cardGod = Components.CreateCardGroup(parent)

    State.UIControllers["AutoGodPray"] = Components.CreateToggleRow(cardGod, "Tự Động Bái Thần (Auto Pray)", "Tự động gửi yêu cầu bái Thần Linh mỗi khi hồi cooldown", config.AutoGodPray, function(v)
        config.AutoGodPray = v
    end)

    State.UIControllers["AutoServerHopTaoist"] = Components.CreateToggleRow(cardGod, "Tự Hop Server Tìm Đạo Sĩ", "Tự động đổi server nếu server hiện tại không có Đạo Sĩ", config.AutoServerHopTaoist, function(v)
        config.AutoServerHopTaoist = v
    end)

    State.UIControllers["AutoServerHopMaoshan"] = Components.CreateToggleRow(cardGod, "Tự Hop Server Tìm Mao Sơn", "Tự động đổi server tìm NPC Mao Sơn", config.AutoServerHopMaoshan, function(v)
        config.AutoServerHopMaoshan = v
    end)
end

return TabThanLinh
