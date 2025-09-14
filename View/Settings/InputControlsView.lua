local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")

local toggleSizeRef = { value = UI.Numeric.ToggleSize, min = 8, max = 40 }
local toggleSpacingRef = { value = UI.Numeric.ToggleSpacing, min = 0, max = 30 }
local boxFramePaddingRef = { value = UI.Numeric.BoxFramePadding, min = 0, max = 30 }
local boxTextPaddingRef = { value = UI.Numeric.BoxTextPadding, min = 0, max = 30 }
local decimalsRef = { value = UI.Numeric.Decimals, min = 0, max = 6 }
local intStepRef = { value = UI.Numeric.DefaultIntStep, min = 1, max = 10 }
local floatStepRef = { value = UI.Numeric.DefaultFloatStep, min = 0.01, max = 5.0, step = 0.01 }

local channelBoxSizeRef = { value = UI.ColorPicker.ChannelBoxSize, min = 8, max = 50 }
local channelPaddingRef = { value = UI.ColorPicker.ChannelPadding, min = 0, max = 20 }
local previewBoxSizeRef = { value = UI.ColorPicker.PreviewBoxSize, min = 8, max = 50 }
local rowSpacingRef = { value = UI.ColorPicker.RowSpacing, min = 0, max = 20 }
local roundingRef = { value = UI.ColorPicker.Rounding, min = 0, max = 30 }

local numericRef = { value = 5, min = 0, max = 20, enabled = false}
local colorRef = { Red = 255, Green = 128, Blue = 64, Alpha = 255 }

local function InputControlsViewFunction()
    Buttons.Option("Reset Input Controls", "Restore Input Controls row defaults", ResetUI.ResetLayout)

    Buttons.Break("Numeric")
    if Buttons.Int("Toggle Size", toggleSizeRef, "Size of the numeric toggle button") then
        UI.Numeric.ToggleSize = toggleSizeRef.value
    end
    if Buttons.Int("Toggle Spacing", toggleSpacingRef, "Spacing between numeric toggle and box") then
        UI.Numeric.ToggleSpacing = toggleSpacingRef.value
    end
    if Buttons.Int("Box Frame Padding", boxFramePaddingRef, "Frame padding inside numeric box") then
        UI.Numeric.BoxFramePadding = boxFramePaddingRef.value
    end
    if Buttons.Int("Box Text Padding", boxTextPaddingRef, "Text padding inside numeric box") then
        UI.Numeric.BoxTextPadding = boxTextPaddingRef.value
    end
    if Buttons.Int("Decimals", decimalsRef, "Decimal places shown for floats") then
        UI.Numeric.Decimals = decimalsRef.value
    end
    if Buttons.Int("Default Int Step", intStepRef, "Step value for integer inputs") then
        UI.Numeric.DefaultIntStep = intStepRef.value
    end
    if Buttons.Float("Default Float Step", floatStepRef, "Step value for float inputs") then
        UI.Numeric.DefaultFloatStep = floatStepRef.value
    end

    Buttons.ColorHex("Frame Background", UI.Numeric, "FrameBg", "Background fill of numeric box")
    Buttons.ColorHex("Text Color", UI.Numeric, "TextColor", "Text color inside numeric box")
    Buttons.ColorHex("Disabled Color", UI.Numeric, "DisabledColor", "Text color when input is disabled")

    Buttons.Break("Numeric Example")
    Buttons.Int("Example Numeric", numericRef, "Preview of numeric input")

    Buttons.Break("Color Picker")
    if Buttons.Int("Channel Box Size", channelBoxSizeRef, "Size of RGBA channel boxes") then
        UI.ColorPicker.ChannelBoxSize = channelBoxSizeRef.value
    end
    if Buttons.Int("Channel Padding", channelPaddingRef, "Spacing between RGBA channel boxes") then
        UI.ColorPicker.ChannelPadding = channelPaddingRef.value
    end
    if Buttons.Int("Preview Box Size", previewBoxSizeRef, "Size of the preview color box") then
        UI.ColorPicker.PreviewBoxSize = previewBoxSizeRef.value
    end
    if Buttons.Int("Row Spacing", rowSpacingRef, "Spacing between color picker rows") then
        UI.ColorPicker.RowSpacing = rowSpacingRef.value
    end
    if Buttons.Float("Rounding", roundingRef, "Corner rounding of color picker boxes") then
        UI.ColorPicker.Rounding = roundingRef.value
    end

    Buttons.ColorHex("Frame Background", UI.ColorPicker, "FrameBg", "Background behind color channels")
    Buttons.ColorHex("Text Color", UI.ColorPicker, "TextColor", "Text color for RGBA labels")
    Buttons.ColorHex("Border Color", UI.ColorPicker, "BorderColor", "Outline color around channel boxes")

    Buttons.Break("Color Picker Example")
    Buttons.Color("Example Color", colorRef, "Preview of color picker style")
end

local InputControlsView = { title = "Input Controls", view = InputControlsViewFunction }

return InputControlsView
