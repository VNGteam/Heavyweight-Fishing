--[[
    v2/features/shop.lua
    Auto Sell with Advanced Protection (Mutations, Weight, Favourites),
    Bait Purchasing & Crafting, Rod Shop & Daily Rewards
--]]

local Services = require(script.Parent.Parent.core.services)
local ReplicatedStorage = Services.ReplicatedStorage
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.core.utils)

local Shop = {}

Shop.lastSellTime = 0
Shop.lastBaitBuyTime = 0
Shop.lastBaitCraftTime = 0
Shop.lastDailyClaimTime = 0
Shop.lastGachaTime = 0

local craftMaterialFish = {
    ["Verdant Alligator Gar"] = true,
    ["Verdant Grouper"] = true,
    ["Verdant Bonefang"] = true,
    ["Crimson Bonefang"] = true,
    ["Scarlet Fish"] = true,
    ["Elder Scarlet Fish"] = true,
    ["Crimson Electric Eel"] = true,
    ["Golden Dragonfish"] = true,
    ["Rainbow Dragonfish"] = true,
    ["Draconic Koi"] = true,
    ["Sanguine Fish"] = true,
}

function Shop.GetPlayerDataFolder()
    local pData = ReplicatedStorage:FindFirstChild("Data")
    if pData and pData:FindFirstChild(tostring(LocalPlayer.UserId)) then
        return pData[tostring(LocalPlayer.UserId)]
    end
    return nil
end

function Shop.IsItemFavorited(item)
    if not item then return false end
    local fav = item:FindFirstChild("Favorite") or item:FindFirstChild("Favorited") or item:FindFirstChild("Locked")
    if fav and fav:IsA("BoolValue") and fav.Value == true then
        return true
    end
    for _, attr in ipairs({"Favorite", "Favorited", "Locked"}) do
        if item:GetAttribute(attr) == true then return true end
    end
    return false
end

function Shop.IsMutatedFish(item)
    if not item then return false end
    local name = tostring(item.Name or "")
    for _, kw in ipairs({"Shiny", "Giant", "Golden", "Albino", "Corrupted", "Colossal", "Heavyweight", "Dark", "Radiant"}) do
        if name:find(kw) then return true end
    end
    local mutVal = item:FindFirstChild("Mutation")
    if mutVal and tostring(mutVal.Value) ~= "" and tostring(mutVal.Value) ~= "None" then
        return true
    end
    for _, attr in ipairs({"Mutation", "Mutated", "Variant"}) do
        local v = item:GetAttribute(attr)
        if v and tostring(v) ~= "" and tostring(v) ~= "None" then
            return true
        end
    end
    return false
end

function Shop.GetItemWeight(item)
    if not item then return 0 end
    local wVal = item:FindFirstChild("Weight") or item:FindFirstChild("Kg")
    if wVal and tonumber(wVal.Value) then
        return tonumber(wVal.Value)
    end
    local wAttr = item:GetAttribute("Weight") or item:GetAttribute("Kg")
    if wAttr and tonumber(wAttr) then
        return tonumber(wAttr)
    end
    local n = tostring(item.Name or "")
    local num = n:match("(%d+%.?%d*)%s*[kK][gG]") or n:match("(%d+%.?%d*)%s*[mM]")
    if num then
        return tonumber(num) or 0
    end
    return 0
end

function Shop.ProtectInventoryItem(item, config, showNotify)
    if not item or Shop.IsItemFavorited(item) then return false end
    local itemName = tostring(item.Name or "")
    local shouldProtect = false
    local reason = ""

    if config.AutoProtectMutations and Shop.IsMutatedFish(item) then
        shouldProtect = true
        reason = "Cá Đột Biến"
    elseif config.KeepFishOverWeight and config.MinWeightToKeep and config.MinWeightToKeep > 0 then
        local w = Shop.GetItemWeight(item)
        if w >= config.MinWeightToKeep then
            shouldProtect = true
            reason = string.format("Trọng Lượng (%.1fkg)", w)
        end
    elseif config.AutoFavouriteFish and config.FavouriteFishName and config.FavouriteFishName ~= "" then
        if itemName:lower():find(config.FavouriteFishName:lower()) then
            shouldProtect = true
            reason = "Cá Quý Chỉ Định"
        end
    elseif config.MaterialFarming and craftMaterialFish[itemName] then
        shouldProtect = true
        reason = "Nguyên Liệu Chế Tạo"
    end

    if shouldProtect and Events and Events:FindFirstChild("FavoriteItem") then
        Events.FavoriteItem:FireServer(item)
        if showNotify then
            Utils.ShowNotification("Khóa Cá", string.format("Đã tự động KHÓA bảo vệ [%s] (%s)!", itemName, reason), "SUCCESS", 5)
        end
        return true
    end
    return false
