--[[
    v2/ui/theme.lua
    Premium Visual Theme, Color Palette & Styles for Identical Hub V2
--]]

local Theme = {
    -- Backgrounds & Panels
    MainBg = Color3.fromRGB(15, 17, 23),
    SidebarBg = Color3.fromRGB(11, 13, 18),
    CardBg = Color3.fromRGB(22, 25, 35),
    CardBgHover = Color3.fromRGB(28, 32, 45),
    RowBg = Color3.fromRGB(18, 21, 29),
    RowBgHover = Color3.fromRGB(24, 28, 38),

    -- Accents & Highlights
    Accent = Color3.fromRGB(0, 168, 255),
    AccentGlow = Color3.fromRGB(0, 140, 220),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Danger = Color3.fromRGB(231, 76, 60),

    -- Text & Typography
    TextPrimary = Color3.fromRGB(245, 247, 250),
    TextSecondary = Color3.fromRGB(160, 168, 185),
    TextMuted = Color3.fromRGB(105, 115, 134),

    -- Borders & Separators
    Border = Color3.fromRGB(35, 40, 55),
    BorderFocus = Color3.fromRGB(0, 168, 255),

    -- Fonts
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontRegular = Enum.Font.Gotham
}

return Theme
