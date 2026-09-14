--[[
    v2/core/utils.lua
    Notification System, Health Calculation & Number Formatting Utilities
--]]

local Services = require(script.Parent.services)
local Workspace = Services.Workspace
local LocalPlayer = Services.LocalPlayer
local HttpService = Services.HttpService
local TweenService = Services.TweenService

local Utils = {}

-- 1. Number Formatting
function Utils.FormatWithSpaces(val)
    local num = tonumber(val)
    if not num then return tostring(val or "") end
    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")
        if k == 0 then break end
    end
    return formatted
end

function Utils.FormatNumber(val)
    local n = tonumber(val)
    if not n then return "0" end
    if n >= 1e9 then
        return string.format("%.2fB", n / 1e9)
    elseif n >= 1e6 then
        return string.format("%.2fM", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fK", n / 1e3)
    end
    return tostring(math.floor(n))
end

-- 2. Notification System (StarterGui + In-game Floating Toast)
local notifContainer = nil
function Utils.SetNotifContainer(container)
    notifContainer = container
end

function Utils.ShowNotification(title, text, notifType, duration)
    duration = duration or 3
    -- Fallback to StarterGui
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Thông Báo",
            Text = text or "",
            Duration = duration
        })
    end)

    -- Floating toast if UI container is available
    if notifContainer and notifContainer.Parent then
        pcall(function()
            local toast = Instance.new("Frame")
            toast.Size = UDim2.new(1, 0, 0, 48)
            toast.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
            toast.BorderSizePixel = 0
            toast.BackgroundTransparency = 0.1

            local uic = Instance.new("UICorner")
            uic.CornerRadius = UDim.new(0, 8)
            uic.Parent = toast

            local uis = Instance.new("UIStroke")
            uis.Color = (notifType == "SUCCESS" and Color3.fromRGB(46, 204, 113))
                or (notifType == "WARN" and Color3.fromRGB(230, 126, 34))
                or (notifType == "ERROR" and Color3.fromRGB(231, 76, 60))
                or Color3.fromRGB(0, 168, 255)
            uis.Thickness = 1.2
            uis.Parent = toast

            local tTitle = Instance.new("TextLabel")
            tTitle.Text = title or "Identical Hub"
            tTitle.TextColor3 = uis.Color
            tTitle.Font = Enum.Font.GothamBold
            tTitle.TextSize = 13
            tTitle.Position = UDim2.new(0, 12, 0, 6)
            tTitle.Size = UDim2.new(1, -24, 0, 16)
            tTitle.BackgroundTransparency = 1
            tTitle.TextXAlignment = Enum.TextXAlignment.Left
            tTitle.Parent = toast

            local tDesc = Instance.new("TextLabel")
            tDesc.Text = text or ""
            tDesc.TextColor3 = Color3.fromRGB(200, 205, 215)
            tDesc.Font = Enum.Font.Gotham
            tDesc.TextSize = 12
            tDesc.Position = UDim2.new(0, 12, 0, 24)
            tDesc.Size = UDim2.new(1, -24, 0, 18)
            tDesc.BackgroundTransparency = 1
            tDesc.TextXAlignment = Enum.TextXAlignment.Left
            tDesc.TextTruncate = Enum.TextTruncate.AtEnd
            tDesc.Parent = toast

            toast.Parent = notifContainer
            task.delay(duration, function()
                if toast and toast.Parent then
                    local tw = TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
                    tw:Play()
                    tw.Completed:Wait()
                    toast:Destroy()
                end
            end)
        end)
    end
end

-- 3. Health Calculation
function Utils.GetFishHealth(fUI)
    -- 1. Check Workspace.Fishes
    local fishID = LocalPlayer:GetAttribute("FishID")
    if fishID and Workspace:FindFirstChild("Fishes") then
        local f = Workspace.Fishes:FindFirstChild(fishID)
        if f then
            local hpVal = f:FindFirstChild("FishHealth") or f:FindFirstChild("Health")
            if hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) and hpVal.Value > 0 then
                return hpVal.Value
            end
        end
    end

    -- 2. Check Character attributes
    local char = LocalPlayer.Character
    if char then
        for _, att in ipairs({"FishHealth", "FishHP", "TargetHealth", "BossHP", "TargetHP"}) do
            local val = char:GetAttribute(att)
            if val and tonumber(val) and tonumber(val) > 0 then
                return tonumber(val)
            end
        end
    end

    -- 3. Check fUI (Fishing GUI)
    if fUI then
        local bossBar = fUI:FindFirstChild("BossFightBar")
        if bossBar and bossBar.Visible and bossBar.Size.X.Scale > 0 then
            return 999999 -- Boss đang chiến đấu
        end

        for _, d in ipairs(fUI:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text ~= "" then
                local dName = d.Name:lower()
                if (dName:find("fish") or dName:find("boss") or dName:find("enemy")) and not dName:find("player") then
                    local kMatch = d.Text:match("([%d%.]+)%s*[kK]")
                    if kMatch and tonumber(kMatch) then return tonumber(kMatch) * 1000 end
                    local slashMatch = d.Text:match("([%d,%.]+)%s*/")
                    if slashMatch then
                        local n = tonumber(slashMatch:gsub("[,]", ""))
                        if n and n > 0 then return n end
                    end
                end
            end
        end
    end

    return 10 -- Cá thông thường mặc định
end

function Utils.GetPlayerHealth(fUI)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.MaxHealth > 0 then
        return (hum.Health / hum.MaxHealth) * 100
    end

    if fUI and fUI:FindFirstChild("HPPlayer") then
        local hpP = fUI.HPPlayer
        local pBar = hpP:FindFirstChild("ProgressionBar")
        if pBar and pBar:FindFirstChild("Bar") then
            return pBar.Bar.Size.X.Scale * 100
        end
    end

    return 100
end

-- 4. Discord Webhook Sender
function Utils.SendDiscordWebhook(title, description, color, fields, webhookUrl)
    if not webhookUrl or webhookUrl == "" or not webhookUrl:find("discord%.com/api/webhooks") then
        return
    end

    local payload = {
        embeds = {
            {
                title = title or "Heavyweight Fishing Notification",
                description = description or "",
                color = color or 3447003,
                fields = fields or {},
                footer = { text = "Identical Hub • Heavyweight Fishing V2" },
                timestamp = DateTime.now():ToIsoDate()
            }
        }
    }

    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        task.spawn(function()
            pcall(req, {
                Url = webhookUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

return Utils
