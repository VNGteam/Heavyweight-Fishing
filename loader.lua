--[[
    ===============================================================
    🚀 IDENTICAL LOADER - LINK THỰC THI DUY NHẤT (AUTO-UPDATE)
    ===============================================================
    Cách sử dụng:
    1. Upload file `local.lua` lên GitHub Repo hoặc GitHub Gist
    2. Thay đường dẫn bên dưới vào biến SCRIPT_URL
    3. Bạn chỉ cần chạy 1 dòng loader này trong Executor (Delta, Fluxus, Hydrogen, Synapse, Wave, v.v.)
    Mỗi khi bạn sửa code và lưu lên link, game sẽ tự động tải bản mới nhất!
--]]

-- RAW URL (fallback)
local SCRIPT_URL = "https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/local.lua"

-- GitHub API URL (không bị CDN cache, luôn trả bản mới nhất)
local GITHUB_API_URL = "https://api.github.com/repos/VNGteam/Heavyweight-Fishing/contents/local.lua"

-- Base64 decode (dùng để giải mã content từ GitHub API)
local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64Decode(data)
    data = data:gsub("[^"..b64chars.."=]", "")
    local result = {}
    local pad = data:sub(-2) == "==" and 2 or (data:sub(-1) == "=" and 1 or 0)
    data = data:gsub("=", "A")
    for i = 1, #data, 4 do
        local n = (b64chars:find(data:sub(i,i))-1) * 262144
                + (b64chars:find(data:sub(i+1,i+1))-1) * 4096
                + (b64chars:find(data:sub(i+2,i+2))-1) * 64
                + (b64chars:find(data:sub(i+3,i+3))-1)
        table.insert(result, string.char(
            math.floor(n / 65536) % 256,
            math.floor(n / 256) % 256,
            n % 256
        ))
    end
    local out = table.concat(result)
    return out:sub(1, #out - pad)
end

-- Cơ chế Anti-Cache: Thử GitHub API trước (không cache), fallback về raw
local function FetchScript()
    -- Bước 1: Thử GitHub API (luôn mới nhất, không bị CDN cache)
    local apiOk, apiResult = pcall(function()
        return game:HttpGet(GITHUB_API_URL .. "?t=" .. tostring(tick()), true)
    end)
    if apiOk and apiResult and #apiResult > 100 then
        local decOk, decoded = pcall(function()
            local HttpService = game:GetService("HttpService")
            local data = HttpService:JSONDecode(apiResult)
            if data and data.content then
                -- GitHub API trả content dạng base64 (có newline \n cần xóa)
                local b64 = data.content:gsub("\n", ""):gsub("\r", "")
                return base64Decode(b64)
            end
        end)
        if decOk and decoded and #decoded > 1000 then
            return true, decoded
        end
    end

    -- Bước 2: Fallback về raw URL với anti-cache query
    local rawOk, rawResult = pcall(function()
        return game:HttpGet(SCRIPT_URL .. "?nocache=" .. tostring(math.random(1, 999999)), true)
    end)
    if rawOk and rawResult and #rawResult > 0 then
        return true, rawResult
    end

    return false, "Không thể tải script từ cả 2 nguồn!"
end

-- Hiển thị thông báo tải script
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Identical Hub",
        Text = "Đang tải bản cập nhật mới nhất...",
        Duration = 3
    })
end)

local ok, content = FetchScript()
if ok and content and #content > 0 then
    local runOk, runErr = pcall(function()
        local fn, compileErr = loadstring(content)
        if not fn then
            error("Lỗi biên dịch: " .. tostring(compileErr))
        end
        fn()
    end)
    if not runOk then
        warn("[Identical Loader] Lỗi thực thi script:", runErr)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Lỗi Chạy Script!",
                Text = tostring(runErr):sub(1, 100),
                Duration = 20
            })
        end)
    end
else
    warn("[Identical Loader] Không thể tải script từ link! Vui lòng kiểm tra lại đường dẫn SCRIPT_URL.")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Lỗi Tải Script",
            Text = "Không thể kết nối đến máy chủ lưu trữ code!",
            Duration = 5
        })
    end)
end
