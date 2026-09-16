--[[
    v2/ui/tabs/tab_thu_nghiem.lua
    Ghost Mode, Auto Reroll Trait, Instant Boat Spawner, Remote Exchange, Rod Colors & Fish Tank
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Services = require(script.Parent.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local Events = Services.Events
local Utils = require(script.Parent.Parent.Parent.core.utils)
local Shop = require(script.Parent.Parent.Parent.features.shop)

local TabThuNghiem = {}

function TabThuNghiem.Render(parent)
    -- 1. 👻 CHẾ ĐỘ TÀNG HÌNH (GHOST / INVISIBILITY MODE)
    Components.CreateCategoryHeader(parent, "👻 CHẾ ĐỘ TÀNG HÌNH (GHOST / INVISIBILITY MODE)")
    local ghostCard = Components.CreateCardGroup(parent)

    local function ApplyGhostInvisibility(state)
        Config.GhostInvisibility = state
        pcall(function()
            local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
            if remotesFolder and remotesFolder:FindFirstChild("ToggleInvisibility") then
                remotesFolder.ToggleInvisibility:InvokeServer(state)
            end
        end)

        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = state and 0.65 or 0
                elseif part:IsA("BillboardGui") then
                    part.Enabled = not state
                end
            end
        end

        Utils.ShowNotification("Tàng Hình", state and "Đã BẬT Tàng Hình Server! Người chơi khác không thể nhìn thấy bạn." or "Đã TẮT Tàng Hình! Nhân vật hiển thị bình thường.", state and "SUCCESS" or "INFO", 4)
    end

    Components.CreateToggleRow(ghostCard, "Bật Tàng Hình Server (Ghost Mode)", "Ẩn hoàn toàn nhân vật khỏi tầm nhìn của người chơi khác và admin", Config.GhostInvisibility, function(v)
        ApplyGhostInvisibility(v)
    end)

    Components.CreateButtonRow(ghostCard, "Làm Mới Trạng Thái Tàng Hình", "Bắn lại remote tàng hình phòng khi server vừa hồi sinh nhân vật", "Làm Mới", function()
        ApplyGhostInvisibility(Config.GhostInvisibility)
    end)

    -- 2. 🎯 TỰ ĐỘNG TẨY LUYỆN TRAIT (AUTO REROLL & LOCK TRAIT)
    Components.CreateCategoryHeader(parent, "🎯 TỰ ĐỘNG TẨY LUYỆN TRAIT (AUTO REROLL & LOCK TRAIT)")
    local traitCard = Components.CreateCardGroup(parent)

    local traitList = {
        "Azure Dragon", "White Tiger", "Vermilion Bird", "Black Tortoise",
        "Assassin", "Berserk", "Chrono", "Executioner", "Powerful",
        "Precision", "Rapid", "Sharp", "Swift"
    }

    Components.CreateDropdownRow(traitCard, "Chọn Trait Cần Săn", "Trait mục tiêu bot sẽ tự động roll cho đến khi trúng", traitList, Config.TargetTraitName or traitList[1], function(v)
        Config.TargetTraitName = v
    end)

    local infoTraitRerolls = Components.CreateInfoRow(traitCard, "Vé Reroll Hiện Có", "Đang tải...")
    local function UpdateTraitRerollInfo()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
        local count = pData and pData:FindFirstChild("Trait Reroll") and pData["Trait Reroll"].Value or 0
        if infoTraitRerolls and infoTraitRerolls.Set then
            infoTraitRerolls.Set(string.format("%d Vé", count))
        end
    end
    task.spawn(UpdateTraitRerollInfo)

    local isAutoRerolling = false
    local function RunAutoRerollTrait()
        if isAutoRerolling then return end
        isAutoRerolling = true
        task.spawn(function()
            local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
            Utils.ShowNotification("Reroll Trait", "Bắt đầu tự động Reroll săn Trait: " .. tostring(Config.TargetTraitName), "INFO", 4)

            while isAutoRerolling and Config.AutoRerollTrait do
                local currentRerolls = pData and pData:FindFirstChild("Trait Reroll") and pData["Trait Reroll"].Value or 0
                UpdateTraitRerollInfo()

                if currentRerolls <= 0 then
                    Utils.ShowNotification("Hết Vé", "Đã hết vé Reroll Trait!", "WARN", 5)
                    Config.AutoRerollTrait = false
                    isAutoRerolling = false
                    break
                end

                if Events and Events:FindFirstChild("RerollTrait") then
                    local res = Events.RerollTrait:InvokeServer()
                    local targetLower = tostring(Config.TargetTraitName or ""):lower()
                    local isHit = false

                    if type(res) == "string" and res:lower():find(targetLower, 1, true) then
                        isHit = true
                    end

                    if not isHit and pData and pData:FindFirstChild("LockTrait") then
                        local tVal = pData.LockTrait:FindFirstChild(Config.TargetTraitName)
                        if tVal and tVal.Value == true then
                            isHit = true
                        end
                    end

                    if isHit then
                        Utils.ShowNotification("TRÚNG TRAIT!", string.format("Đã roll trúng [%s]! Tự động khóa bảo vệ ngay lập tức.", Config.TargetTraitName), "SUCCESS", 8)
                        if Events:FindFirstChild("LockTrait") then
                            Events.LockTrait:FireServer(Config.TargetTraitName)
                        end
                        Config.AutoRerollTrait = false
                        isAutoRerolling = false
                        break
                    end
                end
                task.wait(0.35)
            end
            isAutoRerolling = false
            UpdateTraitRerollInfo()
        end)
    end

    Components.CreateToggleRow(traitCard, "Tự Động Reroll Đến Khi Trúng", "Tự động roll liên tục và khóa lại khi ra đúng Trait mục tiêu", Config.AutoRerollTrait, function(v)
        Config.AutoRerollTrait = v
        if v then
            RunAutoRerollTrait()
        else
            isAutoRerolling = false
        end
    end)

    Components.CreateButtonRow(traitCard, "Reroll 1 Lần Thủ Công", "Thực hiện roll trait 1 lần ngay lập tức", "Reroll 1 Lần", function()
        if Events and Events:FindFirstChild("RerollTrait") then
            local res = Events.RerollTrait:InvokeServer()
            UpdateTraitRerollInfo()
            Utils.ShowNotification("Reroll Trait", "Kết quả roll: " .. tostring(res or "Đã roll thành công"), "INFO", 4)
        end
    end)

    Components.CreateButtonRow(traitCard, "Khóa / Mở Khóa Trait Đang Chọn", "Chuyển đổi trạng thái khóa bảo vệ cho Trait đang chọn", "Khóa / Mở", function()
        if Events and Events:FindFirstChild("LockTrait") then
            Events.LockTrait:FireServer(Config.TargetTraitName)
            Utils.ShowNotification("Khóa Trait", "Đã gửi lệnh đổi trạng thái khóa cho: " .. tostring(Config.TargetTraitName), "SUCCESS", 3)
        end
    end)

    -- 3. ⛵ TRIỆU HỒI THUYỀN TỨC THÌ (INSTANT BOAT SPAWNER)
    Components.CreateCategoryHeader(parent, "⛵ TRIỆU HỒI THUYỀN TỨC THÌ (INSTANT BOAT SPAWNER)")
    local boatCard = Components.CreateCardGroup(parent)

    local boatList = {"Boat", "Golden Boat", "Rainbow Boat", "Ascended Perch", "Kunfish Overlord"}
    Components.CreateDropdownRow(boatCard, "Chọn Loại Thuyền", "Chọn thuyền muốn triệu hồi hoặc mua", boatList, Config.SelectedBoat or boatList[1], function(v)
        Config.SelectedBoat = v
    end)

    local function SpawnBoatNow(boatName)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local bShop = remotes and remotes:FindFirstChild("BoatShop")
        if bShop and bShop:FindFirstChild("Spawn") then
            bShop.Spawn:FireServer(boatName)
            Utils.ShowNotification("Triệu Hồi Thuyền", "Đã triệu hồi thuyền [" .. tostring(boatName) .. "] tại vị trí của bạn!", "SUCCESS", 4)
        elseif Events and Events:FindFirstChild("SpawnBoat") then
            Events.SpawnBoat:FireServer(boatName)
            Utils.ShowNotification("Triệu Hồi Thuyền", "Đã triệu hồi thuyền [" .. tostring(boatName) .. "] tại vị trí của bạn!", "SUCCESS", 4)
        else
            Utils.ShowNotification("Thuyền", "Không tìm thấy remote triệu hồi thuyền!", "WARN", 4)
        end
    end

    Components.CreateButtonRow(boatCard, "Triệu Hồi Thuyền Đang Chọn", "Triệu hồi thuyền xuất hiện ngay tại vị trí bạn đang đứng", "Triệu Hồi", function()
        SpawnBoatNow(Config.SelectedBoat)
    end)

    Components.CreateButtonRow(boatCard, "Mua Thuyền Đang Chọn (Từ Xa)", "Mua thuyền từ xa qua Remote mà không cần gặp NPC bến tàu", "Mua Thuyền", function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local bShop = remotes and remotes:FindFirstChild("BoatShop")
        if bShop and bShop:FindFirstChild("Buy") then
            bShop.Buy:FireServer(Config.SelectedBoat)
            Utils.ShowNotification("Mua Thuyền", "Đã gửi yêu cầu mua thuyền: " .. tostring(Config.SelectedBoat), "SUCCESS", 4)
        end
    end)

    -- 4. 🔄 CỬA HÀNG TRAO ĐỔI TỪ XA (REMOTE EXCHANGE SHOP)
    Components.CreateCategoryHeader(parent, "🔄 CỬA HÀNG TRAO ĐỔI TỪ XA (REMOTE EXCHANGE SHOP)")
    local exCard = Components.CreateCardGroup(parent)

    local exchangeItems = {"Trait Reroll", "EssenceOrb"}
    Components.CreateDropdownRow(exCard, "Vật Phẩm Cần Đổi", "Chọn loại vật phẩm muốn trao đổi", exchangeItems, Config.SelectedExchangeItem or exchangeItems[1], function(v)
        Config.SelectedExchangeItem = v
    end)

    Components.CreateSliderRow(exCard, "Số Lượng Đổi", "Số lượng vật phẩm đổi trong 1 lần bấm", 1, 20, Config.ExchangeAmount or 1, false, " cái", function(v)
        Config.ExchangeAmount = v
    end)

    Components.CreateButtonRow(exCard, "Thực Hiện Đổi Vật Phẩm", "Gửi remote đổi vật phẩm đã chọn ngay lập tức", "Đổi Ngay", function()
        if Events and Events:FindFirstChild("Exchange") then
            Events.Exchange:FireServer(Config.SelectedExchangeItem, Config.ExchangeAmount)
            Utils.ShowNotification("Đổi Đồ", string.format("Đã gửi yêu cầu đổi %d [%s]!", Config.ExchangeAmount, Config.SelectedExchangeItem), "SUCCESS", 4)
            task.delay(1, UpdateTraitRerollInfo)
        else
            Utils.ShowNotification("Lỗi", "Không tìm thấy Remote Exchange!", "WARN", 4)
        end
    end)

    Components.CreateButtonRow(exCard, "Đổi Nhanh 5 Vé Trait Reroll", "Đổi nhanh 5 Vé Reroll Trait chỉ với 1 click", "Đổi 5 Vé", function()
        if Events and Events:FindFirstChild("Exchange") then
            Events.Exchange:FireServer("Trait Reroll", 5)
            Utils.ShowNotification("Đổi Vé", "Đã gửi yêu cầu đổi nhanh 5 Vé Trait Reroll!", "SUCCESS", 4)
            task.delay(1, UpdateTraitRerollInfo)
        end
    end)

    Components.CreateButtonRow(exCard, "Đổi Nhanh 5 Ngọc EssenceOrb", "Đổi nhanh 5 Ngọc EssenceOrb chỉ với 1 click", "Đổi 5 Ngọc", function()
        if Events and Events:FindFirstChild("Exchange") then
            Events.Exchange:FireServer("EssenceOrb", 5)
            Utils.ShowNotification("Đổi Ngọc", "Đã gửi yêu cầu đổi nhanh 5 Ngọc EssenceOrb!", "SUCCESS", 4)
        end
    end)

    -- 5. 🎨 TÙY BIẾN MÀU SẮC CẦN CÂU (ROD COLOR & RGB RAINBOW)
    Components.CreateCategoryHeader(parent, "🎨 TÙY BIẾN MÀU SẮC CẦN CÂU (ROD COLOR & RGB RAINBOW)")
    local colorCard = Components.CreateCardGroup(parent)

    local colorMap = {
        ["Vàng Kim (Gold)"] = Color3.fromRGB(255, 215, 0),
        ["Đỏ Rực (Red)"] = Color3.fromRGB(255, 30, 30),
        ["Xanh Biển (Cyan)"] = Color3.fromRGB(0, 220, 255),
        ["Xanh Lá (Emerald)"] = Color3.fromRGB(40, 255, 120),
        ["Tím Huyền Bí (Purple)"] = Color3.fromRGB(180, 50, 255),
        ["Trắng Tuyết (White)"] = Color3.fromRGB(255, 255, 255),
        ["Hồng Neon (Pink)"] = Color3.fromRGB(255, 105, 180),
    }
    local colorNames = {"Vàng Kim (Gold)", "Đỏ Rực (Red)", "Xanh Biển (Cyan)", "Xanh Lá (Emerald)", "Tím Huyền Bí (Purple)", "Trắng Tuyết (White)", "Hồng Neon (Pink)"}

    local function ApplyRodColor(c3)
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
        local rodName = pData and pData:FindFirstChild("FishingRod") and pData.FishingRod.Value or ""
        if Events and Events:FindFirstChild("SetRodSkinColor") then
            Events.SetRodSkinColor:FireServer(rodName, c3)
        end
    end

    Components.CreateDropdownRow(colorCard, "Màu Sắc Cần Câu", "Chọn màu phát sáng yêu thích cho cần câu", colorNames, Config.SelectedRodColor or colorNames[1], function(v)
        Config.SelectedRodColor = v
        local c3 = colorMap[v]
        if c3 then ApplyRodColor(c3) end
    end)

    Components.CreateButtonRow(colorCard, "Áp Dụng Màu Đã Chọn", "Đổi màu cần câu theo màu được chọn ở trên", "Đổi Màu", function()
        local c3 = colorMap[Config.SelectedRodColor] or Color3.fromRGB(255, 215, 0)
        ApplyRodColor(c3)
        Utils.ShowNotification("Màu Cần Câu", "Đã đổi màu cần câu sang: " .. tostring(Config.SelectedRodColor), "SUCCESS", 4)
    end)

    Components.CreateToggleRow(colorCard, "Chế Độ RGB Cầu Vồng (Rainbow Cycle)", "Tự động xoay chuyển màu liên tục theo dải quang phổ 7 màu", Config.RainbowRodColor, function(v)
        Config.RainbowRodColor = v
        if v then
            Utils.ShowNotification("Màu Cầu Vồng", "Đã BẬT hiệu ứng đổi màu RGB Cầu Vồng cho cần câu!", "SUCCESS", 4)
        end
    end)

    Components.CreateButtonRow(colorCard, "Đặt Lại Màu Mặc Định (Reset)", "Khôi phục màu cần câu về ban đầu của game", "Reset Màu", function()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
        local rodName = pData and pData:FindFirstChild("FishingRod") and pData.FishingRod.Value or ""
        if Events and Events:FindFirstChild("ResetRodSkinColor") then
            Events.ResetRodSkinColor:FireServer(rodName)
            Utils.ShowNotification("Màu Cần", "Đã reset màu cần câu về mặc định!", "SUCCESS", 4)
        end
    end)

    -- 6. 🏰 QUẢN LÝ BỂ NUÔI CÁ & GIA VIÊN (FISH TANK & PLOT)
    Components.CreateCategoryHeader(parent, "🏰 QUẢN LÝ BỂ NUÔI CÁ & GIA VIÊN (FISH TANK & PLOT)")
    local tankCard = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(tankCard, "Thả Cá Quý / Đột Biến Vào Bể", "Tự quét balo và thả các con cá Secret Boss / Đột biến vào bể nuôi", "Thả Vào Bể", function()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
        if not pData or not pData:FindFirstChild("Inventory") then return end
        local count = 0
        for _, item in ipairs(pData.Inventory:GetChildren()) do
            if Shop.IsMutatedFish(item) then
                if Events and Events:FindFirstChild("AddFishToFishTank") then
                    Events.AddFishToFishTank:FireServer(item)
                    count = count + 1
                    task.wait(0.1)
                end
            end
        end
        if count > 0 then
            Utils.ShowNotification("Bể Cá", string.format("Đã thả %d con cá quý / đột biến vào bể nuôi!", count), "SUCCESS", 5)
        else
            Utils.ShowNotification("Bể Cá", "Không có cá Secret Boss hoặc đột biến trong balo.", "INFO", 4)
        end
    end)

    Components.CreateButtonRow(tankCard, "Nâng Cấp Gia Viên (Upgrade Plot)", "Nâng cấp hòn đảo cá nhân của bạn từ xa", "Nâng Cấp", function()
        if Events and Events:FindFirstChild("UpgradePlot") then
            local res = Events.UpgradePlot:InvokeServer()
            Utils.ShowNotification("Gia Viên", "Đã gửi lệnh nâng cấp Plot! " .. tostring(res or ""), "SUCCESS", 4)
        end
    end)
end

return TabThuNghiem
