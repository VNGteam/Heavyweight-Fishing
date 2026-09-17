--[[
    v2/ui/tabs/tab_cai_dat.lua
    Profiles, Priority Manager, Discord Webhook, Telegram Bot & System Exit
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabCaiDat = {}

function TabCaiDat.Render(parent)
    Components.CreateCategoryHeader(parent, "Quản Lý Cấu Hình Tài Khoản (Profiles)")
    local cardProfile = Components.CreateCardGroup(parent)

    local savedList = ConfigModule.GetSavedConfigList()
    if #savedList == 0 then table.insert(savedList, "Default") end
    local selectedCfg = savedList[1]
    local newCfgName = ""

    local cfgDropdown = Components.CreateDropdownRow(cardProfile, "Chọn Cấu Hình Đã Lưu", "Danh sách các file cấu hình đã tạo", savedList, selectedCfg, function(v)
        selectedCfg = v
    end)

    Components.CreateInputRow(cardProfile, "Tên Cấu Hình Mới", "Nhập tên nếu muốn lưu thành profile riêng", "", function(v)
        newCfgName = v
    end, nil, "VD: AfkNight, FarmBoss...")

    Components.CreateButtonRow(cardProfile, "Lưu Cấu Hình", "Lưu toàn bộ thiết lập hiện tại", "Lưu Ngay", function()
        local nameToSave = (newCfgName ~= "" and newCfgName) or selectedCfg or "Default"
        local ok, msg = ConfigModule.SaveAccountConfig(nameToSave, State.UIControllers)
        Utils.ShowNotification("Cài Đặt", msg, ok and "SUCCESS" or "ERROR", 3)
        cfgDropdown.Refresh(ConfigModule.GetSavedConfigList(), true)
    end)

    Components.CreateButtonRow(cardProfile, "Nạp Cấu Hình", "Áp dụng cấu hình đã chọn", "Nạp Ngay", function()
        if selectedCfg then
            local ok, msg = ConfigModule.LoadAccountConfig(selectedCfg, State.UIControllers)
            Utils.ShowNotification("Cài Đặt", msg, ok and "SUCCESS" or "ERROR", 3)
        end
    end)

    Components.CreateCategoryHeader(parent, "Hệ Thống Quản Lý Độ Ưu Tiên (Priority Manager)")
    local cardPriority = Components.CreateCardGroup(parent)
    Components.CreateToggleRow(cardPriority, "Bật Quản Lý Độ Ưu Tiên", "Tự động phân xử khi có nhiều sự kiện trùng lặp", Config.PrioritySystemEnabled, function(v)
        Config.PrioritySystemEnabled = v
    end)

    -- Discord Webhook
    Components.CreateCategoryHeader(parent, "📢 Cảnh Báo Discord Webhook")
    local cardWebhook = Components.CreateCardGroup(parent)
    Components.CreateInputRow(cardWebhook, "Webhook URL", "Dán đường dẫn Webhook Discord tại đây", Config.WebhookUrl or "", function(v)
        Config.WebhookUrl = v
    end, nil, "https://discord.com/api/webhooks/...")
    Components.CreateToggleRow(cardWebhook, "Bật Webhook Discord", "Kích hoạt gửi tin nhắn về Discord", Config.WebhookEnabled, function(v)
        Config.WebhookEnabled = v
    end)
    Components.CreateToggleRow(cardWebhook, "Thông Báo Bắt Được Boss", "Gửi tin nhắn khi câu trúng Secret Boss", Config.WebhookNotifyBoss, function(v)
        Config.WebhookNotifyBoss = v
    end)
    Components.CreateToggleRow(cardWebhook, "Thông Báo Đạo Sĩ (Taoist & Maoshan & Thần Linh)", "Gửi JobID kèm lệnh bay tức thì khi phát hiện NPC", Config.WebhookNotifyNPC, function(v)
        Config.WebhookNotifyNPC = v
    end)
    Components.CreateToggleRow(cardWebhook, "Thông Báo Thời Tiết Đặc Biệt", "Gửi tin nhắn khi phát hiện server thời tiết", Config.WebhookNotifyWeather, function(v)
        Config.WebhookNotifyWeather = v
    end)
    Components.CreateButtonRow(cardWebhook, "Kiểm Tra Webhook Discord", "Gửi 1 tin nhắn test đến kênh Discord", "Test Webhook", function()
        if not Config.WebhookUrl or Config.WebhookUrl == "" then
            Utils.ShowNotification("Webhook", "Vui lòng nhập Webhook URL trước!", "WARN", 3)
            return
        end
        Utils.SendDiscordWebhook(
            "✅ TEST KẾT NỐI DISCORD THÀNH CÔNG!",
            "Heavyweight Fishing Hub V2 đã kết nối thành công với webhook này!",
            65280,
            {
                { name = "Thời Gian", value = os.date("%H:%M:%S - %d/%m/%Y"), inline = true },
                { name = "Job ID", value = game.JobId, inline = false }
            },
            Config.WebhookUrl
        )
        Utils.ShowNotification("Webhook", "Đã gửi tin nhắn test đến Discord!", "SUCCESS", 4)
    end)

    -- Telegram Bot
    Components.CreateCategoryHeader(parent, "✈️ Thông Báo Telegram Bot")
    local cardTele = Components.CreateCardGroup(parent)
    Components.CreateInputRow(cardTele, "Bot Token", "Token lấy từ @BotFather", Config.TelegramBotToken or "", function(v)
        Config.TelegramBotToken = v
    end, nil, "123456789:ABCdefGhIJKlmNoPQR...")
    Components.CreateInputRow(cardTele, "Chat ID", "ID của bạn hoặc nhóm (lấy từ @userinfobot)", Config.TelegramChatId or "", function(v)
        Config.TelegramChatId = v
    end, nil, "123456789 hoặc -100...")
    Components.CreateToggleRow(cardTele, "Bật Telegram Bot", "Kích hoạt gửi thông báo qua Telegram", Config.TelegramEnabled, function(v)
        Config.TelegramEnabled = v
    end)
    Components.CreateToggleRow(cardTele, "Báo Săn Boss", "Gửi thông báo khi gặp Secret Boss", Config.TelegramNotifyBoss, function(v)
        Config.TelegramNotifyBoss = v
    end)
    Components.CreateToggleRow(cardTele, "Báo Đạo Sĩ / Mao Sơn / Thần Linh", "Gửi thông báo khi quét thấy NPC đặc biệt", Config.TelegramNotifyNPC, function(v)
        Config.TelegramNotifyNPC = v
    end)
    Components.CreateToggleRow(cardTele, "Báo Thời Tiết Server", "Gửi thông báo khi tìm thấy thời tiết", Config.TelegramNotifyWeather, function(v)
        Config.TelegramNotifyWeather = v
    end)
    Components.CreateButtonRow(cardTele, "Kiểm Tra Telegram Bot", "Gửi tin nhắn test kiểm tra kết nối", "Test Telegram", function()
        if not Config.TelegramBotToken or Config.TelegramBotToken == "" or not Config.TelegramChatId or Config.TelegramChatId == "" then
            Utils.ShowNotification("Telegram", "Vui lòng nhập Bot Token và Chat ID trước!", "WARN", 3)
            return
        end
        local ok = Utils.SendTelegramMessage(Config, "🤖 *Heavyweight Fishing Hub V2*\n✅ *Kiểm tra kết nối Telegram thành công!*\nThời gian: `" .. os.date("%H:%M:%S - %d/%m/%Y") .. "`\nJob ID: `" .. game.JobId .. "`")
        if ok then
            Utils.ShowNotification("Telegram", "Đã gửi tin nhắn test đến Telegram!", "SUCCESS", 4)
        else
            Utils.ShowNotification("Telegram", "Gửi tin nhắn thất bại, hãy kiểm tra Token và Chat ID!", "ERROR", 5)
        end
    end)

    -- Exit
    Components.CreateCategoryHeader(parent, "Hệ Thống & Thoát")
    local cardExit = Components.CreateCardGroup(parent)
    Components.CreateButtonRow(cardExit, "Hủy Script Hoàn Toàn (Unload)", "Xóa toàn bộ giao diện và ngắt kết nối an toàn", "Hủy Script", function()
        Utils.ShowNotification("Identical Hub", "Đang đóng script an toàn...", "WARN", 2)
        task.wait(0.2)
        State.UnloadScript()
    end)
end

return TabCaiDat
