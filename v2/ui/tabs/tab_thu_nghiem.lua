--[[
    v2/ui/tabs/tab_thu_nghiem.lua
    Tab 11: Thử Nghiệm (Experimental Features)
--]]

local Components = require(script.Parent.Parent.components)

local TabThuNghiem = {}

function TabThuNghiem.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Tính Năng Đang Phát Triển")
    local cardExp = Components.CreateCardGroup(parent)

    Components.CreateInfoRow(cardExp, "Trạng Thái Module", "Hoạt động ổn định trên V2")
    Components.CreateInfoRow(cardExp, "Phiên Bản Engine", "Modular V2.0.0 (Strict Sequential)")
end

return TabThuNghiem
