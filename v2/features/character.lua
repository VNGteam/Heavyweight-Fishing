--[[
    v2/features/character.lua
    Character Movement (Speed, Fly, Noclip, Walk on Water) & Anti-AFK
--]]

local Services = require(script.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local Workspace = Services.Workspace
local UserInputService = Services.UserInputService

local Character = {}

Character.waterPlatform = nil

-- 1. WalkSpeed
function Character.ApplySpeed(config)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if config.CustomSpeedEnabled then
            hum.WalkSpeed = tonumber(config.WalkSpeed) or 16
        else
            hum.WalkSpeed = 16
        end
    end
end

-- 2. Noclip
function Character.ApplyNoclip(config)
    if not config.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

-- 3. Walk on Water
function Character.ApplyWalkOnWater(config)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if config.WalkOnWater then
        if not Character.waterPlatform or not Character.waterPlatform.Parent then
            local p = Instance.new("Part")
            p.Name = "IdenticalWaterPlatform"
            p.Size = Vector3.new(16, 1, 16)
            p.Anchored = true
            p.CanCollide = true
            p.Transparency = 1
            p.Parent = Workspace
            Character.waterPlatform = p
        end
        Character.waterPlatform.Position = Vector3.new(root.Position.X, -0.5, root.Position.Z)
    else
        if Character.waterPlatform then
            pcall(function() Character.waterPlatform:Destroy() end)
            Character.waterPlatform = nil
        end
    end
end

-- 4. Setup Anti-AFK
function Character.SetupAntiAFK()
    pcall(function()
        for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
            if conn.Disable then conn:Disable() end
        end
    end)

    LocalPlayer.Idled:Connect(function()
        pcall(function()
            local vu = game:GetService("VirtualUser")
            if vu then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)
end

return Character
