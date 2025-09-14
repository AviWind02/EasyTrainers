local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")
local TextInput = require("UI/Options/TextInput")
local Notification = require("UI/Elements/Notification")

local widthRef  = { value = UI.TextInput.Width,  min = 200, max = 800 }
local heightRef = { value = UI.TextInput.Height, min = 100, max = 400 }
local roundingRef = { value = UI.TextInput.Rounding, min = 0, max = 30 }
local paddingRef = { value = UI.TextInput.Padding, min = 0, max = 50 }
local spacingRef = { value = UI.TextInput.ButtonSpacing, min = 0, max = 50 }

local testInputRef = { value = "Give yourself time. Ideas'll come. Life'll shake you, roll you, maybe embrace you.", capturing = false }

local function TextInputViewFunction()
    Buttons.Option("Reset Text Input", "Restore Text Input defaults", ResetUI.ResetTextInput)
    Buttons.Break("Text Input")

    if Buttons.Int("Width", widthRef, "Window width of the text input dialog") then
        UI.TextInput.Width = widthRef.value
    end
    if Buttons.Int("Height", heightRef, "Window height of the text input dialog") then
        UI.TextInput.Height = heightRef.value
    end
    if Buttons.Float("Rounding", roundingRef, "Corner rounding of the text input window") then
        UI.TextInput.Rounding = roundingRef.value
    end
    if Buttons.Int("Padding", paddingRef, "Inner padding of the text input window") then
        UI.TextInput.Padding = paddingRef.value
    end
    if Buttons.Int("Button Spacing", spacingRef, "Spacing between OK/Cancel buttons") then
        UI.TextInput.ButtonSpacing = spacingRef.value
    end

    Buttons.ColorHex("Text Color", UI.TextInput, "TextColor", "Text color inside text input")
    Buttons.ColorHex("Background", UI.TextInput, "BackgroundColor", "Background fill of text input")
    Buttons.ColorHex("Border", UI.TextInput, "BorderColor", "Border color of text input window")

    Buttons.Break("Example")
    if TextInput.Option("Sample Input", testInputRef, "Click to edit example text") then
        Notification.Info("TextInput result: " .. tostring(testInputRef.value))
    end
end

local TextInputView = { title = "Text Input", view = TextInputViewFunction }

return TextInputView
