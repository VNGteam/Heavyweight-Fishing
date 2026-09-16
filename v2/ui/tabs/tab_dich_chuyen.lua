--[[
    v2/ui/tabs/tab_dich_chuyen.lua
    Full Teleport System: 10 Islands, Boss Realms, Secret Rods, Rod Dealers, Players & 17 Quest NPCs
--]]

local Components = require(script.Parent.Parent.components)
local Teleport = require(script.Parent.Parent.Parent.features.teleport)
local Services = require(script.Parent.Parent.Parent.core.services)
local Spirits = require(script.Parent.Parent.Parent.features.spirits)
local Utils = require(script.Parent.Parent.Parent.core.utils)

local Players = Services.Players
local LocalPlayer = Services.LocalPlayer
local Workspace = Services.Workspace

local TabDichChuyen = {}

local WorldData = {
    islands = {
        {name = "[1] Đảo Khởi Đầu (Spawn)", pos = Vector3.new(-200.7, 11.1, 35.9), radius = 850},
        {name = "[2] Đảo Tre (Bamboo Isle)", pos = Vector3.new(-1223.0, 7.3, -24.1), radius = 850},
        {name = "[3] Đảo Phóng Xạ (Fallout Isle)", pos = Vector3.new(65.5, 8.8, 1181.3), radius = 850},
        {name = "[4] Đảo Thống Trị (Sovereign Isle)", pos = Vector3.new(-1276.4, 8.8, 1239.7), radius = 850},
        {name = "[5] Đảo Cá Chép (Perch Isle)", pos = Vector3.new(-62.0, 11.9, -1321.4), radius = 850},
        {name = "[6] Đảo Băng Giá (Frost Isle)", pos = Vector3.new(-1366.0, 11.9, -1495.4), radius = 850},
        {name = "[7] Đảo Quả Dừa (Coconut Isle)", pos = Vector3.new(1493.6, 9.1, -1430.6), radius = 850},
        {name = "[8] Đảo Hổ Phách (Amber Isle)", pos = Vector3.new(1259.4, 9.1, 1401.5), radius = 850},
        {name = "[9] Đảo Chiến Trường (Battlefield)", pos = Vector3.new(1393.5, 11.3, 169.6), radius = 850},
        {name = "[10] Đảo Đỉnh Sương Mù (Mistpeak)", pos = Vector3.new(2660.2, 8.8, -86.7), radius = 850},
    },
    bossRealms = {
        {name = "Boss Bạch Tuộc (Phao Biển)", pos = Vector3.new(1608.2, 5.0, -218.3), radius = 450},
        {name = "Vùng Câu Cá Ngầm Lòng Đất", pos = Vector3.new(112.5, -330.0, -30.8), radius = 450},
        {name = "Đấu Trường Boss Enzo", pos = Vector3.new(-115.3, 9.2, 1349.5), radius = 450},
    }
}

local function GetCurrentLocationName()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return "Đang tải vị trí...", nil end
    local myPos = root.Position

    if myPos.Y < -150 then
        return "Vùng Câu Cá Ngầm Lòng Đất", "underground"
    end

    local bestName = "Đang ở giữa biển"
    local bestObj = nil
    local minDist = 999999

    for _, isl in ipairs(WorldData.islands) do
        local dist = (Vector3.new(myPos.X, 0, myPos.Z) - Vector3.new(isl.pos.X, 0, isl.pos.Z)).Magnitude
        if dist < (isl.radius or 850) and dist < minDist then
            minDist = dist
            bestName = isl.name
            bestObj = isl
        end
    end

    for _, br in ipairs(WorldData.bossRealms) do
        local dist = (myPos - br.pos).Magnitude
        if dist < (br.radius or 450) and dist < minDist then
            minDist = dist
            bestName = br.name
            bestObj = br
        end
    end

    return bestName, bestObj, minDist
end

