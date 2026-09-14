--[[
    v2/combo/tracker.lua
    Accurate Skill Cooldown Tracking & Animation Detection
--]]

local Services = require(script.Parent.Parent.core.services)
local LocalPlayer = Services.LocalPlayer

local Tracker = {}

-- 1. Default Base Cooldowns for Heavyweight Fishing skills
Tracker.defaultCooldowns = {
    Z = 2.5,
    X = 3.0,
    C = 5.0,
    V = 4.0
}

Tracker.usedTimes = {
    Z = 0,
    X = 0,
    C = 0,
    V = 0
}

Tracker.lastCastTime = 0

-- 2. Record Skill Used
function Tracker.RecordSkillUsed(key)
    if not key then return end
    local cleanKey = key:match("([ZXCVzxcv])") or key
    cleanKey = cleanKey:upper()
    local now = tick()
    Tracker.usedTimes[cleanKey] = now
    Tracker.lastCastTime = now
end

-- 3. Check if a skill is ready to be cast
function Tracker.IsSkillReady(key, fUI)
    if not key or key == "" or key == "Tắt" then return false end
    local cleanKey = key:match("([ZXCVzxcv])") or key
    cleanKey = cleanKey:upper()

    local now = tick()
    local lastUsed = Tracker.usedTimes[cleanKey] or 0
    local minCD = Tracker.defaultCooldowns[cleanKey] or 2.5

    -- 1. Kiểm tra mốc thời gian cooldown máy khách
    if (now - lastUsed < minCD) then
        return false
    end

    -- 2. Kiểm tra giao diện người dùng fUI (nếu có)
    if fUI then
        for _, desc in ipairs(fUI:GetDescendants()) do
            local nameUpper = desc.Name:upper()
            if nameUpper == cleanKey or (nameUpper:find("SKILL") and nameUpper:find(cleanKey)) or (nameUpper:find("SLOT") and nameUpper:find(cleanKey)) then
                if desc:GetAttribute("OnCooldown") == true or desc:GetAttribute("CD") == true then
                    return false
                end
                for _, child in ipairs(desc:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Visible and child.Text ~= "" then
                        local cName = child.Name:lower()
                        local txt = child.Text
                        if not cName:find("dmg") and not cName:find("damage") and not cName:find("power") and not cName:find("level") and not cName:find("name") then
                            local cdWithS = txt:match("^%s*(%d+%.?%d*)%s*[sS]%s*$") or txt:match("^%s*(%d+%.?%d*)%s*sec%s*$")
                            if cdWithS then
                                local num = tonumber(cdWithS)
                                if num and num > 0 and num <= 999 then
                                    return false
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return true
end

-- 4. Detect whether character is currently playing an attack skill animation
function Tracker.IsCharacterCastingSkill()
    local now = tick()
    if (now - Tracker.lastCastTime > 0.7) then
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end

    for _, att in ipairs({"UsingSkill", "SkillActive", "IsAttacking", "CastingSkill"}) do
        if char:GetAttribute(att) == true then
            return true
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local anim = hum and hum:FindFirstChildOfClass("Animator")
    if anim then
        local ok, tracks = pcall(function() return anim:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, tr in ipairs(tracks) do
                if tr.IsPlaying and (tr.Priority == Enum.AnimationPriority.Action or tr.Priority == Enum.AnimationPriority.Action2 or tr.Priority == Enum.AnimationPriority.Action3 or tr.Priority == Enum.AnimationPriority.Action4) then
                    local animName = tr.Name:lower()
                    if not animName:find("fish") and not animName:find("rod") and not animName:find("reel") and not animName:find("cast") and not animName:find("idle") and not animName:find("hold") and not animName:find("walk") and not animName:find("run") then
                        if animName:find("skill") or animName:find("attack") or animName:find("special") or animName:find("slash") then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

function Tracker.Reset()
    Tracker.lastCastTime = 0
    for k in pairs(Tracker.usedTimes) do
        Tracker.usedTimes[k] = 0
    end
end

return Tracker
