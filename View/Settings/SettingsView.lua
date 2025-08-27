-- View/Settings/StyleSettingsView.lua
local UI = require("UI/Core/Style")
local Buttons = require("UI").Buttons
local StyleConfig = require("Core/StyleConfig")

local layoutRefs = {
    optionHeight = { value = UI.Layout.OptionHeight, min = 10, max = 80 },
    paddingX = { value = UI.Layout.OptionPaddingX, min = 0, max = 65 },
    paddingY = { value = UI.Layout.OptionPaddingY, min = 0, max = 65 },
    labelOffsetX = { value = UI.Layout.LabelOffsetX, min = 0, max = 40 },
    frameRounding = { value = UI.Layout.FrameRounding, min = 0.0, max = 30.0}
}

local scrollAnimRefs = {
    scrollSpeed = { value = UI.Scroll.ScrollSpeed, min = 0.01, max = 20.0, step = 0.01 },
    smoothSpeed = { value = UI.Animation.SmoothSpeed, min = 0.01, max = 2.0, step = 0.01 } 
}

local headerFooterRefs = {
    headerHeight = { value = UI.Header.Height, min = 20, max = 120 },
    footerHeight = { value = UI.Footer.Height, min = 10, max = 80 }
}

-- Colors: updates tbl[key] directly
local function ColorHex(label, tbl, key, tip)
    tbl._meta = tbl._meta or {}
    tbl._meta[key] = tbl._meta[key] or {}

    local ref = tbl._meta[key]
    local hex = tbl[key]

    local f = ImGui.ColorConvertU32ToFloat4(hex)
    ref.Red = math.floor(f[1] * 255)
    ref.Green = math.floor(f[2] * 255)
    ref.Blue = math.floor(f[3] * 255)
    ref.Alpha = math.floor(f[4] * 255)

    if Buttons.Color(label, ref, tip) then
        tbl[key] = ImGui.ColorConvertFloat4ToU32({
            ref.Red / 255, ref.Green / 255, ref.Blue / 255, ref.Alpha / 255
        })
    end
end


local function Default()
    UI.Layout.OptionHeight = 28
    UI.Layout.OptionPaddingX = 3
    UI.Layout.OptionPaddingY = 5
    UI.Layout.LabelOffsetX = 8
    UI.Layout.FrameRounding = 6
    UI.OptionRow.Rounding = 6

    layoutRefs.optionHeight.value = UI.Layout.OptionHeight
    layoutRefs.paddingX.value = UI.Layout.OptionPaddingX
    layoutRefs.paddingY.value = UI.Layout.OptionPaddingY
    layoutRefs.labelOffsetX.value = UI.Layout.LabelOffsetX
    layoutRefs.frameRounding.value = UI.Layout.FrameRounding

    UI.OptionRow.Text = UI.Colors.Text
    UI.OptionRow.MutedText = UI.Colors.MutedText
    UI.OptionRow.HoverBg = UI.Colors.HoverBg
    UI.OptionRow.HighlightBg = UI.Colors.Highlight

    UI.Colors.Background = UI.ColPalette.NearBlackGray

    UI.Header.Height = 40
    UI.Header.BackgroundColor = UI.Colors.Background
    UI.Header.TextColor = 0xFFFFFFFF

    UI.Footer.Height = 25
    UI.Footer.BackgroundColor = UI.Colors.Background
    UI.Footer.TextColor = 0xFFAAAAAA

    headerFooterRefs.headerHeight.value = UI.Header.Height
    headerFooterRefs.footerHeight.value = UI.Footer.Height

    UI.Scroll.ScrollSpeed = 3.0
    UI.Animation.SmoothSpeed = 0.12

    scrollAnimRefs.scrollSpeed.value = UI.Scroll.ScrollSpeed
    scrollAnimRefs.smoothSpeed.value = UI.Animation.SmoothSpeed
end

local function StyleSettingsView()
    -- Layout
if Buttons.Int("Option Height", layoutRefs.optionHeight, 
    "Controls the vertical height of each option row.\nHigher values = taller rows with more spacing for text or widgets.") then
    UI.Layout.OptionHeight = layoutRefs.optionHeight.value
end

if Buttons.Int("Option Padding X", layoutRefs.paddingX, 
    "Controls the horizontal padding (left/right) inside the menu.\nHigher values push content further away from the edges.") then
    UI.Layout.OptionPaddingX = layoutRefs.paddingX.value
end

if Buttons.Int("Option Padding Y", layoutRefs.paddingY, 
    "Controls the vertical padding (top/bottom) between rows.") then
    UI.Layout.OptionPaddingY = layoutRefs.paddingY.value
end

if Buttons.Float("Frame Rounding", layoutRefs.frameRounding, 
    "Rounds the corners of widgets (toggles, option rows, etc.).\n0 = sharp corners, higher values = smoother rounded corners.") then
    UI.Layout.FrameRounding = layoutRefs.frameRounding.value
    UI.OptionRow.Rounding = layoutRefs.frameRounding.value
end

    Buttons.Break("Option Row Colors")
    ColorHex("Row Text", UI.OptionRow, "Text", "Text color for normal option labels")
    ColorHex("Row Muted Text", UI.OptionRow, "MutedText", "Dimmed text color for breaks and inactive entries")
    ColorHex("Row Hover", UI.OptionRow, "HoverBg", "Background color shown when hovering over an option with cursor")
    ColorHex("Row Selected", UI.OptionRow, "HighlightBg", "Background color of the currently selected option")
    ColorHex("Background", UI.Colors, "Background", "Overall background color for menu windows")

    Buttons.Break("Header & Footer")
    if Buttons.Int("Header Height", headerFooterRefs.headerHeight) then
        UI.Header.Height = headerFooterRefs.headerHeight.value
    end
    ColorHex("Header BG", UI.Header, "BackgroundColor", "Background color for the menu header")
    ColorHex("Header Text", UI.Header, "TextColor", "Text color for the header title")
    if Buttons.Int("Footer Height", headerFooterRefs.footerHeight) then
        UI.Footer.Height = headerFooterRefs.footerHeight.value
    end
    ColorHex("Footer BG", UI.Footer, "BackgroundColor", "Background color for the footer")
    ColorHex("Footer Text", UI.Footer, "TextColor", "Text color for footer information")

    Buttons.Break("Scroll & Animation")
    if Buttons.Float("Scroll Speed", scrollAnimRefs.scrollSpeed) then
        UI.Scroll.ScrollSpeed = scrollAnimRefs.scrollSpeed.value
    end
    if Buttons.Float("Smooth Animation Speed", scrollAnimRefs.smoothSpeed) then
        UI.Animation.SmoothSpeed = scrollAnimRefs.smoothSpeed.value
    end

    Buttons.Break()
    Buttons.Option("Save Style", "Save current style settings to config file", StyleConfig.Save)
    Buttons.Option("Reset to Default", "Reset all style settings back to defaults", Default)

end

return { title = "Style Settings", view = StyleSettingsView }
