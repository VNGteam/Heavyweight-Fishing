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
end

return TabSanBoss
