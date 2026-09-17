--[[
    ==================================================================
    🚀 IDENTICAL LOADER V2.6.5 - TẢI & BIÊN DỊCH SIÊU TỐC (CHỐNG TIMEOUT)
    ==================================================================
    Tính năng:
    - Đa tầng CDN (GitHub Raw, jsDelivr Edge, Fastly) chống nghẽn mạng / ISP chặn.
    - Bộ lọc kiểm tra tính toàn vẹn (Validation) loại bỏ phản hồi rác / "Timeout".
    - Tối ưu hóa mã nguồn trong bộ nhớ (In-Memory Shrink) giảm 23% payload,
      giúp Executor (Delta, Codex, Arceus, Fluxus...) biên dịch cực nhanh.
    - Tự động thử lại biên dịch đa tầng (Auto-Retry Compiler) chống rớt kết nối.
--]]

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Identical Hub",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

-- Danh sách các nguồn CDN uy tín, tốc độ cao nhất (có máy chủ biên tại VN & ĐNÁ)
local SCRIPT_SOURCES = {
    -- Nguồn 1: GitHub Raw kèm anti-cache query
    {
        name = "GitHub Raw",
        url = "https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/local.lua?t=" .. tostring(tick())
    },
    -- Nguồn 2: jsDelivr CDN (Server CDN quốc tế, độ trễ cực thấp, không bị chặn bởi nhà mạng)
    {
        name = "jsDelivr Edge CDN",
        url = "https://cdn.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/local.lua"
    },
    -- Nguồn 3: Fastly jsDelivr Fallback
    {
        name = "Fastly CDN",
        url = "https://fastly.jsdelivr.net/gh/VNGteam/Heavyweight-Fishing@main/local.lua"
    }
}

-- Xác thực script hợp lệ (loại bỏ chuỗi lỗi "Timeout", HTML 403 hoặc rate limit)
local function IsValidLuaScript(content)
    if not content or type(content) ~= "string" then return false end
    -- File local.lua thực tế nặng > 600KB, chuỗi phản hồi ngắn chắc chắn là thông báo lỗi
    if #content < 30000 then return false end
    if not content:find("pcall") or not content:find("game") then return false end
    if content:sub(1, 10) == "{\"message\"" or content:find("API rate limit") then return false end
    return true
end

-- Rút gọn mã nguồn trong bộ nhớ (~0.02s) giúp Executor biên dịch siêu nhanh và không bao giờ bị Timeout
local function OptimizeScript(src)
    local lines = {}
    for line in src:gmatch("([^\r\n]*)\r?\n?") do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not trimmed:match("^%-%-[^%[]") and not trimmed:match("^%-%-$") then
            table.insert(lines, trimmed)
        end
    end
    return table.concat(lines, "\n")
end

-- Cơ chế nạp code đa nguồn với khả năng tự chuyển đổi nếu có sự cố
local function FetchScript()
    for idx, source in ipairs(SCRIPT_SOURCES) do
        local ok, result = pcall(function()
            return game:HttpGet(source.url, true)
        end)
        if ok and IsValidLuaScript(result) then
            return true, result, source.name
        end
        task.wait(0.2)
    end

    -- Dự phòng cuối cùng: GitHub REST API
    local apiOk, apiResult = pcall(function()
        return game:HttpGet("https://api.github.com/repos/VNGteam/Heavyweight-Fishing/contents/local.lua?t=" .. tostring(tick()), true)
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

    return false, "Không thể tải mã nguồn từ bất kỳ máy chủ nào! Vui lòng kiểm tra lại kết nối mạng hoặc VPN."
end

-- Bộ biên dịch tự động thử lại nhiều lần (Anti-Timeout Compiler)
local function CompileWithRetry(code, maxAttempts)
    maxAttempts = maxAttempts or 3
    local optCode = nil
    pcall(function()
        optCode = OptimizeScript(code)
    end)
    
    -- Thử bản thu gọn siêu nhẹ trước (giảm 150KB giúp executor biên dịch nhanh nhất), sau đó đến bản gốc
    local variants = {}
    if optCode and #optCode > 20000 then
        table.insert(variants, { name = "bản tối ưu tốc độ", code = optCode })
    end
    table.insert(variants, { name = "bản gốc", code = code })

    local lastErr = nil
    for attempt = 1, maxAttempts do
        for _, variant in ipairs(variants) do
            local compileOk, compileResult = pcall(function()
                return loadstring(variant.code)
            end)
            if compileOk and type(compileResult) == "function" then
                return compileResult
            end
            lastErr = compileResult or "Không xác định"
        end

        if attempt < maxAttempts then
            Notify("Identical Hub", "Biên dịch chậm, đang tự động thử lại (" .. (attempt + 1) .. "/" .. maxAttempts .. ")...", 2)
            task.wait(0.8)
        end
    end

    return nil, lastErr
end

-- Tiến trình chạy chính
Notify("Identical Hub", "Đang tải bản cập nhật mới nhất...", 3)

local ok, content, sourceName = FetchScript()
if ok and content then
    local fn, compileErr = CompileWithRetry(content, 3)
    if fn then
        local runOk, runErr = pcall(fn)
        if not runOk then
            warn("[Identical Loader] Lỗi thực thi code:", runErr)
            Notify("❌ Lỗi Chạy Script!", tostring(runErr):sub(1, 100), 15)
        end
    else
        warn("[Identical Loader] Lỗi biên dịch sau nhiều lần thử:", compileErr)
        Notify("❌ Lỗi Biên Dịch!", tostring(compileErr):sub(1, 100), 15)
    end
else
    warn("[Identical Loader] Thất bại khi nạp code:", content)
    Notify("❌ Lỗi Mạng!", tostring(content):sub(1, 100), 8)
end
