-- ====================================================================
-- QUEST & NPC DIALOGUE DEBUG SPY / LOGGER FOR HEAVYWEIGHT FISHING
-- Chạy script này, sau đó đi tới NPC Ticket Quest Giver và thao tác nhận / trả vé.
-- Script sẽ ghi lại toàn bộ Remotes, GUI Dialogue, Nút bấm và Data Server!
-- Bấm nút [📋 COPY LOG] trên màn hình để dán kết quả vào chat.
-- ====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

local logHistory = {}
local maxLogLines = 200

local function getTimestamp()
    local d = os.date("*t")
    return string.format("[%02d:%02d:%02d]", d.hour, d.min, d.sec)
end

-- GUI Logger trên màn hình
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuestDebugSpyGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    else
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 480, 0, 320)
mainFrame.Position = UDim2.new(1, -500, 0, 80)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(147, 51, 234)
mainStroke.Thickness = 1.5

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(24, 18, 36)
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -160, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Font = Enum.Font.GothamBold
titleLbl.Text = "🕵️ QUEST & NPC DIALOGUE SPY"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize = 12
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = header

local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(0, 85, 0, 22)
btnCopy.Position = UDim2.new(1, -145, 0.5, -11)
btnCopy.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
btnCopy.Font = Enum.Font.GothamBold
btnCopy.Text = "📋 COPY LOG"
btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCopy.TextSize = 10
btnCopy.BorderSizePixel = 0
btnCopy.Parent = header
Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 4)

local btnClear = Instance.new("TextButton")
btnClear.Size = UDim2.new(0, 50, 0, 22)
btnClear.Position = UDim2.new(1, -55, 0.5, -11)
btnClear.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
btnClear.Font = Enum.Font.GothamBold
btnClear.Text = "XÓA"
btnClear.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClear.TextSize = 10
btnClear.BorderSizePixel = 0
btnClear.Parent = header
Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 4)

-- Scrolling Log List
local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, -16, 1, -44)
scrollList.Position = UDim2.new(0, 8, 0, 38)
scrollList.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
scrollList.BorderSizePixel = 0
scrollList.ScrollBarThickness = 4
scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollList.Parent = mainFrame
Instance.new("UICorner", scrollList).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = scrollList

local function serializeVal(v)
    if type(v) == "table" then
        local parts = {}
        for k, val in pairs(v) do
            table.insert(parts, string.format("%s = %s", tostring(k), serializeVal(val)))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif typeof(v) == "Instance" then
        return string.format("<%s: %s>", v.ClassName, v:GetFullName())
    elseif type(v) == "string" then
        return string.format("%q", v)
    else
        return tostring(v)
    end
end

local logCounter = 0
local function AddLog(tag, msg, color)
    local timeStr = getTimestamp()
    local fullText = string.format("%s [%s] %s", timeStr, tag, msg)
    table.insert(logHistory, fullText)
    if #logHistory > maxLogLines then table.remove(logHistory, 1) end

    print(fullText)

    logCounter = logCounter + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = fullText
    lbl.TextColor3 = color or Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.LayoutOrder = logCounter
    lbl.Parent = scrollList

    task.defer(function()
        scrollList.CanvasPosition = Vector2.new(0, scrollList.AbsoluteCanvasSize.Y)
    end)
end

btnCopy.MouseButton1Click:Connect(function()
    local fullLog = table.concat(logHistory, "\n")
    local copied = false
    if setclipboard then
        setclipboard(fullLog)
        copied = true
    elseif toclipboard then
        toclipboard(fullLog)
        copied = true
    end

    if copied then
        btnCopy.Text = "✔ ĐÃ COPY!"
        btnCopy.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        task.delay(1.5, function()
            btnCopy.Text = "📋 COPY LOG"
            btnCopy.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        end)
    else
        AddLog("COPY", "Không hỗ trợ setclipboard! Hãy mở F9 Console để copy.", Color3.fromRGB(239, 68, 68))
    end
end)

btnClear.MouseButton1Click:Connect(function()
    logHistory = {}
    for _, ch in ipairs(scrollList:GetChildren()) do
        if ch:IsA("TextLabel") then ch:Destroy() end
    end
    AddLog("SYSTEM", "Đã xóa sạch bộ nhớ Log.", Color3.fromRGB(150, 150, 150))
end)

AddLog("START", "=== BẮT ĐẦU THEO DÕI QUEST & NPC DIALOGUE ===", Color3.fromRGB(168, 85, 247))
AddLog("GUIDE", "Hãy đi tới NPC Ticket Quest Giver, bấm E và thao tác nhận/trả vé.", Color3.fromRGB(255, 215, 0))

