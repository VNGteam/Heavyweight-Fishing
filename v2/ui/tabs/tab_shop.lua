--[[
    v2/ui/tabs/tab_shop.lua
    Tab 6: Cửa Hàng & Chế Mồi (Auto Sell, Buy Bait, Craft Bait, Daily Claim)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)

local TabShop = {}

function TabShop.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Bán Cá Tự Động")
    local cardSell = Components.CreateCardGroup(parent)

    State.UIControllers["AutoSellFish"] = Components.CreateToggleRow(cardSell, "Tự Động Bán Cá (Auto Sell)", "Tự động bán cá theo chu kỳ định sẵn", config.AutoSellFish, function(v)
        config.AutoSellFish = v
    end)

    State.UIControllers["SellInterval"] = Components.CreateSliderRow(cardSell, "Chu Kỳ Bán (Giây)", "Khoảng thời gian giữa 2 lần bán cá", 10, 120, config.SellInterval, false, "s", function(v)
        config.SellInterval = v
    end)

    Components.CreateCategoryHeader(parent, "Mua & Chế Mồi Câu")
    local cardBait = Components.CreateCardGroup(parent)

    State.UIControllers["AutoBuyBait"] = Components.CreateToggleRow(cardBait, "Tự Động Mua Mồi Thường", "Tự động mua mồi cơ bản khi trong túi sắp hết", config.AutoBuyBait, function(v)
        config.AutoBuyBait = v
    end)

    State.UIControllers["AutoCraftBait"] = Components.CreateToggleRow(cardBait, "Tự Động Chế Mồi Nâng Cao", "Tự động chế mồi khi có đủ nguyên liệu", config.AutoCraftBait, function(v)
        config.AutoCraftBait = v
    end)

    Components.CreateCategoryHeader(parent, "Phần Thưởng Hàng Ngày")
    local cardDaily = Components.CreateCardGroup(parent)

    State.UIControllers["AutoClaimDaily"] = Components.CreateToggleRow(cardDaily, "Tự Nhận Thưởng Hàng Ngày", "Tự động nhận quà đăng nhập mỗi ngày", config.AutoClaimDaily, function(v)
        config.AutoClaimDaily = v
    end)
end

return TabShop
