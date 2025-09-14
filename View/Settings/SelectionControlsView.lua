local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")
local toggleSizeRef = { value = UI.Toggle.Size, min = 8, max = 40 }
local toggleRoundingRef = { value = UI.Toggle.Rounding, min = 0, max = 20 }
local toggleInsetRef = { value = UI.Toggle.Inset, min = 0, max = 10 }
local toggleStatePaddingRef = { value = UI.Toggle.StatePadding, min = 0, max = 20 }
local toggleStateSpacingRef = { value = UI.Toggle.StateSpacing, min = 0, max = 20 }

local radioRadiusRef = { value = UI.Radio.Radius, min = 2, max = 20 }
local radioThicknessRef = { value = UI.Radio.LineThickness, min = 0.5, max = 5.0, step = 0.1 }
local radioSegmentsRef = { value = UI.Radio.Segments, min = 3, max = 40 }

local exampleToggleRef = { value = true }
local exampleRadioRef = { index = 1 }
local exampleRadioOptions = { "Plugged In", "Disconnected" }

local function SelectionControlsViewFunction()
    Buttons.Option("Reset Selection Controls", "Restore Selection defaults", ResetUI.ResetSelectionControls)
    Buttons.Break("Toggle")
    if Buttons.Int("Size", toggleSizeRef, "Overall size of the toggle box") then
        UI.Toggle.Size = toggleSizeRef.value
    end
    if Buttons.Float("Rounding", toggleRoundingRef, "Corner roundness of the toggle box") then
        UI.Toggle.Rounding = toggleRoundingRef.value
    end
    if Buttons.Int("Inset", toggleInsetRef, "Inset for the toggle fill when ON") then
        UI.Toggle.Inset = toggleInsetRef.value
    end
    if Buttons.Int("State Padding", toggleStatePaddingRef, "Padding inside the toggle state indicator") then
        UI.Toggle.StatePadding = toggleStatePaddingRef.value
    end
    if Buttons.Int("State Spacing", toggleStateSpacingRef, "Spacing between toggle and label") then
        UI.Toggle.StateSpacing = toggleStateSpacingRef.value
    end

    Buttons.ColorHex("On Color", UI.Toggle, "OnColor", "Fill color when toggle is ON")
    Buttons.ColorHex("Off Color", UI.Toggle, "OffColor", "Fill color when toggle is OFF")
    Buttons.ColorHex("Border Color", UI.Toggle, "BorderColor", "Outline color of the toggle")
    Buttons.ColorHex("Frame Background", UI.Toggle, "FrameBg", "Background behind toggle box")
    Buttons.ColorHex("Text Color", UI.Toggle, "TextColor", "Text color for toggle labels")

    Buttons.Break("Toggle Example")
    Buttons.Toggle("Example Toggle", exampleToggleRef, "Preview of toggle style")

    Buttons.Break("Radio")
    if Buttons.Int("Radius", radioRadiusRef, "Radius of the radio circle") then
        UI.Radio.Radius = radioRadiusRef.value
    end
    if Buttons.Float("Line Thickness", radioThicknessRef, "Thickness of the unselected circle line") then
        UI.Radio.LineThickness = radioThicknessRef.value
    end
    if Buttons.Int("Segments", radioSegmentsRef, "Circle smoothness (more segments = smoother)") then
        UI.Radio.Segments = radioSegmentsRef.value
    end

    Buttons.ColorHex("Selected Color", UI.Radio, "SelectedColor", "Fill color for selected radio buttons")
    Buttons.ColorHex("Unselected Color", UI.Radio, "UnselectedColor", "Outline color for unselected radios")

    Buttons.Break("Radio Example")
    Buttons.Radio("Example Radio", exampleRadioRef, exampleRadioOptions, "Preview of radio button style")
end

local SelectionControlsView = { title = "Selection Controls", view = SelectionControlsViewFunction }

return SelectionControlsView
