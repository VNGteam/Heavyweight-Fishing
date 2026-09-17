--[[
    v2/ui/tabs/tab_nhiem_vu.lua
    Daily Tickets Engine, Zeng Tianguo Quest, Spots Management & Remote Actions
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Quest = require(script.Parent.Parent.Parent.features.quest)
local Services = require(script.Parent.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local Events = Services.Events
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabNhiemVu = {}

function TabNhiemVu.Render(parent)
    -- ============================================================
    -- 1. TRẠNG THÁI & BẬT/TẮT NHIỆM VỤ VÉ (TICKET QUESTS)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "Trạng Thái & Bật/Tắt Nhiệm Vụ Vé (Ticket Quests)")
    local questCard = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(questCard, "Tự Động Làm Vé Nhiệm Vụ", "Tự động nhận, thực hiện và trả vé nhiệm vụ theo chu kỳ 20p", Config.AutoTicketQuest, function(v)
        Config.AutoTicketQuest = v
        if v then
            Quest.state.active = true
            Utils.ShowNotification("Nhiệm Vụ Vé", "Đã bật tự động làm vé nhiệm vụ! Script sẽ quét và thực hiện quest.", "SUCCESS", 5)
        else
            Quest.state.active = false
            Quest.state.isBusyRoutine = false
            Quest.state.currentQuestType = "none"
            Quest.state.isCooldown = false
            Quest.state.isAtHomeSpot = false
            Utils.ShowNotification("Nhiệm Vụ Vé", "Đã tắt tự động làm vé nhiệm vụ.", "INFO", 4)
        end
        Quest.ScanAndUpdateStatus()
    end)

    Components.CreateDropdownRow(questCard, "Độ Khó Nhiệm Vụ", "Chọn độ khó vé nhiệm vụ nhận từ NPC (Mặc định: Hard)", {"Hard", "Easy"}, Config.TicketDifficulty, function(v)
        Config.TicketDifficulty = v
    end)

    local questModes = {
        "Tự Động (Auto Detect)",
        "Câu 10 Con Cá 1.5M+ (Map 9)",
        "Tiêu Thụ 100 Mồi (Map 1)",
        "Dùng Kỹ Năng 100 Lần",
        "Câu Nhanh 100 Con Cá (Map 1)"
    }
    Components.CreateDropdownRow(questCard, "Chế Độ Nhiệm Vụ", "Tự động nhận diện từ game hoặc ép kiểu nhiệm vụ bạn muốn bot làm", questModes, Config.TicketQuestMode, function(v)
        Config.TicketQuestMode = v
        Quest.state.currentQuestType = "none"
        Quest.state.currentProgress = 0
        Quest.ScanAndUpdateStatus()
    end)

    local uiStatus = Components.CreateInfoRow(questCard, "Nhiệm Vụ Hiện Tại", Quest.state.statusText)
    local uiProgress = Components.CreateInfoRow(questCard, "Tiến Độ Nhiệm Vụ", "0 / 100 (0%)")
    local uiCooldown = Components.CreateInfoRow(questCard, "Hồi Chiêu 20 Phút", "Sẵn sàng nhận vé!")

    task.spawn(function()
        while true do
            task.wait(1.2)
            pcall(function()
                if uiStatus and uiStatus.Set then
                    uiStatus.Set(Quest.state.statusText)
                end
                if uiProgress and uiProgress.Set then
                    local cur = Quest.state.currentProgress or 0
                    local max = Quest.state.targetProgress or 100
                    local pct = max > 0 and math.floor((cur / max) * 100) or 0
                    uiProgress.Set(string.format("%d / %d (%d%%)", cur, max, pct))
                end
                if uiCooldown and uiCooldown.Set then
                    if Quest.state.isCooldown and (Quest.state.cooldownEnd or 0) > tick() then
                        local remain = math.max(0, math.floor(Quest.state.cooldownEnd - tick()))
                        local mins = math.floor(remain / 60)
                        local secs = remain % 60
                        uiCooldown.Set(string.format("Còn %02d:%02d", mins, secs))
                    elseif Quest.IsAllQuestsDoneToday and Quest.IsAllQuestsDoneToday() then
                        uiCooldown.Set("Đã hết nhiệm vụ hôm nay!")
                    else
                        uiCooldown.Set("Sẵn sàng nhận vé!")
                    end
                end
            end)
        end
    end)

    -- ============================================================
    -- 2. NHIỆM VỤ KỸ NĂNG ZENG TIANGUO & CHẾ ĐỘ SONG SONG
    -- ============================================================
    Components.CreateCategoryHeader(parent, "⚡ Nhiệm Vụ Kỹ Năng Zeng Tianguo & Chế Độ Song Song")
    local zengCard = Components.CreateCardGroup(parent)

    local uiParallelBadge = Components.CreateInfoRow(zengCard, "Chế Độ Vận Hành", "Đang Tắt")
    Quest.zengState.uiParallelBadge = uiParallelBadge

    Components.CreateToggleRow(zengCard, "Tự Động Nhiệm Vụ Zeng Tianguo", "Tự động nhận, thực hiện và trả nhiệm vụ nâng cấp kỹ năng của Zeng Tianguo", Config.AutoZengTianguoQuest, function(v)
        Config.AutoZengTianguoQuest = v
        if v then
            Quest.zengState.active = true
            Utils.ShowNotification("Zeng Tianguo", "Đã bật tự động làm nhiệm vụ Zeng Tianguo (Skill Upgrade)!", "SUCCESS", 5)
        else
            Quest.zengState.active = false
            Utils.ShowNotification("Zeng Tianguo", "Đã tắt tự động làm nhiệm vụ Zeng Tianguo.", "INFO", 4)
        end
        Quest.DetectActiveZengQuest()
        Quest.UpdateZengUI(Config)
    end)

    Components.CreateToggleRow(zengCard, "Ưu Tiên Ghép Bãi Song Song", "Khi bật cả 2, tự động câu ở đảo của Zeng Tianguo để hoàn thành cả 2 cùng lúc (Ưu tiên vé)", Config.ParallelQuestMode, function(v)
        Config.ParallelQuestMode = v
        Quest.UpdateZengUI(Config)
    end)

    Components.CreateToggleRow(zengCard, "Tự Động Trả Quest Zeng Tianguo", "Tự động bay về NPC trả quest khi hoàn thành chuỗi mục tiêu", Config.ZengTianguoAutoClaim, function(v)
        Config.ZengTianguoAutoClaim = v
    end)

    local uiZengStatus = Components.CreateInfoRow(zengCard, "Nhiệm Vụ Kỹ Năng", Quest.zengState.statusText)
    local uiZengProgress = Components.CreateInfoRow(zengCard, "Tiến Độ Kỹ Năng", "0 / 100 (0%)")
    Quest.zengState.uiStatus = uiZengStatus
    Quest.zengState.uiProgress = uiZengProgress

    Components.CreateButtonRow(zengCard, "Tìm & Bay Đến NPC Zeng Tianguo", "Tự động tìm kiếm vị trí NPC Zeng Tianguo (Skill Upgrade) và bay tới đối diện", "Bay Đến NPC", function()
        local ok = Quest.TeleportToZengNPC()
        if ok then
            Utils.ShowNotification("Dịch Chuyển", "Đã bay đến NPC Zeng Tianguo (Skill Upgrade)!", "SUCCESS", 4)
        else
            Utils.ShowNotification("Dịch Chuyển", "Không tìm thấy model NPC Zeng Tianguo trong game!", "WARN", 4)
        end
    end)

    Components.CreateButtonRow(zengCard, "Nhận / Nộp Quest Zeng Tianguo", "Tương tác nhanh với NPC Zeng Tianguo để nhận hoặc nộp nhiệm vụ hoàn thành", "Tương Tác", function()
        task.spawn(function()
            Utils.ShowNotification("Zeng Tianguo", "Đang tương tác với NPC Zeng Tianguo...", "INFO", 3)
            local isDone = Quest.zengState.isCompleted
            Quest.InteractZengNPC(isDone)
            task.wait(1.0)
            Quest.DetectActiveZengQuest()
            Quest.UpdateZengUI(Config)
        end)
    end)

    -- ============================================================
    -- 3. CÀI ĐẶT VỊ TRÍ CÂU & NPC TICKET QUEST
    -- ============================================================
    Components.CreateCategoryHeader(parent, "📍 Cài Đặt Vị Trí Câu & NPC Ticket Quest")
    local spotCard = Components.CreateCardGroup(parent)

    local function getSpotPos(spot)
        if not spot then return Vector3.zero end
        if typeof(spot) == "CFrame" then return spot.Position end
        if typeof(spot) == "Vector3" then return spot end
        if type(spot) == "table" and spot.x then return Vector3.new(spot.x, spot.y, spot.z) end
        return Vector3.zero
    end

    local p100 = getSpotPos(Quest.state.spot100Fish)
    local ui100Spot = Components.CreateInfoRow(spotCard, "Điểm Câu 100 Con (Map 1)", string.format("(%.0f, %.0f, %.0f)", p100.X, p100.Y, p100.Z))
    Components.CreateButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 100 Con", "Gán vị trí bạn đang đứng làm nơi câu 100 con cá nhẹ", "Lấy Vị Trí", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot100Fish = root.CFrame
            Quest.SaveSpots()
            if ui100Spot and ui100Spot.Set then
                ui100Spot.Set(string.format("(%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z))
            end
            Utils.ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu vị trí câu 100 con: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS", 4)
        end
    end)
    Components.CreateButtonRow(spotCard, "Bay Đến Điểm Câu 100 Con", "Dịch chuyển tức thì đến điểm câu 100 con đã cài", "Bay Đến", function()
        Quest.TeleportTo(Quest.state.spot100Fish)
        Utils.ShowNotification("Dịch Chuyển", "Đã bay đến điểm câu 100 con!", "SUCCESS", 3)
    end)

    local p100B = getSpotPos(Quest.state.spot100Bait)
    local ui100BaitSpot = Components.CreateInfoRow(spotCard, "Điểm Tiêu Thụ 100 Mồi (Map 1)", string.format("(%.0f, %.0f, %.0f)", p100B.X, p100B.Y, p100B.Z))
    Components.CreateButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 100 Mồi", "Gán vị trí bạn đang đứng làm nơi câu tiêu thụ 100 mồi", "Lấy Vị Trí", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot100Bait = root.CFrame
            Quest.SaveSpots()
            if ui100BaitSpot and ui100BaitSpot.Set then
                ui100BaitSpot.Set(string.format("(%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z))
            end
            Utils.ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu vị trí 100 mồi: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS", 4)
        end
    end)
    Components.CreateButtonRow(spotCard, "Bay Đến Điểm 100 Mồi", "Dịch chuyển tức thì đến điểm câu 100 mồi đã cài", "Bay Đến", function()
        Quest.TeleportTo(Quest.state.spot100Bait)
        Utils.ShowNotification("Dịch Chuyển", "Đã bay đến điểm 100 mồi!", "SUCCESS", 3)
    end)

    local p100S = getSpotPos(Quest.state.spot100Skill)
    local ui100SkillSpot = Components.CreateInfoRow(spotCard, "Điểm Câu 100 Skill (Map 1)", string.format("(%.0f, %.0f, %.0f)", p100S.X, p100S.Y, p100S.Z))
    Components.CreateButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 100 Skill", "Gán vị trí bạn đang đứng làm nơi spam 100 skill", "Lấy Vị Trí", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot100Skill = root.CFrame
            Quest.SaveSpots()
            if ui100SkillSpot and ui100SkillSpot.Set then
                ui100SkillSpot.Set(string.format("(%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z))
            end
            Utils.ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu vị trí 100 skill: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS", 4)
        end
    end)
    Components.CreateButtonRow(spotCard, "Bay Đến Điểm 100 Skill", "Dịch chuyển tức thì đến điểm spam 100 skill đã cài", "Bay Đến", function()
        Quest.TeleportTo(Quest.state.spot100Skill)
        Utils.ShowNotification("Dịch Chuyển", "Đã bay đến điểm 100 skill!", "SUCCESS", 3)
    end)

    local p15M = getSpotPos(Quest.state.spot15MFish)
    local ui15MSpot = Components.CreateInfoRow(spotCard, "Điểm Câu 1.5M (Map 9)", string.format("(%.0f, %.0f, %.0f)", p15M.X, p15M.Y, p15M.Z))
    Components.CreateButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Điểm 1.5M", "Gán vị trí bạn đang đứng làm nơi câu cá 1.5M+", "Lấy Vị Trí", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spot15MFish = root.CFrame
            Quest.SaveSpots()
            if ui15MSpot and ui15MSpot.Set then
                ui15MSpot.Set(string.format("(%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z))
            end
            Utils.ShowNotification("Vị Trí Nhiệm Vụ", string.format("Đã lưu vị trí câu 1.5M: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS", 4)
        end
    end)
    Components.CreateButtonRow(spotCard, "Bay Đến Điểm Câu 1.5M", "Dịch chuyển tức thì đến điểm câu cá 1.5M+ đã cài", "Bay Đến", function()
        Quest.TeleportTo(Quest.state.spot15MFish)
        Utils.ShowNotification("Dịch Chuyển", "Đã bay đến điểm câu 1.5M!", "SUCCESS", 3)
    end)

    local pNPC = getSpotPos(Quest.state.spotNPC)
    local uiNPCSpot = Components.CreateInfoRow(spotCard, "Vị Trí NPC Ticket Quest (Map 1)", string.format("(%.0f, %.0f, %.0f)", pNPC.X, pNPC.Y, pNPC.Z))
    Components.CreateButtonRow(spotCard, "Lấy Tọa Độ Hiện Tại Làm Vị Trí NPC", "Gán vị trí bạn đang đứng cạnh NPC Ticket Quest", "Lấy Vị Trí", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            Quest.state.spotNPC = root.CFrame
            Quest.SaveSpots()
            if uiNPCSpot and uiNPCSpot.Set then
                uiNPCSpot.Set(string.format("(%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z))
            end
            Utils.ShowNotification("Vị Trí NPC", string.format("Đã lưu vị trí NPC Ticket Quest: (%.0f, %.0f, %.0f)!", root.Position.X, root.Position.Y, root.Position.Z), "SUCCESS", 4)
        end
    end)
    Components.CreateButtonRow(spotCard, "Tìm & Bay Đến NPC Ticket Quest", "Tự động quét, xoay góc nhìn và bay thẳng đến NPC Ticket Quest", "Bay Đến NPC", function()
        local npcModel, focusPos, prompt = Quest.TeleportToNPC()
        if focusPos then
            Quest.state.spotNPC = focusPos
            Quest.SaveSpots()
            if uiNPCSpot and uiNPCSpot.Set then
                uiNPCSpot.Set(string.format("(%.0f, %.0f, %.0f)", focusPos.X, focusPos.Y, focusPos.Z))
            end
            Utils.ShowNotification("Dịch Chuyển", "Đã tìm thấy, căn góc nhìn chuẩn và bay đến NPC Ticket Quest!", "SUCCESS", 4)
        else
            Quest.TeleportTo(Quest.state.spotNPC)
            Utils.ShowNotification("Dịch Chuyển", "Đã bay đến tọa độ lưu của NPC Ticket Quest!", "SUCCESS", 4)
        end
    end)

    -- ============================================================
    -- 4. TÙY CHỈNH MỒI & KỸ NĂNG CHO NHIỆM VỤ
    -- ============================================================
    Components.CreateCategoryHeader(parent, "⚙️ Tùy Chỉnh Mồi & Kỹ Năng Cho Nhiệm Vụ")
    local optionCard = Components.CreateCardGroup(parent)

    local ticketBaits = {"Basic Bait", "Crude Mash Bait", "Corrupted Essence Bait", "Elite Bait", "Ancestral Bait"}
    Components.CreateDropdownRow(optionCard, "Mồi Cho Nhiệm Vụ 100 Mồi", "Loại mồi bot sẽ mua và dùng khi nhận nv 100 mồi", ticketBaits, Config.TicketBaitChoice, function(v)
        Config.TicketBaitChoice = v
    end)

    local skillList = {"Chiêu Z", "Chiêu X", "Chiêu C", "Chiêu V"}
    Components.CreateDropdownRow(optionCard, "Chiêu Dùng Cho Nhiệm Vụ 100 Skill", "Kỹ năng bot dùng sau 3s khóa chiêu rồi cất cần lặp lại", skillList, Config.TicketSkillKey, function(v)
        Config.TicketSkillKey = v
    end)

    Components.CreateDropdownRow(optionCard, "Chiêu Giật Nhanh Cho 100 Con Cá", "Chiêu mạnh nhất dùng để kết liễu cá Map 1 trong 1 hit", skillList, Config.TicketQuickSkill, function(v)
        Config.TicketQuickSkill = v
    end)

    Components.CreateToggleRow(optionCard, "Tự Bán Cá Khi Đầy Balo (Vé NV)", "Tự động bán sạch cá khi balo đạt giới hạn để câu tiếp", Config.TicketAutoSellFull, function(v)
        Config.TicketAutoSellFull = v
    end)

    Components.CreateToggleRow(optionCard, "Tự Về Home Spot Câu Farm (Chờ 20p)", "Khi trả xong vé và chờ hồi 20p, tự bay về Home Spot và tự động câu cá/combo", Config.TicketReturnHomeWhenDone, function(v)
        Config.TicketReturnHomeWhenDone = v
        Config.TicketAutoCastAtHome = v
    end)

    Components.CreateToggleRow(optionCard, "Nhận & Nộp Vé Từ Xa (Remote)", "Đứng yên tại chỗ câu để nhận và nộp vé Hard từ xa (không cần bay về NPC)", Config.TicketRemoteClaim, function(v)
        Config.TicketRemoteClaim = v
    end)

    -- ============================================================
    -- 5. THAO TÁC NHANH BẰNG TAY
    -- ============================================================
    Components.CreateCategoryHeader(parent, "⚡ Thao Tác Nhanh Bằng Tay")
    local manualCard = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(manualCard, "Nhận Vé Hard Ngay", "Tương tác NPC, mở hội thoại và bấm nút Quest để nhận vé mới", "Nhận Hard", function()
        task.spawn(function()
            Utils.ShowNotification("Nhiệm Vụ Vé", "Đang tương tác NPC nhận vé Hard...", "INFO", 3)
            Quest.InteractNPC(false, Config)
        end)
    end)

    Components.CreateButtonRow(manualCard, "Nộp / Trả Vé Hard Ngay", "Tương tác NPC, mở hội thoại và trả vé nhận quà", "Nộp Hard", function()
        task.spawn(function()
            Utils.ShowNotification("Nhiệm Vụ Vé", "Đang tương tác NPC nộp vé Hard...", "INFO", 3)
            Quest.InteractNPC(true, Config)
        end)
    end)

    Components.CreateButtonRow(manualCard, "Quét Lại Tiến Độ Nhiệm Vụ", "Quét ngay lập tức PlayerGui để kiểm tra nhiệm vụ và tiến độ hiện tại", "Quét Ngay", function()
        Quest.ScanAndUpdateStatus()
        Utils.ShowNotification("Nhiệm Vụ Vé", tostring(Quest.state.statusText), "INFO", 5)
    end)

    Components.CreateButtonRow(manualCard, "Đặt Lại / Bỏ Chặn Hết Vé Hôm Nay", "Xóa cờ đánh dấu hết vé hôm nay để bot thử tương tác nhận vé lại", "🔄 Đặt Lại", function()
        Quest.state.allQuestsDoneForToday = false
        Quest.state.allQuestsDoneDate = nil
        Quest.state.allQuestsDoneUtcDate = nil
        Quest.state.savedDailyCount = nil
        Quest.state.readyForNewQuest = true
        Quest.state.isCooldown = false
        Quest.state.isAtHomeSpot = false
        Quest.state.cooldownEnd = 0
        Quest.state.statusText = "Đã đặt lại! Sẵn sàng thử nhận vé mới."
        Utils.ShowNotification("Nhiệm Vụ Vé", "Đã xóa cờ hết vé hôm nay! Bot sẽ thử nhận vé lại.", "SUCCESS", 5)
    end)

    -- ============================================================
    -- 6. ĐIỂM DANH & NHIỆM VỤ HÀNG NGÀY
    -- ============================================================
    Components.CreateCategoryHeader(parent, "Điểm Danh & Nhiệm Vụ Hàng Ngày")
    local dailyCard = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(dailyCard, "Nhận Thưởng Nhiệm Vụ Ngày", "Tự kiểm tra và nhận thưởng các quest đã xong", "Nhận Thưởng", function()
        if Events and Events:FindFirstChild("ClaimQuest") then
            for i = 1, 4 do
                Events.ClaimQuest:FireServer("Daily", i)
            end
            Utils.ShowNotification("Nhiệm Vụ Ngày", "Đã nhận thưởng tất cả nhiệm vụ ngày hoàn thành!", "SUCCESS", 4)
        else
            Utils.ShowNotification("Lỗi", "Không tìm thấy Remote ClaimQuest!", "ERROR", 3)
        end
    end)

    Components.CreateToggleRow(dailyCard, "Tự Điểm Danh 7 Ngày", "Tự động nhận quà điểm danh hàng ngày từ ngày 1 - 7", Config.AutoClaimDaily, function(v)
        Config.AutoClaimDaily = v
    end)

    Components.CreateSliderRow(dailyCard, "Độ Trễ Nhận Quà", "Thời gian giãn cách giữa các ngày", 0.2, 2.0, Config.DailyClaimDelay or 0.5, true, "s", function(v)
        Config.DailyClaimDelay = v
    end)
end

return TabNhiemVu
