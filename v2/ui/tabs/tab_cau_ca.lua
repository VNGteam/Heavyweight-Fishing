--[[
    v2/ui/tabs/tab_cau_ca.lua
    Tab 1: Câu Cá (Auto Cast, Hook, Perfect Slam, Max Charge, Mồi & Cần)
--]]

local Components = require(script.Parent.Parent.components)
local State = require(script.Parent.Parent.Parent.core.state)

local TabCauCa = {}

function TabCauCa.Render(parent, config)
    -- Section 1: Tự Động Câu & Giật Cần
    Components.CreateCategoryHeader(parent, "Tự Động Câu & Minigame")
    local cardFishing = Components.CreateCardGroup(parent)

    State.UIControllers["AutoCast"] = Components.CreateToggleRow(cardFishing, "Tự Động Quăng Cần (Auto Cast)", "Tự động thả cần câu khi đứng yên hoặc sau khi bắt cá", config.AutoCast, function(v)
        config.AutoCast = v
    end)

    State.UIControllers["AnchorBar"] = Components.CreateToggleRow(cardFishing, "Giữ Cân Bằng Minigame (Anchor Bar)", "Tự động khóa thanh kéo ở vị trí chuẩn xác nhất", config.AnchorBar, function(v)
        config.AnchorBar = v
    end)

    State.UIControllers["AutoSlam"] = Components.CreateToggleRow(cardFishing, "Tự Động Slam (Perfect Slam)", "Tự động giật Perfect ngay khi nút kích hoạt xuất hiện", config.AutoSlam, function(v)
        config.AutoSlam = v
    end)

    State.UIControllers["AutoCharge"] = Components.CreateToggleRow(cardFishing, "Tự Động Max Charge (Gồng 100%)", "Tự động nạp tối đa thanh lực khi cá kéo mạnh", config.AutoCharge, function(v)
        config.AutoCharge = v
    end)

    State.UIControllers["AntiStuck"] = Components.CreateToggleRow(cardFishing, "Chống Kẹt Cần (Anti-Stuck)", "Tự động giật lại cần nếu thả quá 15s không có cá cắn", config.AntiStuck, function(v)
        config.AntiStuck = v
    end)

    State.UIControllers["AutoRhythmHit"] = Components.CreateToggleRow(cardFishing, "Tự Đánh Nhịp Octo (Rhythm Hit)", "Tự động hoàn thành minigame nhịp điệu của cá mực", config.AutoRhythmHit, function(v)
        config.AutoRhythmHit = v
    end)

    -- Section 2: Tự Đổi Mồi & Cần
    Components.CreateCategoryHeader(parent, "Trang Bị Mồi & Cần Câu")
    local cardLoadout = Components.CreateCardGroup(parent)

    State.UIControllers["AutoEquipBestBait"] = Components.CreateToggleRow(cardLoadout, "Tự Trang Bị Mồi Tốt Nhất", "Tự động kiểm tra túi và lắp mồi có bậc phẩm cao nhất", config.AutoEquipBestBait, function(v)
        config.AutoEquipBestBait = v
    end)

    State.UIControllers["AutoEquipBestRod"] = Components.CreateToggleRow(cardLoadout, "Tự Trang Bị Cần Mạnh Nhất", "Tự động cầm cần câu có lực kéo lớn nhất trong túi", config.AutoEquipBestRod, function(v)
        config.AutoEquipBestRod = v
    end)
end

return TabCauCa
