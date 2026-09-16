--[[
    v2/features/spoof.lua
    Visual Spoofing (Ảo Hoá Hiển Thị) Gems & Tickets
--]]

local Services = require(script.Parent.Parent.core.services)
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer = Services.LocalPlayer
local HttpService = Services.HttpService
local Utils = require(script.Parent.Parent.core.utils)

local Spoof = {}

Spoof.fakeTicket = 0
Spoof.fakeGems = 0
Spoof.hookedGemLabels = {}

function Spoof.FormatWithSpaces(num)
    if not num then return "0" end
    local s = tostring(math.floor(math.abs(num)))
    local res = ""
    local len = #s
    for i = 1, len do
        res = res .. s:sub(i, i)
        if (len - i) % 3 == 0 and i ~= len then
            res = res .. " "
        end
    end
    return (num < 0 and "-" or "") .. res
end

function Spoof.GetFileName()
    local accName = (LocalPlayer and LocalPlayer.Name) or "Default"
    local safeAcc = accName:gsub("[^%w_]", "")
    if #safeAcc == 0 then safeAcc = "Default" end
    return "heavyweight_visual_spoof_" .. safeAcc .. ".json"
end

function Spoof.Save()
    if not writefile then return end
    pcall(function()
        local data = {
            fakeTicket = Spoof.fakeTicket or 0,
            fakeGems = Spoof.fakeGems or 0,
        }
        writefile(Spoof.GetFileName(), HttpService:JSONEncode(data))
    end)
end

function Spoof.Load()
    local fileName = Spoof.GetFileName()
    if not (readfile and isfile and isfile(fileName)) then return end
    pcall(function()
        local raw = readfile(fileName)
        if raw and #raw > 0 then
            local dec = HttpService:JSONDecode(raw)
            if type(dec) == "table" then
                if dec.fakeTicket and tonumber(dec.fakeTicket) then
                    Spoof.fakeTicket = tonumber(dec.fakeTicket)
                end
                if dec.fakeGems and tonumber(dec.fakeGems) then
                    Spoof.fakeGems = tonumber(dec.fakeGems)
                end
            end
        end
    end)
end

function Spoof.UpdateTextLabelWithGems(label, gNum)
    if not label or not label:IsA("TextLabel") then return end
    local oldText = label.Text
    local formatted = Spoof.FormatWithSpaces(gNum)

    if oldText:find("💎") then
        if oldText:find("^%s*💎") then
            label.Text = "💎 " .. formatted
        elseif oldText:find("💎%s*$") then
            label.Text = formatted .. " 💎"
        else
            label.Text = "💎 " .. formatted
        end
    elseif oldText:find("🔷") then
        label.Text = "🔷 " .. formatted
    elseif oldText:lower():find("gem") then
        if oldText:find(":") then
            label.Text = "Gems: " .. formatted
        else
            label.Text = formatted .. " Gems"
        end
    elseif oldText:lower():find("diamond") then
        label.Text = formatted .. " Diamonds"
    else
        label.Text = formatted
    end
end

function Spoof.HookGemLabel(label, gNum)
    if Spoof.hookedGemLabels[label] then return end
    Spoof.hookedGemLabels[label] = true
    pcall(function()
        label:GetPropertyChangedSignal("Text"):Connect(function()
            if Spoof.fakeGems and Spoof.fakeGems > 0 then
                local targetText = Spoof.FormatWithSpaces(Spoof.fakeGems)
                if not label.Text:find(targetText, 1, true) then
                    task.defer(function()
                        if Spoof.fakeGems and Spoof.fakeGems > 0 then
                            Spoof.UpdateTextLabelWithGems(label, Spoof.fakeGems)
                        end
                    end)
                end
            end
        end)
    end)
end

