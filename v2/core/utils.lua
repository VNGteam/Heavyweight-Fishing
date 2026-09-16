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

-- 5. Telegram Bot Sender
function Utils.SendTelegramMessage(token, chatId, text)
    if not token or token == "" or not chatId or chatId == "" or not text or text == "" then return end
    pcall(function()
        local url = "https://api.telegram.org/bot" .. token .. "/sendMessage"
        local payload = {
            chat_id = chatId,
            text = text,
            parse_mode = "Markdown"
        }
        local body = HttpService:JSONEncode(payload)
        local headers = { ["Content-Type"] = "application/json" }
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then
            task.spawn(function()
                pcall(req, {
                    Url = url,
                    Method = "POST",
                    Headers = headers,
                    Body = body
                })
            end)
        end
    end)
end

-- 6. NPC Detection Alert (Discord + Telegram with Anti-Spam)
local npcAlertsSent = {}
function Utils.SendNPCDetectionAlert(npcType, npcName, npcInst, config)
    if not config then return end
    local alertKey = tostring(game.JobId or "local") .. "_" .. tostring(npcType)
    if npcAlertsSent[alertKey] then return end
    npcAlertsSent[alertKey] = true

    local posStr = "Không xác định"
    if npcInst then
        local root = npcInst:FindFirstChild("HumanoidRootPart") or npcInst.PrimaryPart or npcInst:FindFirstChild("Head") or npcInst:FindFirstChildWhichIsA("BasePart")
        if root then
            local p = root.Position
            posStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", p.X, p.Y, p.Z)
        end
    end

    local jobId = tostring(game.JobId or "")
    local placeId = tostring(game.PlaceId or "0")
    local playerName = (LocalPlayer and LocalPlayer.Name) or "Unknown"
    local timeStr = os.date("%H:%M:%S - %d/%m/%Y")

    -- Discord Webhook
    if config.WebhookEnabled and config.WebhookNotifyNPC and config.WebhookUrl and #config.WebhookUrl > 0 then
        local fields = {
            { name = "🎯 NPC Phát Hiện", value = "**" .. tostring(npcName) .. "**", inline = true },
            { name = "👤 Người Tìm Thấy", value = playerName, inline = true },
            { name = "📍 Tọa Độ Đứng", value = posStr, inline = true },
            { name = "🔑 Job ID Server", value = "```" .. (jobId ~= "" and jobId or "N/A (Chơi 1 mình)") .. "```", inline = false },
            { name = "⚡ Lệnh Vào Server Nhanh", value = "```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. placeId .. ", \"" .. jobId .. "\", game.Players.LocalPlayer)\n```", inline = false },
            { name = "⏰ Thời Gian", value = timeStr, inline = true }
        }
        Utils.SendDiscordWebhook("📜 PHÁT HIỆN " .. tostring(npcName):upper() .. " TRONG SERVER!", "Bot đã tìm thấy **" .. tostring(npcName) .. "** tại server hiện tại!", 16753920, fields, config.WebhookUrl)
    end

    -- Telegram Bot
    if config.TelegramEnabled and config.TelegramNotifyNPC and config.TelegramBotToken and #config.TelegramBotToken > 0 and config.TelegramChatId and #config.TelegramChatId > 0 then
        local teleText = "📜 *PHÁT HIỆN " .. tostring(npcName):upper() .. "!*\n\n"
            .. "🎯 *NPC:* " .. tostring(npcName) .. "\n"
            .. "👤 *Người tìm thấy:* " .. playerName .. "\n"
            .. "📍 *Tọa độ:* " .. posStr .. "\n"
            .. "🔑 *Job ID:* `" .. (jobId ~= "" and jobId or "N/A") .. "`\n"
            .. "⏰ *Thời gian:* " .. timeStr .. "\n\n"
            .. "⚡ *Code vào server:*\n`game:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. placeId .. ", \"" .. jobId .. "\", game.Players.LocalPlayer)`"
        Utils.SendTelegramMessage(config.TelegramBotToken, config.TelegramChatId, teleText)
    end
end

-- 7. Queue Script On Teleport & ServerHop
function Utils.QueueScriptOnTeleport()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot([[loadstring(game:HttpGet("https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/loader_v2.lua"))()]])
        end)
    end
end

function Utils.ServerHop(avoidServers)
    Utils.ShowNotification("Đổi Server", "Đang tìm kiếm server phù hợp...", "WARN")
    Utils.QueueScriptOnTeleport()
    task.spawn(function()
        local placeId = game.PlaceId
        local avoidMap = {}
        if avoidServers and type(avoidServers) == "table" then
            for _, sid in ipairs(avoidServers) do avoidMap[sid] = true end
        end
        avoidMap[game.JobId] = true

        local cursor = ""
        local candidates = {}
        for page = 1, 4 do
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s", placeId, cursor ~= "" and ("&cursor=" .. cursor) or "")
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if ok and res then
                local bOk, body = pcall(function() return HttpService:JSONDecode(res) end)
                if bOk and body and body.data then
                    for _, s in ipairs(body.data) do
                        if s.playing and s.maxPlayers and s.id and not avoidMap[s.id] then
                            local free = s.maxPlayers - s.playing
                            if free >= 2 then
                                table.insert(candidates, s.id)
                            end
                        end
                    end
                    if #candidates >= 5 then break end
                    cursor = body.nextPageCursor or ""
                    if not cursor or cursor == "" then break end
                end
            end
            task.wait(0.15)
        end

        local TeleportService = Services.TeleportService
        local chosen = (#candidates > 0 and candidates[math.random(1, #candidates)]) or nil
        if chosen then
            Utils.ShowNotification("Đổi Server", "Đã tìm thấy server mới! Đang chuyển...", "SUCCESS", 3)
            task.wait(0.5)
            local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, chosen, LocalPlayer) end)
            if not ok then
                pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
            end
            return
        end
        Utils.ShowNotification("Đổi Server", "Đang chuyển sang server ngẫu nhiên...", "INFO", 3)
        task.wait(0.5)
        pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
    end)
end

return Utils
