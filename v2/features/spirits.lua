--[[
    v2/features/spirits.lua
    God Spirit Praying & Taoist / Maoshan Scanning
--]]

local Services = require(script.Parent.Parent.core.services)
local Events = Services.Events
local Workspace = Services.Workspace
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.core.utils)

local Spirits = {}

Spirits.lastGodPrayTime = 0

-- 1. Auto God Pray
function Spirits.HandleGodPray(config)
    if not config.AutoGodPray then return end
    local now = tick()
    if (now - Spirits.lastGodPrayTime < 60) then return end

    if Events and Events:FindFirstChild("Pray") then
        pcall(function()
            Events.Pray:FireServer()
            Spirits.lastGodPrayTime = now
            Utils.ShowNotification("Thần Linh", "Đã thực hiện bái Thần!", "SUCCESS", 3)
        end)
    end
end

-- 2. Scan Taoist / Maoshan NPCs in workspace
function Spirits.FindSpecialNPC(namePattern)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():find(namePattern:lower()) then
            return obj
        end
    end
    return nil
end

return Spirits
