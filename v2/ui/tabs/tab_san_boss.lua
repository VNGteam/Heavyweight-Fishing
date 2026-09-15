--[[
    v2/ui/tabs/tab_san_boss.lua
    Exact Tab Săn Boss from backup.lua (Chat Hunter, Fast Skip, Power Check, Custom Spots & Full Boss Target List)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config

local TabSanBoss = {}

function TabSanBoss.Render(parent)
    Components.CreateCategoryHeader(parent, "Tự Động Săn Boss & Đổi Server")
    local bossCoreCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(bossCoreCard, "Bật Chế Độ Săn Boss (Tự Quăng Cần & Lọc Cá)", "Tự động thả cần câu và săn boss tại chỗ", Config.AutoHuntBoss, function(v) Config.AutoHuntBoss = v end)
    Components.CreateToggleRow(bossCoreCard, "Bật Săn Secret Boss (Chat Sniper)", "Tự động dịch chuyển đến đảo ngay khi có thông báo chat xuất hiện Boss", Config.AutoChatSecretBoss, function(v) Config.AutoChatSecretBoss = v end)
    Components.CreateToggleRow(bossCoreCard, "Giật Cần Thả Lại (Fast Skip Cá Thường)", "Tự động giật lại cần ngay lập tức nếu cá cắn câu không phải Boss được chọn", Config.FastSkipNonBoss, function(v) Config.FastSkipNonBoss = v end)
    Components.CreateToggleRow(bossCoreCard, "Kiểm Tra Lực Cần (Power Check)", "Chỉ săn khi đủ lực cần yêu cầu của từng hòn đảo", Config.SecretBossCheckPower, function(v) Config.SecretBossCheckPower = v end)
    Components.CreateToggleRow(bossCoreCard, "Tự Đổi Server Khi Hết Boss (Auto-Hop)", "Tự chuyển server mới khi boss biến mất", Config.AutoServerHopOnDespawn, function(v) Config.AutoServerHopOnDespawn = v end)
    Components.CreateToggleRow(bossCoreCard, "Tự Về Vị Trí Farm Khi Hết Boss / Clear", "Quay lại điểm câu farm chính sau khi săn boss xong", Config.ReturnToHomeWhenClear, function(v) Config.ReturnToHomeWhenClear = v end)

    Components.CreateCategoryHeader(parent, "🎯 Mục Tiêu Secret Boss (Bật / Tắt Từng Con)")
    local targetsGroup = Components.CreateCollapsibleCardGroup(parent, "Danh Sách Boss Mục Tiêu (" .. tostring(22) .. " Loại)", true)

    local bossList = {
        "Verdant Alligator Gar",
        "Verdant Grouper",
        "Verdant Bonefang",
        "Crimson Bonefang",
        "Scarlet Fish",
        "Elder Scarlet Fish",
        "Crimson Electric Eel",
        "Golden Dragonfish",
        "Rainbow Dragonfish",
        "Flying Fish Emperor",
        "Flying Fish Empress",
        "Draconic Koi",
        "Sanguine Fish",
        "Tigerfang Whale",
        "Heavenpiercer Turtle",
        "Heaven Piercer Turtle",
        "Reborn Puffer Beast",
        "Frost Kingfish",
        "Frost Queenfish",
        "Mountain Dragonwhale",
        "Mirage Lanternfish",
        "Nameless Octoparasite"
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
