--[[
    v2/ui/tabs/tab_shop.lua
    Exact Tab Shop & Chế Mồi from backup.lua (Bait crafting/buying & Rod Shop)
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Shop = require(script.Parent.Parent.Parent.features.shop)

local TabShop = {}

function TabShop.Render(parent)
    Components.CreateCategoryHeader(parent, "Tự Động Chế Mồi & Mua Mồi")
    local cardBait = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardBait, "Tự Động Chế Mồi", "Tự động chế mồi khi đủ nguyên liệu", Config.AutoCraftBait, function(v) Config.AutoCraftBait = v end)
    Components.CreateDropdownRow(cardBait, "Chọn Mồi Cần Chế", "Loại mồi muốn tự động chế", {"Nameless Bait", "Abyssal Bait", "Kraken Bait", "Secret Bait"}, Config.CraftBaitName or "Nameless Bait", function(v) Config.CraftBaitName = v end)
    Components.CreateSliderRow(cardBait, "Số Lượng Chế Mỗi Lần", "Số lượng mồi chế mỗi lượt", 1, 10, Config.CraftAmount or 1, false, " cái", function(v) Config.CraftAmount = v end)

    Components.CreateToggleRow(cardBait, "Tự Động Mua Mồi", "Tự động mua mồi khi số lượng dưới ngưỡng", Config.AutoBuyBait, function(v) Config.AutoBuyBait = v end)
    Components.CreateDropdownRow(cardBait, "Chọn Mồi Cần Mua", "Loại mồi muốn tự động mua tại cửa hàng", {"Ancestral Bait", "Midnight Bait", "Basic Bait"}, Config.BuyBaitName or "Ancestral Bait", function(v) Config.BuyBaitName = v end)
    Components.CreateSliderRow(cardBait, "Số Lượng Mua Mỗi Lần", "Số lượng mua mỗi lần gửi yêu cầu", 1, 20, Config.BuyBaitAmount or 5, false, " cái", function(v) Config.BuyBaitAmount = v end)
    Components.CreateSliderRow(cardBait, "Ngưỡng Tự Mua (Khi Dưới)", "Khi số mồi trong túi ít hơn mức này sẽ mua thêm", 5, 50, Config.BuyBaitThreshold or 10, false, " cái", function(v) Config.BuyBaitThreshold = v end)

    Components.CreateCategoryHeader(parent, "🎣 Cửa Hàng Cần Câu (Rod Shop)")
    local rodShopCard = Components.CreateCollapsibleCardGroup(parent, "Danh Sách Cần Câu Có Thể Mua / Trang Bị", true)

    local rods = {
        { name = "Wooden Rod", price = "$0", power = 8 },
        { name = "Bamboo Rod", price = "$100", power = 11 },
        { name = "Iron Hook Rod", price = "$500", power = 13 },
        { name = "Steel Rod", price = "$1,000", power = 17 },
        { name = "Enchanted Steel Rod", price = "$2,000", power = 19 },
        { name = "Alloy Rod", price = "$5,000", power = 22 },
        { name = "Emerald Rod", price = "$10,000", power = 25 },
        { name = "Bloodfire Rod", price = "$20,000", power = 27 },
        { name = "Shadow Rod", price = "$60,000", power = 29 },
        { name = "Triple Steel Rod", price = "$100,000", power = 32 },
        { name = "Golden Rod", price = "$200,000", power = 35 },
        { name = "Grandmaster Steel Rod", price = "$250,000", power = 37 },
        { name = "Grandmaster Golden Rod", price = "$1,000,000", power = 45 },
        { name = "Steel Spine Rod", price = "$1,500,000", power = 48 },
        { name = "Inferno Rod", price = "$1,500,000", power = 48 },
        { name = "Golden Spine Rod", price = "$2,000,000", power = 51 },
        { name = "Platinum Spine Rod", price = "$3,000,000", power = 54 },
        { name = "Diamond Spine Rod", price = "$4,000,000", power = 56 },
        { name = "Gravisteel Rod", price = "$5,000,000", power = 58 },
        { name = "Auric Gravity Rod", price = "$6,000,000", power = 60 },
        { name = "Inferno Gravity Rod", price = "$7,000,000", power = 62 },
        { name = "Cryo Gravity Rod", price = "$8,000,000", power = 65 },
        { name = "Thunder Thorn Rod", price = "$10,000,000", power = 67 },
        { name = "Starlight Rod", price = "$60,000,000", power = 83 },
    }

    for _, r in ipairs(rods) do
        local desc = string.format("Giá: %s | Sức kéo: %d", r.price, r.power)
        Components.CreateButtonRow(rodShopCard, r.name, desc, "Trang Bị", function()
            Shop.EquipRod(r.name)
        end)
    end
end

return TabShop
