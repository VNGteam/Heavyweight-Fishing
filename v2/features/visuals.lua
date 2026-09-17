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
function Visuals.ApplyFullbright(enabled, config)
    config = config or {}
    if enabled then
        local brightLevel = math.clamp(tonumber(config.FullbrightLevel) or 2.0, 1.0, 3.5)
        Lighting.Brightness = brightLevel
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.ExposureCompensation = 0
        -- Giảm Atmosphere glare/haze
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo then
            atmo.Density = 0.05
            atmo.Haze = 0
            atmo.Glare = 0
        end
        -- Giảm BloomEffect tránh chói
        local bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
        if bloom then
            bloom.Intensity = 0.1
            bloom.Size = 10
        end
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.GlobalShadows = true
        Lighting.ExposureCompensation = 0
        local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
        if atmo then
            atmo.Density = 0.3
            atmo.Haze = 0.5
        end
        local bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
        if bloom then
            bloom.Intensity = 1
        end
    end
end

-- Anti-Glare: kìm hãm ánh sáng khi thời tiết đổi (Sunny, Windy, v.v.)
function Visuals.SetupAntiGlare(config, activeConnections)
    local conn = Lighting.Changed:Connect(function(prop)
        if not config.Fullbright or (config.FullbrightAntiGlare == false) then return end
        if prop == "Brightness" and Lighting.Brightness > 3.0 then
            Lighting.Brightness = math.clamp(tonumber(config.FullbrightLevel) or 2.0, 1.0, 3.5)
        elseif prop == "ExposureCompensation" and Lighting.ExposureCompensation > 0.1 then
            Lighting.ExposureCompensation = 0
        end
    end)
    if activeConnections then
        table.insert(activeConnections, conn)
    end
    return conn
end

function Visuals.ApplyClearVision(enabled)
    local Camera = Workspace.CurrentCamera
    if enabled then
        pcall(function()
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 1000000
        end)
        for _, obj in ipairs(Lighting:GetDescendants()) do
            pcall(function()
                if obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = false
                    obj.FarIntensity = 0
                    obj.NearIntensity = 0
                elseif obj:IsA("BlurEffect") then
                    obj.Enabled = false
                    obj.Size = 0
                elseif obj:IsA("Atmosphere") then
                    obj.Density = 0
                    obj.Haze = 0
                    obj.Glare = 0
                    obj.Offset = 0
                end
            end)
        end
        if Camera then
            for _, obj in ipairs(Camera:GetDescendants()) do
                pcall(function()
                    if obj:IsA("DepthOfFieldEffect") then
                        obj.Enabled = false
                    elseif obj:IsA("BlurEffect") then
                        obj.Enabled = false
                    elseif obj:IsA("ParticleEmitter") then
                        obj.Enabled = false
                    end
                end)
            end
        end
    else
        pcall(function()
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end)
        for _, obj in ipairs(Lighting:GetDescendants()) do
            pcall(function()
                if obj:IsA("DepthOfFieldEffect") or obj:IsA("BlurEffect") then
                    obj.Enabled = true
                elseif obj:IsA("Atmosphere") then
                    obj.Density = 0.3
                    obj.Haze = 0.5
                end
            end)
        end
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
