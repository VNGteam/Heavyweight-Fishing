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

    Components.CreateButtonRow(cardWebhook, "Báo Cáo Toàn Diện Ngay", "Gửi bảng tổng kết 14 chỉ số đầy đủ về Discord ngay", "📊 Báo Cáo Ngay", function()
        if not Config.WebhookUrl or Config.WebhookUrl == "" then
            Utils.ShowNotification("Webhook", "Vui lòng nhập Webhook URL trước!", "WARN", 3)
            return
        end
        Utils.ShowNotification("Webhook", "Đang tổng hợp báo cáo toàn diện...", "INFO", 2)
        local pData = game:GetService("ReplicatedStorage"):FindFirstChild("Data") and LocalPlayer and game:GetService("ReplicatedStorage").Data:FindFirstChild(LocalPlayer.UserId)
        local fishCount = pData and pData:FindFirstChild("FishCaught") and tonumber(pData.FishCaught.Value) or 0
        local cashVal = pData and pData:FindFirstChild("Cash") and tonumber(pData.Cash.Value) or 0
        local ticketVal = pData and pData:FindFirstChild("Ticket") and tonumber(pData.Ticket.Value) or 0
        local questDone = pData and pData:FindFirstChild("TicketQuestDailyCount") and tonumber(pData.TicketQuestDailyCount.Value) or 0
        local essenceVal = pData and pData:FindFirstChild("EssenceOrb") and tonumber(pData.EssenceOrb.Value) or 0
        local rerollVal = pData and pData:FindFirstChild("Trait Reroll") and tonumber(pData["Trait Reroll"].Value) or 0
        local curWeather = (State and State.CurrentWeather) or "Clear (Trời Quang)"
        local timeStr = os.date("%H:%M:%S - %d/%m/%Y")
        local jobId = tostring(game.JobId or "N/A")
        local placeId = tostring(game.PlaceId or "18779600655")

        Utils.SendDiscordWebhook(
            "📊 BÁO CÁO TOÀN DIỆN (YÊU CẦU THỦ CÔNG)",
            string.format("👤 **%s** — Server: `%s`", LocalPlayer and LocalPlayer.DisplayName or "User", jobId),
            3447003,
            {
                { name = "🌦️ Thời Tiết", value = curWeather, inline = true },
                { name = "🐟 Tổng Cá", value = tostring(fishCount) .. " con", inline = true },
                { name = "💰 Tiền", value = "$" .. tostring(cashVal), inline = true },
                { name = "🎫 Vé Nhiệm Vụ", value = tostring(ticketVal) .. " Vé", inline = true },
                { name = "📜 NV Xong Hôm Nay", value = tostring(questDone) .. "/20 NV", inline = true },
                { name = "🔮 Essence Orb", value = tostring(essenceVal) .. " Viên", inline = true },
                { name = "🎲 Trait Reroll", value = tostring(rerollVal) .. " Vé", inline = true },
                { name = "⚡ Code Vào Server", value = string.format("```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\", game.Players.LocalPlayer)\n```", placeId, jobId), inline = false },
                { name = "⏰ Cập nhật lúc", value = timeStr, inline = false }
            },
            Config.WebhookUrl
        )
        Utils.ShowNotification("Webhook", "Đã gửi báo cáo toàn diện!", "SUCCESS", 4)
    end)

    Components.CreateButtonRow(cardWebhook, "Báo Cáo Thời Tiết & Boss", "Gửi embed thời tiết và boss mục tiêu có thể ra", "🌦️ Thời Tiết", function()
        if not Config.WebhookUrl or Config.WebhookUrl == "" then
            Utils.ShowNotification("Webhook", "Vui lòng nhập Webhook URL trước!", "WARN", 3)
            return
        end
        local curWeather = (State and State.CurrentWeather) or "Clear (Trời Quang)"
        local jobId = tostring(game.JobId or "N/A")
        local placeId = tostring(game.PlaceId or "18779600655")
        Utils.SendDiscordWebhook(
            "🌦️ BÁO CÁO THỜI TIẾT & BOSS",
            string.format("👤 **%s** — Server: `%s`", LocalPlayer and LocalPlayer.DisplayName or "User", jobId),
            3447003,
            {
                { name = "🌦️ Thời Tiết", value = curWeather, inline = true },
                { name = "⚡ Code Vào Server", value = string.format("```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\", game.Players.LocalPlayer)\n```", placeId, jobId), inline = false },
                { name = "⏰ Cập nhật lúc", value = os.date("%H:%M:%S - %d/%m/%Y"), inline = false }
            },
            Config.WebhookUrl
        )
        Utils.ShowNotification("Webhook", "Đã gửi báo cáo Thời Tiết!", "SUCCESS", 4)
    end)

    Components.CreateButtonRow(cardWebhook, "Báo Cáo Tài Sản & Ba Lô", "Gửi embed tiền, gems, vé, essence, trait", "💰 Tài Sản", function()
        if not Config.WebhookUrl or Config.WebhookUrl == "" then
            Utils.ShowNotification("Webhook", "Vui lòng nhập Webhook URL trước!", "WARN", 3)
            return
        end
        local pData = game:GetService("ReplicatedStorage"):FindFirstChild("Data") and LocalPlayer and game:GetService("ReplicatedStorage").Data:FindFirstChild(LocalPlayer.UserId)
        local fishCount = pData and pData:FindFirstChild("FishCaught") and tonumber(pData.FishCaught.Value) or 0
        local cashVal = pData and pData:FindFirstChild("Cash") and tonumber(pData.Cash.Value) or 0
        local ticketVal = pData and pData:FindFirstChild("Ticket") and tonumber(pData.Ticket.Value) or 0
        local essenceVal = pData and pData:FindFirstChild("EssenceOrb") and tonumber(pData.EssenceOrb.Value) or 0
        local rerollVal = pData and pData:FindFirstChild("Trait Reroll") and tonumber(pData["Trait Reroll"].Value) or 0
        Utils.SendDiscordWebhook(
            "💰 BÁO CÁO TÀI SẢN & KHO ĐỒ",
            string.format("👤 **%s** — Server: `%s`", LocalPlayer and LocalPlayer.DisplayName or "User", tostring(game.JobId or "N/A")),
            16766720,
            {
                { name = "💰 Tiền", value = "$" .. tostring(cashVal), inline = true },
                { name = "🐟 Tổng Cá", value = tostring(fishCount) .. " con", inline = true },
                { name = "🎫 Vé", value = tostring(ticketVal) .. " Vé", inline = true },
                { name = "🔮 Essence", value = tostring(essenceVal) .. " Viên", inline = true },
                { name = "🎲 Trait", value = tostring(rerollVal) .. " Vé", inline = true },
                { name = "⏰ Cập nhật lúc", value = os.date("%H:%M:%S - %d/%m/%Y"), inline = false }
            },
            Config.WebhookUrl
        )
        Utils.ShowNotification("Webhook", "Đã gửi thông tin Tài Sản!", "SUCCESS", 4)
    end)

    Components.CreateButtonRow(cardWebhook, "Lấy Code Teleport Server", "Gửi embed chứa Server Job ID và script teleport", "⚡ Teleport", function()
        if not Config.WebhookUrl or Config.WebhookUrl == "" then
            Utils.ShowNotification("Webhook", "Vui lòng nhập Webhook URL trước!", "WARN", 3)
            return
        end
        local jobId = tostring(game.JobId or "N/A")
        local placeId = tostring(game.PlaceId or "18779600655")
        Utils.SendDiscordWebhook(
            "⚡ THÔNG TIN SERVER & CODE TELEPORT",
            string.format("👤 **%s** — Dùng code dưới đây để vào server:", LocalPlayer and LocalPlayer.DisplayName or "User"),
            3447003,
            {
                { name = "🔑 Job ID", value = string.format("`%s`", jobId), inline = true },
                { name = "⚡ Code Teleport", value = string.format("```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%s, \"%s\", game.Players.LocalPlayer)\n```", placeId, jobId), inline = false },
                { name = "⏰ Cập nhật lúc", value = os.date("%H:%M:%S - %d/%m/%Y"), inline = false }
            },
            Config.WebhookUrl
        )
        Utils.ShowNotification("Webhook", "Đã gửi mã Teleport!", "SUCCESS", 4)
    end)

    Components.CreateToggleRow(cardWebhook, "Bật Phím Tắt Báo Cáo (F4, F6, F7, F8)", "F4: Thời Tiết | F6: Tài Sản | F7: Nhiệm Vụ | F8: Teleport", Config.ReportKeybindsEnabled, function(v)
        Config.ReportKeybindsEnabled = v
    end)

    -- Discord Remote Controls
    Components.CreateCategoryHeader(parent, "🤖 Nhận Lệnh Điều Khiển Từ Xa (Discord Remote Commands)")
    local cardRemote = Components.CreateCardGroup(parent)
    Components.CreateToggleRow(cardRemote, "Bật Lắng Nghe Lệnh Discord", "Tự động nhận lệnh chat (!thoitiet, !kho, !ve, !tele, !baocao, !help)", Config.DiscordRemoteEnabled, function(v)
        Config.DiscordRemoteEnabled = v
    end)
    Components.CreateInputRow(cardRemote, "Discord Bot Token", "Token Bot từ Discord Developer Portal", Config.DiscordBotToken or "", function(v)
        Config.DiscordBotToken = v
    end, nil, "MTIzNDU2Nzg5...")
    Components.CreateInputRow(cardRemote, "Channel ID", "ID kênh Discord (tự phát hiện từ webhook nếu trống)", Config.DiscordChannelId or "", function(v)
        Config.DiscordChannelId = v
    end, nil, "1396490335269421238")

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
