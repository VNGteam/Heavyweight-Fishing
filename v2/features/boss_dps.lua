--[[
    v2/features/boss_dps.lua
    Multiplayer Boss DPS & Damage Percentage Meter HUD
--]]

local Services = require(script.Parent.Parent.core.services)
local Players = Services.Players
local Workspace = Services.Workspace
local LocalPlayer = Services.LocalPlayer
local State = require(script.Parent.Parent.core.state)
local Utils = require(script.Parent.Parent.core.utils)
local Theme = require(script.Parent.Parent.ui.theme)

local BossDps = {}

local tracker = {
    active = false,
    currentFish = nil,
    bossName = "Secret Boss",
    maxHp = 0,
    curHp = 0,
    lastHp = 0,
    totalDamage = 0,
    players = {},
    victoryUntil = 0
}

local widget = nil
local dpsTitle = nil
local dpsBossHpLabel = nil
local dpsHpBarFill = nil
local dpsListContainer = nil
local dpsRowPool = {}

local dpsColors = {
    Color3.fromRGB(0, 255, 140),
    Color3.fromRGB(0, 210, 255),
    Color3.fromRGB(255, 170, 0),
    Color3.fromRGB(210, 130, 255),
    Color3.fromRGB(255, 100, 120),
}

local function GetOrCreateDpsRow(index)
    if dpsRowPool[index] then
        dpsRowPool[index].Visible = true
        return dpsRowPool[index]
    end

    local row = Instance.new("Frame")
    row.Name = "Row_" .. tostring(index)
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    row.BorderSizePixel = 0
    row.ClipsDescendants = true
    row.Parent = dpsListContainer
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local rowFill = Instance.new("Frame")
    rowFill.Name = "Fill"
    rowFill.Size = UDim2.new(0, 0, 1, 0)
    rowFill.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    rowFill.BackgroundTransparency = 0.65
    rowFill.BorderSizePixel = 0
    rowFill.Parent = row
    Instance.new("UICorner", rowFill).CornerRadius = UDim.new(0, 6)

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 22, 0, 22)
    avatar.Position = UDim2.new(0, 3, 0.5, -11)
    avatar.BackgroundTransparency = 1
    avatar.Parent = row
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "NameLabel"
    nameLbl.Size = UDim2.new(0.55, -30, 1, 0)
    nameLbl.Position = UDim2.new(0, 30, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 10.5
    nameLbl.TextColor3 = Color3.fromRGB(240, 240, 255)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = row

    local dmgLbl = Instance.new("TextLabel")
    dmgLbl.Name = "DmgLabel"
    dmgLbl.Size = UDim2.new(0.45, -6, 1, 0)
    dmgLbl.Position = UDim2.new(0.55, 0, 0, 0)
    dmgLbl.BackgroundTransparency = 1
    dmgLbl.Font = Enum.Font.GothamBold
    dmgLbl.TextSize = 10.5
    dmgLbl.TextColor3 = Color3.fromRGB(0, 255, 140)
    dmgLbl.TextXAlignment = Enum.TextXAlignment.Right
    dmgLbl.Parent = row

    dpsRowPool[index] = row
    return row
end

function BossDps.Init(parentGui)
    if widget then return end

    widget = Instance.new("Frame")
    widget.Name = "BossDpsWidget"
    widget.Size = UDim2.new(0, 310, 0, 150)
    widget.Position = UDim2.new(1, -330, 0.22, 0)
    widget.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    widget.BackgroundTransparency = 0.08
    widget.BorderSizePixel = 0
    widget.Visible = false
    widget.ZIndex = 1500
    widget.Parent = parentGui or Services.GetGuiParent()
    State.AddInstance(widget)

    local dpsCorner = Instance.new("UICorner")
    dpsCorner.CornerRadius = UDim.new(0, 10)
    dpsCorner.Parent = widget

    local dpsStroke = Instance.new("UIStroke")
    dpsStroke.Color = Theme.PurpleAccent or Color3.fromRGB(168, 85, 247)
    dpsStroke.Thickness = 1.8
    dpsStroke.Parent = widget

    local dpsHeader = Instance.new("Frame")
    dpsHeader.Name = "Header"
    dpsHeader.Size = UDim2.new(1, 0, 0, 34)
    dpsHeader.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    dpsHeader.BorderSizePixel = 0
    dpsHeader.Parent = widget
    Instance.new("UICorner", dpsHeader).CornerRadius = UDim.new(0, 10)

    local dpsHeaderPatch = Instance.new("Frame")
    dpsHeaderPatch.Size = UDim2.new(1, 0, 0, 10)
    dpsHeaderPatch.Position = UDim2.new(0, 0, 1, -10)
    dpsHeaderPatch.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    dpsHeaderPatch.BorderSizePixel = 0
    dpsHeaderPatch.Parent = dpsHeader

    dpsTitle = Instance.new("TextLabel")
    dpsTitle.Name = "Title"
    dpsTitle.Size = UDim2.new(1, -20, 1, 0)
    dpsTitle.Position = UDim2.new(0, 10, 0, 0)
    dpsTitle.BackgroundTransparency = 1
    dpsTitle.Text = "⚔️ SÁT THƯƠNG BOSS"
    dpsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    dpsTitle.Font = Enum.Font.GothamBold
    dpsTitle.TextSize = 13
    dpsTitle.TextXAlignment = Enum.TextXAlignment.Left
    dpsTitle.Parent = dpsHeader

    -- Draggable
    local dpsDragging, dpsDragStart, dpsStartPos
    dpsHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dpsDragging = true
            dpsDragStart = input.Position
            dpsStartPos = widget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dpsDragging = false
                end
            end)
        end
    end)
    dpsHeader.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dpsDragging and dpsDragStart and dpsStartPos then
                local delta = input.Position - dpsDragStart
                widget.Position = UDim2.new(dpsStartPos.X.Scale, dpsStartPos.X.Offset + delta.X, dpsStartPos.Y.Scale, dpsStartPos.Y.Offset + delta.Y)
            end
        end
    end)

    local dpsBossInfo = Instance.new("Frame")
    dpsBossInfo.Name = "BossInfo"
    dpsBossInfo.Size = UDim2.new(1, -20, 0, 26)
    dpsBossInfo.Position = UDim2.new(0, 10, 0, 36)
    dpsBossInfo.BackgroundTransparency = 1
    dpsBossInfo.Parent = widget

    dpsBossHpLabel = Instance.new("TextLabel")
    dpsBossHpLabel.Name = "BossHpLabel"
    dpsBossHpLabel.Size = UDim2.new(1, 0, 0, 16)
    dpsBossHpLabel.BackgroundTransparency = 1
    dpsBossHpLabel.Text = "Đang tìm Boss..."
    dpsBossHpLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
    dpsBossHpLabel.Font = Enum.Font.GothamMedium
    dpsBossHpLabel.TextSize = 11
    dpsBossHpLabel.TextXAlignment = Enum.TextXAlignment.Left
    dpsBossHpLabel.Parent = dpsBossInfo

    local dpsHpBarBg = Instance.new("Frame")
    dpsHpBarBg.Name = "HpBarBg"
    dpsHpBarBg.Size = UDim2.new(1, 0, 0, 5)
    dpsHpBarBg.Position = UDim2.new(0, 0, 0, 18)
    dpsHpBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
    dpsHpBarBg.BorderSizePixel = 0
    dpsHpBarBg.Parent = dpsBossInfo
    Instance.new("UICorner", dpsHpBarBg).CornerRadius = UDim.new(1, 0)

    dpsHpBarFill = Instance.new("Frame")
    dpsHpBarFill.Name = "Fill"
    dpsHpBarFill.Size = UDim2.new(1, 0, 1, 0)
    dpsHpBarFill.BackgroundColor3 = Color3.fromRGB(255, 65, 85)
    dpsHpBarFill.BorderSizePixel = 0
    dpsHpBarFill.Parent = dpsHpBarBg
    Instance.new("UICorner", dpsHpBarFill).CornerRadius = UDim.new(1, 0)

    dpsListContainer = Instance.new("Frame")
    dpsListContainer.Name = "PlayerList"
    dpsListContainer.Size = UDim2.new(1, -20, 0, 80)
    dpsListContainer.Position = UDim2.new(0, 10, 0, 66)
    dpsListContainer.BackgroundTransparency = 1
    dpsListContainer.Parent = widget

    local dpsListLayout = Instance.new("UIListLayout")
    dpsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dpsListLayout.Padding = UDim.new(0, 4)
    dpsListLayout.Parent = dpsListContainer
