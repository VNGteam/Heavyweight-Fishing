--[[
    v2/ui/tabs/tab_nhiem_vu.lua
    Tab 4: Nhiệm Vụ (Daily Ticket Quests)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)
local Quest = require(script.Parent.Parent.Parent.features.quest)

local TabNhiemVu = {}

function TabNhiemVu.Render(parent, config)
    Components.CreateCategoryHeader(parent, "Tự Động Làm Nhiệm Vụ Vé Hàng Ngày")
    local cardQuest = Components.CreateCardGroup(parent)

    State.UIControllers["AutoTicketQuest"] = Components.CreateToggleRow(cardQuest, "Kích Hoạt Auto Nhiệm Vụ Vé", "Tự động nhận quest, làm quest, trả quest và chuyển đổi thông minh", config.AutoTicketQuest, function(v)
        config.AutoTicketQuest = v
    end)

    State.UIControllers["TicketAutoCastAtHome"] = Components.CreateToggleRow(cardQuest, "Tự Về Điểm Farm Khi Hết Vé", "Khi hoàn thành hết vé trong ngày, tự bay về điểm câu chính để farm tiếp", config.TicketAutoCastAtHome, function(v)
        config.TicketAutoCastAtHome = v
    end)

    -- Hiển thị trạng thái nhiệm vụ hiện tại
    Components.CreateCategoryHeader(parent, "Trạng Thái Nhiệm Vụ")
    local cardStatus = Components.CreateCardGroup(parent)

    local qTypeRow = Components.CreateInfoRow(cardStatus, "Nhiệm Vụ Đang Làm", Quest.state.currentQuestType or "Không có")
    local qCdRow = Components.CreateInfoRow(cardStatus, "Trạng Thái Cooldown", Quest.state.isCooldown and "Đang chờ ngày mới" or "Sẵn sàng")

    task.spawn(function()
        while State.isRunning do
            task.wait(1.5)
            pcall(function()
                qTypeRow.Set(Quest.state.currentQuestType or "Không có")
                qCdRow.Set(Quest.state.isCooldown and "Đang chờ ngày mới" or "Sẵn sàng")
            end)
        end
    end)
end

return TabNhiemVu
