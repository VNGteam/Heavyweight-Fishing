--[[
    v2/features/shop.lua
    Auto Sell, Bait Purchasing & Crafting, Rod Shop & Daily Rewards
--]]

local Services = require(script.Parent.Parent.core.services)
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.core.utils)

local Shop = {}

Shop.lastSellTime = 0
Shop.lastBaitBuyTime = 0
Shop.lastBaitCraftTime = 0
Shop.lastDailyClaimTime = 0

-- 1. Auto Sell Fish
function Shop.HandleAutoSell(config)
    if not config.AutoSellFish then return end
    local now = tick()
    local interval = tonumber(config.SellInterval) or 30
    if (now - Shop.lastSellTime < interval) then return end
    Shop.lastSellTime = now

    if Events and Events:FindFirstChild("SellFish") then
        pcall(function()
            local mode = config.AutoSellRarity or "All"
            Events.SellFish:FireServer(mode)
        end)
    end
end

-- 2. Auto Buy Bait
function Shop.HandleBuyBait(config)
    if not config.AutoBuyBait then return end
    local now = tick()
    if (now - Shop.lastBaitBuyTime < 5.0) then return end
    Shop.lastBaitBuyTime = now

    local baitType = config.AutoBuyBaitType or "Basic Bait"
    if Events and Events:FindFirstChild("BuyBait") then
        pcall(function()
            Events.BuyBait:FireServer(baitType)
        end)
    end
end

-- 3. Auto Craft Bait
function Shop.HandleCraftBait(config)
    if not config.AutoCraftBait then return end
    local now = tick()
    if (now - Shop.lastBaitCraftTime < 5.0) then return end
    Shop.lastBaitCraftTime = now

    local baitType = config.AutoCraftBaitType or "Secret Bait"
    if Events and Events:FindFirstChild("CraftBait") then
        pcall(function()
            Events.CraftBait:FireServer(baitType)
        end)
    end
end

-- 4. Auto Claim Daily Reward
function Shop.HandleDailyClaim(config)
    if not config.AutoClaimDaily then return end
    local now = tick()
    if (now - Shop.lastDailyClaimTime < 300) then return end
    Shop.lastDailyClaimTime = now

    if Events and Events:FindFirstChild("ClaimDaily") then
        pcall(function()
            Events.ClaimDaily:FireServer()
        end)
    end
end

-- 5. Rod Shop Helpers
function Shop.IsRodOwned(rodName)
    if not rodName or rodName == "Wooden Rod" then return true end
    local pData = LocalPlayer:FindFirstChild("Data")
    if pData then
        local inv = pData:FindFirstChild("FishingRodInventory") or pData:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild(rodName) then return true end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild(rodName) then return true end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild(rodName) then return true end
    return false
end

function Shop.EquipRod(rodName)
    if Events and Events:FindFirstChild("EquipFishingRod") then
        pcall(function()
            Events.EquipFishingRod:FireServer(rodName)
            Utils.ShowNotification("Cần Câu", "Đã trang bị cần: " .. rodName, "SUCCESS", 3)
        end)
    end
end

return Shop
