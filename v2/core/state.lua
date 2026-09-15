--[[
    v2/core/state.lua
    Shared Runtime State, Active Connections, Mutexes & Priority Manager
--]]

local State = {}

-- 1. Lifecycle Flags & Tracking
State.isRunning = true
State.activeConnections = {}
State.cleanUpInstances = {}
State.UIControllers = {}
State.ConfigLabelMap = {}
State.bossTogglesMap = {}

-- 2. Secret Boss Runtime State
State.secretBossState = {
    active = false,
    activeBoss = nil,
    currentIsland = nil,
    teleportedToBoss = false,
    isCatchingTarget = false,
    webhookSentForCurrent = false,
    lastHookedCheckTime = 0,
    lastHomeReturnTime = 0
}

-- 3. Ticket Quest Runtime State
State.ticketQuestState = {
    active = false,
    currentQuestType = "none",
    isCooldown = false,
    isBusyRoutine = false,
    isAtHomeSpot = false,
    lastScanTime = 0
}

-- 4. Gem Tracker
State.gemTracker = {
    baseline = 0,
    gained = 0,
    fishCount = 0
}

-- 5. Combo State
State.comboState = {
    openerUsedCount = 0,
    openerDone = false,
    loopTargetIndex = 1,
    loopIndex = 1,
    lastCastTime = 0,
    lastActionTime = 0,
    minigameStartTime = 0,
    usedTimes = { Z = 0, X = 0, C = 0, V = 0 },
    defaultCooldowns = { Z = 2.5, X = 3.0, C = 5.0, V = 4.0 },
    loopWaitStartTime = 0
}

-- 6. Priority Manager
State.PriorityManager = {
    cachedTask = "NormalFarm",
    lastTaskScan = 0
}

function State.PriorityManager.GetTaskDisplayName(taskKey)
    if taskKey == "SecretBoss" then return "🎯 Săn Secret Boss"
    elseif taskKey == "TicketQuest" then return "📜 Làm Vé Nhiệm Vụ"
    elseif taskKey == "GodSpirit" then return "⛩️ Cúng Thần Linh"
    elseif taskKey == "TrainSkill" then return "⚔️ Auto Luyện Chiêu"
    else return "🎣 Treo Farm Thường" end
end

function State.AddConnection(conn)
    if conn then table.insert(State.activeConnections, conn) end
    return conn
end

function State.AddInstance(inst)
    if inst then table.insert(State.cleanUpInstances, inst) end
    return inst
end

function State.UnloadScript(onCustomUnload)
    if not State.isRunning then return end
    State.isRunning = false

    for _, conn in ipairs(State.activeConnections) do
        pcall(function()
            if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                conn:Disconnect()
            end
        end)
    end
    table.clear(State.activeConnections)

    if onCustomUnload then pcall(onCustomUnload) end

    for _, inst in ipairs(State.cleanUpInstances) do
        pcall(function()
            if typeof(inst) == "Instance" and inst.Parent then
                inst:Destroy()
            end
        end)
    end
    table.clear(State.cleanUpInstances)

    local gEnv = (getgenv and getgenv()) or _G or shared
    if gEnv then
        gEnv.HeavyweightFishingKill = nil
        gEnv.IdenticalHeavyweightFishingUnload = nil
    end
end

return State
