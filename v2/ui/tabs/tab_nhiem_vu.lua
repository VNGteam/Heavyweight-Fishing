--[[
    v2/ui/tabs/tab_nhiem_vu.lua
    Exact Tab Nhiệm Vụ from backup.lua (Daily Tickets Engine & Settings)
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config

local TabNhiemVu = {}

function TabNhiemVu.Render(parent)
    Components.CreateCategoryHeader(parent, "Tự Động Nộp & Làm Vé Nhiệm Vụ (Tickets)")
    local cardTicket = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardTicket, "Tự Động Nộp Vé Nhiệm Vụ (Tickets)", "Tự động nhận, thực hiện và trả nhiệm vụ vé hàng ngày", Config.AutoTicketQuest, function(v) Config.AutoTicketQuest = v end)
    Components.CreateDropdownRow(cardTicket, "Chọn Độ Khó Vé Nhiệm Vụ", "Độ khó nhiệm vụ muốn ưu tiên nhận", {"Easy", "Medium", "Hard"}, Config.TicketDifficulty, function(v) Config.TicketDifficulty = v end)
    Components.CreateDropdownRow(cardTicket, "Chế Độ Nhiệm Vụ", "Chế độ lọc loại nhiệm vụ ưu tiên", {"Tự Động (Auto Detect)", "100 Cá (Fish 100)", "100 Chiêu (Skill 100)", "15m Cá (Size 15m)", "100 Mồi (Bait 100)"}, Config.TicketQuestMode, function(v) Config.TicketQuestMode = v end)
    Components.CreateDropdownRow(cardTicket, "Chiêu Dùng Cho Nhiệm Vụ 100 Skill", "Chiêu spam cho nhiệm vụ 100 skill", {"Chiêu Z", "Chiêu X", "Chiêu C", "Chiêu V"}, Config.TicketSkillKey, function(v) Config.TicketSkillKey = v end)
    Components.CreateDropdownRow(cardTicket, "Chiêu Giật Nhanh Cho 100 Con Cá", "Chiêu kết liễu nhanh cho nhiệm vụ 100 cá", {"Chiêu Z", "Chiêu X", "Chiêu C", "Chiêu V"}, Config.TicketQuickSkill, function(v) Config.TicketQuickSkill = v end)
    Components.CreateToggleRow(cardTicket, "Tự Bán Cá Khi Đầy Balo (Vé NV)", "Tự bán cá giải phóng chỗ trống khi đang làm vé", Config.TicketAutoSellFull, function(v) Config.TicketAutoSellFull = v end)
    Components.CreateToggleRow(cardTicket, "Tự Về Home Spot Khi Xong Nhiệm Vụ", "Tự bay về điểm farm chính khi hết vé", Config.TicketReturnHomeWhenDone, function(v) Config.TicketReturnHomeWhenDone = v end)
    Components.CreateToggleRow(cardTicket, "Tự Động Quăng Cần Tại Home Spot", "Tiếp tục farm cá tại Home Spot khi hoàn thành vé", Config.TicketAutoCastAtHome, function(v) Config.TicketAutoCastAtHome = v end)
    Components.CreateToggleRow(cardTicket, "Nhận & Nộp Vé Từ Xa (Remote)", "Thực hiện nhận và trả nhiệm vụ từ xa", Config.TicketRemoteClaim, function(v) Config.TicketRemoteClaim = v end)
    Components.CreateToggleRow(cardTicket, "Tự Động Nhận Thưởng Hàng Ngày (Daily)", "Tự động nhận quà đăng nhập mỗi ngày", Config.AutoClaimDaily, function(v) Config.AutoClaimDaily = v end)
end

return TabNhiemVu