end

function Shop.ProtectAllInventoryItems(config, showNotify)
    local pData = Shop.GetPlayerDataFolder()
    if pData and pData:FindFirstChild("Inventory") then
        for _, item in ipairs(pData.Inventory:GetChildren()) do
            Shop.ProtectInventoryItem(item, config, showNotify)
        end
    end
end

-- 1. Auto Sell Fish với bộ lọc bảo vệ
function Shop.HandleAutoSell(config)
    if not config.AutoSell then return end
    local now = tick()
    local interval = tonumber(config.SellInterval) or 30
    if (now - Shop.lastSellTime < interval) then return end
    Shop.lastSellTime = now

    Shop.ProtectAllInventoryItems(config, false)

    if Events and Events:FindFirstChild("SellFish") then
        pcall(function()
            Events.SellFish:FireServer("All")
        end)
    end
end

-- 2. Auto Buy Bait
function Shop.HandleBuyBait(config)
    if not config.AutoBuyBait then return end
    local now = tick()
    local delayTime = tonumber(config.BuyBaitDelay) or 1.0
    if (now - Shop.lastBaitBuyTime < delayTime) then return end

    local baitType = config.BuyBaitName or "Ancestral Bait"
    local threshold = tonumber(config.BuyBaitThreshold) or 10
    local amount = tonumber(config.BuyBaitAmount) or 5

    local pData = Shop.GetPlayerDataFolder()
    if pData and pData:FindFirstChild("Bait") then
        local bVal = pData.Bait:FindFirstChild(baitType)
        local count = bVal and tonumber(bVal.Value) or 0
        if count <= threshold then
            Shop.lastBaitBuyTime = now
            if Events and Events:FindFirstChild("BuyBait") then
                pcall(function()
                    Events.BuyBait:FireServer(baitType, amount)
                end)
            end
        end
    end
end

-- 3. Auto Craft Bait
function Shop.HandleCraftBait(config)
    if not config.AutoCraftBait then return end
    local now = tick()
    if (now - Shop.lastBaitCraftTime < 3.0) then return end
    Shop.lastBaitCraftTime = now

    local baitType = config.CraftBaitName or "Nameless Bait"
    local amount = tonumber(config.CraftAmount) or 1

    if Events and Events:FindFirstChild("CraftBait") then
        pcall(function()
            Events.CraftBait:FireServer(baitType, amount)
        end)
    end
end

-- 4. Auto Claim Daily Reward
function Shop.HandleDailyClaim(config)
    if not config.AutoClaimDaily then return end
    local now = tick()
    local delayTime = tonumber(config.DailyClaimDelay) or 0.5
    if (now - Shop.lastDailyClaimTime < (delayTime * 60)) then return end
    Shop.lastDailyClaimTime = now

    if Events and Events:FindFirstChild("ClaimDaily") then
        pcall(function()
            Events.ClaimDaily:FireServer()
        end)
    end
end

-- 4b. Auto Gacha
function Shop.HandleGacha(config)
    if not config.AutoGacha then return end
    local now = tick()
    if (now - (Shop.lastGachaTime or 0) < 1.5) then return end
    Shop.lastGachaTime = now

    local banner = config.GachaBanner or "Taiji Banner"
    local pulls = tonumber(config.GachaPullsPerAction) or 1
    if Events and Events:FindFirstChild("Gacha") then
        pcall(function()
            Events.Gacha:FireServer(banner, pulls)
        end)
    end
end

-- 5. Lắng nghe vật phẩm mới thêm vào kho để khóa bảo vệ ngay lập tức
function Shop.InitInventoryWatcher(config)
    task.spawn(function()
        local pDataInit = ReplicatedStorage:WaitForChild("Data", 10)
        local userFolder = pDataInit and pDataInit:WaitForChild(tostring(LocalPlayer.UserId), 10)
        local invFolder = userFolder and userFolder:WaitForChild("Inventory", 10)
        if invFolder then
            invFolder.ChildAdded:Connect(function(child)
                task.wait(0.3)
                Shop.ProtectInventoryItem(child, config, true)
            end)
        end
    end)
end

-- 6. Rod Shop Helpers
function Shop.IsRodOwned(rodName)
    if not rodName or rodName == "Wooden Rod" then return true end
    local pData = Shop.GetPlayerDataFolder()
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
