--[[
    v2/ui/tabs/tab_quan_ly_ca.lua
    Fish Manager: Safe Junk Cleaning, Search & Batch Lock/Unlock, Rod & Bait Crafting Trackers
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Services = require(script.Parent.Parent.Parent.core.services)
local ReplicatedStorage = Services.ReplicatedStorage
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.Parent.core.utils)
local Shop = require(script.Parent.Parent.Parent.features.shop)

local TabQuanLyCa = {}

-- Danh sách các loài cá nguyên liệu quý chế Cần & Mồi
local protectedFishNames = {
    ["Verdant Alligator Gar"] = "Mồi Thần Thoại",
    ["Verdant Grouper"] = "Mồi Thần Thoại",
    ["Verdant Bonefang"] = "Mồi Thần Thoại",
    ["Crimson Bonefang"] = "Cần / Mồi Quý",
    ["Scarlet Fish"] = "Cần Sanguine",
    ["Elder Scarlet Fish"] = "Cần Sanguine",
    ["Crimson Electric Eel"] = "Cần Sanguine",
    ["Golden Dragonfish"] = "Cần Dragon",
    ["Rainbow Dragonfish"] = "Cần Thần Thoại",
    ["Draconic Koi"] = "Cần Dragon",
    ["Sanguine Fish"] = "Cần Sanguine",
    ["Crimson Bream"] = "Cần / Mồi Quý",
}

function TabQuanLyCa.ScanAndClassify()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
    local inv = pData and pData:FindFirstChild("Inventory")

    local protList = {}
    local junkList = {}
    local countsByName = {}

    if not inv then
        return protList, junkList, countsByName
    end

    for _, item in ipairs(inv:GetChildren()) do
        local rawName = tostring(item.Name or "")
        local cleanName = rawName:gsub("^%[.-%]%s*", ""):gsub("%s*%b()", ""):gsub("%s*x%d+$", ""):match("^%s*(.-)%s*$") or rawName
        local weight = Shop.GetItemWeight(item)
        local isFav = Shop.IsItemFavorited(item)
        local isMut = Shop.IsMutatedFish(item)
        local isSpecial = protectedFishNames[cleanName] ~= nil

        local entry = {
            item = item,
            name = cleanName,
            weight = weight,
            isLocked = isFav,
            isMut = isMut,
            isSpecial = isSpecial,
            specialReason = protectedFishNames[cleanName]
        }

        if not countsByName[cleanName] then
            countsByName[cleanName] = {
                name = cleanName,
                total = 0,
                locked = 0,
                unlocked = 0,
                items = {}
            }
        end
        countsByName[cleanName].total = countsByName[cleanName].total + 1
        if isFav then
            countsByName[cleanName].locked = countsByName[cleanName].locked + 1
        else
            countsByName[cleanName].unlocked = countsByName[cleanName].unlocked + 1
        end
        table.insert(countsByName[cleanName].items, entry)

        local shouldProtect = isFav or isMut or isSpecial or (Config.KeepHeavyFish and weight >= (Config.HeavyFishThreshold or 1000))
        if shouldProtect then
            table.insert(protList, entry)
        else
            table.insert(junkList, entry)
        end
    end

    return protList, junkList, countsByName
end

function TabQuanLyCa.Render(parent)
    local isBusy = false

    -- ============================================================
    -- 1. QUẢN LÝ TÚI CÁ & DỌN RÁC AN TOÀN
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🛡️ Quản Lý Túi Cá & Dọn Rác An Toàn")
    local bagCard = Components.CreateCardGroup(parent)

    local rowTotal = Components.CreateInfoRow(bagCard, "Tổng cá trong Balo", "Đang quét...")
    local rowProtected = Components.CreateInfoRow(bagCard, "Cá quý đang bảo vệ", "...")
    local rowJunk = Components.CreateInfoRow(bagCard, "Cá rác có thể bán an toàn", "...")

    local function refreshOverview()
        local protList, junkList, _ = TabQuanLyCa.ScanAndClassify()
        local total = #protList + #junkList
        if rowTotal and rowTotal.Set then rowTotal.Set(string.format("%d con", total)) end
        if rowProtected and rowProtected.Set then rowProtected.Set(string.format("%d con (Đột biến / Cần / Mồi / Khóa)", #protList)) end
        if rowJunk and rowJunk.Set then rowJunk.Set(string.format("%d con (Có thể bán ngay)", #junkList)) end
    end

    task.spawn(function()
        while true do
            task.wait(2.5)
            pcall(refreshOverview)
        end
    end)

    Components.CreateButtonRow(bagCard, "Khóa Toàn Bộ Cá Quý", "Bảo vệ cá Đột Biến, Nguyên Liệu Chế Cần & Mồi", "🔒 Khóa Cá Quý", function()
        if isBusy then return end
        isBusy = true
        task.spawn(function()
            local protList, _, _ = TabQuanLyCa.ScanAndClassify()
            local favEvent = Events and Events:FindFirstChild("FavoriteItem")
            if not favEvent then
                Utils.ShowNotification("Lỗi", "Không tìm thấy Remote FavoriteItem!", "ERROR", 3)
                isBusy = false
                return
            end
            local count = 0
            for _, p in ipairs(protList) do
                if not p.isLocked and p.item and p.item.Parent then
                    pcall(function() favEvent:FireServer(p.item) end)
                    count = count + 1
                    task.wait(0.04)
                end
            end
            Utils.ShowNotification("Bảo Vệ Cá Quý", string.format("Đã khóa an toàn %d con cá quý!", count), "SUCCESS", 4)
            refreshOverview()
            isBusy = false
        end)
    end)

    Components.CreateButtonRow(bagCard, "Mở Khóa Riêng Cá Rác", "Mở khóa toàn bộ cá thường để chuẩn bị bán", "🔓 Mở Khóa Rác", function()
        if isBusy then return end
        isBusy = true
        task.spawn(function()
            local _, junkList, _ = TabQuanLyCa.ScanAndClassify()
            local favEvent = Events and Events:FindFirstChild("FavoriteItem")
            if not favEvent then
                Utils.ShowNotification("Lỗi", "Không tìm thấy Remote FavoriteItem!", "ERROR", 3)
                isBusy = false
                return
            end
            local count = 0
            for _, j in ipairs(junkList) do
                if j.isLocked and j.item and j.item.Parent then
                    pcall(function() favEvent:FireServer(j.item) end)
                    count = count + 1
                    task.wait(0.04)
                end
            end
            Utils.ShowNotification("Mở Khóa Rác", string.format("Đã mở khóa %d con cá rác!", count), "SUCCESS", 4)
            refreshOverview()
            isBusy = false
        end)
    end)

    Components.CreateButtonRow(bagCard, "Bán Sạch Cá Rác An Toàn", "Tự động khóa cá quý, mở khóa rác và bán sạch", "💰 Bán Sạch Rác", function()
        if isBusy then
            Utils.ShowNotification("Dọn Rác", "Đang bận xử lý, vui lòng chờ...", "WARN", 2)
            return
        end
        isBusy = true
        task.spawn(function()
            local protList, junkList, _ = TabQuanLyCa.ScanAndClassify()
            if #junkList == 0 then
                Utils.ShowNotification("Dọn Rác", "Không có cá rác nào cần bán!", "INFO", 3)
                isBusy = false
                return
            end

            local favEvent = Events and Events:FindFirstChild("FavoriteItem")
            local sellEvent = Events and Events:FindFirstChild("SellFish")
            if not sellEvent then
                Utils.ShowNotification("Lỗi", "Không tìm thấy Remote SellFish!", "ERROR", 3)
                isBusy = false
                return
            end

            Utils.ShowNotification("Dọn Rác", string.format("Đang dọn dẹp %d con cá rác an toàn...", #junkList), "INFO", 3)

            -- 1. Khóa cá quý chưa khóa
            if favEvent then
                for _, p in ipairs(protList) do
                    if not p.isLocked and p.item and p.item.Parent then
                        pcall(function() favEvent:FireServer(p.item) end)
                        task.wait(0.04)
                    end
                end
                task.wait(0.2)

                -- 2. Mở khóa cá rác nếu đang khóa
                for _, j in ipairs(junkList) do
                    if j.isLocked and j.item and j.item.Parent then
                        pcall(function() favEvent:FireServer(j.item) end)
                        task.wait(0.04)
                    end
                end
                task.wait(0.3)
            end

            -- 3. Bán sạch cá
            sellEvent:FireServer("All")
            Utils.ShowNotification("Bán Cá", string.format("Đã bán sạch %d con cá rác! Cá quý được bảo vệ 100%%.", #junkList), "SUCCESS", 5)
            task.wait(1.0)
            refreshOverview()
            isBusy = false
        end)
    end)

    -- ============================================================
    -- 2. TIẾN ĐỘ NGUYÊN LIỆU CHẾ CẦN CÂU (ROD CRAFTING TRACKER)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🎣 Tiến Độ Chế Cần Câu (Rod Crafting Tracker)")
    local rodCard = Components.CreateCardGroup(parent)

    local rowCrimson = Components.CreateInfoRow(rodCard, "Crimson Bonefang (Cần Sanguine)", "...")
    local rowScarlet = Components.CreateInfoRow(rodCard, "Scarlet Fish (Cần Sanguine)", "...")
    local rowDragon = Components.CreateInfoRow(rodCard, "Golden Dragonfish (Cần Dragon)", "...")

    local function refreshRodProgress()
        local _, _, counts = TabQuanLyCa.ScanAndClassify()
        local cBone = counts["Crimson Bonefang"] and counts["Crimson Bonefang"].total or 0
        local sFish = counts["Scarlet Fish"] and counts["Scarlet Fish"].total or 0
        local gDragon = counts["Golden Dragonfish"] and counts["Golden Dragonfish"].total or 0

        if rowCrimson and rowCrimson.Set then rowCrimson.Set(string.format("Đang có: %d con", cBone)) end
        if rowScarlet and rowScarlet.Set then rowScarlet.Set(string.format("Đang có: %d con", sFish)) end
        if rowDragon and rowDragon.Set then rowDragon.Set(string.format("Đang có: %d con", gDragon)) end
    end

    task.spawn(function()
        while true do
            task.wait(3.0)
            pcall(refreshRodProgress)
        end
    end)

    -- ============================================================
    -- 3. TIẾN ĐỘ NGUYÊN LIỆU CHẾ MỒI (BAIT CRAFTING TRACKER)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🍖 Nguyên Liệu Chế Mồi Thần Thoại")
    local baitCard = Components.CreateCardGroup(parent)

    local rowAlligator = Components.CreateInfoRow(baitCard, "Verdant Alligator Gar", "...")
    local rowGrouper = Components.CreateInfoRow(baitCard, "Verdant Grouper", "...")
    local rowEel = Components.CreateInfoRow(baitCard, "Crimson Electric Eel", "...")

    local function refreshBaitProgress()
        local _, _, counts = TabQuanLyCa.ScanAndClassify()
        local vGar = counts["Verdant Alligator Gar"] and counts["Verdant Alligator Gar"].total or 0
        local vGroup = counts["Verdant Grouper"] and counts["Verdant Grouper"].total or 0
        local cEel = counts["Crimson Electric Eel"] and counts["Crimson Electric Eel"].total or 0

        if rowAlligator and rowAlligator.Set then rowAlligator.Set(string.format("Đang có: %d con", vGar)) end
        if rowGrouper and rowGrouper.Set then rowGrouper.Set(string.format("Đang có: %d con", vGroup)) end
        if rowEel and rowEel.Set then rowEel.Set(string.format("Đang có: %d con", cEel)) end
    end

    task.spawn(function()
        while true do
            task.wait(3.0)
            pcall(refreshBaitProgress)
        end
    end)

    -- Initial load
    task.delay(0.5, function()
        refreshOverview()
        refreshRodProgress()
        refreshBaitProgress()
    end)
end

return TabQuanLyCa
