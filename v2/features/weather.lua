--[[
    v2/features/weather.lua
    Weather Detection, Weather Totems Interaction & Auto Server Hop
--]]

local Services = require(script.Parent.Parent.core.services)
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Services.LocalPlayer
local HttpService = Services.HttpService
local Utils = require(script.Parent.Parent.core.utils)

local Weather = {}

Weather.isHopping = false
Weather.currentTargetWeather = nil
Weather.visitedServers = {}
Weather.lastHopCheck = 0

Weather.totems = {
    {name = "Totem Bão Sấm (Bamboo Isle)", island = "Đảo Tre (Bamboo Isle)", weather = "Thunderstorm (Bão Sấm)", pos = Vector3.new(-1242.0, 8.5, -195.0)},
    {name = "Totem Bão Tuyết (Frost Isle)", island = "Đảo Băng (Frost Isle)", weather = "Snowy (Bão Tuyết)", pos = Vector3.new(-1390.0, 10.2, -1515.0)},
    {name = "Totem Sương Mù (Coconut Isle)", island = "Đảo Quả Dừa (Coconut Isle)", weather = "Foggy (Sương Mù)", pos = Vector3.new(1475.0, 9.8, -1415.0)},
    {name = "Totem Nắng Gắt (Amber Isle)", island = "Đảo Hổ Phách (Amber Isle)", weather = "Blazing Sun (Nắng Gắt)", pos = Vector3.new(1275.0, 9.5, 1450.0)},
}

Weather.weatherChoices = {
    "Bất Kỳ Thời Tiết Nào (Trừ Clear)",
    "Thunderstorm (Bão Sấm)",
    "Snowy (Bão Tuyết)",
    "Foggy (Sương Mù)",
    "Blazing Sun (Nắng Gắt)",
    "Rainy (Trời Mưa)",
    "Windy (Trời Gió)",
    "Acid Rain (Mưa Axit)",
    "Blood Moon (Trăng Máu)",
    "Boss Realm",
}

function Weather.DetectWeatherPattern(text)
    if not text or typeof(text) ~= "string" then return nil, nil end
    local lower = text:lower()

    if lower:find("clear") or lower:find("sunny") or lower:find("normal") or lower:find("none")
       or lower:find("trong xanh") or lower:find("bình thường") then
        return nil, "Clear"
    end

    local patterns = {
        {"thunder", "Thunderstorm (Bão Sấm)"},
        {"snow", "Snowy (Bão Tuyết)"},
        {"fog", "Foggy (Sương Mù)"},
        {"blazing", "Blazing Sun (Nắng Gắt)"},
        {"sun", "Blazing Sun (Nắng Gắt)"},
        {"rain", "Rainy (Trời Mưa)"},
        {"wind", "Windy (Trời Gió)"},
        {"acid", "Acid Rain (Mưa Axit)"},
        {"blood", "Blood Moon (Trăng Máu)"},
        {"realm", "Boss Realm"},
    }

    for _, p in ipairs(patterns) do
        if lower:find(p[1], 1, true) then
            return p[2], p[2]
        end
    end

    return text, text
end

function Weather.DetectWeather()
    -- 1. Workspace
    local wsWeather = Workspace:GetAttribute("Weather") or Workspace:GetAttribute("CurrentWeather") or Workspace:GetAttribute("ActiveWeather")
    if typeof(wsWeather) == "string" and #wsWeather > 0 then
        local _, wName = Weather.DetectWeatherPattern(wsWeather)
        if wName then return wName end
    end
    if Workspace:FindFirstChild("Weather") then
        local wObj = Workspace.Weather
        if wObj:IsA("StringValue") and #wObj.Value > 0 then
            local _, wName = Weather.DetectWeatherPattern(wObj.Value)
            if wName then return wName end
        end
    end

    -- 2. ReplicatedStorage
    if ReplicatedStorage then
        local rsWeather = ReplicatedStorage:GetAttribute("Weather") or ReplicatedStorage:GetAttribute("CurrentWeather")
        if typeof(rsWeather) == "string" and #rsWeather > 0 then
            local _, wName = Weather.DetectWeatherPattern(rsWeather)
            if wName then return wName end
        end
        if ReplicatedStorage:FindFirstChild("Weather") then
            local rwObj = ReplicatedStorage.Weather
            if rwObj:IsA("StringValue") and #rwObj.Value > 0 then
                local _, wName = Weather.DetectWeatherPattern(rwObj.Value)
                if wName then return wName end
            end
        end
    end

    -- 1. Ưu tiên đọc trực tiếp từ HUD thời tiết game (MainGui.Info.Info.Weather.Value)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("MainGui") then
        local mainGui = pg.MainGui
        local direct = mainGui:FindFirstChild("Info")
        local wLabel = nil
        if direct then
            local subInfo = direct:FindFirstChild("Info") or direct
            local wFrame = subInfo:FindFirstChild("Weather")
            if wFrame and wFrame:FindFirstChild("Value") and wFrame.Value:IsA("TextLabel") then
                wLabel = wFrame.Value
            end
        end
        if wLabel and wLabel.Text and #wLabel.Text > 0 then
            local _, wName = Weather.DetectWeatherPattern(wLabel.Text)
            if wName then return wName end
        end

        -- Fallback quét trong Info
        if direct then
            for _, d in ipairs(direct:GetDescendants()) do
                if d:IsA("TextLabel") and d.Parent and d.Parent.Name:lower():find("weather") then
                    local _, wName = Weather.DetectWeatherPattern(d.Text)
                    if wName then return wName end
                end
            end
        end
    end

    return "Clear"
