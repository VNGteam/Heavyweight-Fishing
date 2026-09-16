--[[
    v2/ui/tabs/tab_visuals.lua
    Exact Tab ESP & Đồ Hoạ from backup.lua (Fish Rings, ESP Entities & Lighting)
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Visuals = require(script.Parent.Parent.Parent.features.visuals)

local TabVisuals = {}

function TabVisuals.Render(parent)
    Components.CreateCategoryHeader(parent, "ESP Định Vị Mục Tiêu")
    local cardEsp = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardEsp, "Vòng Tròn Định Vị Cá", "Vẽ vòng định vị cá dưới nước theo độ hiếm", Config.FishRedRing, function(v) Config.FishRedRing = v end)
    Components.CreateToggleRow(cardEsp, "Hiện Cân Nặng & Đột Biến Trên Vòng Đỏ", "Hiển thị chi tiết cân nặng kg và dạng đột biến", Config.ShowFishWeightRing, function(v) Config.ShowFishWeightRing = v end)
    Components.CreateToggleRow(cardEsp, "ESP Người Chơi", "Định vị người chơi khác trong server", Config.ESP_Players, function(v) Config.ESP_Players = v end)
    Components.CreateToggleRow(cardEsp, "ESP Trùm Boss", "Định vị vị trí xuất hiện Boss", Config.ESP_Boss, function(v) Config.ESP_Boss = v end)
    Components.CreateToggleRow(cardEsp, "ESP Cần Câu Bí Mật", "Hiện vị trí các cần câu ẩn trên bản đồ", Config.ESP_SecretRod, function(v) Config.ESP_SecretRod = v end)
    Components.CreateToggleRow(cardEsp, "ESP Thuyền Bè", "Hiện vị trí tất cả thuyền xung quanh", Config.ESP_Boats, function(v) Config.ESP_Boats = v end)
    Components.CreateToggleRow(cardEsp, "ESP Thần Linh (God Spirit)", "Định vị Thần Linh", Config.ESP_GodSpirit, function(v) Config.ESP_GodSpirit = v end)
    Components.CreateToggleRow(cardEsp, "ESP Đạo Sĩ (Taoist)", "Định vị NPC Đạo Sĩ", Config.ESP_Taoist, function(v) Config.ESP_Taoist = v end)
    Components.CreateToggleRow(cardEsp, "ESP Maoshan", "Định vị NPC Mao Sơn", Config.ESP_Maoshan, function(v) Config.ESP_Maoshan = v end)
    Components.CreateToggleRow(cardEsp, "Ẩn Tên Mặc Định Người Chơi", "Ẩn toàn bộ bảng tên, danh hiệu và thanh máu trên đầu của người chơi khác", Config.HideOverheadNames, function(v)
        Config.HideOverheadNames = v
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.DisplayDistanceType = v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
                end
                for _, d in ipairs(p.Character:GetDescendants()) do
                    if d:IsA("BillboardGui") and d.Name:sub(1, 4) ~= "ESP_" then
                        d.Enabled = not v
                    end
                end
            end
        end
    end)

    Components.CreateCategoryHeader(parent, "Hiệu Ứng Ánh Sáng & Tối Ưu")
    local cardLighting = Components.CreateCardGroup(parent)

    Components.CreateToggleRow(cardLighting, "Sáng Màn Hình (Fullbright)", "Làm sáng toàn bản đồ, nhìn rõ dưới nước sâu", Config.Fullbright, function(v)
        Config.Fullbright = v
        Visuals.ApplyFullbright(v)
    end)
    Components.CreateToggleRow(cardLighting, "Tầm Nhìn Xa (Xóa Mờ Map)", "Tắt hiệu ứng làm mờ xa (DepthOfField) & sương mù, nhìn rõ mọi hòn đảo từ xa", Config.ClearFarVision, function(v)
        Config.ClearFarVision = v
        Visuals.ApplyClearVision(v or Config.NoFog)
    end)
    Components.CreateToggleRow(cardLighting, "Xóa Sương Mù & Mưa Bão", "Xóa sạch sương mù và mưa bão che khuất tầm nhìn", Config.NoFog, function(v)
        Config.NoFog = v
        Visuals.ApplyClearVision(v or Config.ClearFarVision)
    end)
    Components.CreateToggleRow(cardLighting, "Chế Độ Giảm Lag (Low GFX)", "Giảm đồ họa giúp máy yếu chạy mượt", Config.PerformanceMode, function(v) Config.PerformanceMode = v end)
    Components.CreateToggleRow(cardLighting, "Ẩn Giao Diện Gốc Của Game", "Ẩn các thanh UI mặc định của game để thoáng màn hình", Config.HideGameUI, function(v) Config.HideGameUI = v end)
end

return TabVisuals
