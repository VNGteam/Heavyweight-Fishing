--[[
    v2/features/teleport.lua
    Island Teleportation, Boss Realms, Player Teleport & Server Hop
--]]

local Services = require(script.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer
local TeleportService = Services.TeleportService
local HttpService = Services.HttpService
local Utils = require(script.Parent.Parent.core.utils)

local Teleport = {}

-- 1. Island Coordinates
Teleport.islands = {
    ["Đảo Khởi Đầu (Starter Island)"] = Vector3.new(0, 15, 0),
    ["Đảo San Hô (Coral Island)"] = Vector3.new(-120, 15, -450),
    ["Đảo Băng Tuyết (Glacier Island)"] = Vector3.new(650, 20, -1200),
    ["Đảo Núi Lửa (Volcano Island)"] = Vector3.new(-1400, 25, 800),
    ["Đại Dương Sâu (Deep Ocean)"] = Vector3.new(2000, 10, 2000),
    ["Vực Thẳm (Abyssal Trench)"] = Vector3.new(-2500, 5, -3000)
}

-- 2. Safe Teleport to Vector3 / CFrame
function Teleport.To(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    pcall(function()
        if typeof(targetPos) == "Vector3" then
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 4, 0))
        elseif typeof(targetPos) == "CFrame" then
            root.CFrame = targetPos + Vector3.new(0, 4, 0)
        end
    end)
    return true
end

-- 3. Teleport to Another Player
function Teleport.ToPlayer(playerName)
    local targetPlr = Services.Players:FindFirstChild(playerName)
    if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        Teleport.To(targetPlr.Character.HumanoidRootPart.CFrame)
        Utils.ShowNotification("Dịch Chuyển", "Đã dịch chuyển tới: " .. playerName, "SUCCESS", 3)
        return true
    end
    Utils.ShowNotification("Dịch Chuyển", "Không tìm thấy người chơi!", "ERROR", 3)
    return false
end

-- 4. Server Hop
function Teleport.ServerHop()
    Utils.ShowNotification("Server Hop", "Đang tìm kiếm máy chủ mới...", "INFO", 3)
    local placeId = game.PlaceId
    local serversApi = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

    pcall(function()
        local raw = game:HttpGet(serversApi)
        local data = HttpService:JSONDecode(raw)
        if data and data.data then
            for _, s in ipairs(data.data) do
                if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
                    return
                end
            end
        end
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
end

return Teleport