end

function Weather.IsWeatherMatch(currentWeatherName, targetWeather)
    if not currentWeatherName or currentWeatherName == "" or currentWeatherName == "Clear" then
        return false
    end
    if not targetWeather or targetWeather == "Bất Kỳ Thời Tiết Nào (Trừ Clear)" or targetWeather == "Bất Kỳ Thời Tiết Nào" then
        return currentWeatherName ~= "Clear"
    end
    local curLow = currentWeatherName:lower()
    local tgtLow = targetWeather:lower()
    return curLow:find(tgtLow, 1, true) ~= nil or tgtLow:find(curLow, 1, true) ~= nil
end

function Weather.SaveWeatherHopState(config)
    if not (writefile and HttpService) then return end
    pcall(function()
        writefile("HeavyweightFishing_WeatherHop.json", HttpService:JSONEncode({
            Active = config.AutoWeatherHop == true,
            TargetWeather = config.TargetWeather,
            AutoFish = config.WeatherHopAutoFish,
            Webhook = config.WeatherHopAlertWebhook,
            Visited = Weather.visitedServers,
            StartTime = tick()
        }))
    end)
end

function Weather.ClearWeatherHopState(config)
    config.AutoWeatherHop = false
    Weather.isHopping = false
    pcall(function()
        if isfile and isfile("HeavyweightFishing_WeatherHop.json") and delfile then
            delfile("HeavyweightFishing_WeatherHop.json")
        end
    end)
end

function Weather.CheckWeatherHopOnJoin(config)
    if not (isfile and readfile and isfile("HeavyweightFishing_WeatherHop.json")) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("HeavyweightFishing_WeatherHop.json"))
    end)
    if ok and type(data) == "table" and data.Active then
        config.AutoWeatherHop = true
        Weather.isHopping = true
        if data.TargetWeather then config.TargetWeather = data.TargetWeather end
        Weather.currentTargetWeather = config.TargetWeather
        Weather.visitedServers = data.Visited or {}
        Utils.ShowNotification("Tìm Thời Tiết", string.format("Đang kiểm tra thời tiết cho: %s...", config.TargetWeather), "INFO", 5)
    end
end

function Weather.InteractTotem(totem)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not totem or not totem.pos then return end

    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = CFrame.new(totem.pos + Vector3.new(0, 3, 0))
    Utils.ShowNotification("Bàn Thờ Thời Tiết", "Đã đến " .. totem.name .. "! Đang tương tác...", "SUCCESS", 4)
    task.wait(0.4)

    pcall(function()
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and (d.Parent:IsA("BasePart") or d.Parent:IsA("Model")) then
                local pPos = d.Parent:IsA("BasePart") and d.Parent.Position or d.Parent:GetPivot().Position
                if (pPos - totem.pos).Magnitude <= 35 then
                    if fireproximityprompt then
                        fireproximityprompt(d)
                    end
                end
            end
        end
    end)
end

function Weather.Tick(config)
    if not config.AutoWeatherHop then return end
    local now = tick()
    if (now - Weather.lastHopCheck < 6.0) then return end
    Weather.lastHopCheck = now

    local curWeather = Weather.DetectWeather()
    local target = config.TargetWeather or "Bất Kỳ Thời Tiết Nào (Trừ Clear)"

    if Weather.IsWeatherMatch(curWeather, target) then
        Utils.ShowNotification("TÌM THẤY THỜI TIẾT", string.format("🎉 ĐÃ TÌM THẤY SERVER!\nThời tiết: %s (Mục tiêu: %s)", curWeather, target), "SUCCESS", 10)
        Weather.ClearWeatherHopState(config)

        if config.WeatherHopAlertWebhook then
            local fields = {
                { name = "Thời Tiết", value = curWeather, inline = true },
                { name = "Server Job ID", value = game.JobId, inline = false }
            }
            if config.WebhookUrl ~= "" then
                Utils.SendDiscordWebhook("🌪️ PHÁT HIỆN SERVER THỜI TIẾT!", "Đã tìm thấy thời tiết: **" .. curWeather .. "**", 3447003, fields, config.WebhookUrl)
            end
            if config.TelegramNotifyWeather and config.TelegramBotToken ~= "" and config.TelegramChatId ~= "" then
                Utils.SendTelegramMessage(config, string.format("🌪️ *PHÁT HIỆN SERVER THỜI TIẾT!*\nThời tiết: *%s*\nJob ID: `%s`", curWeather, game.JobId))
            end
        end
        return
    end

    -- Không khớp -> Lưu trạng thái và nhảy server tiếp
    Weather.SaveWeatherHopState(config)
    Utils.ShowNotification("Đổi Server", string.format("Thời tiết hiện tại: %s (Không khớp). Tiếp tục đổi server...", curWeather), "WARN", 4)
    task.delay(1.5, function()
        Utils.ServerHop(Weather.visitedServers)
    end)
end

return Weather