function Spoof.ScanPlayerGuiGems(gNum)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    for _, desc in ipairs(pg:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Visible then
            local selfName = desc.Name:lower()
            local pName = desc.Parent and desc.Parent.Name:lower() or ""
            local isGem = false

            if selfName:find("gem") or selfName:find("diamond") or selfName:find("ruby") or selfName:find("da_quy") then
                isGem = true
            elseif pName:find("gem") or pName:find("diamond") or pName:find("ruby") or pName:find("currency2") then
                isGem = true
            end

            if isGem then
                Spoof.UpdateTextLabelWithGems(desc, gNum)
                Spoof.HookGemLabel(desc, gNum)
            end
        end
    end
end

function Spoof.ScanPlayerDataGems(gNum)
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if pData then
        for _, gName in ipairs({"Gem", "Gems", "Diamond", "Diamonds", "Ruby", "Currency2"}) do
            local item = pData:FindFirstChild(gName)
            if item and item:IsA("ValueBase") then
                pcall(function()
                    item.Value = gNum
                    item.Changed:Connect(function(v)
                        if Spoof.fakeGems and Spoof.fakeGems > 0 and v ~= Spoof.fakeGems then
                            task.defer(function()
                                if Spoof.fakeGems and Spoof.fakeGems > 0 then
                                    item.Value = Spoof.fakeGems
                                end
                            end)
                        end
                    end)
                end)
            end
        end
    end

    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        for _, gName in ipairs({"Gem", "Gems", "Diamond", "Diamonds"}) do
            local nv = ls:FindFirstChild(gName)
            if nv and nv:IsA("ValueBase") then
                pcall(function()
                    nv.Value = gNum
                end)
            end
        end
    end
end

function Spoof.Apply(isReset)
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local pg = LocalPlayer:FindFirstChild("PlayerGui")

    -- 1. Spoof Tickets
    if Spoof.fakeTicket and Spoof.fakeTicket > 0 and not isReset then
        local num = Spoof.fakeTicket
        if pData then
            local tObj = pData:FindFirstChild("Ticket") or pData:FindFirstChild("Tickets")
            if tObj and tObj:IsA("ValueBase") then
                pcall(function() tObj.Value = num end)
            end
        end
        if ls then
            local lsT = ls:FindFirstChild("Ticket") or ls:FindFirstChild("Tickets")
            if lsT and lsT:IsA("ValueBase") then
                pcall(function() lsT.Value = num end)
            end
        end
        if pg then
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextLabel") and d.Visible then
                    local sLow = d.Name:lower()
                    local pLow = d.Parent and d.Parent.Name:lower() or ""
                    if sLow:find("ticket") or pLow:find("ticket") then
                        if d.Text:match("^[%d%s,%.]+$") or d.Text:find("Vé") or d.Text:find("Ticket") then
                            d.Text = Spoof.FormatWithSpaces(num)
                        end
                    end
                end
            end
        end
    end

    -- 2. Spoof Gems
    if Spoof.fakeGems and Spoof.fakeGems > 0 and not isReset then
        local gNum = Spoof.fakeGems
        Spoof.ScanPlayerDataGems(gNum)
        Spoof.ScanPlayerGuiGems(gNum)
    end
end

function Spoof.Hook()
    local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
    if not pData then return end

    local tObj = pData:FindFirstChild("Ticket") or pData:FindFirstChild("Tickets")
    if tObj and tObj:IsA("ValueBase") then
        pcall(function()
            tObj.Changed:Connect(function(newVal)
                if Spoof.fakeTicket and Spoof.fakeTicket > 0 and newVal ~= Spoof.fakeTicket then
                    task.defer(function()
                        if Spoof.fakeTicket and Spoof.fakeTicket > 0 then
                            tObj.Value = Spoof.fakeTicket
                        end
                    end)
                end
            end)
        end)
    end

    if Spoof.fakeGems and Spoof.fakeGems > 0 then
        Spoof.ScanPlayerDataGems(Spoof.fakeGems)
        Spoof.ScanPlayerGuiGems(Spoof.fakeGems)
    end
end

pcall(Spoof.Load)
pcall(Spoof.Hook)

return Spoof
