--[[
    ==================================================================
    🚀 IDENTICAL LOADER V2.5.5 - SIÊU TỐC & CHỐNG CACHE 100% (ULTRA-FAST)
    ==================================================================
    - Tự động bỏ qua Cache của Executor và GitHub CDN (Anti-Cache Query + Headers).
    - Biên dịch trực tiếp 0ms (Zero latency compile), không delay xử lý chuỗi.
    - Đa tầng CDN dự phòng (GitHub Raw, jsDelivr, Fastly).
--]]

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Identical V2",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

local antiCacheKey = tostring(math.floor(tick())) .. "_" .. tostring(math.random(10000, 99999))

local SCRIPT_SOURCES = {
    -- Nguồn 1: GitHub Raw kèm Anti-Cache dynamic parameter
    {
        name = "GitHub Raw (Mới Nhất)",
        url = "https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/v2_bundle.lua?t=" .. antiCacheKey
    },
    -- Nguồn 2: jsDelivr Edge CDN (kèm purge timestamp)
    {
        name = "jsDelivr CDN",
        url = "https://cdn.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/v2_bundle.lua?t=" .. antiCacheKey
    },
    -- Nguồn 3: Fastly Edge CDN
    {
        name = "Fastly CDN",
        url = "https://fastly.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/v2_bundle.lua?t=" .. antiCacheKey
    }
}

local function IsValidLuaScript(content)
    if not content or type(content) ~= "string" then return false end
    if #content < 20000 then return false end
    if not content:find("pcall") or not content:find("game") then return false end
    if content:sub(1, 10) == "{\"message\"" or content:find("API rate limit") then return false end
    return true
end

-- Tải mã nguồn với hỗ trợ Header chống Cache chuyên sâu của Executor
local function HttpGetNoCache(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok, res = pcall(function()
            return req({
                Url = url,
                Method = "GET",
                Headers = {
                    ["Cache-Control"] = "no-cache, no-store, must-revalidate",
                    ["Pragma"] = "no-cache",
                    ["Expires"] = "0"
                }
            })
        end)
        if ok and res and res.Body and IsValidLuaScript(res.Body) then
            return true, res.Body
        end
    end

    -- Fallback sang game:HttpGet chuẩn
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and IsValidLuaScript(res) then
        return true, res
    end

    return false, nil
end

local function FetchScript()
    for _, source in ipairs(SCRIPT_SOURCES) do
        local ok, content = HttpGetNoCache(source.url)
        if ok and content then
            return true, content, source.name
        end
        task.wait(0.1)
    end

    -- Fallback cuối cùng: GitHub REST API
    local apiOk, apiResult = pcall(function()
        return game:HttpGet("https://api.github.com/repos/VNGteam/Heavyweight-Fishing/contents/v2_bundle.lua?t=" .. antiCacheKey, true)
    end)
    if apiOk and apiResult and #apiResult > 1000 then
        local decOk, decoded = pcall(function()
            local HttpService = game:GetService("HttpService")
            local data = HttpService:JSONDecode(apiResult)
            if data and data.content then
                local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
                local b64 = data.content:gsub("[^"..b64chars.."=]", "")
                local res = {}
                local pad = b64:sub(-2) == "==" and 2 or (b64:sub(-1) == "=" and 1 or 0)
                b64 = b64:gsub("=", "A")
                for i = 1, #b64, 4 do
                    local n = (b64chars:find(b64:sub(i,i))-1) * 262144
                            + (b64chars:find(b64:sub(i+1,i+1))-1) * 4096
                            + (b64chars:find(b64:sub(i+2,i+2))-1) * 64
                            + (b64chars:find(b64:sub(i+3,i+3))-1)
                    table.insert(res, string.char(
                        math.floor(n / 65536) % 256,
                        math.floor(n / 256) % 256,
                        n % 256
                    ))
                end
                local out = table.concat(res)
                return out:sub(1, #out - pad)
            end
        end)
        if decOk and IsValidLuaScript(decoded) then
            return true, decoded, "GitHub API"
        end
    end

    return false, "Không thể tải mã nguồn V2! Vui lòng kiểm tra lại kết nối mạng."
end

-- Khởi động nạp siêu tốc
Notify("Identical V2", "⚡ Đang nạp bản V2 mới nhất (Chống Cache)...", 3)

local ok, content, sourceName = FetchScript()
if ok and content then
    -- Biên dịch trực tiếp 0ms không qua loop xử lý chuỗi
    local fn, compileErr = loadstring(content)
    if fn then
        local runOk, runErr = pcall(fn)
        if not runOk then
            warn("[Identical V2] Lỗi chạy code:", runErr)
            Notify("❌ Lỗi Chạy Script V2!", tostring(runErr):sub(1, 100), 12)
        end
    else
        warn("[Identical V2] Lỗi biên dịch code:", compileErr)
        Notify("❌ Lỗi Biên Dịch V2!", tostring(compileErr):sub(1, 100), 12)
    end
else
    warn("[Identical V2] Thất bại khi nạp code:", content)
    Notify("❌ Lỗi Mạng V2!", tostring(content):sub(1, 100), 8)
end
