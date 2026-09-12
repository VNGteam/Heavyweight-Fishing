--[[
    ============================================================================
    🚀 ADVANCED CLIENT DATA & QUEST INSPECTOR v2 (DEBUG / INSPECTION TOOL)
    Environment: Roblox Client (LocalScript / Executor Compatible)
    
    TÍNH NĂNG V2 MỞ RỘNG:
    1. Multi-Root Scanner: Quét LocalPlayer, Character, ReplicatedStorage, 
       ReplicatedFirst, Workspace (lọc thông minh tránh lag).
    2. RemoteEvent Spy (Listen-Only): Lắng nghe OnClientEvent của server gửi về,
       ghi nhận Payload/Arguments (Quest update, data sync) mà KHÔNG FireServer.
    3. Safe Module Inspector: Hỗ trợ inspect table data của ModuleScripts (Config, Quests).
    4. Explorer Tree View: Hiển thị phân cấp cây thư mục trực quan.
    5. Snapshot Diff Engine v2: So sánh chính xác ADDED, REMOVED, CHANGED.
    6. Smart Quest Filter: 1 click lọc ra toàn bộ Quest/Mission/Task/Objective/Bounty.
    7. Clean Tabbed Debug UI: Tree View, Flat View, Remote Spy, Diff Log.
    ============================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ============================================================================
-- 1. UTILS & SERIALIZER
-- ============================================================================
local Utils = {}

function Utils.safeGet(obj, prop)
    local ok, res = pcall(function() return obj[prop] end)
    return ok and res or nil
end

function Utils.tableToString(tbl, maxDepth, curDepth)
    maxDepth = maxDepth or 3
    curDepth = curDepth or 1
    if curDepth > maxDepth then return "{...}" end

    local parts = {}
    local count = 0
    for k, v in pairs(tbl) do
        count = count + 1
        if count > 25 then
            table.insert(parts, "... (truncated)")
            break
        end
        local keyStr = tostring(k)
        local valStr = ""
        if type(v) == "table" then
            valStr = Utils.tableToString(v, maxDepth, curDepth + 1)
        elseif typeof(v) == "Instance" then
            valStr = "<" .. v:GetFullName() .. ">"
        else
            valStr = Utils.valueToString(v)
        end
        table.insert(parts, string.format("%s: %s", keyStr, valStr))
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

function Utils.valueToString(val)
    if val == nil then
        return "nil"
    elseif typeof(val) == "Instance" then
        return val:GetFullName()
    elseif typeof(val) == "Vector3" then
        return string.format("Vector3(%.1f, %.1f, %.1f)", val.X, val.Y, val.Z)
    elseif typeof(val) == "CFrame" then
        return string.format("CFrame(%.1f, %.1f, %.1f)", val.X, val.Y, val.Z)
    elseif typeof(val) == "Color3" then
        return string.format("Color3(%.2f, %.2f, %.2f)", val.R, val.G, val.B)
    elseif type(val) == "table" then
        return Utils.tableToString(val, 2)
    else
        return tostring(val)
    end
end

-- ============================================================================
-- 2. CORE INSPECTOR ENGINE v2
-- ============================================================================
local Inspector = {
    CurrentRoot = "ALL", -- "PLAYER", "REPLICATED_STORAGE", "REPLICATED_FIRST", "WORKSPACE", "ALL"
    LastScanResults = {},
    LastSummary = {},
    Snapshots = {},
    WatchConnections = {},
    RemoteSpyConnections = {},
    IsWatching = false,
    IsRemoteSpying = false,
    RemoteLogs = {},
    LogCallback = nil,
    RemoteLogCallback = nil,
}

function Inspector:Classify(obj)
    local fullName = obj:GetFullName()
    if obj == LocalPlayer or (LocalPlayer and obj:IsDescendantOf(LocalPlayer)) then
        if fullName:find("%.Backpack") then return "BACKPACK" end
        if fullName:find("%.PlayerGui") then return "PLAYERGUI" end
        if fullName:find("%.PlayerScripts") then return "PLAYERSCRIPTS" end
        return "PLAYER"
    elseif LocalPlayer.Character and (obj == LocalPlayer.Character or obj:IsDescendantOf(LocalPlayer.Character)) then
        return "CHARACTER"
    elseif obj == ReplicatedStorage or obj:IsDescendantOf(ReplicatedStorage) then
        return "REPLICATED_STORAGE"
    elseif obj == ReplicatedFirst or obj:IsDescendantOf(ReplicatedFirst) then
        return "REPLICATED_FIRST"
    elseif obj == Workspace or obj:IsDescendantOf(Workspace) then
        return "WORKSPACE"
    elseif obj:IsA("ValueBase") then
        return "VALUES"
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        return "REMOTES"
    elseif obj:IsA("ModuleScript") then
        return "MODULES"
    else
        return "OTHER"
    end
end

function Inspector:ExtractObjectData(obj, rootContext)
    local path = obj:GetFullName()
    local record = {
        Instance = obj,
        Name = obj.Name,
        ClassName = obj.ClassName,
        Parent = obj.Parent and obj.Parent.Name or "nil",
        Path = path,
        Category = self:Classify(obj),
        Attributes = {},
        Tags = {},
        Extra = {},
    }

    -- 1. Attributes
    local attrs = obj:GetAttributes()
    if attrs and next(attrs) ~= nil then
        for aName, aVal in pairs(attrs) do
            record.Attributes[aName] = {
                Value = aVal,
                Type = typeof(aVal),
                Display = Utils.valueToString(aVal),
            }
        end
    end

    -- 2. Tags
    local tags = CollectionService:GetTags(obj)
    if tags and #tags > 0 then
        record.Tags = tags
    end

    -- 3. ValueBase objects
    if obj:IsA("ValueBase") then
        if obj:IsA("ObjectValue") then
            local ref = obj.Value
            record.Value = ref and ref:GetFullName() or "None (nil)"
            record.RawValue = ref
        else
            local val = Utils.safeGet(obj, "Value")
            record.Value = Utils.valueToString(val)
            record.RawValue = val
        end
    end

    -- 4. GuiObject
    if obj:IsA("GuiObject") then
        record.Extra.Visible = tostring(obj.Visible)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            record.Extra.Text = obj.Text
        end
    end

    -- 5. ModuleScript Inspection (Safe pcall require)
    if obj:IsA("ModuleScript") then
        local lowerName = string.lower(obj.Name)
        if lowerName:find("quest") or lowerName:find("mission") or lowerName:find("data") or lowerName:find("config") then
            local ok, ret = pcall(function() return require(obj) end)
            if ok and type(ret) == "table" then
                record.Extra.ModuleData = Utils.tableToString(ret, 2)
            end
        end
    end

    return record
end

-- Quét linh hoạt theo root chỉ định
function Inspector:Scan(targetRoot)
    targetRoot = targetRoot or self.CurrentRoot or "ALL"
    local results = {}
    local summary = {
        TotalObjects = 0,
        Folders = 0,
        ValueObjects = 0,
        GuiObjects = 0,
        RemoteEvents = 0,
        RemoteFunctions = 0,
        ModuleScripts = 0,
        Attributes = 0,
        Categories = {},
    }

    local function process(obj, depth, maxDepth)
        if not obj then return end
        if depth and maxDepth and depth > maxDepth then return end

        local record = self:ExtractObjectData(obj)
        table.insert(results, record)

        summary.TotalObjects = summary.TotalObjects + 1
        summary.Categories[record.Category] = (summary.Categories[record.Category] or 0) + 1

        if obj:IsA("Folder") then summary.Folders = summary.Folders + 1 end
        if obj:IsA("ValueBase") then summary.ValueObjects = summary.ValueObjects + 1 end
        if obj:IsA("GuiObject") then summary.GuiObjects = summary.GuiObjects + 1 end
        if obj:IsA("RemoteEvent") then summary.RemoteEvents = summary.RemoteEvents + 1 end
        if obj:IsA("RemoteFunction") then summary.RemoteFunctions = summary.RemoteFunctions + 1 end
        if obj:IsA("ModuleScript") then summary.ModuleScripts = summary.ModuleScripts + 1 end
        for _ in pairs(record.Attributes) do
            summary.Attributes = summary.Attributes + 1
        end

        for _, child in ipairs(obj:GetChildren()) do
            process(child, (depth or 0) + 1, maxDepth)
        end
    end

    -- Thực hiện quét theo root
    if targetRoot == "ALL" or targetRoot == "PLAYER" then
        process(LocalPlayer, 0, 15)
        if LocalPlayer.Character then
            process(LocalPlayer.Character, 0, 8)
        end
    end

    if targetRoot == "ALL" or targetRoot == "REPLICATED_STORAGE" then
        process(ReplicatedStorage, 0, 12)
    end

    if targetRoot == "ALL" or targetRoot == "REPLICATED_FIRST" then
        process(ReplicatedFirst, 0, 8)
    end

    -- Workspace: Lọc tránh quét hàng chục nghìn Part gây lag
    if targetRoot == "WORKSPACE" then
        for _, child in ipairs(Workspace:GetChildren()) do
            if child ~= LocalPlayer.Character and not child:IsA("Terrain") then
                -- Ưu tiên Folders, Models, NPCs, Spawners
                if child:IsA("Folder") or child:IsA("Model") or child:IsA("Configuration") or child:IsA("ValueBase") then
                    process(child, 0, 6)
                end
            end
        end
    end

    self.LastScanResults = results
    self.LastSummary = summary
    return results, summary
end

-- ============================================================================
-- 3. EXPLORER TREE VIEW GENERATOR
-- ============================================================================
function Inspector:BuildTreeView(filterKeyword)
    local query = filterKeyword and string.lower(filterKeyword) or ""
    local treeRoot = { Children = {}, Name = "Explorer", Class = "Root" }

    local function insertPath(pathSegments, item)
        local cur = treeRoot
        for i, seg in ipairs(pathSegments) do
            if not cur.Children[seg] then
                cur.Children[seg] = {
                    Name = seg,
                    Children = {},
                    Item = (i == #pathSegments) and item or nil,
                }
            elseif i == #pathSegments then
                cur.Children[seg].Item = item
            end
            cur = cur.Children[seg]
        end
    end

    -- Lọc dữ liệu phù hợp
    for _, item in ipairs(self.LastScanResults) do
        local match = true
        if query ~= "" then
            match = self:CheckMatch(item, query)
        end
        if match then
            local segments = string.split(item.Path, ".")
            insertPath(segments, item)
        end
    end

    -- Render cây ASCII
    local lines = {}
    local function renderNode(node, prefix, isLast)
        local sortedKeys = {}
        for k in pairs(node.Children) do table.insert(sortedKeys, k) end
        table.sort(sortedKeys)

        for i, k in ipairs(sortedKeys) do
            local child = node.Children[k]
            local last = (i == #sortedKeys)
            local branch = last and "└── " or "├── "
            local icon = "📁 "

            local item = child.Item
            local extraInfo = ""
            if item then
                if item.ClassName == "RemoteEvent" then icon = "⚡ "
                elseif item.ClassName == "RemoteFunction" then icon = "📡 "
                elseif item.ClassName == "ModuleScript" then icon = "📜 "
                elseif item.Instance:IsA("ValueBase") then
                    icon = "🏷️ "
                    extraInfo = string.format(" = %s [%s]", tostring(item.Value), item.ClassName)
                elseif item.Instance:IsA("GuiObject") then
                    icon = "🖥️ "
                    if item.Extra.Text then extraInfo = string.format(" (Text: \"%s\")", item.Extra.Text) end
                elseif item.ClassName == "Folder" then icon = "📁 "
                elseif item.ClassName == "Model" then icon = "📦 "
                else icon = "🔹 " end

                if next(item.Attributes) ~= nil then
                    local attrList = {}
                    for aName, aData in pairs(item.Attributes) do
                        table.insert(attrList, aName .. "=" .. tostring(aData.Display))
                    end
                    extraInfo = extraInfo .. " {Attrs: " .. table.concat(attrList, ", ") .. "}"
                end
            end

            table.insert(lines, prefix .. branch .. icon .. child.Name .. extraInfo)
            local nextPrefix = prefix .. (last and "    " or "│   ")
            renderNode(child, nextPrefix, last)
        end
    end

    renderNode(treeRoot, "", true)
    return table.concat(lines, "\n")
end

-- ============================================================================
-- 4. SEARCH & FILTER (QUEST FOCUS)
-- ============================================================================
function Inspector:CheckMatch(item, query)
    if string.find(string.lower(item.Name), query, 1, true) then return true end
    if string.find(string.lower(item.Path), query, 1, true) then return true end
    if string.find(string.lower(item.ClassName), query, 1, true) then return true end
    if item.Value and string.find(string.lower(tostring(item.Value)), query, 1, true) then return true end
    if item.Extra and item.Extra.Text and string.find(string.lower(item.Extra.Text), query, 1, true) then return true end

    for aName, aData in pairs(item.Attributes) do
        if string.find(string.lower(aName), query, 1, true) or
           string.find(string.lower(tostring(aData.Display)), query, 1, true) then
            return true
        end
    end
    for _, tag in ipairs(item.Tags) do
        if string.find(string.lower(tag), query, 1, true) then return true end
    end
    return false
end

function Inspector:Find(query, category)
    local matched = {}
    local q = query and string.lower(query) or ""
    for _, item in ipairs(self.LastScanResults) do
        if category and category ~= "ALL" and item.Category ~= category then
            continue
        end
        if q == "" or self:CheckMatch(item, q) then
            table.insert(matched, item)
        end
    end
    return matched
end

-- Lọc siêu tốc các từ khóa liên quan đến Quest
function Inspector:FindQuests()
    local questKeywords = { "quest", "mission", "task", "objective", "bounty", "target", "progress", "ticket" }
    local matched = {}
    local seen = {}

    for _, kw in ipairs(questKeywords) do
        local sub = self:Find(kw)
        for _, item in ipairs(sub) do
            if not seen[item.Path] then
                seen[item.Path] = true
                table.insert(matched, item)
            end
        end
    end
    return matched
end

-- ============================================================================
-- 5. REMOTE EVENT SPY (LISTEN-ONLY, PAYLOAD CAPTURE)
-- ============================================================================
function Inspector:StartRemoteSpy()
    if self.IsRemoteSpying then return end
    self.IsRemoteSpying = true

    local function hookRemote(remote)
        if not remote:IsA("RemoteEvent") then return end
        local conn = remote.OnClientEvent:Connect(function(...)
            local args = { ... }
            local timeStr = os.date("%X")
            local logEntry = {
                Time = timeStr,
                RemoteName = remote.Name,
                Path = remote:GetFullName(),
                Args = args,
                ArgsDisplay = Utils.tableToString(args, 3),
            }
            table.insert(self.RemoteLogs, 1, logEntry)
            if #self.RemoteLogs > 100 then table.remove(self.RemoteLogs) end

            local formatted = string.format("[%s] ⚡ %s\n   Payload: %s", timeStr, remote:GetFullName(), logEntry.ArgsDisplay)
            print(formatted)
            if self.RemoteLogCallback then
                self.RemoteLogCallback(formatted)
            end
        end)
        table.insert(self.RemoteSpyConnections, conn)
    end

    -- Hook toàn bộ RemoteEvents trong ReplicatedStorage và Players
    for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
        if item:IsA("RemoteEvent") then hookRemote(item) end
    end
    for _, item in ipairs(LocalPlayer:GetDescendants()) do
        if item:IsA("RemoteEvent") then hookRemote(item) end
    end

    local repAdded = ReplicatedStorage.DescendantAdded:Connect(function(desc)
        if desc:IsA("RemoteEvent") then hookRemote(desc) end
    end)
    table.insert(self.RemoteSpyConnections, repAdded)

    print("[Inspector] RemoteEvent Spy ACTIVATED (Capturing server payloads).")
end

function Inspector:StopRemoteSpy()
    if not self.IsRemoteSpying then return end
    for _, conn in ipairs(self.RemoteSpyConnections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    self.RemoteSpyConnections = {}
    self.IsRemoteSpying = false
    print("[Inspector] RemoteEvent Spy DEACTIVATED.")
end

-- ============================================================================
-- 6. SNAPSHOT & DIFF ENGINE v2
-- ============================================================================
function Inspector:Snapshot(name)
    local results = self:Scan(self.CurrentRoot)
    local snap = {}
    for _, item in ipairs(results) do
        local attrFlat = {}
        for aName, aData in pairs(item.Attributes) do attrFlat[aName] = aData.Display end
        snap[item.Path] = {
            Name = item.Name,
            ClassName = item.ClassName,
            Value = item.Value,
            Attributes = attrFlat,
            Text = item.Extra and item.Extra.Text,
        }
    end
    self.Snapshots[name] = snap
    return snap
end

function Inspector:Compare(nameBefore, nameAfter)
    local before = self.Snapshots[nameBefore]
    local after = self.Snapshots[nameAfter]
    if not before or not after then return nil, "Snapshots not found!" end

    local diff = { Added = {}, Removed = {}, Changed = {} }

    -- So sánh Changed & Removed
    for path, oldData in pairs(before) do
        local newData = after[path]
        if not newData then
            table.insert(diff.Removed, { Path = path, ClassName = oldData.ClassName, Value = oldData.Value })
        else
            local valDiff = (oldData.Value ~= newData.Value)
            local textDiff = (oldData.Text ~= newData.Text)
            local attrDiffs = {}

            for aName, aVal in pairs(oldData.Attributes) do
                if newData.Attributes[aName] == nil then
                    table.insert(attrDiffs, string.format("Attr '%s' [REMOVED]", aName))
                elseif newData.Attributes[aName] ~= aVal then
                    table.insert(attrDiffs, string.format("Attr '%s': %s -> %s", aName, tostring(aVal), tostring(newData.Attributes[aName])))
                end
            end
            for aName, aVal in pairs(newData.Attributes) do
                if oldData.Attributes[aName] == nil then
                    table.insert(attrDiffs, string.format("Attr '%s' [ADDED]: %s", aName, tostring(aVal)))
                end
            end

            if valDiff or textDiff or #attrDiffs > 0 then
                table.insert(diff.Changed, {
                    Path = path,
                    OldValue = oldData.Value,
                    NewValue = newData.Value,
                    OldText = oldData.Text,
                    NewText = newData.Text,
                    AttrDiffs = attrDiffs,
                })
            end
        end
    end

    -- So sánh Added
    for path, newData in pairs(after) do
        if not before[path] then
            table.insert(diff.Added, { Path = path, ClassName = newData.ClassName, Value = newData.Value })
        end
    end

    local lines = {}
    table.insert(lines, string.format("===== SNAPSHOT DIFF: '%s' vs '%s' =====", nameBefore, nameAfter))
    table.insert(lines, "\n[CHANGED]:")
    if #diff.Changed == 0 then table.insert(lines, "  (None)")
    else
        for _, ch in ipairs(diff.Changed) do
            table.insert(lines, "  " .. ch.Path)
            if ch.OldValue ~= ch.NewValue then
                table.insert(lines, string.format("    Value: %s -> %s", tostring(ch.OldValue), tostring(ch.NewValue)))
            end
            if ch.OldText ~= ch.NewText then
                table.insert(lines, string.format("    Text: \"%s\" -> \"%s\"", tostring(ch.OldText), tostring(ch.NewText)))
            end
            for _, ad in ipairs(ch.AttrDiffs) do
                table.insert(lines, "    " .. ad)
            end
        end
    end

    table.insert(lines, "\n[ADDED]:")
    if #diff.Added == 0 then table.insert(lines, "  (None)")
    else
        for _, ad in ipairs(diff.Added) do
            local extra = ad.Value and (" | Value: " .. tostring(ad.Value)) or ""
            table.insert(lines, string.format("  + %s [%s]%s", ad.Path, ad.ClassName, extra))
        end
    end

    table.insert(lines, "\n[REMOVED]:")
    if #diff.Removed == 0 then table.insert(lines, "  (None)")
    else
        for _, rm in ipairs(diff.Removed) do
            table.insert(lines, string.format("  - %s [%s]", rm.Path, rm.ClassName))
        end
    end

    return diff, table.concat(lines, "\n")
end

-- ============================================================================
-- 7. INTERACTIVE DEBUG UI v2 (Clean Modern Theme)
-- ============================================================================
local function CreateInspectorUI()
    local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("PlayerInspectorGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PlayerInspectorGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 780, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(45, 50, 65)
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "CLIENT DATA & QUEST INSPECTOR v2"
    Title.TextColor3 = Color3.fromRGB(235, 240, 255)
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 13
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Root Selector Tabs (Bar 1)
    local RootBar = Instance.new("Frame")
    RootBar.Name = "RootBar"
    RootBar.Size = UDim2.new(1, -20, 0, 30)
    RootBar.Position = UDim2.new(0, 10, 0, 48)
    RootBar.BackgroundTransparency = 1
    RootBar.Parent = MainFrame

    local RootLayout = Instance.new("UIListLayout")
    RootLayout.FillDirection = Enum.FillDirection.Horizontal
    RootLayout.Padding = UDim.new(0, 6)
    RootLayout.Parent = RootBar

    local function createTabBtn(text, parent)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 115, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
        btn.Font = Enum.Font.GothamSemibold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 205, 220)
        btn.TextSize = 11
        btn.Parent = parent
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 5)
        cr.Parent = btn
        return btn
    end

    local BtnRootAll = createTabBtn("Root: ALL", RootBar)
    local BtnRootRep = createTabBtn("ReplicatedStorage", RootBar)
    local BtnRootPlayer = createTabBtn("LocalPlayer", RootBar)
    local BtnRootWorkspace = createTabBtn("Workspace", RootBar)

    -- Control Actions (Bar 2)
    local ControlBar = Instance.new("Frame")
    ControlBar.Name = "ControlBar"
    ControlBar.Size = UDim2.new(1, -20, 0, 32)
    ControlBar.Position = UDim2.new(0, 10, 0, 84)
    ControlBar.BackgroundTransparency = 1
    ControlBar.Parent = MainFrame

    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.Padding = UDim.new(0, 6)
    ControlLayout.Parent = ControlBar

    local function createActionBtn(text, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 1, 0)
        btn.BackgroundColor3 = color or Color3.fromRGB(45, 50, 70)
        btn.Font = Enum.Font.GothamSemibold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(240, 245, 255)
        btn.TextSize = 11
        btn.Parent = ControlBar
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 5)
        cr.Parent = btn
        return btn
    end

    local BtnScan = createActionBtn("Scan", Color3.fromRGB(37, 99, 235))
    local BtnQuestFocus = createActionBtn("⭐ Quest Focus", Color3.fromRGB(234, 88, 12))
    local BtnTree = createActionBtn("Tree View", Color3.fromRGB(16, 149, 114))
    local BtnRemoteSpy = createActionBtn("Remote Spy: OFF", Color3.fromRGB(75, 85, 99))
    local BtnSnapA = createActionBtn("Snap [A]", Color3.fromRGB(59, 130, 246))
    local BtnSnapB = createActionBtn("Snap [B]", Color3.fromRGB(37, 99, 235))
    local BtnCompare = createActionBtn("Diff", Color3.fromRGB(147, 51, 234))
    local BtnCopy = createActionBtn("Copy", Color3.fromRGB(31, 41, 55))

    -- Search Bar
    local SearchBarFrame = Instance.new("Frame")
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.Size = UDim2.new(1, -20, 0, 32)
    SearchBarFrame.Position = UDim2.new(0, 10, 0, 122)
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
    SearchBarFrame.BorderSizePixel = 0
    SearchBarFrame.Parent = MainFrame

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBarFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -16, 1, 0)
    SearchBox.Position = UDim2.new(0, 10, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.PlaceholderText = "Search Name, Path, Class, Value, Attribute, Tag (e.g., 'quest', 'mission', 'progress')..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 115, 130)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(240, 245, 255)
    SearchBox.TextSize = 11
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = SearchBarFrame

    -- ScrollingFrame Display
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -168)
    Scroll.Position = UDim2.new(0, 10, 0, 160)
    Scroll.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 85)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Scroll.Parent = MainFrame

    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 6)
    ScrollCorner.Parent = Scroll

    local ContentText = Instance.new("TextLabel")
    ContentText.Size = UDim2.new(1, -16, 0, 0)
    ContentText.Position = UDim2.new(0, 8, 0, 8)
    ContentText.BackgroundTransparency = 1
    ContentText.Font = Enum.Font.Code
    ContentText.Text = "Ready. Click [Scan] or [⭐ Quest Focus] to inspect client data & quest structures."
    ContentText.TextColor3 = Color3.fromRGB(200, 210, 230)
    ContentText.TextSize = 11
    ContentText.TextXAlignment = Enum.TextXAlignment.Left
    ContentText.TextYAlignment = Enum.TextYAlignment.Top
    ContentText.AutomaticSize = Enum.AutomaticSize.XY
    ContentText.Parent = Scroll

    -- Window Dragging
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Root Selector Buttons
    local function setRoot(rootName, activeBtn)
        Inspector.CurrentRoot = rootName
        for _, b in ipairs({ BtnRootAll, BtnRootRep, BtnRootPlayer, BtnRootWorkspace }) do
            b.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
        end
        activeBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        ContentText.Text = "Target root set to: " .. rootName .. ". Click [Scan] to run."
    end
    BtnRootAll.MouseButton1Click:Connect(function() setRoot("ALL", BtnRootAll) end)
    BtnRootRep.MouseButton1Click:Connect(function() setRoot("REPLICATED_STORAGE", BtnRootRep) end)
    BtnRootPlayer.MouseButton1Click:Connect(function() setRoot("PLAYER", BtnRootPlayer) end)
    BtnRootWorkspace.MouseButton1Click:Connect(function() setRoot("WORKSPACE", BtnRootWorkspace) end)
    BtnRootAll.BackgroundColor3 = Color3.fromRGB(59, 130, 246)

    -- Scan Action
    BtnScan.MouseButton1Click:Connect(function()
        ContentText.Text = "Scanning [" .. Inspector.CurrentRoot .. "]..."
        task.wait()
        local results, summary = Inspector:Scan(Inspector.CurrentRoot)
        local lines = {}
        table.insert(lines, string.format("===== SCAN RESULTS: ROOT [%s] =====", Inspector.CurrentRoot))
        table.insert(lines, string.format("Total Objects: %d | Values: %d | Remotes: %d | Modules: %d",
            summary.TotalObjects, summary.ValueObjects, summary.RemoteEvents, summary.ModuleScripts))
        table.insert(lines, "--------------------------------------------------")
        for i, item in ipairs(results) do
            local valText = item.Value and (" = " .. tostring(item.Value)) or ""
            table.insert(lines, string.format("[%d] %s (%s)%s", i, item.Path, item.ClassName, valText))
            if item.Extra.Text then table.insert(lines, "    Text: " .. item.Extra.Text) end
            if item.Extra.ModuleData then table.insert(lines, "    ModuleData: " .. item.Extra.ModuleData) end
        end
        ContentText.Text = table.concat(lines, "\n")
    end)

    -- Quest Focus Button
    BtnQuestFocus.MouseButton1Click:Connect(function()
        ContentText.Text = "Scanning & Filtering Quests..."
        task.wait()
        if not Inspector.LastScanResults or #Inspector.LastScanResults == 0 then
            Inspector:Scan("ALL")
        end
        local quests = Inspector:FindQuests()
        local lines = {}
        table.insert(lines, string.format("===== ⭐ QUEST FOCUS DETECTOR (%d POTENTIAL OBJECTS) =====", #quests))
        table.insert(lines, "Keywords: quest, mission, task, objective, bounty, target, progress, ticket")
        table.insert(lines, "--------------------------------------------------")
        for i, item in ipairs(quests) do
            local valText = item.Value and (" = " .. tostring(item.Value)) or ""
            table.insert(lines, string.format("[%d] %s [%s]%s", i, item.Path, item.ClassName, valText))
            if next(item.Attributes) ~= nil then
                for aName, aData in pairs(item.Attributes) do
                    table.insert(lines, string.format("    Attr: %s = %s", aName, aData.Display))
                end
            end
            if item.Extra.Text then
                table.insert(lines, string.format("    UI Text: \"%s\"", item.Extra.Text))
            end
            if item.Extra.ModuleData then
                table.insert(lines, string.format("    Module Data: %s", item.Extra.ModuleData))
            end
        end
        ContentText.Text = table.concat(lines, "\n")
    end)

    -- Tree View Button
    BtnTree.MouseButton1Click:Connect(function()
        if not Inspector.LastScanResults or #Inspector.LastScanResults == 0 then
            Inspector:Scan(Inspector.CurrentRoot)
        end
        ContentText.Text = "Building Explorer Tree View..."
        task.wait()
        local treeText = Inspector:BuildTreeView(SearchBox.Text)
        ContentText.Text = "===== EXPLORER TREE VIEW =====\n" .. treeText
    end)

    -- Remote Spy Button
    BtnRemoteSpy.MouseButton1Click:Connect(function()
        if Inspector.IsRemoteSpying then
            Inspector:StopRemoteSpy()
            BtnRemoteSpy.Text = "Remote Spy: OFF"
            BtnRemoteSpy.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
        else
            Inspector:StartRemoteSpy()
            BtnRemoteSpy.Text = "Remote Spy: ON"
            BtnRemoteSpy.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
            ContentText.Text = "[REMOTE SPY ACTIVATED]\nListening to all RemoteEvents from server...\n"
        end
    end)
    Inspector.RemoteLogCallback = function(logLine)
        ContentText.Text = logLine .. "\n-------------------------\n" .. ContentText.Text
    end

    -- Snapshot & Diff
    BtnSnapA.MouseButton1Click:Connect(function()
        Inspector:Snapshot("before")
        ContentText.Text = "[SNAPSHOT] Saved 'before'. Perform your action, then click [Snap [B]]."
    end)
    BtnSnapB.MouseButton1Click:Connect(function()
        Inspector:Snapshot("after")
        ContentText.Text = "[SNAPSHOT] Saved 'after'. Click [Diff] to compare."
    end)
    BtnCompare.MouseButton1Click:Connect(function()
        local _, diffText = Inspector:Compare("before", "after")
        ContentText.Text = diffText or "Error comparing snapshots."
    end)

    -- Copy / Export
    BtnCopy.MouseButton1Click:Connect(function()
        local txt = ContentText.Text
        print(txt)
        pcall(function()
            if setclipboard then setclipboard(txt) end
        end)
    end)

    -- Live Search Filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text
        if query == "" then return end
        local filtered = Inspector:Find(query)
        local lines = {}
        table.insert(lines, string.format("Search Results for '%s' (%d matches):", query, #filtered))
        table.insert(lines, "--------------------------------------------------")
        for i, item in ipairs(filtered) do
            local valText = item.Value and (" = " .. tostring(item.Value)) or ""
            table.insert(lines, string.format("[%d] %s [%s]%s", i, item.Path, item.ClassName, valText))
            if item.Extra.Text then table.insert(lines, "    Text: " .. item.Extra.Text) end
        end
        ContentText.Text = table.concat(lines, "\n")
    end)

    -- Close / Toggle
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = not ScreenGui.Enabled end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F4 then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Init UI
task.spawn(CreateInspectorUI)

_G.Inspector = Inspector
shared.Inspector = Inspector

print([[
====================================================================
 [CLIENT DATA & QUEST INSPECTOR v2 LOADED]
 Hotkey: Press [F4] to Toggle UI
 Key Features:
   - Root Selector: ALL, ReplicatedStorage, LocalPlayer, Workspace
   - [⭐ Quest Focus]: Auto-scan & filter quest keywords
   - [Tree View]: Explorer tree hierarchy
   - [Remote Spy]: Capture server RemoteEvent payloads
   - [Snap A/B & Diff]: Instant state difference analyzer
====================================================================
]])

return Inspector
