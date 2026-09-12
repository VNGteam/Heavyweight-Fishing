--[[
    ============================================================================
    PLAYER DATA & OBJECT INSPECTOR (DEBUG / INSPECTION TOOL)
    Environment: Roblox Client (LocalScript)
    Description: Recursive scanner, real-time watcher, snapshot diff engine,
                 and interactive debugger UI for Players.LocalPlayer.
    Security: Purely Read-Only (NO Remote fire/invoke, NO metamethods/hooks).
    ============================================================================
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ============================================================================
-- 1. UTILITY FUNCTIONS
-- ============================================================================
local Utils = {}

function Utils.safeGet(obj, prop)
    local success, result = pcall(function()
        return obj[prop]
    end)
    if success then
        return result
    end
    return nil
end

function Utils.getRelativeDepth(obj, root)
    local depth = 0
    local cur = obj.Parent
    while cur and cur ~= root and cur ~= game do
        depth = depth + 1
        cur = cur.Parent
    end
    return depth
end

function Utils.valueToString(val)
    if val == nil then
        return "nil"
    elseif typeof(val) == "Instance" then
        return val:GetFullName()
    elseif typeof(val) == "Vector3" then
        return string.format("Vector3(%.2f, %.2f, %.2f)", val.X, val.Y, val.Z)
    elseif typeof(val) == "CFrame" then
        local x, y, z = val.X, val.Y, val.Z
        return string.format("CFrame(Pos: %.2f, %.2f, %.2f)", x, y, z)
    elseif typeof(val) == "Color3" then
        return string.format("Color3(R: %.2f, G: %.2f, B: %.2f)", val.R, val.G, val.B)
    else
        return tostring(val)
    end
end

function Utils.copyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Utils.copyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- ============================================================================
-- 2. CORE SCANNER ENGINE
-- ============================================================================
local Scanner = {
    Snapshots = {},
    WatchConnections = {},
    IsWatching = false,
    LastScanResults = {},
    LogCallback = nil, -- Hook for UI display
}

-- Phân loại đối tượng thành các category chuẩn
function Scanner:Classify(obj, record)
    local fullName = record.Path
    local className = record.ClassName

    if obj == LocalPlayer then
        return "PLAYER"
    elseif fullName:find("^Workspace%." .. LocalPlayer.Name) or (LocalPlayer.Character and (obj == LocalPlayer.Character or obj:IsDescendantOf(LocalPlayer.Character))) then
        return "CHARACTER"
    elseif fullName:find("%.Backpack") then
        return "BACKPACK"
    elseif fullName:find("%.PlayerGui") then
        return "PLAYERGUI"
    elseif obj:IsA("ValueBase") then
        return "VALUES"
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
        return "REMOTES"
    elseif obj:IsA("ModuleScript") then
        return "MODULES"
    elseif obj:IsA("GuiObject") or obj:IsA("LayerCollector") then
        return "GUI"
    elseif obj:IsA("BasePart") then
        return "PARTS"
    else
        return "OTHER"
    end
end

-- Trích xuất toàn bộ metadata chi tiết từ một Instance
function Scanner:ExtractObjectData(obj, rootContext)
    local record = {
        Instance = obj,
        Name = obj.Name,
        ClassName = obj.ClassName,
        Parent = obj.Parent and obj.Parent.Name or "nil",
        Path = obj:GetFullName(),
        Depth = Utils.getRelativeDepth(obj, rootContext or LocalPlayer),
        Attributes = {},
        Tags = {},
        Category = "OTHER",
        Extra = {},
    }

    -- 1. Attributes
    local attrs = obj:GetAttributes()
    if attrs and next(attrs) ~= nil then
        for attrName, attrVal in pairs(attrs) do
            record.Attributes[attrName] = {
                Value = attrVal,
                Type = typeof(attrVal),
                Display = Utils.valueToString(attrVal),
            }
        end
    end

    -- 2. Tags (CollectionService)
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

    -- 4. GuiObject (TextLabel, TextButton, TextBox, Frame, etc.)
    if obj:IsA("GuiObject") then
        record.Extra.Position = Utils.valueToString(obj.Position)
        record.Extra.Size = Utils.valueToString(obj.Size)
        record.Extra.Visible = tostring(obj.Visible)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            record.Extra.Text = obj.Text
        end
    end

    -- 5. BasePart
    if obj:IsA("BasePart") then
        record.Extra.Position = Utils.valueToString(obj.Position)
        record.Extra.Size = Utils.valueToString(obj.Size)
        record.Extra.Anchored = tostring(obj.Anchored)
        record.Extra.Transparency = tostring(obj.Transparency)
    end

    -- 6. Remote / Module markers (Tuyệt đối không fire / require)
    if obj:IsA("RemoteEvent") then
        record.Extra.RemoteType = "RemoteEvent (Listen Only)"
    elseif obj:IsA("RemoteFunction") then
        record.Extra.RemoteType = "RemoteFunction (Listen Only)"
    elseif obj:IsA("BindableEvent") then
        record.Extra.RemoteType = "BindableEvent (Internal)"
    elseif obj:IsA("BindableFunction") then
        record.Extra.RemoteType = "BindableFunction (Internal)"
    elseif obj:IsA("ModuleScript") then
        record.Extra.Module = "ModuleScript (Not Required)"
    end

    -- Phân loại Category
    record.Category = self:Classify(obj, record)

    return record
end

-- Quét đệ quy toàn bộ LocalPlayer + Character
function Scanner:ScanAll()
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
        CharacterObjects = 0,
        BackpackObjects = 0,
        PlayerGuiObjects = 0,
        Categories = {},
    }

    local function process(obj, root)
        if not obj then return end
        local record = self:ExtractObjectData(obj, root)
        table.insert(results, record)

        -- Thống kê tổng hợp
        summary.TotalObjects = summary.TotalObjects + 1
        summary.Categories[record.Category] = (summary.Categories[record.Category] or 0) + 1

        if obj:IsA("Folder") then summary.Folders = summary.Folders + 1 end
        if obj:IsA("ValueBase") then summary.ValueObjects = summary.ValueObjects + 1 end
        if obj:IsA("GuiObject") then summary.GuiObjects = summary.GuiObjects + 1 end
        if obj:IsA("RemoteEvent") then summary.RemoteEvents = summary.RemoteEvents + 1 end
        if obj:IsA("RemoteFunction") then summary.RemoteFunctions = summary.RemoteFunctions + 1 end
        if obj:IsA("ModuleScript") then summary.ModuleScripts = summary.ModuleScripts + 1 end
        if next(record.Attributes) then
            for _ in pairs(record.Attributes) do
                summary.Attributes = summary.Attributes + 1
            end
        end

        if record.Category == "CHARACTER" then summary.CharacterObjects = summary.CharacterObjects + 1 end
        if record.Category == "BACKPACK" then summary.BackpackObjects = summary.BackpackObjects + 1 end
        if record.Category == "PLAYERGUI" then summary.PlayerGuiObjects = summary.PlayerGuiObjects + 1 end

        -- Quét con đệ quy
        for _, child in ipairs(obj:GetChildren()) do
            process(child, root)
        end
    end

    -- 1. Quét từ LocalPlayer (Bao gồm Backpack, PlayerGui, PlayerScripts, Folders...)
    process(LocalPlayer, LocalPlayer)

    -- 2. Quét Character (Character thường nằm ở Workspace)
    local char = LocalPlayer.Character
    if char and char.Parent then
        process(char, char)
    end

    self.LastScanResults = results
    self.LastSummary = summary

    return results, summary
end

-- Định dạng kết quả thành chuỗi văn bản hoàn chỉnh
function Scanner:FormatOutput(results, summary)
    local lines = {}
    table.insert(lines, "==================================================")
    table.insert(lines, "               PLAYER DATA SCAN RESULT            ")
    table.insert(lines, "==================================================")

    for i, item in ipairs(results) do
        table.insert(lines, string.format("[%d]", i))
        table.insert(lines, "Path: " .. item.Path)
        table.insert(lines, "Name: " .. item.Name)
        table.insert(lines, "Class: " .. item.ClassName)
        table.insert(lines, "Category: " .. item.Category)
        table.insert(lines, "Depth: " .. tostring(item.Depth))

        if item.Value ~= nil then
            table.insert(lines, "Value: " .. tostring(item.Value))
        end

        if next(item.Attributes) ~= nil then
            table.insert(lines, "Attributes:")
            for attrName, attrData in pairs(item.Attributes) do
                table.insert(lines, string.format("  - %s (%s) = %s", attrName, attrData.Type, attrData.Display))
            end
        end

        if #item.Tags > 0 then
            table.insert(lines, "Tags: " .. table.concat(item.Tags, ", "))
        end

        if next(item.Extra) ~= nil then
            for k, v in pairs(item.Extra) do
                table.insert(lines, string.format("%s: %s", k, tostring(v)))
            end
        end

        table.insert(lines, "")
    end

    table.insert(lines, "==================================================")
    table.insert(lines, "                   SCAN SUMMARY                   ")
    table.insert(lines, "==================================================")
    table.insert(lines, string.format("Total Objects:     %d", summary.TotalObjects))
    table.insert(lines, string.format("Folders:           %d", summary.Folders))
    table.insert(lines, string.format("Value Objects:     %d", summary.ValueObjects))
    table.insert(lines, string.format("GUI Objects:       %d", summary.GuiObjects))
    table.insert(lines, string.format("RemoteEvents:      %d", summary.RemoteEvents))
    table.insert(lines, string.format("RemoteFunctions:   %d", summary.RemoteFunctions))
    table.insert(lines, string.format("ModuleScripts:     %d", summary.ModuleScripts))
    table.insert(lines, string.format("Attributes:        %d", summary.Attributes))
    table.insert(lines, string.format("Character Objects: %d", summary.CharacterObjects))
    table.insert(lines, string.format("Backpack Objects:  %d", summary.BackpackObjects))
    table.insert(lines, string.format("PlayerGui Objects: %d", summary.PlayerGuiObjects))
    table.insert(lines, "==================================================")

    return table.concat(lines, "\n")
end

-- ============================================================================
-- 3. SEARCH & FILTER ENGINE
-- ============================================================================
function Scanner:Find(keyword, targetCategory)
    if not self.LastScanResults or #self.LastScanResults == 0 then
        self:ScanAll()
    end

    local query = string.lower(keyword or "")
    local matched = {}

    for _, item in ipairs(self.LastScanResults) do
        if targetCategory and targetCategory ~= "ALL" and item.Category ~= targetCategory then
            continue
        end

        local isMatch = false
        if string.find(string.lower(item.Name), query, 1, true) then
            isMatch = true
        elseif string.find(string.lower(item.Path), query, 1, true) then
            isMatch = true
        elseif string.find(string.lower(item.ClassName), query, 1, true) then
            isMatch = true
        elseif item.Value and string.find(string.lower(tostring(item.Value)), query, 1, true) then
            isMatch = true
        else
            -- Kiểm tra trong Attributes
            for attrName, attrData in pairs(item.Attributes) do
                if string.find(string.lower(attrName), query, 1, true) or
                   string.find(string.lower(tostring(attrData.Display)), query, 1, true) then
                    isMatch = true
                    break
                end
            end
            -- Kiểm tra trong Tags
            if not isMatch then
                for _, tag in ipairs(item.Tags) do
                    if string.find(string.lower(tag), query, 1, true) then
                        isMatch = true
                        break
                    end
                end
            end
            -- Kiểm tra trong Extra info (Text của Gui, v.v.)
            if not isMatch and item.Extra.Text then
                if string.find(string.lower(item.Extra.Text), query, 1, true) then
                    isMatch = true
                end
            end
        end

        if isMatch then
            table.insert(matched, item)
        end
    end

    return matched
end

-- ============================================================================
-- 4. REAL-TIME WATCH MODE
-- ============================================================================
function Scanner:EmitLog(tag, message)
    local timeStr = os.date("%X")
    local formatted = string.format("[%s] [%s] %s", timeStr, tag, message)
    print(formatted)
    if self.LogCallback then
        self.LogCallback(tag, message, timeStr)
    end
end

function Scanner:Watch()
    if self.IsWatching then
        warn("[Scanner] Watch mode is already running.")
        return
    end

    self.IsWatching = true
    self:EmitLog("WATCH", "Real-time Watch Mode ENABLED.")

    local function bindInstance(obj)
        if not obj or not obj.Parent then return end

        -- 1. Theo dõi ValueBase
        if obj:IsA("ValueBase") then
            local conn = obj.Changed:Connect(function(newVal)
                local displayVal = Utils.valueToString(newVal)
                self:EmitLog("CHANGED", string.format("Path: %s\n  Class: %s\n  New Value: %s", obj:GetFullName(), obj.ClassName, displayVal))
            end)
            table.insert(self.WatchConnections, conn)
        end

        -- 2. Theo dõi Attributes
        local attrConn = obj.AttributeChanged:Connect(function(attrName)
            local newVal = obj:GetAttribute(attrName)
            local displayVal = Utils.valueToString(newVal)
            self:EmitLog("ATTR_CHANGE", string.format("Path: %s\n  Attribute: %s\n  New Value: %s", obj:GetFullName(), attrName, displayVal))
        end)
        table.insert(self.WatchConnections, attrConn)
    end

    local function setupHierarchy(root)
        if not root then return end

        -- Bind cho các con hiện có
        for _, descendant in ipairs(root:GetDescendants()) do
            bindInstance(descendant)
        end

        -- Lắng nghe con mới được thêm vào
        local addedConn = root.DescendantAdded:Connect(function(descendant)
            local path = descendant:GetFullName()
            local valText = ""
            if descendant:IsA("ValueBase") then
                valText = " | Value: " .. Utils.valueToString(Utils.safeGet(descendant, "Value"))
            end
            self:EmitLog("ADDED", string.format("Path: %s [Class: %s]%s", path, descendant.ClassName, valText))
            bindInstance(descendant)
        end)
        table.insert(self.WatchConnections, addedConn)

        -- Lắng nghe con bị gỡ bỏ
        local removingConn = root.DescendantRemoving:Connect(function(descendant)
            self:EmitLog("REMOVED", string.format("Path: %s [Class: %s]", descendant:GetFullName(), descendant.ClassName))
        end)
        table.insert(self.WatchConnections, removingConn)
    end

    -- Setup cho LocalPlayer
    setupHierarchy(LocalPlayer)

    -- Setup cho Character hiện tại
    if LocalPlayer.Character then
        setupHierarchy(LocalPlayer.Character)
    end

    -- Theo dõi khi Character respawn
    local charConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        self:EmitLog("CHARACTER", "Character spawned: " .. newChar.Name)
        setupHierarchy(newChar)
    end)
    table.insert(self.WatchConnections, charConn)
