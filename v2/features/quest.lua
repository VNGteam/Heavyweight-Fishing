--[[
    v2/features/quest.lua
    Automated Daily Ticket Quests & Dialogue Handling
--]]

local Services = require(script.Parent.Parent.core.services)
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Workspace = Services.Workspace
local Utils = require(script.Parent.Parent.core.utils)

local Quest = {}

Quest.state = {
    active = false,
    currentQuestType = "none",  -- "fish_100", "skill_100", "fish_15m", "bait_100", "none"
    isCooldown = false,
    isBusyRoutine = false,
    isAtHomeSpot = false,
    lastScanTime = 0
}

-- 1. Click button safely across multiple executor layers
local function clickGuiButton(btn)
    if not btn or not btn:IsA("GuiButton") or not btn.Visible then return false end
    pcall(function()
        if firesignal then
            if btn.Activated then firesignal(btn.Activated) end
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
        end
        if getconnections then
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
        end
    end)
    return true
end

-- 2. Detect Active Quest from Data/PlayerGui
function Quest.DetectActiveQuest()
    local pData = LocalPlayer:FindFirstChild("Data")
    local questFolder = pData and pData:FindFirstChild("Quest")
    if questFolder then
        for _, item in ipairs(questFolder:GetChildren()) do
            local name = item.Name:lower()
            if name:find("fish") and name:find("100") then
                Quest.state.currentQuestType = "fish_100"
                return "fish_100"
            elseif name:find("skill") or (name:find("cast") and name:find("100")) then
                Quest.state.currentQuestType = "skill_100"
                return "skill_100"
            elseif name:find("15m") or name:find("giant") or name:find("heavy") then
                Quest.state.currentQuestType = "fish_15m"
                return "fish_15m"
            elseif name:find("bait") then
                Quest.state.currentQuestType = "bait_100"
                return "bait_100"
            end
        end
    end

    Quest.state.currentQuestType = "none"
    return "none"
end

-- 3. Handle NPC Dialogue
function Quest.HandleDialogue()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local dGui = pGui and (pGui:FindFirstChild("DialogueGui") or pGui:FindFirstChild("Dialogue") or pGui:FindFirstChild("TalkGui"))
    if not dGui or not dGui.Visible then return false end

    for _, desc in ipairs(dGui:GetDescendants()) do
        if desc:IsA("GuiButton") and desc.Visible then
            local txt = ""
            if desc:IsA("TextButton") then
                txt = desc.Text:lower()
            end
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("TextLabel") and child.Visible then
                    txt = txt .. " " .. child.Text:lower()
                end
            end

            -- Click through accept, claim, continue buttons
            if txt:find("nhận") or txt:find("accept") or txt:find("claim") or txt:find("tiếp") or txt:find("yes") or txt:find("ok") then
                clickGuiButton(desc)
                return true
            end
        end
    end

    return false
end

-- 4. Quest Tick Logic
function Quest.Tick(config)
    if not config.AutoTicketQuest or Quest.state.isBusyRoutine then return end
    local now = tick()
    if (now - Quest.state.lastScanTime < 1.0) then return end
    Quest.state.lastScanTime = now

    Quest.DetectActiveQuest()
    Quest.HandleDialogue()
end

return Quest
