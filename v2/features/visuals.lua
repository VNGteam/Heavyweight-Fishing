--[[
    v2/features/visuals.lua
    Fullbright, Fog Removal, FPS Optimization & Multi-Target ESP System
--]]

local Services = require(script.Parent.Parent.core.services)
local Lighting = Services.Lighting
local Workspace = Services.Workspace
local LocalPlayer = Services.LocalPlayer

local Visuals = {}

Visuals.espFolder = nil

-- 1. Ensure ESP Folder in Workspace
function Visuals.EnsureESPFolder()
    if not Visuals.espFolder or not Visuals.espFolder.Parent then
        local folder = Workspace:FindFirstChild("IdenticalESP")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "IdenticalESP"
            folder.Parent = Workspace
        end
        Visuals.espFolder = folder
    end
    return Visuals.espFolder
end

-- 2. Lighting Tweaks (Fullbright & Fog)
function Visuals.ApplyFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

-- 3. ESP Helper
function Visuals.AddBillboard(parentPart, title, color)
    if not parentPart or parentPart:FindFirstChild("ESP_Tag") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Tag"
    bb.Adornee = parentPart
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = title or "Target"
    txt.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12
    txt.TextStrokeTransparency = 0.2
    txt.Parent = bb

    bb.Parent = Visuals.EnsureESPFolder()
end

function Visuals.ClearAllESP()
    if Visuals.espFolder then
        Visuals.espFolder:ClearAllChildren()
    end
end

return Visuals