function TabDichChuyen.Render(parent)
    -- ============================================================
    -- 1. DỊCH CHUYỂN ĐẾN ĐẢO (1 - 10)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🏝️ Dịch Chuyển Đến Đảo (Đảo 1 - 10)")
    local islandCard = Components.CreateCardGroup(parent)

    local infoCurrentMap = Components.CreateInfoRow(islandCard, "📍 Vị Trí Bạn Đang Đứng", "Đang nhận diện...")

    Components.CreateButtonRow(islandCard, "📋 Sao Chép Tọa Độ Hiện Tại", "Copy tọa độ đứng hiện tại vào Clipboard để lưu trữ", "Sao Chép", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local pos = root.Position
        local str = string.format("Vector3.new(%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)
        pcall(function()
            if setclipboard then setclipboard(str)
            elseif toclipboard then toclipboard(str) end
        end)
        Utils.ShowNotification("TỌA ĐỘ HIỆN TẠI", "Đã copy: " .. str .. " vào Clipboard!", "SUCCESS", 5)
    end)

    task.spawn(function()
        while true do
            task.wait(2.0)
            if infoCurrentMap and infoCurrentMap.Set then
                local locName = GetCurrentLocationName()
                infoCurrentMap.Set(locName)
            end
        end
    end)

    for _, isl in ipairs(WorldData.islands) do
        Components.CreateButtonRow(islandCard, isl.name, "Bay thẳng đến " .. isl.name, "Bay Tới", function()
            local curLoc = GetCurrentLocationName()
            if curLoc == isl.name then
                Utils.ShowNotification("Dịch Chuyển", "Bạn đang ở ngay " .. isl.name .. " rồi!", "INFO", 3)
                return
            end
            Teleport.To(isl.pos + Vector3.new(0, 3, 0))
            Utils.ShowNotification("Dịch Chuyển", "Đã đến " .. isl.name .. "!", "SUCCESS", 3)
        end)
    end

    -- ============================================================
    -- 2. ĐẤU TRƯỜNG BOSS & VÙNG ĐẤT BÍ MẬT
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🐙 Đấu Trường Boss & Vùng Đất Bí Mật")
    local bossRealmCard = Components.CreateCardGroup(parent)

    for _, br in ipairs(WorldData.bossRealms) do
        Components.CreateButtonRow(bossRealmCard, br.name, "Dịch chuyển tức thì đến " .. br.name, "Bay Đến", function()
            Teleport.To(br.pos + Vector3.new(0, 3, 0))
            Utils.ShowNotification("Dịch Chuyển", "Đã đến " .. br.name .. "!", "SUCCESS", 4)
        end)
    end

    -- ============================================================
    -- 3. CỬA HÀNG BÁN CẦN (BIAO DI)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🏪 Cửa Hàng Bán Cần (Biao Di)")
    local rodDealerCard = Components.CreateCollapsibleCardGroup(parent, "Danh Sách Thợ Bán Cần Tại Các Đảo", false)

    local rodDealers = {
        {name = "[1] Shop Đảo Khởi Đầu", pos = Vector3.new(-151.4, 8.7, -49.9)},
        {name = "[2] Shop Đảo Tre", pos = Vector3.new(-1236.8, 7.3, -174.1)},
        {name = "[3] Shop Đảo Phóng Xạ", pos = Vector3.new(138.4, 9.0, 1179.7)},
        {name = "[4] Shop Đảo Thống Trị", pos = Vector3.new(-1262.6, 8.2, 1202.2)},
        {name = "[5] Shop Đảo Cá Chép", pos = Vector3.new(-9.5, 9.2, -1330.0)},
        {name = "[6] Shop Đảo Băng Giá", pos = Vector3.new(-1400.4, 9.2, -1490.6)},
        {name = "[7] Shop Đảo Quả Dừa", pos = Vector3.new(1446.0, 9.3, -1408.0)},
        {name = "[8] Shop Đảo Hổ Phách", pos = Vector3.new(1292.7, 8.2, 1497.4)},
    }

    for _, rd in ipairs(rodDealers) do
        Components.CreateButtonRow(rodDealerCard, rd.name, "Bay trực tiếp đến " .. rd.name, "Bay Đến", function()
            Teleport.To(rd.pos + Vector3.new(0, 3, 0))
            Utils.ShowNotification("Cửa Hàng", "Đã đến " .. rd.name .. "!", "SUCCESS", 3)
        end)
    end

    -- ============================================================
    -- 4. VỊ TRÍ CẦN CÂU BÍ MẬT
    -- ============================================================
    Components.CreateCategoryHeader(parent, "✨ Vị Trí Cần Câu Bí Mật (Secret Rods)")
    local sRodCard = Components.CreateCardGroup(parent)

    local secretRods = {
        {name = "Anchorbound Rod", pos = Vector3.new(-1208.5, 56.3, 1646.2)},
        {name = "Blazeshark Rod", pos = Vector3.new(-8.4, 53.9, 6.7)},
        {name = "Kraken Rod", pos = Vector3.new(1543.8, 73.4, 1490.9)},
        {name = "Ascendant Bamboo Rod", pos = Vector3.new(-1360.6, 140.6, 31.0)},
        {name = "Lifebloom Rod", pos = Vector3.new(-114.9, 74.9, -1533.2)},
        {name = "Demonic Rod", pos = Vector3.new(1181.9, 82.9, -1243.8)}
    }

    for _, sr in ipairs(secretRods) do
        Components.CreateButtonRow(sRodCard, sr.name, "Bay đến tọa độ lấy cần: " .. sr.name, "Bay Đến", function()
            Teleport.To(sr.pos + Vector3.new(0, 3, 0))
            Utils.ShowNotification("Cần Bí Mật", "Đã bay đến vị trí " .. sr.name .. "!", "SUCCESS", 4)
        end)
    end

    -- ============================================================
    -- 5. DỊCH CHUYỂN ĐẾN NGƯỜI CHƠI TRONG MAP
    -- ============================================================
    Components.CreateCategoryHeader(parent, "👥 Dịch Chuyển Đến Người Chơi Trong Map")
    local srvCard = Components.CreateCardGroup(parent)

    local playerLookup = {}
    local selectedPlayerKey = nil

    local function BuildPlayerList()
        local list = {}
        table.clear(playerLookup)
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local distStr = ""
                if myPos and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = math.floor((p.Character.HumanoidRootPart.Position - myPos).Magnitude)
                    distStr = string.format(" [%dm]", d)
                end
                local key = string.format("%s (@%s)%s", p.DisplayName, p.Name, distStr)
                table.insert(list, key)
                playerLookup[key] = p
            end
        end

        if #list == 0 then
            table.insert(list, "Không có người chơi khác")
        end
        return list
    end

    local initialPlayerList = BuildPlayerList()
    selectedPlayerKey = initialPlayerList[1]

    local playerDropdown = Components.CreateDropdownRow(srvCard, "Chọn Người Chơi", "Danh sách người chơi đang có mặt trong server", initialPlayerList, selectedPlayerKey, function(v)
        selectedPlayerKey = v
    end)

    local function RefreshPlayerDropdown()
        local newList = BuildPlayerList()
        if playerDropdown and playerDropdown.Refresh then
            playerDropdown.Refresh(newList, true)
            selectedPlayerKey = playerDropdown.Get and playerDropdown.Get() or newList[1]
        end
    end

    Components.CreateButtonRow(srvCard, "Bay Đến Người Chơi Đã Chọn", "Dịch chuyển tức thì đến ngay bên cạnh người chơi đang chọn", "🚀 Bay Đến", function()
        local targetPlayer = playerLookup[selectedPlayerKey]
        if not targetPlayer then
            local uName = selectedPlayerKey and selectedPlayerKey:match("@([%w_]+)")
            if uName then
                targetPlayer = Players:FindFirstChild(uName)
            end
        end

        if not targetPlayer or not targetPlayer.Parent then
            Utils.ShowNotification("Dịch Chuyển", "Vui lòng chọn người chơi hợp lệ!", "WARN", 3)
            RefreshPlayerDropdown()
            return
        end

        local tChar = targetPlayer.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if myRoot and tRoot then
            myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 2, 3)
            Utils.ShowNotification("Dịch Chuyển", "Đã bay đến người chơi: " .. targetPlayer.DisplayName, "SUCCESS", 4)
            RefreshPlayerDropdown()
        else
            Utils.ShowNotification("Dịch Chuyển", "Người chơi này chưa hồi sinh hoặc không có nhân vật!", "WARN", 3)
        end
    end)

    Components.CreateButtonRow(srvCard, "Làm Mới Danh Sách Người Chơi", "Cập nhật danh sách người chơi vừa tham gia hoặc rời server", "🔄 Làm Mới", function()
        RefreshPlayerDropdown()
        Utils.ShowNotification("Danh Sách", "Đã cập nhật danh sách người chơi trong map!", "INFO", 3)
    end)

    local lastTpTarget = nil
    Components.CreateButtonRow(srvCard, "Bay Đến Người Chơi Ngẫu Nhiên", "Dịch chuyển tức thì đến vị trí của một người chơi bất kỳ", "🎲 Ngẫu Nhiên", function()
        local targets = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(targets, p)
            end
        end
        if #targets == 0 then
            Utils.ShowNotification("Dịch Chuyển", "Không tìm thấy người chơi nào khác trong server.", "WARN", 3)
            return
        end
        local pool = {}
        for _, p in ipairs(targets) do
            if not (#targets > 1 and p == lastTpTarget) then
                table.insert(pool, p)
            end
        end
        local selected = (#pool > 0 and pool[math.random(1, #pool)]) or targets[math.random(1, #targets)]
        lastTpTarget = selected
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and selected.Character and selected.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = selected.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 3)
            Utils.ShowNotification("Dịch Chuyển", "Đã bay đến người chơi: " .. selected.DisplayName, "SUCCESS", 4)
            RefreshPlayerDropdown()
        end
    end)

    -- ============================================================
    -- 6. DỊCH CHUYỂN ĐẾN 17 NPC NHIỆM VỤ
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🧙 Dịch Chuyển Đến 17 NPC Nhiệm Vụ")
    local npcTeleCard = Components.CreateCollapsibleCardGroup(parent, "Danh Sách Tất Cả NPC Trong Game", true)

    local questNPCList = {
        { name="Ha Dieu De",            path="Function",  icon="🏆", role="Main Quest",          desc="Trả quest cá Rainbow Dragonfish & Heavenpiercer Turtle", island="Bamboo / Coconut / Frost" },
        { name="Giang Lao",             path="Function",  icon="🎣", role="Main Quest",          desc="NPC nhiệm vụ chính • Trả quest cá nặng", island="Bamboo / Mistpeak / World Angler" },
        { name="Sage Yijiu",            path="Function",  icon="🔮", role="Skill Shop + Quest",  desc="Bán skill Heavenpiercer & Pure Diamond • Trả quest Frost", island="Frost Isle / World Angler" },
        { name="Blind Grand Angler",    path="Function",  icon="👁️", role="Main Quest",          desc="Lão ngư ông mù • Trả quest mở khóa câu bí mật", island="Battlefield Isle" },
        { name="Duan Gan",              path="Function",  icon="🗡️", role="Main Quest",          desc="Võ sĩ gãy cần • Quest chính • Cần Huyết Long", island="Đảo chính" },
        { name="Bac Minh",              path="Function",  icon="⬆️", role="Skill Shop",          desc="Bán và nâng cấp kỹ năng câu cá bằng Gems", island="Đảo chính" },
        { name="Zeng Tianguo",          path="Function",  icon="⚡", role="Skill Upgrade",       desc="Nâng cấp kỹ năng đặc biệt", island="Perch / Sovereign" },
        { name="Tang Thien Quoc",       path="Function",  icon="🌟", role="Skill Upgrade",       desc="NPC nâng cấp kỹ năng cấp cao", island="Sovereign / Perch" },
        { name="Biao Di",               path="Function",  icon="🎯", role="Thợ Chế Cần Câu",    desc="Craft & mua bán cần câu các loại", island="Mọi đảo chính" },
        { name="Hua Heshang",           path="Function",  icon="🐉", role="Dragon Quest",        desc="Yêu cầu skill Dragon Subjugation", island="Đảo chính" },
        { name="The Shadow",            path="Function",  icon="🌑", role="Bí Mật / PVP",       desc="Nhiệm vụ bí mật và PVP arena đặc biệt", island="Đảo chính" },
        { name="Lao Ngo",               path="Function",  icon="👴", role="Quest Phụ",           desc="Lão Ngô • Cung cấp thông tin câu hiếm", island="Đảo chính" },
        { name="Nanjiang",              path="Function",  icon="🗺️", role="Quest Phụ",           desc="Nam Giang • Thông tin đảo và vị trí câu hiếm", island="Đảo chính" },
        { name="Giang Lao PVP",         path="Function",  icon="⚔️", role="PVP Arena",           desc="Đấu trường PVP câu cá • Nhận Stars đổi skin cần", island="Battlefield Isle" },
        { name="Battlefield Isle's Giang Lao", path="Function", icon="🏟️", role="Battlefield Quest", desc="Quest đấu trường Battlefield", island="Battlefield Isle" },
        { name="Ticket Quest Giver",    path="Function",  icon="🎫", role="Sự Kiện",             desc="Phát nhiệm vụ vé hàng ngày (Daily Tickets)", island="Đảo chính" },
        { name="Nana",                  path="SellFish",  icon="🐟", role="Bán Cá",             desc="Thu mua cá nhanh lấy Gems", island="Mọi đảo" },
        { name="Ba Chang",              path="BuyBait",   icon="🪱", role="Bán Mồi Câu",        desc="Bán mồi câu cơ bản giá rẻ", island="Đảo chính / Coconut" },
    }

    local function findNPCModel(npcName, npcPath)
        local npcFolder = Workspace:FindFirstChild("NPC")
        if npcFolder then
            local pathFolder = npcFolder:FindFirstChild(npcPath)
            if pathFolder then
                local found = pathFolder:FindFirstChild(npcName)
                if found and (found:FindFirstChild("HumanoidRootPart") or found:IsA("BasePart")) then
                    return found
                end
            end
            for _, sub in ipairs(npcFolder:GetChildren()) do
                local found = sub:FindFirstChild(npcName)
                if found then return found end
            end
        end
        return Workspace:FindFirstChild(npcName, true)
    end

    for _, npc in ipairs(questNPCList) do
        local title = string.format("%s %s [%s]", npc.icon, npc.name, npc.role)
        local desc = string.format("%s\n📍 %s", npc.desc, npc.island)
        Components.CreateButtonRow(npcTeleCard, title, desc, "Bay Đến", function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                Utils.ShowNotification("Lỗi", "Nhân vật chưa spawn!", "ERROR", 3)
                return
            end
            local model = findNPCModel(npc.name, npc.path)
            if model then
                local npcRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                if npcRoot then
                    root.CFrame = CFrame.new(npcRoot.Position + Vector3.new(0, 3, 3))
                    Utils.ShowNotification("✅ Đến " .. npc.name, "Đã bay đến NPC " .. npc.name .. "!", "SUCCESS", 4)
                    return
                end
            end
            Utils.ShowNotification("❌ Không Tìm Thấy", "NPC '" .. npc.name .. "' không có trong map lúc này.", "WARN", 4)
        end)
    end

    -- ============================================================
    -- 7. DỊCH CHUYỂN ĐẾN ĐẠO SĨ (TAOIST & MAOSHAN)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "📜 Dịch Chuyển Đến Đạo Sĩ (Taoist & Maoshan)")
    local taoistTeleCard = Components.CreateCardGroup(parent)

    Components.CreateButtonRow(taoistTeleCard, "📜 Bay Đến Đạo Sĩ (Taoist)", "Dịch chuyển tức thì đến NPC Đạo Sĩ nếu có trong server", "Bay Đến", function()
        local tInst, tName = Spirits.ScanForTaoistNPC()
        if tInst then
            local ok = Spirits.TeleportToNPC(tInst)
            if ok then
                Utils.ShowNotification("Đạo Sĩ (Taoist)", "Đã dịch chuyển đến vị trí " .. tostring(tName) .. "!", "SUCCESS", 5)
            else
                Utils.ShowNotification("Đạo Sĩ (Taoist)", "Không lấy được tọa độ Đạo Sĩ.", "WARN", 3)
            end
        else
            Utils.ShowNotification("Đạo Sĩ (Taoist)", "Server này hiện chưa có Đạo Sĩ (Taoist)! Hãy bật 'Đổi Server Tìm Taoist'.", "WARN", 5)
        end
    end)

    Components.CreateButtonRow(taoistTeleCard, "✨ Bay Đến Đạo Sĩ Maoshan", "Dịch chuyển tức thì đến NPC Đạo Sĩ Maoshan nếu có trong server", "Bay Đến", function()
        local mInst, mName = Spirits.ScanForMaoshanNPC()
        if mInst then
            local ok = Spirits.TeleportToNPC(mInst)
            if ok then
                Utils.ShowNotification("Đạo Sĩ Maoshan", "Đã dịch chuyển đến vị trí " .. tostring(mName) .. "!", "SUCCESS", 5)
            else
                Utils.ShowNotification("Đạo Sĩ Maoshan", "Không lấy được tọa độ Đạo Sĩ Maoshan.", "WARN", 3)
            end
        else
            Utils.ShowNotification("Đạo Sĩ Maoshan", "Server này hiện chưa có Đạo Sĩ Maoshan! Hãy bật 'Đổi Server Tìm Maoshan'.", "WARN", 5)
        end
    end)

    -- ============================================================
    -- 8. CHUYỂN SERVER (SERVER HOP)
    -- ============================================================
    Components.CreateCategoryHeader(parent, "🌐 Chuyển Server (Server Hop)")
    local cardHop = Components.CreateCardGroup(parent)
    Components.CreateButtonRow(cardHop, "Chuyển Server Khác (Hop Server)", "Tìm server ngẫu nhiên còn chỗ và chuyển vào", "Đổi Server", function()
        Teleport.ServerHop()
    end)
end

return TabDichChuyen
