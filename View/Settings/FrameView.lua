local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")
local headerHeightRef = { value = UI.Header.Height, min = 20, max = 120 }
local headerFontSizeRef = { value = UI.Header.FontSize, min = 8, max = 40 }
local headerFontSizeSubRef = { value = UI.Header.FontSizeSub, min = 8, max = 40 }

local footerHeightRef = { value = UI.Footer.Height, min = 10, max = 80 }
local footerFontSizeRef = { value = UI.Footer.FontSize, min = 8, max = 30 }

local function FrameViewFunction()
    Buttons.Option("Reset Frame", "Restore Frame defaults", ResetUI.ResetFrame)

    Buttons.Break("Header")
    if Buttons.Int("Height", headerHeightRef, "Vertical size of the header bar") then
        UI.Header.Height = headerHeightRef.value
    end
    if Buttons.Int("Font Size", headerFontSizeRef, "Font size for the main header title") then
        UI.Header.FontSize = headerFontSizeRef.value
    end
    if Buttons.Int("Subtitle Font Size", headerFontSizeSubRef, "Font size for secondary header text") then
        UI.Header.FontSizeSub = headerFontSizeSubRef.value
    end
    Buttons.ColorHex("Background", UI.Header, "BackgroundColor", "Background fill of the header bar")
    Buttons.ColorHex("Text Color", UI.Header, "TextColor", "Text color used for the header title")

    Buttons.Break("Footer")
    if Buttons.Int("Height", footerHeightRef, "Vertical size of the footer bar") then
        UI.Footer.Height = footerHeightRef.value
    end
    if Buttons.Int("Font Size", footerFontSizeRef, "Font size for footer text") then
        UI.Footer.FontSize = footerFontSizeRef.value
    end
    Buttons.ColorHex("Background", UI.Footer, "BackgroundColor", "Background fill of the footer bar")
    Buttons.ColorHex("Text Color", UI.Footer, "TextColor", "Text color used for footer text")
end

local FrameView = { title = "Header & Footer", view = FrameViewFunction }

return FrameView