end

function BossDps.Update(config)
    if not widget then return end
    if not config or not config.ShowBossDpsMeter then
        widget.Visible = false
        return
    end

    local now = tick()
    local fish = nil
    local fishesFolder = Workspace:FindFirstChild("Fishes")

    if fishesFolder then
        local myFishId = LocalPlayer:GetAttribute("FishID")
        if myFishId and myFishId ~= "" then
            local myF = fishesFolder:FindFirstChild(myFishId)
            if myF and myF:GetAttribute("Boss") == true then
                fish = myF
            end
        end

        if not fish then
            local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.zero
            local nearestDist = 999999
            for _, f in ipairs(fishesFolder:GetChildren()) do
                if f:GetAttribute("Boss") == true and typeof(f.Value) == "number" and f.Value > 0 then
                    local fPos = nil
                    if f:FindFirstChild("Buoy") and f.Buoy:IsA("BasePart") then
                        fPos = f.Buoy.Position
                    elseif f:FindFirstChild("Model") and f.Model:IsA("Model") then
                        fPos = f.Model:GetPivot().Position
                    end
                    local dist = fPos and (fPos - myPos).Magnitude or 100
                    if dist < nearestDist and dist <= 250 then
                        nearestDist = dist
                        fish = f
                    end
                end
            end
        end
    end

    if fish and fish.Parent then
        local bName = fish:GetAttribute("FishName") or "Secret Boss"
        local maxHp = tonumber(fish:GetAttribute("MaxHealth")) or 10000
        local curHp = typeof(fish.Value) == "number" and fish.Value or 0
        if maxHp <= 0 then maxHp = math.max(curHp, 1) end

        if tracker.currentFish ~= fish then
            tracker.currentFish = fish
            tracker.bossName = bName
            tracker.maxHp = maxHp
            tracker.curHp = curHp
            tracker.lastHp = curHp
            tracker.totalDamage = 0
            tracker.players = {}
            tracker.victoryUntil = 0
            tracker.active = true
        end

        local deltaHp = tracker.lastHp - curHp
        if deltaHp > 0 and deltaHp < (maxHp * 0.95) then
            tracker.totalDamage = tracker.totalDamage + deltaHp

            local activeParticipants = {}
            local myName = LocalPlayer.Name
            table.insert(activeParticipants, myName)

            local contribFolder = fish:FindFirstChild("PlayerContribution")
            if contribFolder then
                for _, c in ipairs(contribFolder:GetChildren()) do
                    if c.Name ~= myName and not table.find(activeParticipants, c.Name) then
                        table.insert(activeParticipants, c.Name)
                    end
                end
            end

            for _, c in ipairs(fish:GetChildren()) do
                if c.Name:find("_PlayerHealth") then
                    local uid = tonumber(c.Name:match("^(%d+)_PlayerHealth"))
                    if uid then
                        local pl = Players:GetPlayerByUserId(uid)
                        if pl and not table.find(activeParticipants, pl.Name) then
                            table.insert(activeParticipants, pl.Name)
                        end
                    end
                end
            end

            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character then
                    local isPlMinigame = pl.Character:GetAttribute("Minigame") == true or pl.Character:GetAttribute("Fishing") == true
                    if isPlMinigame and not table.find(activeParticipants, pl.Name) then
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and myHrp and (hrp.Position - myHrp.Position).Magnitude <= 120 then
                            table.insert(activeParticipants, pl.Name)
                        end
                    end
                end
            end

            for _, pName in ipairs(activeParticipants) do
                if not tracker.players[pName] then
                    local pl = Players:FindFirstChild(pName)
                    tracker.players[pName] = {
                        name = pName,
                        displayName = pl and pl.DisplayName or pName,
                        userId = pl and pl.UserId or 0,
                        damage = 0,
                        lastHit = now
                    }
                end
            end

            local numParticipants = #activeParticipants
            if numParticipants <= 1 then
                tracker.players[myName].damage = tracker.players[myName].damage + deltaHp
                tracker.players[myName].lastHit = now
            else
                local weights = {}
                local totalWeight = 0
                for _, pName in ipairs(activeParticipants) do
                    local w = 1.0
                    local pl = Players:FindFirstChild(pName)
                    if pl and pl.Character then
                        local stats = pl.Character:FindFirstChild("Stats")
                        local rp = stats and stats:FindFirstChild("RodPower")
                        if rp and tonumber(rp.Value) and tonumber(rp.Value) > 0 then
                            w = math.max(tonumber(rp.Value), 10)
                        end
                    end
                    weights[pName] = w
                    totalWeight = totalWeight + w
                end

                for _, pName in ipairs(activeParticipants) do
                    local share = deltaHp * (weights[pName] / totalWeight)
                    tracker.players[pName].damage = tracker.players[pName].damage + share
                    tracker.players[pName].lastHit = now
                end
            end
        end

        tracker.lastHp = curHp
        tracker.curHp = curHp

        if curHp <= 0 and tracker.victoryUntil == 0 then
            tracker.victoryUntil = now + 6.0
        end

        local hpPercent = math.clamp((curHp / maxHp) * 100, 0, 100)
        dpsTitle.Text = "⚔️ SÁT THƯƠNG BOSS • " .. string.format("%d%% HP", math.floor(hpPercent))
        dpsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
        dpsBossHpLabel.Text = string.format("%s • %s / %s HP", bName, Utils.FormatWithSpaces(math.floor(curHp)), Utils.FormatWithSpaces(maxHp))
        dpsHpBarFill.Size = UDim2.new(math.clamp(curHp / maxHp, 0, 1), 0, 1, 0)

        local sortedList = {}
        for _, pData in pairs(tracker.players) do
            table.insert(sortedList, pData)
        end
        table.sort(sortedList, function(a, b) return a.damage > b.damage end)

        local rowCount = #sortedList
        local visibleRows = math.min(rowCount, 5)
        for i = 1, math.max(#dpsRowPool, visibleRows) do
            if i <= visibleRows then
                local row = GetOrCreateDpsRow(i)
                local pData = sortedList[i]
                local pDmg = math.floor(pData.damage)
                local pPctOfBossHp = math.clamp((pData.damage / maxHp) * 100, 0, 100)
                local isMe = (pData.name == LocalPlayer.Name)

                local fill = row:FindFirstChild("Fill")
                local avatar = row:FindFirstChild("Avatar")
                local nameLbl = row:FindFirstChild("NameLabel")
                local dmgLbl = row:FindFirstChild("DmgLabel")

                if avatar and pData.userId > 0 then
                    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(pData.userId) .. "&w=100&h=100"
                end

                local rankIcons = {"🥇", "🥈", "🥉", "⚔️", "🗡️"}
                local rankIcon = rankIcons[i] or "•"
                local nameText = (isMe and "Bạn (" .. pData.displayName .. ")" or pData.displayName)
                nameLbl.Text = string.format("%s %s", rankIcon, nameText)
                nameLbl.TextColor3 = isMe and Color3.fromRGB(255, 230, 80) or Color3.fromRGB(230, 230, 255)

                dmgLbl.Text = string.format("%.1f%% (%s)", pPctOfBossHp, Utils.FormatWithSpaces(pDmg))
                dmgLbl.TextColor3 = dpsColors[i] or Color3.fromRGB(0, 210, 255)

                local fillPct = (tracker.totalDamage > 0) and math.clamp(pData.damage / tracker.totalDamage, 0, 1) or 0
                if fill then
                    fill.Size = UDim2.new(fillPct, 0, 1, 0)
                    fill.BackgroundColor3 = dpsColors[i] or Color3.fromRGB(60, 60, 90)
                end
            elseif dpsRowPool[i] then
                dpsRowPool[i].Visible = false
            end
        end

        local targetHeight = 70 + (visibleRows * 32)
        widget.Size = UDim2.new(0, 310, 0, targetHeight)
        dpsListContainer.Size = UDim2.new(1, -20, 0, visibleRows * 32)
        widget.Visible = true

    else
        if tracker.victoryUntil > 0 and now < tracker.victoryUntil then
            dpsTitle.Text = "🏆 HẠ GỤC BOSS THÀNH CÔNG!"
            dpsTitle.TextColor3 = Color3.fromRGB(0, 255, 140)
            dpsBossHpLabel.Text = "Bảng Tổng Kết Sát Thương Của Từng Người Chơi:"
            dpsHpBarFill.Size = UDim2.new(0, 0, 1, 0)
            widget.Visible = true
        else
            tracker.active = false
            tracker.currentFish = nil
            tracker.victoryUntil = 0
            widget.Visible = false
        end
    end
end

return BossDps
