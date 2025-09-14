local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")
local paddingRef = { value = UI.InfoBox.Padding, min = 0, max = 50 }
local spacingRef = { value = UI.InfoBox.Spacing, min = 0, max = 50 }
local roundingRef = { value = UI.InfoBox.Rounding, min = 0, max = 30 }
local cpsRef = { value = UI.InfoBox.CharsPerSecond, min = 20, max = 500 }
local rotateRef = { value = UI.InfoBox.FallbackRotateSeconds, min = 1, max = 60 }

local function InfoBoxViewFunction()
    Buttons.Option("Reset Info Box", "Restore Info Box defaults", ResetUI.ResetInfoBox)
    Buttons.Break("Info Box")
    if Buttons.Int("Padding", paddingRef, "Inner padding of the info box") then
        UI.InfoBox.Padding = paddingRef.value
    end
    if Buttons.Int("Spacing", spacingRef, "Distance from menu to info box") then
        UI.InfoBox.Spacing = spacingRef.value
    end
    if Buttons.Float("Rounding", roundingRef, "Corner rounding of the info box") then
        UI.InfoBox.Rounding = roundingRef.value
    end
    if Buttons.Int("Characters Per Second", cpsRef, "Speed of animated text reveal") then
        UI.InfoBox.CharsPerSecond = cpsRef.value
    end
    if Buttons.Int("Rotate Seconds", rotateRef, "Fallback rotation time for cycling text") then
        UI.InfoBox.FallbackRotateSeconds = rotateRef.value
    end

    Buttons.ColorHex("Text Color", UI.InfoBox, "TextColor", "Info box text color")
    Buttons.ColorHex("Background", UI.InfoBox, "BackgroundColor", "Info box background fill")
    Buttons.ColorHex("Border", UI.InfoBox, "BorderColor", "Info box border color")
end

local InfoBoxView = { title = "Info Box", view = InfoBoxViewFunction }

return InfoBoxView
