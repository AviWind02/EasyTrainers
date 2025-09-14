local Buttons = require("UI").Buttons
local UI = require("UI/Core/Style")
local ResetUI = require("UI/Core/ResetUI")

local optionHeightRef = { value = UI.Layout.OptionHeight, min = 10, max = 80 }
local paddingXRef = { value = UI.Layout.OptionPaddingX, min = 0, max = 65 }
local paddingYRef = { value = UI.Layout.OptionPaddingY, min = 0, max = 65 }
local frameRoundingRef = { value = UI.Layout.FrameRounding, min = 0, max = 30 }
local frameHeightRef = { value = UI.Layout.FrameHeight, min = 10, max = 80 }
local labelOffsetRef = { value = UI.Layout.LabelOffsetX, min = 0, max = 40 }
local itemSpacingXRef = { value = UI.Layout.ItemSpacing.x, min = 0, max = 50 }
local itemSpacingYRef = { value = UI.Layout.ItemSpacing.y, min = 0, max = 50 }
local framePaddingXRef = { value = UI.Layout.FramePadding.x, min = 0, max = 50 }
local framePaddingYRef = { value = UI.Layout.FramePadding.y, min = 0, max = 50 }

local smoothSpeedRef = { value = UI.OptionRow.SmoothSpeed, min = 0.01, max = 1.0, step = 0.01 }


local function LayoutOptionRowViewFunction()
    Buttons.Option("Reset Layout", "Restore layout & option row defaults", ResetUI.ResetLayout)
    Buttons.Break("Layout")
    if Buttons.Int("Option Height", optionHeightRef, "Vertical height of each option row") then
        UI.Layout.OptionHeight = optionHeightRef.value
    end
    if Buttons.Int("Frame Height", frameHeightRef, "Height of widgets like sliders and numeric boxes") then
        UI.Layout.FrameHeight = frameHeightRef.value
    end
    if Buttons.Int("Padding X", paddingXRef, "Horizontal padding inside the menu edges") then
        UI.Layout.OptionPaddingX = paddingXRef.value
    end
    if Buttons.Int("Padding Y", paddingYRef, "Vertical padding between rows and from menu edges") then
        UI.Layout.OptionPaddingY = paddingYRef.value
    end
    if Buttons.Int("Label Offset X", labelOffsetRef, "Distance between row start and left-aligned labels") then
        UI.Layout.LabelOffsetX = labelOffsetRef.value
        UI.OptionRow.LabelOffsetX = labelOffsetRef.value
    end
    if Buttons.Float("Frame Rounding", frameRoundingRef, "Corner rounding radius for rows and widgets") then
        UI.Layout.FrameRounding = frameRoundingRef.value
        UI.OptionRow.Rounding = frameRoundingRef.value
    end
    if Buttons.Int("Item Spacing X", itemSpacingXRef, "Horizontal gap between inline items") then
        UI.Layout.ItemSpacing.x = itemSpacingXRef.value
    end
    if Buttons.Int("Item Spacing Y", itemSpacingYRef, "Vertical gap between stacked items") then
        UI.Layout.ItemSpacing.y = itemSpacingYRef.value
    end
    if Buttons.Float("Frame Padding X", framePaddingXRef, "Inner horizontal padding for framed widgets") then
        UI.Layout.FramePadding.x = framePaddingXRef.value
    end
    if Buttons.Float("Frame Padding Y", framePaddingYRef, "Inner vertical padding for framed widgets") then
        UI.Layout.FramePadding.y = framePaddingYRef.value
    end

    Buttons.Break("Option Row")
    if Buttons.Float("Smooth Speed", smoothSpeedRef, "Speed of highlight bar smoothing when changing selection") then
        UI.OptionRow.SmoothSpeed = smoothSpeedRef.value
    end
    Buttons.ColorHex("Text", UI.OptionRow, "Text", "Primary text color for option labels")
    Buttons.ColorHex("Muted Text", UI.OptionRow, "MutedText", "Secondary text color (break rows, inactive entries)")
    Buttons.ColorHex("Hover Background", UI.OptionRow, "HoverBg", "Background color when hovering a row")
    Buttons.ColorHex("Highlight Background", UI.OptionRow, "HighlightBg", "Background color of the selected row")
end

local LayoutOptionRowView = { title = "Layout & Option Row", view = LayoutOptionRowViewFunction }

return LayoutOptionRowView
