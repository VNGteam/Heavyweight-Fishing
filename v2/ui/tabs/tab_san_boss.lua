--[[
    v2/ui/tabs/tab_san_boss.lua
    Tab 3: Săn Boss (Secret Boss Targets, Fast Skip & Chat Sniper)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local Boss = require(script.Parent.Parent.Parent.features.boss)

local TabSanBoss = {}

function TabSanBoss.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Cơ Chế Săn Boss Nhanh")
    local cardFast = Components.CreateCardGroup(parent)

    State.UIControllers["FastSkipNonTarget"] = Components.CreateToggleRow(cardFast, "Fast-Skip (Hủy Cá Rác)", "Tự hủy cần ngay lập tức nếu cá cắn câu không phải Boss được chọn", config.FastSkipNonTarget, function(v)
        config.FastSkipNonTarget = v
    end)

    State.UIControllers["AutoChatSecretBoss"] = Components.CreateToggleRow(cardFast, "Sniper Kênh Chat", "Tự động dịch chuyển đến đảo ngay khi có thông báo Boss xuất hiện trong chat", config.AutoChatSecretBoss, function(v)
        config.AutoChatSecretBoss = v
    end)

    State.UIControllers["SecretBossAlertWebhook"] = Components.CreateToggleRow(cardFast, "Gửi Thông Báo Webhook Discord", "Gửi cảnh báo đến Discord khi móc câu thành công Secret Boss", config.SecretBossAlertWebhook, function(v)
        config.SecretBossAlertWebhook = v
    end)

    -- Danh sách Boss bí mật để chọn mục tiêu
    Components.CreateCategoryHeader(parent, "Danh Sách Mục Tiêu Secret Boss")
    local bossListCard = Components.CreateCollapsibleCardGroup(parent, "Chọn Boss Cần Săn (" .. tostring(15) .. "+ Loại)", true)

    for bossName in pairs(Boss.lookup) do
        local isTarget = config.SecretBossTargets and config.SecretBossTargets[bossName] == true
        Components.CreateToggleRow(bossListCard, bossName, "Khu vực: " .. (Boss.lookup[bossName].islandName or "Đại dương"), isTarget, function(v)
            if not config.SecretBossTargets then config.SecretBossTargets = {} end
            config.SecretBossTargets[bossName] = v
        end)
    end
end

return TabSanBoss
