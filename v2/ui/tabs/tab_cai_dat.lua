--[[
    v2/ui/tabs/tab_cai_dat.lua
    Tab 10: Cài Đặt (Profiles, Config Management & Script Unload)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabCaiDat = {}

function TabCaiDat.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Quản Lý Cấu Hình (Profiles)")
    local cardConfig = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardConfig, "Lưu Cấu Hình Mặc Định", "Ghi nhớ toàn bộ thiết lập vào bộ nhớ máy", "Lưu Cấu Hình", function()
        local ok, msg = ConfigModule.SaveAccountConfig("Default", State.UIControllers)
        Utils.ShowNotification("Cài Đặt", msg, ok and "SUCCESS" or "ERROR", 3)
    end)

    Components.CreateButtonRow(cardConfig, "Tải Cấu Hình Mặc Định", "Nạp lại thiết lập đã lưu", "Tải Cấu Hình", function()
        local ok, msg = ConfigModule.LoadAccountConfig("Default", State.UIControllers)
        Utils.ShowNotification("Cài Đặt", msg, ok and "SUCCESS" or "ERROR", 3)
    end)

    Components.CreateCategoryHeader(parent, "Hệ Thống & Thoát")
    local cardExit = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardExit, "Hủy Script An Toàn (Unload)", "Xóa toàn bộ giao diện, ngắt kết nối an toàn", "Hủy Script", function()
        State.UnloadScript()
        Utils.ShowNotification("Identical Hub", "Đã hủy script thành công!", "SUCCESS", 3)
    end)
end

return TabCaiDat
