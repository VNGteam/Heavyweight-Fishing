--[[
    v2/core/state.lua
    Shared Runtime State, Connection Tracking & UI Controllers Map
--]]

local State = {}

-- 1. Lifecycle Flags
State.isRunning = true
State.activeConnections = {}
State.cleanUpInstances = {}
State.UIControllers = {}
State.ConfigLabelMap = {}

-- 2. Helper to register connections for automatic cleanup
function State.AddConnection(conn)
    if conn then
        table.insert(State.activeConnections, conn)
    end
    return conn
end

-- 3. Helper to register instances for cleanup
function State.AddInstance(inst)
    if inst then
        table.insert(State.cleanUpInstances, inst)
    end
    return inst
end

-- 4. Full Unload Execution
function State.UnloadScript(onCustomUnload)
    if not State.isRunning then return end
    State.isRunning = false

    -- Disconnect all RBXScriptConnections
    for _, conn in ipairs(State.activeConnections) do
        pcall(function()
            if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                conn:Disconnect()
            end
        end)
    end
    table.clear(State.activeConnections)

    -- Invoke custom callbacks (e.g. restoring walkspeed, lighting)
    if onCustomUnload then
        pcall(onCustomUnload)
    end

    -- Destroy registered instances
    for _, inst in ipairs(State.cleanUpInstances) do
        pcall(function()
            if typeof(inst) == "Instance" then
                inst:Destroy()
            end
        end)
    end
    table.clear(State.cleanUpInstances)

    -- Clear global environment references
    local gEnv = (getgenv and getgenv()) or _G or shared
    if gEnv then
        gEnv.HeavyweightFishingKill = nil
        gEnv.IdenticalHeavyweightFishingUnload = nil
    end
end

return State
