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

local SCRIPT_URL = "https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/local.lua"

-- Cơ chế Anti-Cache: Thêm query ngẫu nhiên để Roblox không bao giờ nạp bản cũ
local function FetchScript(url)
    local antiCacheUrl = url .. "?t=" .. tostring(tick())
    local success, result = pcall(function()
        return game:HttpGet(antiCacheUrl, true)
    end)
    if not success or not result or #result == 0 then
        success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
    end
    return success, result
end

-- Hiển thị thông báo tải script
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Identical Hub",
        Text = "Đang tải bản cập nhật mới nhất...",
        Duration = 3
    })
end)

local ok, content = FetchScript(SCRIPT_URL)
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
