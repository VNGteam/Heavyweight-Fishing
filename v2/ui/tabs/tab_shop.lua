--[[
    v2/ui/tabs/tab_shop.lua
    Auto Sell with Advanced Protection Filters, Bait Crafting/Buying & Rod Shop
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Shop = require(script.Parent.Parent.Parent.features.shop)
local Services = require(script.Parent.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local Events = Services.Events
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabShop = {}

function TabShop.Render(parent)
    Components.CreateCategoryHeader(parent, "💰 Kinh Tế & Tự Động Bán Cá")
    local sellCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(sellCard, "Tự Động Bán Cá (Auto Sell)", "Tự động bán toàn bộ cá trong balo theo chu kỳ", Config.AutoSell, function(v) Config.AutoSell = v end)
    Components.CreateSliderRow(sellCard, "Thời Gian Giãn Cách Bán", "Chu kỳ số giây tự động bán cá 1 lần", 10, 300, Config.SellInterval, false, "s", function(v) Config.SellInterval = v end)

    Components.CreateButtonRow(sellCard, "Bán Ngay & Bay Đến Nana", "Dịch chuyển tức thì đến NPC Nana và bán cá an toàn", "Bán Ngay", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(-203.5, 7.3, 107.1)
            task.wait(0.3)
            Shop.ProtectAllInventoryItems(Config, false)
            if Events and Events:FindFirstChild("SellFish") then
                Events.SellFish:FireServer("All")
                Utils.ShowNotification("Bán Cá", "Đã bán cá cho NPC Nana thành công!", "SUCCESS", 4)
            end
        end
    end)

    local fishList = {
        "Verdant Alligator Gar", "Verdant Grouper", "Verdant Bonefang", "Crimson Bonefang",
        "Scarlet Fish", "Elder Scarlet Fish", "Crimson Electric Eel", "Golden Dragonfish", "Rainbow Dragonfish",
        "Flying Fish Emperor", "Flying Fish Empress", "Draconic Koi", "Sanguine Fish",
        "Tigerfang Whale", "Heavenpiercer Turtle", "Reborn Puffer Beast", "Frost Kingfish", "Frost Queenfish",
        "Mountain Dragonwhale", "Mirage Lanternfish", "Nameless Octoparasite"
    }

    Components.CreateToggleRow(sellCard, "Tự Động Khóa Cá Đột Biến", "Khóa mọi cá Shiny, Giant, Golden, Albino, Corrupted...", Config.AutoProtectMutations, function(v) Config.AutoProtectMutations = v end)
    Components.CreateToggleRow(sellCard, "Giữ Cá Theo Trọng Lượng", "Giữ lại mọi con cá có cân nặng vượt ngưỡng", Config.KeepFishOverWeight, function(v) Config.KeepFishOverWeight = v end)
    Components.CreateSliderRow(sellCard, "Ngưỡng Cân Nặng Giữ (kg)", "Mức cân nặng tối thiểu để giữ cá lại không bán", 100, 1000000, Config.MinWeightToKeep or 1000, true, " kg", function(v) Config.MinWeightToKeep = v end)
    Components.CreateToggleRow(sellCard, "Khóa Cá Quý (Auto Favourite)", "Bảo vệ cá quý hiếm đã chọn, không bao giờ bị bán nhầm", Config.AutoFavouriteFish, function(v) Config.AutoFavouriteFish = v end)
    Components.CreateDropdownRow(sellCard, "Chọn Cá Cần Khóa", "Loại cá cần bảo vệ không bán", fishList, Config.FavouriteFishName or fishList[1], function(v) Config.FavouriteFishName = v end)
    Components.CreateToggleRow(sellCard, "Chế Độ Cày Nguyên Liệu", "Giữ lại cá làm nguyên liệu chế mồi, không bán", Config.MaterialFarming, function(v) Config.MaterialFarming = v end)

    Components.CreateCategoryHeader(parent, "🪱 Tự Động Chế Mồi & Mua Mồi")
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
