local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")
local framesPerOptionRef = { value = UI.Dropdown.FramesPerOption, min = 1, max = 10 }
local revealDelayRef = { value = UI.Dropdown.RevealFrameDelay, min = 0, max = 10 }

local framePaddingRef = { value = UI.StringCycler.FramePadding, min = 0, max = 30 }
local textPaddingRef = { value = UI.StringCycler.TextPadding, min = 0, max = 30 }
local boxRoundingRef = { value = UI.StringCycler.BoxRounding, min = 0, max = 30 }

local prefixRef = { index = 1 }
local prefixOptions = { "- ", "* ", "> ", ">> ", "[ " }

local cyclerRef = { index = 1 }
local cyclerOptions = { "Netrunner", "Nomad", "Fixer", "Rockerboy" }
local dropdownRef = { index = 1, expanded = false }

local function SimpleControlsViewFunction()
    Buttons.Option("Reset Simple Controls", "Restore Simple defaults", ResetUI.ResetSimpleControls)

    Buttons.Break("Break Row")
    Buttons.ColorHex("Text Color", UI.BreakRow, "Text", "Color of break row labels")
    Buttons.ColorHex("Highlight Background", UI.BreakRow, "HighlightBg", "Background highlight color of break rows")

    Buttons.Break("Dropdown")
    if Buttons.Int("Frames Per Option", framesPerOptionRef, "How many frames to wait before revealing the next option") then
        UI.Dropdown.FramesPerOption = framesPerOptionRef.value
    end
    if Buttons.Int("Reveal Frame Delay", revealDelayRef, "Extra delay between option reveals in frames") then
        UI.Dropdown.RevealFrameDelay = revealDelayRef.value
    end
    Buttons.ColorHex("Text Color", UI.Dropdown, "TextColor", "Normal text color for dropdown entries")
    Buttons.ColorHex("Selected Color", UI.Dropdown, "SelectedColor", "Text color for the selected dropdown entry")

    Buttons.Dropdown("Row Prefix", prefixRef, prefixOptions, "Prefix shown before each dropdown option")
    UI.Dropdown.RowPrefix = prefixOptions[prefixRef.index]

    Buttons.Break("Dropdown Example")
    Buttons.Dropdown("Example Dropdown", dropdownRef, { "Option One", "Option Two", "Option Three" },
    "Preview of dropdown style")

    Buttons.Break("String Cycler")
    if Buttons.Int("Frame Padding", framePaddingRef, "Horizontal/vertical padding around the cycler box") then
        UI.StringCycler.FramePadding = framePaddingRef.value
    end
    if Buttons.Int("Text Padding", textPaddingRef, "Padding between the cycler box edge and the text") then
        UI.StringCycler.TextPadding = textPaddingRef.value
    end
    if Buttons.Float("Box Rounding", boxRoundingRef, "Corner rounding of the cycler box") then
        UI.StringCycler.BoxRounding = boxRoundingRef.value
    end
    Buttons.ColorHex("Frame Background", UI.StringCycler, "FrameBg", "Background fill of the cycler box")
    Buttons.ColorHex("Value Color", UI.StringCycler, "ValueColor", "Color of the selected cycler value")

    Buttons.Break("String Cycler Example")
    Buttons.StringCycler("Example Cycler", cyclerRef, cyclerOptions, "Preview of string cycler style")
end

local SimpleControlsView = { title = "Simple Controls", view = SimpleControlsViewFunction }

return SimpleControlsView
