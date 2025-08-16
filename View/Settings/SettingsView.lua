-- View/Settings/StyleSettingsView.lua
local UI = require("UI/Core/Style")
local Buttons = require("UI").Buttons

-- Since the ImGui buttons are hex we'll use this
function ColorHex(label, tbl, key, tip)
    tbl._meta = tbl._meta or {}
    tbl._meta[key] = tbl._meta[key] or {}

    local ref = tbl._meta[key]
    local hex = tbl[key]

    local f = ImGui.ColorConvertU32ToFloat4(hex)
    ref.Red = math.floor(f[1] * 255)
    ref.Green = math.floor(f[2] * 255)
    ref.Blue = math.floor(f[3] * 255)
    ref.Alpha = math.floor(f[4] * 255)

    ref._expanded = ref._expanded or false
    ref._reveal = ref._reveal or 0
    ref._lastFrame = ref._lastFrame or 0

    local changed = Buttons.Color(label, ref, tip)

    if changed then
        local newColor = {
            (ref.Red or 0) / 255,
            (ref.Green or 0) / 255,
            (ref.Blue or 0) / 255,
            (ref.Alpha or 255) / 255
        }

        tbl[key] = ImGui.ColorConvertFloat4ToU32(newColor)
    end

    return changed
end

local function ColorView()
    ColorHex("Text Color", UI.Colors, "Text", "Primary text color used for most visible labels")
    ColorHex("Muted Text", UI.Colors, "MutedText", "Dimmed text used for secondary details and tips")
    ColorHex("Background", UI.Colors, "Background", "Menu background color for full screens or windows")
    ColorHex("Frame Background", UI.Colors, "FrameBg", "Used for input boxes, toggles, sliders, etc.")
    ColorHex("Border", UI.Colors, "Border", "Color of outer borders around UI components")
    ColorHex("Highlight", UI.Colors, "Highlight", "Hover highlight for rows and options")
    ColorHex("Active Highlight", UI.Colors, "ActiveHighlight", "Applied when option is actively selected")
    ColorHex("Hover Background", UI.Colors, "HoverBg", "Soft background when hovering over a row")
    ColorHex("Active State", UI.Colors, "Active", "Color shown when toggle is ON or item is ACTIVE")
    ColorHex("Grab Handle", UI.Colors, "Grab", "The draggable part of sliders and numeric inputs")
    ColorHex("Transparent", UI.Colors, "Transparent", "Fully transparent color used for empty gaps or no fill")
end

local colorView = { title = "Colors", view = ColorView }

local function StyleSettingsView()
    Buttons.Submenu("Colors", colorView, "Adjust the colors used throughout the UI")
end

return {
    title = "Style Settings",
    view = StyleSettingsView
}
