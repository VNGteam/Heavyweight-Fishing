--[[
    v2/ui/tabs/tab_thu_nghiem.lua
    Exact Tab Thử Nghiệm from backup.lua
--]]

local Components = require(script.Parent.Parent.components)

local TabThuNghiem = {}

function TabThuNghiem.Render(parent)
    Components.CreateCategoryHeader(parent, "Tính Năng Thử Nghiệm & Đang Phát Triển")
    local cardExp = Components.CreateCardGroup(parent)

    Components.CreateInfoRow(cardExp, "Trạng Thái Engine", "Modular V2 (Strict Sequential Combo)")
    Components.CreateInfoRow(cardExp, "Giao Diện Hoạt Động", "Identical Theme (Full Original Layout)")
    Components.CreateInfoRow(cardExp, "Tab Wiki", "Đã gỡ bỏ theo yêu cầu để tối ưu hiệu năng")
end

return TabThuNghiem