end

function Scanner:Unwatch()
    if not self.IsWatching then return end

    for _, conn in ipairs(self.WatchConnections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    self.WatchConnections = {}
    self.IsWatching = false
    self:EmitLog("WATCH", "Real-time Watch Mode DISABLED.")
end

-- ============================================================================
-- 5. SNAPSHOT & COMPARE ENGINE
-- ============================================================================
function Scanner:Snapshot(name)
    local results = self:ScanAll()
    local snap = {}

    for _, item in ipairs(results) do
        local attrFlat = {}
        for aName, aData in pairs(item.Attributes) do
            attrFlat[aName] = aData.Display
        end

        snap[item.Path] = {
            Name = item.Name,
            ClassName = item.ClassName,
            Value = item.Value,
            Category = item.Category,
            Attributes = attrFlat,
            Text = item.Extra.Text,
        }
    end

    self.Snapshots[name] = snap
    self:EmitLog("SNAPSHOT", string.format("Saved snapshot '%s' (%d objects recorded).", name, #results))
    return snap
end

function Scanner:Compare(nameBefore, nameAfter)
    local before = self.Snapshots[nameBefore]
    local after = self.Snapshots[nameAfter]

    if not before then
        warn(string.format("[Scanner] Snapshot '%s' does not exist!", nameBefore))
        return nil
    end
    if not after then
        warn(string.format("[Scanner] Snapshot '%s' does not exist!", nameAfter))
        return nil
    end

    local diff = {
        Added = {},
        Removed = {},
        Changed = {},
    }

    -- 1. Kiểm tra Changed & Removed
    for path, oldData in pairs(before) do
        local newData = after[path]
        if not newData then
            table.insert(diff.Removed, {
                Path = path,
                ClassName = oldData.ClassName,
                Value = oldData.Value,
            })
        else
            -- Kiểm tra ValueBase Value thay đổi
            local valueChanged = oldData.Value ~= newData.Value
            -- Kiểm tra Gui Text thay đổi
            local textChanged = oldData.Text ~= newData.Text
            -- Kiểm tra Attributes thay đổi
            local attrChanges = {}
            for aName, aVal in pairs(oldData.Attributes) do
                if newData.Attributes[aName] ~= aVal then
                    table.insert(attrChanges, string.format("Attr '%s': %s -> %s", aName, tostring(aVal), tostring(newData.Attributes[aName])))
                end
            end
            for aName, aVal in pairs(newData.Attributes) do
                if oldData.Attributes[aName] == nil then
                    table.insert(attrChanges, string.format("Attr '%s' [ADDED]: %s", aName, tostring(aVal)))
                end
            end

            if valueChanged or textChanged or #attrChanges > 0 then
                table.insert(diff.Changed, {
                    Path = path,
                    OldValue = oldData.Value,
                    NewValue = newData.Value,
                    OldText = oldData.Text,
                    NewText = newData.Text,
                    AttrChanges = attrChanges,
                })
            end
        end
    end

    -- 2. Kiểm tra Added
    for path, newData in pairs(after) do
        if not before[path] then
            table.insert(diff.Added, {
                Path = path,
                ClassName = newData.ClassName,
                Value = newData.Value,
            })
        end
    end

    -- Định dạng chuỗi DIFF
    local lines = {}
    table.insert(lines, "==================================================")
    table.insert(lines, string.format("       SNAPSHOT DIFF: '%s' vs '%s'", nameBefore, nameAfter))
    table.insert(lines, "==================================================")

    table.insert(lines, "\n[CHANGED]:")
    if #diff.Changed == 0 then
        table.insert(lines, "  (None)")
    else
        for _, ch in ipairs(diff.Changed) do
            table.insert(lines, "  Path: " .. ch.Path)
            if ch.OldValue ~= ch.NewValue then
                table.insert(lines, string.format("    Value: %s -> %s", tostring(ch.OldValue), tostring(ch.NewValue)))
            end
            if ch.OldText ~= ch.NewText then
                table.insert(lines, string.format("    Text: %s -> %s", tostring(ch.OldText), tostring(ch.NewText)))
            end
            for _, ac in ipairs(ch.AttrChanges) do
                table.insert(lines, "    " .. ac)
            end
        end
    end

    table.insert(lines, "\n[ADDED]:")
    if #diff.Added == 0 then
        table.insert(lines, "  (None)")
    else
        for _, ad in ipairs(diff.Added) do
            local extra = ad.Value and (" | Value: " .. tostring(ad.Value)) or ""
            table.insert(lines, string.format("  + %s [%s]%s", ad.Path, ad.ClassName, extra))
        end
    end

    table.insert(lines, "\n[REMOVED]:")
    if #diff.Removed == 0 then
        table.insert(lines, "  (None)")
    else
        for _, rm in ipairs(diff.Removed) do
            table.insert(lines, string.format("  - %s [%s]", rm.Path, rm.ClassName))
        end
    end
    table.insert(lines, "==================================================")

    local diffText = table.concat(lines, "\n")
    print(diffText)
    return diff, diffText
end

-- ============================================================================
-- 6. INTERACTIVE DEBUG UI (ScreenGui)
-- ============================================================================
local function CreateInspectorUI()
    local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("PlayerInspectorGui")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PlayerInspectorGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Container Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 720, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(50, 53, 68)
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    -- Header / Title Bar
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "PLAYER DATA & OBJECT INSPECTOR"
    Title.TextColor3 = Color3.fromRGB(230, 235, 245)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 13
    CloseBtn.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Control Bar (Buttons & Actions)
    local ControlBar = Instance.new("Frame")
    ControlBar.Name = "ControlBar"
    ControlBar.Size = UDim2.new(1, -20, 0, 38)
    ControlBar.Position = UDim2.new(0, 10, 0, 48)
    ControlBar.BackgroundTransparency = 1
    ControlBar.Parent = MainFrame

    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.Padding = UDim.new(0, 6)
    ControlLayout.Parent = ControlBar

    local function createBtn(text, bgColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 92, 0, 32)
        btn.BackgroundColor3 = bgColor or Color3.fromRGB(45, 49, 66)
        btn.Font = Enum.Font.GothamSemibold
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(240, 240, 245)
        btn.TextSize = 12
        btn.Parent = ControlBar

        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(0, 6)
        cr.Parent = btn
        return btn
    end

    local BtnScan = createBtn("Scan All", Color3.fromRGB(37, 99, 235))
    local BtnWatch = createBtn("Watch: OFF", Color3.fromRGB(75, 85, 99))
    local BtnSnapBefore = createBtn("Snap [A]", Color3.fromRGB(16, 149, 114))
    local BtnSnapAfter = createBtn("Snap [B]", Color3.fromRGB(13, 115, 88))
    local BtnCompare = createBtn("Compare", Color3.fromRGB(147, 51, 234))
    local BtnExport = createBtn("Export/Log", Color3.fromRGB(59, 130, 246))
    local BtnClear = createBtn("Clear", Color3.fromRGB(220, 38, 38))

    -- Search Bar Container
    local SearchBarFrame = Instance.new("Frame")
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.Size = UDim2.new(1, -20, 0, 34)
    SearchBarFrame.Position = UDim2.new(0, 10, 0, 90)
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
    SearchBarFrame.BorderSizePixel = 0
    SearchBarFrame.Parent = MainFrame

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBarFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -16, 1, 0)
    SearchBox.Position = UDim2.new(0, 10, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.PlaceholderText = "Search by Name, Path, Class, Value, Attribute, Tag (e.g., 'quest', 'cash', 'level')..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
    SearchBox.TextSize = 12
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = SearchBarFrame

    -- Display ScrollingFrame
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "DisplayScroll"
    Scroll.Size = UDim2.new(1, -20, 1, -135)
    Scroll.Position = UDim2.new(0, 10, 0, 128)
    Scroll.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(75, 85, 99)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
    Scroll.Parent = MainFrame

    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 6)
    ScrollCorner.Parent = Scroll

    local ContentText = Instance.new("TextLabel")
    ContentText.Name = "ContentText"
    ContentText.Size = UDim2.new(1, -16, 0, 0)
    ContentText.Position = UDim2.new(0, 8, 0, 8)
    ContentText.BackgroundTransparency = 1
    ContentText.Font = Enum.Font.Code
    ContentText.Text = "Ready. Click [Scan All] to inspect LocalPlayer data."
    ContentText.TextColor3 = Color3.fromRGB(200, 210, 225)
    ContentText.TextSize = 11
    ContentText.TextXAlignment = Enum.TextXAlignment.Left
    ContentText.TextYAlignment = Enum.TextYAlignment.Top
    ContentText.AutomaticSize = Enum.AutomaticSize.XY
    ContentText.Parent = Scroll

    -- Make Window Draggable
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Button Actions
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)

    BtnScan.MouseButton1Click:Connect(function()
        ContentText.Text = "Scanning LocalPlayer..."
        task.wait()
        local results, summary = Scanner:ScanAll()
        local formatted = Scanner:FormatOutput(results, summary)
        ContentText.Text = formatted
    end)

    BtnWatch.MouseButton1Click:Connect(function()
        if Scanner.IsWatching then
            Scanner:Unwatch()
            BtnWatch.Text = "Watch: OFF"
            BtnWatch.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
        else
            Scanner:Watch()
            BtnWatch.Text = "Watch: ON"
            BtnWatch.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        end
    end)

    BtnSnapBefore.MouseButton1Click:Connect(function()
        Scanner:Snapshot("before")
        ContentText.Text = "[SNAPSHOT] Snapshot 'before' captured.\nNow perform your in-game action, then click [Snap [B]], followed by [Compare]."
    end)

    BtnSnapAfter.MouseButton1Click:Connect(function()
        Scanner:Snapshot("after")
        ContentText.Text = "[SNAPSHOT] Snapshot 'after' captured.\nNow click [Compare] to inspect differences."
    end)

    BtnCompare.MouseButton1Click:Connect(function()
        local _, diffText = Scanner:Compare("before", "after")
        if diffText then
            ContentText.Text = diffText
        else
            ContentText.Text = "Failed to compare. Ensure both Snap [A] and Snap [B] have been captured!"
        end
    end)

    BtnExport.MouseButton1Click:Connect(function()
        local output = ContentText.Text
        print(output)
        pcall(function()
            if setclipboard then
                setclipboard(output)
            end
        end)
    end)

    BtnClear.MouseButton1Click:Connect(function()
        ContentText.Text = ""
    end)

    -- Live Search Filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text
        if query == "" then
            if Scanner.LastScanResults and #Scanner.LastScanResults > 0 then
                ContentText.Text = Scanner:FormatOutput(Scanner.LastScanResults, Scanner.LastSummary)
            end
            return
        end

        local filtered = Scanner:Find(query)
        local lines = {}
        table.insert(lines, string.format("Search Results for '%s' (%d matches):", query, #filtered))
        table.insert(lines, "--------------------------------------------------")
        for i, item in ipairs(filtered) do
            table.insert(lines, string.format("[%d] %s (%s)", i, item.Path, item.ClassName))
            if item.Value ~= nil then
                table.insert(lines, "    Value: " .. tostring(item.Value))
            end
            if next(item.Attributes) ~= nil then
                for aName, aData in pairs(item.Attributes) do
                    table.insert(lines, string.format("    Attr: %s = %s", aName, aData.Display))
                end
            end
            if item.Extra.Text then
                table.insert(lines, "    Text: " .. item.Extra.Text)
            end
        end
        ContentText.Text = table.concat(lines, "\n")
    end)

    -- Hook Watcher to UI display
    Scanner.LogCallback = function(tag, msg, timeStr)
        local line = string.format("[%s] [%s] %s\n", timeStr, tag, msg)
        ContentText.Text = line .. ContentText.Text
    end

    -- Toggle key (F4)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.F4 then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- Mount UI to PlayerGui
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Parent = playerGui
    print("[Inspector] UI Loaded successfully. Press F4 to toggle.")
end

-- ============================================================================
-- 7. INITIALIZATION & GLOBAL EXPORT
-- ============================================================================
-- Khởi tạo UI
task.spawn(CreateInspectorUI)

-- Đưa Scanner vào _G / shared để lập trình viên có thể gõ command từ Console
_G.Scanner = Scanner
shared.Scanner = Scanner

print([[
====================================================================
 [PLAYER DATA INSPECTOR LOADED]
 Controls:
   - Press [F4] to Toggle Debug UI
   - _G.Scanner:ScanAll()
   - _G.Scanner:Find("keyword")
   - _G.Scanner:Watch() / _G.Scanner:Unwatch()
   - _G.Scanner:Snapshot("before")
   - _G.Scanner:Snapshot("after")
   - _G.Scanner:Compare("before", "after")
====================================================================
]])

return Scanner
