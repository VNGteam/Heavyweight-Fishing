--[[
    v2/ui/tabs/tab_thu_nghiem.lua
    Tab Thử Nghiệm: Tự Động Tẩy Luyện Trait (Auto Reroll & Lock Trait)
--]]

local Components = require(script.Parent.Parent.components)
local ConfigModule = require(script.Parent.Parent.Parent.core.config)
local Config = ConfigModule.Config
local Services = require(script.Parent.Parent.Parent.core.services)
local ReplicatedStorage = Services.ReplicatedStorage
local Events = Services.Events
local LocalPlayer = Services.LocalPlayer
local Utils = require(script.Parent.Parent.Parent.core.utils)

local TabThuNghiem = {}

function TabThuNghiem.Render(parent)
    -- 🎯 TỰ ĐỘNG TẨY LUYỆN TRAIT (AUTO REROLL & LOCK TRAIT)
    Components.CreateCategoryHeader(parent, "🎯 TỰ ĐỘNG TẨY LUYỆN TRAIT (AUTO REROLL & LOCK TRAIT)")
    local traitCard = Components.CreateCardGroup(parent)

    local traitList = {
        "Azure Dragon", "White Tiger", "Vermilion Bird", "Black Tortoise",
        "Assassin", "Berserk", "Chrono", "Executioner", "Powerful",
        "Precision", "Rapid", "Sharp", "Swift"
    }

    Components.CreateDropdownRow(traitCard, "Chọn Trait Cần Săn", "Trait mục tiêu bot sẽ tự động roll cho đến khi trúng", traitList, Config.TargetTraitName or traitList[1], function(v)
        Config.TargetTraitName = v
    end)

    local infoTraitRerolls = Components.CreateInfoRow(traitCard, "Vé Reroll Hiện Có", "Đang tải...")
    local function UpdateTraitRerollInfo()
        local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
        local count = pData and pData:FindFirstChild("Trait Reroll") and pData["Trait Reroll"].Value or 0
        if infoTraitRerolls and infoTraitRerolls.Set then
            infoTraitRerolls.Set(string.format("%d Vé", count))
        end
    end
    task.spawn(UpdateTraitRerollInfo)

    local isAutoRerolling = false
    local function RunAutoRerollTrait()
        if isAutoRerolling then return end
        isAutoRerolling = true
        task.spawn(function()
            local pData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild(tostring(LocalPlayer.UserId))
            Utils.ShowNotification("Reroll Trait", "Bắt đầu tự động Reroll săn Trait: " .. tostring(Config.TargetTraitName), "INFO", 4)

            while isAutoRerolling and Config.AutoRerollTrait do
                local currentRerolls = pData and pData:FindFirstChild("Trait Reroll") and pData["Trait Reroll"].Value or 0
                UpdateTraitRerollInfo()

                if currentRerolls <= 0 then
                    Utils.ShowNotification("Hết Vé", "Đã hết vé Reroll Trait!", "WARN", 5)
                    Config.AutoRerollTrait = false
                    isAutoRerolling = false
                    break
                end

                if Events and Events:FindFirstChild("RerollTrait") then
                    local res = Events.RerollTrait:InvokeServer()
                    local targetLower = tostring(Config.TargetTraitName or ""):lower()
                    local isHit = false

                    if type(res) == "string" and res:lower():find(targetLower, 1, true) then
                        isHit = true
                    end

                    if not isHit and pData and pData:FindFirstChild("LockTrait") then
                        local tVal = pData.LockTrait:FindFirstChild(Config.TargetTraitName)
                        if tVal and tVal.Value == true then
                            isHit = true
                        end
                    end

                    if isHit then
                        Utils.ShowNotification("TRÚNG TRAIT!", string.format("Đã roll trúng [%s]! Tự động khóa bảo vệ ngay lập tức.", Config.TargetTraitName), "SUCCESS", 8)
                        if Events:FindFirstChild("LockTrait") then
                            Events.LockTrait:FireServer(Config.TargetTraitName)
                        end
                        Config.AutoRerollTrait = false
                        isAutoRerolling = false
                        break
                    end
                end
                task.wait(0.35)
            end
            isAutoRerolling = false
            UpdateTraitRerollInfo()
        end)
    end

    Components.CreateToggleRow(traitCard, "Tự Động Reroll Đến Khi Trúng", "Tự động roll liên tục và khóa lại khi ra đúng Trait mục tiêu", Config.AutoRerollTrait, function(v)
        Config.AutoRerollTrait = v
        if v then
            RunAutoRerollTrait()
        else
            isAutoRerolling = false
        end
    end)

    Components.CreateButtonRow(traitCard, "Reroll 1 Lần Thủ Công", "Thực hiện roll trait 1 lần ngay lập tức", "Reroll 1 Lần", function()
        if Events and Events:FindFirstChild("RerollTrait") then
            local res = Events.RerollTrait:InvokeServer()
            UpdateTraitRerollInfo()
            Utils.ShowNotification("Reroll Trait", "Kết quả roll: " .. tostring(res or "Đã roll thành công"), "INFO", 4)
        end
    end)

    Components.CreateButtonRow(traitCard, "Khóa / Mở Khóa Trait Đang Chọn", "Chuyển đổi trạng thái khóa bảo vệ cho Trait đang chọn", "Khóa / Mở", function()
        if Events and Events:FindFirstChild("LockTrait") then
            Events.LockTrait:FireServer(Config.TargetTraitName)
            Utils.ShowNotification("Khóa Trait", "Đã gửi lệnh đổi trạng thái khóa cho: " .. tostring(Config.TargetTraitName), "SUCCESS", 3)
        end
    end)
end

return TabThuNghiem
