--[[
    v2/core/services.lua
    Roblox Services, Player References & Cleanup Logic
--]]

local Services = {}

-- 1. Bind Roblox Services
Services.Players = game:GetService("Players")
Services.Workspace = game:GetService("Workspace")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.RunService = game:GetService("RunService")
Services.UserInputService = game:GetService("UserInputService")
Services.TweenService = game:GetService("TweenService")
Services.HttpService = game:GetService("HttpService")
Services.TeleportService = game:GetService("TeleportService")
Services.Lighting = game:GetService("Lighting")
Services.CoreGui = game:GetService("CoreGui")
Services.GuiService = game:GetService("GuiService")
Services.VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager") or nil

-- 2. Player & Camera
Services.LocalPlayer = Services.Players.LocalPlayer
if not Services.LocalPlayer then
    Services.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Services.LocalPlayer = Services.Players.LocalPlayer
end
Services.Camera = Services.Workspace.CurrentCamera

-- 3. Safe Events folder lookup
Services.Events = Services.ReplicatedStorage:FindFirstChild("Events")
if not Services.Events then
    task.spawn(function()
        Services.Events = Services.ReplicatedStorage:WaitForChild("Events", 5)
    end)
end

-- 4. Clean old script instances
function Services.CleanOldInstances()
    pcall(function()
        local function purge(parent, name)
            if not parent then return end
            for _, c in ipairs(parent:GetChildren()) do
                if c.Name == name or c.Name:find("Identical") or c.Name:find("HeavyweightFishing") then
                    pcall(function() c:Destroy() end)
                end
            end
        end

        local gh = (gethui and gethui()) or nil
        if gh then
            purge(gh, "IdenticalHeavyweightFishing")
            purge(gh, "FloatingAvatar")
            purge(gh, "FloatingCrescent")
            purge(gh, "Notifications")
        end

        if Services.CoreGui then
            purge(Services.CoreGui, "IdenticalHeavyweightFishing")
            purge(Services.CoreGui, "FloatingAvatar")
            purge(Services.CoreGui, "FloatingCrescent")
            purge(Services.CoreGui, "Notifications")
        end

        local pGui = Services.LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            purge(pGui, "IdenticalHeavyweightFishing")
            purge(pGui, "FloatingAvatar")
            purge(pGui, "FloatingCrescent")
            purge(pGui, "Notifications")
        end

        local espFolder = Services.Workspace:FindFirstChild("IdenticalESP")
        if espFolder then
            pcall(function() espFolder:Destroy() end)
        end
    end)
end

-- 5. Safe GUI Parent Resolver
function Services.GetGuiParent()
    local success, result = pcall(function()
        if gethui then return gethui() end
        if Services.CoreGui then return Services.CoreGui end
        return Services.LocalPlayer:WaitForChild("PlayerGui")
    end)
    return success and result or Services.LocalPlayer:WaitForChild("PlayerGui")
end

return Services
