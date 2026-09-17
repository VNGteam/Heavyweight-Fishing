--[[
    ==================================================================
    🚀 IDENTICAL LOADER V2.8.7 - SMART DUAL-SOURCE LOADER
    ==================================================================
    - Thử local.lua (100% tính năng) trước.
    - Nếu executor không biên dịch được (size limit/Xeno), tự động
      fallback sang v2_bundle.lua mà không cần làm gì thêm.
    - Đa tầng CDN chống nghẽn mạng. Anti-Cache luôn tải bản mới.
--]]

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Identical Hub",
            Text  = text  or "",
            Duration = duration or 4
        })
    end)
end

local antiCache = tostring(math.floor(tick())) .. tostring(math.random(1000,9999))

local SOURCES_FULL = {
    { url="https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/local.lua?t="..antiCache },
    { url="https://cdn.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/local.lua?t="..antiCache },
    { url="https://fastly.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/local.lua?t="..antiCache },
}
local SOURCES_LITE = {
    { url="https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/v2_bundle.lua?t="..antiCache },
    { url="https://cdn.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/v2_bundle.lua?t="..antiCache },
    { url="https://fastly.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/v2_bundle.lua?t="..antiCache },
}

local function IsValid(content, minSize)
    if not content or type(content) ~= "string" then return false end
    if #content < (minSize or 20000) then return false end
    if not content:find("pcall") or not content:find("game") then return false end
    if content:find("API rate limit") then return false end
    return true
end

local function Fetch(sources, minSize)
    for _, src in ipairs(sources) do
        local ok, res = pcall(function() return game:HttpGet(src.url, true) end)
        if ok and IsValid(res, minSize) then return res end
        task.wait(0.15)
    end
    return nil
end

local function Shrink(src)
    local out = {}
    for line in src:gmatch("([^\r\n]*)\r?\n?") do
        local t = line:match("^%s*(.-)%s*$")
        if t ~= "" and not t:match("^%-%-[^%[]") and not t:match("^%-%-$") then
            table.insert(out, t)
        end
    end
    return table.concat(out, "\n")
end

local function TryCompile(code)
    local shrunk
    pcall(function() shrunk = Shrink(code) end)
    local variants = {}
    if shrunk and #shrunk > 10000 then table.insert(variants, shrunk) end
    table.insert(variants, code)
    for _, v in ipairs(variants) do
        local ok, fn = pcall(loadstring, v)
        if ok and type(fn) == "function" then return fn end
    end
    return nil
end

-- === MAIN ===
Notify("Cau Ca Pro", "Dang tai script (v2.8.7)...", 3)

-- Buoc 1: Thu local.lua (100% tinh nang)
local full = Fetch(SOURCES_FULL, 50000)
if full then
    local fn = TryCompile(full)
    if fn then
        Notify("Cau Ca Pro", "Full Version - 100% tinh nang!", 3)
        local ok, err = pcall(fn)
        if not ok then Notify("Loi Chay!", tostring(err):sub(1,120), 12) end
        return
    end
    warn("[Loader] local.lua compile failed - falling back to v2_bundle.lua")
    Notify("Cau Ca Pro", "Executor gioi han kich thuoc. Dang chuyen Lite...", 3)
else
    warn("[Loader] Cannot fetch local.lua")
end

task.wait(0.3)

-- Buoc 2: Fallback v2_bundle.lua
local lite = Fetch(SOURCES_LITE, 20000)
if lite then
    local fn = TryCompile(lite)
    if fn then
        Notify("Cau Ca Pro", "Lite Version - dang chay!", 3)
        local ok, err = pcall(fn)
        if not ok then Notify("Loi Chay!", tostring(err):sub(1,120), 12) end
    else
        Notify("Loi Bien Dich!", "Ca 2 ban deu that bai. Thu executor khac.", 15)
    end
else
    Notify("Loi Mang!", "Kiem tra ket noi mang hoac VPN.", 10)
end
