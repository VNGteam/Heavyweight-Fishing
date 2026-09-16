--[[
    v2/ui/tabs/tab_san_boss.lua
    Secret Boss Hunter, Fast Skip, Spot Allocation, Jitter, Weather Server Hop & Totems
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Boss = require(script.Parent.Parent.Parent.features.boss)
local Weather = require(script.Parent.Parent.Parent.features.weather)
local Services = require(script.Parent.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabSanBoss = {}

function TabSanBoss.Render(parent)
    Components.CreateCategoryHeader(parent, "👹 Tự Động Săn Boss & Đổi Server")
    local bossCoreCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(bossCoreCard, "Bật Chế Độ Săn Boss (Tự Quăng Cần & Lọc Cá)", "Tự động thả cần câu và săn boss tại chỗ", Config.AutoHuntBoss, function(v) Config.AutoHuntBoss = v end)
    Components.CreateToggleRow(bossCoreCard, "Bật Săn Secret Boss (Chat Sniper)", "Tự động dịch chuyển đến đảo ngay khi có thông báo chat xuất hiện Boss", Config.AutoChatSecretBoss, function(v) Config.AutoChatSecretBoss = v end)
    Components.CreateToggleRow(bossCoreCard, "Giật Cần Thả Lại (Fast Skip Cá Thường)", "Tự động giật lại cần ngay lập tức nếu cá cắn câu không phải Boss được chọn", Config.FastSkipNonBoss, function(v) Config.FastSkipNonBoss = v end)
    Components.CreateToggleRow(bossCoreCard, "Kiểm Tra Lực Cần (Power Check)", "Chỉ săn khi đủ lực cần yêu cầu của từng hòn đảo", Config.SecretBossCheckPower, function(v) Config.SecretBossCheckPower = v end)
    Components.CreateToggleRow(bossCoreCard, "Hiện Bảng Sát Thương Boss (% HP)", "Hiển thị bảng DPS % máu khi nhiều người cùng pem Boss", Config.ShowBossDpsMeter, function(v) Config.ShowBossDpsMeter = v end)
    Components.CreateToggleRow(bossCoreCard, "Tự Đổi Server Khi Hết Boss (Auto-Hop)", "Tự chuyển server mới khi boss biến mất", Config.AutoServerHopOnDespawn, function(v) Config.AutoServerHopOnDespawn = v end)
    Components.CreateToggleRow(bossCoreCard, "Tự Về Vị Trí Farm Khi Hết Boss / Clear", "Quay lại điểm câu farm chính sau khi săn boss xong", Config.ReturnToHomeWhenClear, function(v) Config.ReturnToHomeWhenClear = v end)

    Components.CreateCategoryHeader(parent, "📍 Phân Bổ Điểm Đứng & Chống Trùng Tọa Độ")
    local spotCard = Components.CreateCardGroup(parent)

    Components.CreateDropdownRow(spotCard, "Chế Độ Chọn Điểm Câu Boss", "Phân chia điểm câu an toàn tránh giẫm chân bot khác", {"Tự Động (Theo Acc)", "Cố Định"}, Config.BossSpotAllocationMode or "Tự Động (Theo Acc)", function(v) Config.BossSpotAllocationMode = v end)
    Components.CreateToggleRow(spotCard, "Bật Jitter Dịch Chuyển (Lệch Tọa Độ)", "Tạo độ lệch nhẹ ngẫu nhiên khi bay tránh trùng lặp tuyệt đối", Config.BossTeleportJitter, function(v) Config.BossTeleportJitter = v end)
    Components.CreateSliderRow(spotCard, "Khoảng Cách Jitter", "Bán kính độ lệch tọa độ khi dịch chuyển", 0.5, 5.0, Config.BossTeleportJitterDist or 1.0, false, " studs", function(v) Config.BossTeleportJitterDist = v end)

    local islandList = {"Đảo Tre (Bamboo Isle)", "Đảo Quả Dừa (Coconut Isle)", "Đảo Hổ Phách (Amber Isle)", "Đảo Băng (Frost Isle)", "Đảo Bão Tố (Storm Isle)"}
    local selectedIsland = Config.SelectedCustomSpotIsland or islandList[1]
    local selectedSlot = Config.SelectedCustomSpotSlot or 1

    Components.CreateDropdownRow(spotCard, "Chọn Hòn Đảo", "Hòn đảo muốn tùy chỉnh điểm câu boss", islandList, selectedIsland, function(v)
        selectedIsland = v
        Config.SelectedCustomSpotIsland = v
    end)
    Components.CreateDropdownRow(spotCard, "Chọn Slot Điểm Câu (1-5)", "Vị trí slot điểm an toàn", {"1", "2", "3", "4", "5"}, tostring(selectedSlot), function(v)
        selectedSlot = tonumber(v) or 1
        Config.SelectedCustomSpotSlot = selectedSlot
    end)
    Components.CreateButtonRow(spotCard, "Lưu Vị Trí Hiện Tại Cho Slot Này", "Lưu tọa độ đứng hiện tại làm điểm an toàn cho hòn đảo đã chọn", "Lưu Slot", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Boss.SetCustomSpot(selectedIsland, selectedSlot, root.Position)
            Utils.ShowNotification("Điểm Boss", string.format("Đã lưu Slot %d cho %s!", selectedSlot, selectedIsland), "SUCCESS", 4)
        end
    end)

    -- Weather Server Hop Card
    Components.CreateCategoryHeader(parent, "🌪️ Tự Động Tìm Server Thời Tiết")
    local weatherCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(weatherCard, "Tự Động Tìm Server Thời Tiết", "Tự động đổi server liên tục đến khi gặp thời tiết mong muốn", Config.AutoWeatherHop, function(v)
        Config.AutoWeatherHop = v
        Weather.SaveWeatherHopState(Config)
    end)
    Components.CreateDropdownRow(weatherCard, "Thời Tiết Cần Tìm", "Loại thời tiết muốn bot tìm kiếm", Weather.weatherChoices, Config.TargetWeather or Weather.weatherChoices[1], function(v)
        Config.TargetWeather = v
    end)
    Components.CreateToggleRow(weatherCard, "Tự Động Câu / Săn Khi Tìm Thấy", "Bắt đầu câu ngay khi vào server có thời tiết mục tiêu", Config.WeatherHopAutoFish, function(v) Config.WeatherHopAutoFish = v end)
    Components.CreateToggleRow(weatherCard, "Gửi Webhook Khi Tìm Thấy Server", "Gửi thông báo JobID vào Discord/Telegram", Config.WeatherHopAlertWebhook, function(v) Config.WeatherHopAlertWebhook = v end)

    Components.CreateCategoryHeader(parent, "🌩️ Bàn Thờ Thời Tiết (Weather Totems)")
    local totemCard = Components.CreateCardGroup(parent)

    for _, t in ipairs(Weather.totems) do
        Components.CreateButtonRow(totemCard, t.name, "Bay đến và kích hoạt: " .. t.weather, "Kích Hoạt", function()
            Weather.InteractTotem(t)
        end)
    end

    Components.CreateCategoryHeader(parent, "🎯 Mục Tiêu Secret Boss (Bật / Tắt Từng Con)")
    local targetsGroup = Components.CreateCollapsibleCardGroup(parent, "Danh Sách Boss Mục Tiêu", true)

    local bossList = {
        "Verdant Alligator Gar", "Verdant Grouper", "Verdant Bonefang", "Crimson Bonefang",
        "Scarlet Fish", "Elder Scarlet Fish", "Crimson Electric Eel", "Golden Dragonfish", "Rainbow Dragonfish",
        "Flying Fish Emperor", "Flying Fish Empress", "Draconic Koi", "Sanguine Fish",
        "Tigerfang Whale", "Heavenpiercer Turtle", "Heaven Piercer Turtle", "Reborn Puffer Beast",
        "Frost Kingfish", "Frost Queenfish", "Mountain Dragonwhale", "Mirage Lanternfish", "Nameless Octoparasite"
    }

    for _, bossName in ipairs(bossList) do
        local initVal = (Config.SecretBossTargets[bossName] ~= false)
        local ctrl = Components.CreateToggleRow(targetsGroup, bossName, "Săn " .. bossName, initVal, function(v)
            Config.SecretBossTargets[bossName] = v
            ConfigModule.SaveBossTargets()
        end)
        State.bossTogglesMap[bossName] = ctrl
    end

    -- Boss Bạch Tuộc Bí Mật
    Components.CreateCategoryHeader(parent, "🐙 Boss Bạch Tuộc Bí Mật (Octoparasite)")
    local octoCard = Components.CreateCardGroup(parent)
    Components.CreateToggleRow(octoCard, "Tự Chơi Minigame (Rhythm Bot)", "Bot tự động gõ nhịp chuẩn Perfect 100%", Config.OctoAutoMinigame, function(v) Config.OctoAutoMinigame = v end)
    Components.CreateButtonRow(octoCard, "Bay Đến Phao Boss Bạch Tuộc", "Dịch chuyển đến phao triệu hồi Secret Boss giữa biển", "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(1608.2, 5.0, -218.3)
            Utils.ShowNotification("Dịch Chuyển", "Đã đến Phao Boss Bạch Tuộc!", "SUCCESS")
        end
    end)
    Components.CreateButtonRow(octoCard, "Bay Đến Vùng Lòng Đất", "Dịch chuyển đến vùng đất câu cá ngầm bí mật", "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(112.5, -330.0, -30.8)
            Utils.ShowNotification("Dịch Chuyển", "Đã đến Vùng Câu Cá Ngầm!", "SUCCESS")
        end
    end)

    -- Cần Câu Cần Ráp (Rod Crafting Guide)
    Components.CreateCategoryHeader(parent, "🎣 Cần Câu Cần Ráp (Rod Crafting Guide)")
    local rodGuideCard = Components.CreateCollapsibleCardGroup(parent, "Hướng Dẫn Ráp Cần & Bộ Lọc Nhanh", false)

    local rodRecipes = {
        {
            rod = "Heavenpiercer Rod",
            desc = "Cần Thiên Xuyên (Cao Cấp)",
            bosses = {"Flying Fish Emperor", "Flying Fish Empress", "Rainbow Dragonfish", "Heavenpiercer Turtle"},
            notes = {
                ["Flying Fish Emperor"]  = "Nguyên liệu chính",
                ["Flying Fish Empress"]  = "Nguyên liệu chính",
                ["Rainbow Dragonfish"]   = "Nguyên liệu + Trả Quest",
                ["Heavenpiercer Turtle"] = "Nguyên liệu + Mồi Rainbow",
            }
        },
        {
            rod = "Pure Diamond Rod",
            desc = "Cần Kim Cương Thuần (Cao Cấp)",
            bosses = {"Frost Kingfish", "Frost Queenfish", "Sanguine Fish", "Draconic Koi"},
            notes = {
                ["Frost Kingfish"]  = "Nguyên liệu + Mồi Frost",
                ["Frost Queenfish"] = "Nguyên liệu chính",
                ["Sanguine Fish"]   = "Nguyên liệu chính",
                ["Draconic Koi"]    = "Nguyên liệu phụ",
            }
        },
        {
            rod = "Sacred Bamboo Rod",
            desc = "Cần Trúc Thánh (Cao Cấp)",
            bosses = {"Nameless Octoparasite", "Reborn Puffer Beast", "Mountain Dragonwhale"},
            notes = {
                ["Nameless Octoparasite"] = "Nguyên liệu + Trả Quest Đạo Sĩ",
                ["Reborn Puffer Beast"]   = "Nguyên liệu + Trả Quest",
                ["Mountain Dragonwhale"]  = "Nguyên liệu + Mồi Nameless",
            }
        },
        {
            rod = "Rainbow Bait (Mồi)",
            desc = "Mồi Rainbow Bait (Gọi Boss Rùa)",
            bosses = {"Crimson Electric Eel", "Colossal Tigerfish", "Golden Guardian Fish"},
            notes = {
                ["Crimson Electric Eel"]  = "Nguyên liệu chính",
            }
        },
        {
            rod = "Nameless Bait (Mồi)",
            desc = "Mồi Nameless Bait (Gọi Bạch Tuộc)",
            bosses = {"Mirage Lanternfish", "Tiger Mirefish", "Octoparasitic Fish"},
            notes = {
                ["Mirage Lanternfish"]  = "Nguyên liệu chính",
            }
        }
    }

    for _, recipe in ipairs(rodRecipes) do
        Components.CreateInfoRow(rodGuideCard, "🪝 " .. recipe.rod, recipe.desc)
        Components.CreateButtonRow(rodGuideCard,
            "Ưu Tiên Chỉ Săn Cho: " .. recipe.rod,
            "Tắt hết boss khác, chỉ bật những boss cần cho " .. recipe.rod,
            "⚡ Lọc Boss",
            function()
                for bName, _ in pairs(Config.SecretBossTargets) do
                    Config.SecretBossTargets[bName] = false
                    if State.bossTogglesMap[bName] and State.bossTogglesMap[bName].Set then
                        pcall(function() State.bossTogglesMap[bName].Set(false, true) end)
                    end
                end
                for _, bName in ipairs(recipe.bosses) do
                    Config.SecretBossTargets[bName] = true
                    if State.bossTogglesMap[bName] and State.bossTogglesMap[bName].Set then
                        pcall(function() State.bossTogglesMap[bName].Set(true, true) end)
                    end
                end
                ConfigModule.SaveBossTargets()
                Utils.ShowNotification("Lọc Boss", "Đã bật mục tiêu cho: " .. recipe.rod, "SUCCESS", 5)
            end
        )
    end

    Components.CreateButtonRow(rodGuideCard, "Bật Lại Tất Cả Secret Boss", "Khôi phục lại toàn bộ danh sách secret boss", "Bật Tất Cả", function()
        for bName, _ in pairs(Config.SecretBossTargets) do
            Config.SecretBossTargets[bName] = true
            if State.bossTogglesMap[bName] and State.bossTogglesMap[bName].Set then
                pcall(function() State.bossTogglesMap[bName].Set(true, true) end)
            end
        end
        ConfigModule.SaveBossTargets()
        Utils.ShowNotification("Boss Targets", "Đã bật lại toàn bộ mục tiêu Secret Boss!", "SUCCESS", 4)
    end)

    -- Đấu Trường Boss Enzo
    Components.CreateCategoryHeader(parent, "⚔️ Đấu Trường Boss Enzo")
    local enzoCard = Components.CreateCardGroup(parent)
    Components.CreateToggleRow(enzoCard, "Tự Động Săn Boss (Enzo)", "Liên tục triệu hồi và câu boss Enzo", Config.AutoFarmBoss, function(v) Config.AutoFarmBoss = v end)
    Components.CreateToggleRow(enzoCard, "Tự Săn Secret Boss (Bạch Tuộc)", "Tự chế mồi Nameless Bait, triệu hồi và tiêu diệt", Config.AutoFarmSecretBoss, function(v) Config.AutoFarmSecretBoss = v end)
    Components.CreateButtonRow(enzoCard, "Bay Đến Boss Enzo", "Dịch chuyển trực tiếp đến đấu trường Enzo", "Bay Đến", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(-115.3, 9.2, 1349.5)
            Utils.ShowNotification("Dịch Chuyển", "Đã đến Đấu trường Boss Enzo!", "SUCCESS")
        end
    end)
end

return TabSanBoss
