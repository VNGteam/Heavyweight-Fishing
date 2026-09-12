--[[
    ============================================================================
    🔍 PLAYER DATA & OBJECT INSPECTOR - LOADER
    GitHub: https://github.com/VNGteam/Heavyweight-Fishing
    Raw Script: https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/find/debug.lua
    ============================================================================
]]

local SCRIPT_URL = "https://raw.githubusercontent.com/VNGteam/Heavyweight-Fishing/main/find/debug.lua"

local function LoadInspector()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔍 Player Inspector",
            Text = "Đang tải Player Data Inspector...",
            Duration = 3
        })
    end)

    -- Anti-cache parameter để luôn lấy bản mới nhất
    local url = SCRIPT_URL .. "?t=" .. tostring(tick())
    local success, content = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success or not content or #content == 0 then
        -- Fallback URL không kèm query string
        success, content = pcall(function()
            return game:HttpGet(SCRIPT_URL, true)
        end)
    end

    if success and content and #content > 0 then
        local runSuccess, runError = pcall(function()
            loadstring(content)()
        end)

        if not runSuccess then
            warn("[Inspector Loader] Lỗi thực thi script:", runError)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "❌ Lỗi Thực Thi",
                    Text = tostring(runError):sub(1, 100),
                    Duration = 10
                })
            end)
        else
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "✅ Loaded!",
                    Text = "Bấm F4 để mở/đóng UI Inspector",
                    Duration = 4
                })
            end)
        end
    else
        warn("[Inspector Loader] Không thể tải script từ GitHub. Kiểm tra kết nối mạng hoặc link raw.")
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Lỗi Tải Script",
                Text = "Không thể tải từ GitHub!",
                Duration = 5
            })
        end)
    end
end

LoadInspector()
