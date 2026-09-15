--[[
    v2/ui/tabs/tab_cai_dat.lua
    Exact Tab Cài Đặt from backup.lua (Profiles, Priority Manager, Webhooks & Unload)
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

    Components.CreateCategoryHeader(parent, "Cảnh Báo Discord Webhook")
    local cardWebhook = Components.CreateCardGroup(parent)
    Components.CreateInputRow(cardWebhook, "Webhook URL", "Dán đường dẫn Webhook Discord tại đây", Config.WebhookUrl or "", function(v)
        Config.WebhookUrl = v
    end, nil, "https://discord.com/api/webhooks/...")
    Components.CreateToggleRow(cardWebhook, "Bật Webhook", "Kích hoạt gửi tin nhắn về Discord", Config.WebhookEnabled, function(v)
        Config.WebhookEnabled = v
    end)
    Components.CreateToggleRow(cardWebhook, "Thông Báo Bắt Được Boss", "Gửi tin nhắn khi câu trúng Secret Boss", Config.WebhookNotifyBoss, function(v)
        Config.WebhookNotifyBoss = v
    end)

    Components.CreateCategoryHeader(parent, "Hệ Thống & Thoát")
    local cardExit = Components.CreateCardGroup(parent)
    Components.CreateButtonRow(cardExit, "Hủy Script Hoàn Toàn (Unload)", "Xóa toàn bộ giao diện và ngắt kết nối an toàn", "Hủy Script", function()
        Utils.ShowNotification("Identical Hub", "Đang đóng script an toàn...", "WARN", 2)
        task.wait(0.2)
        State.UnloadScript()
    end)
end

return TabCaiDat
