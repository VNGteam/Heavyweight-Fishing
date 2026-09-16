--[[
    v2/ui/tabs/tab_nhiem_vu.lua
    Daily Tickets Engine, Settings, Spots Management & Remote Actions
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Quest = require(script.Parent.Parent.Parent.features.quest)
local Services = require(script.Parent.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabNhiemVu = {}

function TabNhiemVu.Render(parent)
    Components.CreateCategoryHeader(parent, "📊 Trạng Thái Vé Nhiệm Vụ")
    local cardStatus = Components.CreateCardGroup(parent)

    local statusRow = Components.CreateInfoRow(cardStatus, "Tiến Độ Nhiệm Vụ", Quest.state.statusText)
    task.spawn(function()
        while true do
            task.wait(1.5)
            if statusRow and statusRow.Set then
                statusRow.Set(Quest.state.statusText)
            end
        end
    end)

    Components.CreateCategoryHeader(parent, "🎟️ Tự Động Nộp & Làm Vé Nhiệm Vụ (Tickets)")
    local cardTicket = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardTicket, "Tự Động Nộp Vé Nhiệm Vụ (Tickets)", "Tự động nhận, thực hiện và trả nhiệm vụ vé hàng ngày", Config.AutoTicketQuest, function(v) Config.AutoTicketQuest = v end)
    Components.CreateDropdownRow(cardTicket, "Chọn Độ Khó Vé Nhiệm Vụ", "Độ khó nhiệm vụ muốn ưu tiên nhận", {"Hard", "Easy"}, Config.TicketDifficulty, function(v) Config.TicketDifficulty = v end)
    Components.CreateDropdownRow(cardTicket, "Chế Độ Nhiệm Vụ", "Chế độ lọc loại nhiệm vụ ưu tiên", {"Tự Động (Auto Detect)", "100 Cá (Fish 100)", "100 Chiêu (Skill 100)", "15m Cá (Size 15m)", "100 Mồi (Bait 100)"}, Config.TicketQuestMode, function(v) Config.TicketQuestMode = v end)
    Components.CreateDropdownRow(cardTicket, "Mồi Cho Nhiệm Vụ 100 Mồi", "Loại mồi dùng khi làm quest 100 mồi", {"Basic Bait", "Ancestral Bait", "Secret Bait"}, Config.TicketBaitChoice, function(v) Config.TicketBaitChoice = v end)
    Components.CreateDropdownRow(cardTicket, "Chiêu Dùng Cho Nhiệm Vụ 100 Skill", "Chiêu spam cho nhiệm vụ 100 skill", {"Chiêu Z", "Chiêu X", "Chiêu C", "Chiêu V"}, Config.TicketSkillKey, function(v) Config.TicketSkillKey = v end)
    Components.CreateDropdownRow(cardTicket, "Chiêu Giật Nhanh Cho 100 Con Cá", "Chiêu kết liễu nhanh cho nhiệm vụ 100 cá", {"Chiêu Z", "Chiêu X", "Chiêu C", "Chiêu V"}, Config.TicketQuickSkill, function(v) Config.TicketQuickSkill = v end)
    Components.CreateToggleRow(cardTicket, "Tự Bán Cá Khi Đầy Balo (Vé NV)", "Tự bán cá giải phóng chỗ trống khi đang làm vé", Config.TicketAutoSellFull, function(v) Config.TicketAutoSellFull = v end)
    Components.CreateToggleRow(cardTicket, "Tự Về Home Spot Khi Xong Nhiệm Vụ", "Tự bay về điểm farm chính khi hết vé", Config.TicketReturnHomeWhenDone, function(v) Config.TicketReturnHomeWhenDone = v end)
    Components.CreateToggleRow(cardTicket, "Tự Động Quăng Cần Tại Home Spot", "Tiếp tục farm cá tại Home Spot khi hoàn thành vé", Config.TicketAutoCastAtHome, function(v) Config.TicketAutoCastAtHome = v end)
    Components.CreateToggleRow(cardTicket, "Nhận & Nộp Vé Từ Xa (Remote)", "Thực hiện nhận và trả nhiệm vụ từ xa", Config.TicketRemoteClaim, function(v) Config.TicketRemoteClaim = v end)
    Components.CreateToggleRow(cardTicket, "Tự Động Nhận Thưởng Hàng Ngày (Daily)", "Tự động nhận quà đăng nhập mỗi ngày", Config.AutoClaimDaily, function(v) Config.AutoClaimDaily = v end)

    Components.CreateCategoryHeader(parent, "⚡ Thao Tác Nhanh")
    local cardActions = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardActions, "Nộp Vé Ngay Lập Tức", "Dịch chuyển tức thì đến NPC và nộp vé hoàn thành", "Nộp Vé", function()
        Utils.ShowNotification("Nhiệm Vụ Vé", "Đang tiến hành nộp vé...", "INFO", 3)
        task.spawn(function()
            Quest.InteractNPC(true, Config)
        end)
    end)

    Components.CreateButtonRow(cardActions, "Nhận Vé Mới Ngay", "Dịch chuyển đến NPC và nhận vé nhiệm vụ mới", "Nhận Vé", function()
        Utils.ShowNotification("Nhiệm Vụ Vé", "Đang tiến hành nhận vé mới...", "INFO", 3)
        task.spawn(function()
            Quest.InteractNPC(false, Config)
        end)
    end)

    Components.CreateButtonRow(cardActions, "Bay Đến NPC Vé", "Dịch chuyển tức thì đến vị trí của NPC trao vé", "Bay Đến", function()
        Quest.TeleportToNPC()
        Utils.ShowNotification("Nhiệm Vụ Vé", "Đã bay đến vị trí NPC nhận vé!", "SUCCESS", 4)
    end)

    Components.CreateCategoryHeader(parent, "📍 Cài Đặt Điểm Câu Cho Từng Loại Vé")
    local cardSpots = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(cardSpots, "Lưu Vị Trí Hiện Tại Làm Điểm 100 Cá", "Đặt tọa độ đứng hiện tại làm điểm farm 100 con cá", "Lưu 100 Cá", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot100Fish = root.Position
            Quest.SaveSpots()
            Utils.ShowNotification("Điểm Câu", "Đã lưu điểm làm nhiệm vụ 100 con cá!", "SUCCESS", 4)
        end
    end)

    Components.CreateButtonRow(cardSpots, "Lưu Vị Trí Hiện Tại Làm Điểm 1.5M Cá", "Đặt tọa độ đứng hiện tại làm điểm farm cá 1.5M (Map 9)", "Lưu 1.5M Cá", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot15MFish = root.Position
            Quest.SaveSpots()
            Utils.ShowNotification("Điểm Câu", "Đã lưu điểm làm nhiệm vụ cá 1.5M!", "SUCCESS", 4)
        end
    end)

    Components.CreateButtonRow(cardSpots, "Lưu Vị Trí Hiện Tại Làm Điểm 100 Mồi", "Đặt tọa độ đứng hiện tại làm điểm farm tiêu thụ 100 mồi", "Lưu 100 Mồi", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot100Bait = root.Position
            Quest.SaveSpots()
            Utils.ShowNotification("Điểm Câu", "Đã lưu điểm làm nhiệm vụ 100 mồi!", "SUCCESS", 4)
        end
    end)
end

return TabNhiemVu
