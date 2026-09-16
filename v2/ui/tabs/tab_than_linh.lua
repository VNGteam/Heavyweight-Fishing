--[[
    v2/ui/tabs/tab_than_linh.lua
    God Spirit, Taoist, Maoshan Pray, Server Hop & Teleport Controls
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Spirits = require(script.Parent.Parent.Parent.features.spirits)
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabThanLinh = {}

function TabThanLinh.Render(parent)
    Components.CreateCategoryHeader(parent, "🙏 Cúng Bái & Đổi Server Thần Linh")
    local cardGod = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardGod, "Tự Động Quét Trạng Thái Thần Linh", "Liên tục kiểm tra Thần Linh xuất hiện trong game", Config.AutoGodSpiritCheck, function(v) Config.AutoGodSpiritCheck = v end)
    Components.CreateToggleRow(cardGod, "Tự Động Cầu Nguyện Thần Linh", "Tự động gửi yêu cầu cầu nguyện khi đứng gần", Config.AutoPrayGodSpirit, function(v) Config.AutoPrayGodSpirit = v end)
    Components.CreateToggleRow(cardGod, "Đổi Server Tìm Thần Linh", "Tự động đổi máy chủ nếu chưa có Thần Linh", Config.AutoServerHopGod, function(v)
        Config.AutoServerHopGod = v
        Spirits.SaveNPCHopState(Config)
    end)
    Components.CreateToggleRow(cardGod, "Đổi Server Tìm Maoshan", "Tự đổi máy chủ săn NPC Mao Sơn", Config.AutoServerHopMaoshan, function(v)
        Config.AutoServerHopMaoshan = v
        Spirits.SaveNPCHopState(Config)
    end)
    Components.CreateToggleRow(cardGod, "Đổi Server Tìm Đạo Sĩ (Taoist)", "Tự đổi máy chủ săn NPC Đạo Sĩ", Config.AutoServerHopTaoist, function(v)
        Config.AutoServerHopTaoist = v
        Spirits.SaveNPCHopState(Config)
    end)

    Components.CreateCategoryHeader(parent, "📜 Dịch Chuyển Tức Thì Đến NPC")
    local cardTele = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardTele, "📜 Bay Đến Đạo Sĩ (Taoist)", "Dịch chuyển tức thì đến NPC Đạo Sĩ nếu có trong server", "Bay Đến", function()
        local tInst, tName = Spirits.ScanForTaoistNPC()
        if tInst then
            local ok = Spirits.TeleportToNPC(tInst)
            if ok then
                Utils.ShowNotification("Đạo Sĩ (Taoist)", "Đã dịch chuyển đến vị trí " .. tostring(tName) .. "!", "SUCCESS", 5)
            else
                Utils.ShowNotification("Đạo Sĩ (Taoist)", "Không lấy được tọa độ Đạo Sĩ.", "WARN")
            end
        else
            Utils.ShowNotification("Đạo Sĩ (Taoist)", "Server này hiện chưa có Đạo Sĩ (Taoist)! Hãy bật 'Đổi Server Tìm Taoist'.", "WARN", 6)
        end
    end)

    Components.CreateButtonRow(cardTele, "✨ Bay Đến Đạo Sĩ Mao Sơn", "Dịch chuyển tức thì đến NPC Mao Sơn nếu có trong server", "Bay Đến", function()
        local mInst, mName = Spirits.ScanForMaoshanNPC()
        if mInst then
            local ok = Spirits.TeleportToNPC(mInst)
            if ok then
                Utils.ShowNotification("Đạo Sĩ Mao Sơn", "Đã dịch chuyển đến vị trí " .. tostring(mName) .. "!", "SUCCESS", 5)
            else
                Utils.ShowNotification("Đạo Sĩ Mao Sơn", "Không lấy được tọa độ Mao Sơn.", "WARN")
            end
        else
            Utils.ShowNotification("Đạo Sĩ Mao Sơn", "Server này hiện chưa có Mao Sơn! Hãy bật 'Đổi Server Tìm Maoshan'.", "WARN", 6)
        end
    end)

    Components.CreateButtonRow(cardTele, "⚡ Bay Đến Thần Linh (God Spirit)", "Dịch chuyển tức thì đến Thần Linh nếu có trong server", "Bay Đến", function()
        local sp = Spirits.ScanForGodSpirit()
        if sp then
            local ok = Spirits.TeleportToNPC(sp)
            if ok then
                Utils.ShowNotification("Thần Linh", "Đã dịch chuyển đến Thần Linh thành công!", "SUCCESS", 5)
            else
                Utils.ShowNotification("Thần Linh", "Không lấy được tọa độ Thần Linh.", "WARN")
            end
        else
            Utils.ShowNotification("Thần Linh", "Server này hiện chưa có Thần Linh!", "WARN", 5)
        end
    end)
end

return TabThanLinh