-- 1. BẮT SỰ KIỆN PROXIMITY PROMPT
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if player == LocalPlayer then
        local pName = prompt.Name
        local actionText = prompt.ActionText or ""
        local objText = prompt.ObjectText or ""
        local parentName = prompt.Parent and prompt.Parent:GetFullName() or "Unknown"
        AddLog("PROMPT_TRIGGERED", string.format("Prompt: %s | Action: %s | Object: %s | Parent: %s", pName, actionText, objText, parentName), Color3.fromRGB(56, 189, 248))
    end
end)

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
    if player == LocalPlayer then
        AddLog("PROMPT_HOLD", string.format("Bắt đầu giữ Prompt: %s (%s)", prompt.Name, prompt.ActionText or ""), Color3.fromRGB(148, 163, 184))
    end
end)

-- 2. HOOK METAMETHOD __namecall (BẮT TẤT CẢ REMOTE FIRED)
local hooked = false
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if method == "FireServer" or method == "InvokeServer" then
                local sName = tostring(self.Name)
                local sFull = tostring(self:GetFullName())

                -- Lọc các remote liên quan đến Quest, Dialogue, Ticket, NPC
                local lower = sName:lower()
                local isTarget = lower:find("quest") or lower:find("dialogue") or lower:find("ticket") 
                    or lower:find("claim") or lower:find("prompt") or lower:find("interact")
                    or lower:find("start") or lower:find("choose") or lower:find("trigger")

                if isTarget then
                    local argStrings = {}
                    for i, a in ipairs(args) do
                        table.insert(argStrings, string.format("arg[%d]=%s", i, serializeVal(a)))
                    end
                    local paramStr = table.concat(argStrings, ", ")
                    AddLog("REMOTE_CALL", string.format("[%s] %s:%s(%s)", method, sFull, sName, paramStr), Color3.fromRGB(251, 146, 60))
                end
            end

            return oldNamecall(self, ...)
        end)
        hooked = true
        AddLog("HOOK", "Đã hook thành công __namecall để theo dõi mọi RemoteEvent!", Color3.fromRGB(34, 197, 94))
    end
end)

if not hooked then
    AddLog("HOOK_WARN", "Executor không hỗ trợ hookmetamethod! Đang dùng chế độ giám sát GUI & Remote Event thay thế.", Color3.fromRGB(245, 158, 11))
end

-- 3. LẮNG NGHE CÁC REMOTE NHẬN TỪ SERVER (OnClientEvent)
local targetRemoteNames = {
    "StartDialogue", "ChooseDialogueOption", "Dialogue", "ClaimQuest", 
    "Notification", "ChatAnnounce", "RewardNotification", "ProximityPromptToClient"
}

local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if eventsFolder then
    for _, rName in ipairs(targetRemoteNames) do
        local r = eventsFolder:FindFirstChild(rName)
        if r and r:IsA("RemoteEvent") then
            r.OnClientEvent:Connect(function(...)
                local args = {...}
                local argStrings = {}
                for i, a in ipairs(args) do
                    table.insert(argStrings, string.format("arg[%d]=%s", i, serializeVal(a)))
                end
                AddLog("SERVER_EVENT", string.format("Nhận sự kiện từ Server: Events.%s(%s)", rName, table.concat(argStrings, ", ")), Color3.fromRGB(236, 72, 153))
            end)
        end
    end
end

-- 4. THEO DÕI GIAO DIỆN HỘI THOẠI (PlayerGui.MainGui.Menu.Dialogue)
task.spawn(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
    local mainGui = pg and pg:WaitForChild("MainGui", 10)
    local menu = mainGui and mainGui:WaitForChild("Menu", 10)
    local dialogueFrame = menu and menu:WaitForChild("Dialogue", 10)

    if not dialogueFrame then
        AddLog("UI_WARN", "Không tìm thấy PlayerGui.MainGui.Menu.Dialogue!", Color3.fromRGB(239, 68, 68))
        return
    end

    AddLog("UI_FOUND", "Đã kết nối giám sát giao diện Dialogue!", Color3.fromRGB(34, 197, 94))

    local lastVisible = dialogueFrame.Visible
    local lastDialogText = ""
    local lastTitleText = ""

    local function checkDialogueState()
        local curVis = dialogueFrame.Visible
        if curVis ~= lastVisible then
            lastVisible = curVis
            AddLog("DIALOGUE_VIS", string.format("Bảng hội thoại Dialogue.Visible = %s", tostring(curVis)), curVis and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(239, 68, 68))
        end

        if curVis then
            local titleObj = dialogueFrame:FindFirstChild("Title")
            local curTitle = titleObj and titleObj:IsA("TextLabel") and titleObj.Text or ""
            if curTitle ~= lastTitleText and #curTitle > 0 then
                lastTitleText = curTitle
                AddLog("DIALOGUE_NPC", string.format("NPC Tên: %s", curTitle), Color3.fromRGB(250, 204, 21))
            end

            local dialogObj = dialogueFrame:FindFirstChild("Dialog")
            local curDialog = dialogObj and dialogObj:IsA("TextLabel") and dialogObj.Text or ""
            if curDialog ~= lastDialogText and #curDialog > 0 then
                lastDialogText = curDialog
                AddLog("DIALOGUE_TEXT", string.format("Lời thoại NPC: %q", curDialog), Color3.fromRGB(253, 230, 138))
            end

            -- Quét ButtonFrame để kiểm tra các lựa chọn
            local btnFrame = dialogueFrame:FindFirstChild("ButtonFrame")
            if btnFrame then
                for _, ch in ipairs(btnFrame:GetChildren()) do
                    if ch:IsA("TextButton") and ch.Name ~= "Template" and ch.Visible then
                        local bTitle = ch:FindFirstChild("Title")
                        local tText = bTitle and bTitle:IsA("TextLabel") and bTitle.Text or ch.Text or ""

                        if not ch:GetAttribute("SpyHooked") then
                            ch:SetAttribute("SpyHooked", true)
                            AddLog("OPTION_BUTTON", string.format("Xuất hiện nút lựa chọn: [%s] với text: %q", ch.Name, tText), Color3.fromRGB(96, 165, 250))

                            ch.MouseButton1Click:Connect(function()
                                AddLog("USER_CLICK", string.format("👉 BẠN ĐÃ BẤM NÚT LỰA CHỌN: [%s] (Text: %q)", ch.Name, tText), Color3.fromRGB(244, 63, 94))
                            end)
                        end
                    end
                end
            end
        else
            lastDialogText = ""
            lastTitleText = ""
        end
    end

    while true do
        pcall(checkDialogueState)
        task.wait(0.2)
    end
end)

-- 5. THEO DÕI BIẾN ĐỘNG DỮ LIỆU QUEST CỦA PLAYER TRÊN SERVER
task.spawn(function()
    local pData = ReplicatedStorage:WaitForChild("Data", 10)
    local userFolder = pData and pData:WaitForChild(tostring(LocalPlayer.UserId), 10)
    if not userFolder then return end

    local questFolder = userFolder:WaitForChild("Quest", 10)
    if questFolder then
        AddLog("DATA", "Đã kết nối giám sát Data.Quest người chơi!", Color3.fromRGB(34, 197, 94))

        local function hookDesc(d)
            if d:IsA("ValueBase") then
                d.Changed:Connect(function(newVal)
                    AddLog("DATA_VALUE_CHANGE", string.format("Data thay đổi: %s = %s", d:GetFullName(), tostring(newVal)), Color3.fromRGB(244, 114, 182))
                end)
            end
        end

        for _, d in ipairs(questFolder:GetDescendants()) do
            hookDesc(d)
        end

        questFolder.DescendantAdded:Connect(function(d)
            hookDesc(d)
            local valStr = d:IsA("ValueBase") and (" = " .. tostring(d.Value)) or ""
            AddLog("DATA_QUEST_ADDED", string.format("Thêm dữ liệu Quest: %s (%s)%s", d.Name, d.ClassName, valStr), Color3.fromRGB(167, 139, 250))
        end)

        questFolder.DescendantRemoving:Connect(function(d)
            AddLog("DATA_QUEST_REMOVED", string.format("Xóa dữ liệu Quest: %s (%s)", d.Name, d.ClassName), Color3.fromRGB(251, 113, 133))
        end)
    end

    local cdVal = userFolder:FindFirstChild("TicketQuestCooldown")
    if cdVal and cdVal:IsA("ValueBase") then
        cdVal.Changed:Connect(function(newVal)
            AddLog("DATA_COOLDOWN_CHANGE", string.format("TicketQuestCooldown thay đổi = %s", tostring(newVal)), Color3.fromRGB(251, 191, 36))
        end)
    end
end)

AddLog("READY", "Hệ thống Spy sẵn sàng! Mời bạn tương tác với NPC Ticket Quest ngay bây giờ.", Color3.fromRGB(34, 197, 94))
