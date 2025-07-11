local OptionManager = {}

-- Internal state
OptionManager.smoothY = 0

-- Layout state (set from outside)
OptionManager.menuX, OptionManager.menuY = 0, 0
OptionManager.menuW, OptionManager.menuH = 0, 0

-- Scroll state
OptionManager.maxVisible = 0
OptionManager.startOpt = 1
OptionManager.endOpt = 1

local UI = require("Draw/Style") 
local DrawHelpers = require("Draw/DrawHelpers")
local Controls = require("Draw/Controls")
-- Sets layout bounds (menu position/size)
function OptionManager.SetMenuBounds(x, y, w, h)
    OptionManager.menuX = x
    OptionManager.menuY = y
    OptionManager.menuW = w
    OptionManager.menuH = h
end

function OptionManager.IsSelected()
    return Controls.optionIndex == Controls.currentOption
end
function OptionManager.IsIconGlyph(str)
    return type(str) == "string" and str:match("^[\u{f0000}-\u{fFFFF}]") ~= nil
end
-- Moves to the next option and draws it
function OptionManager.Option(left, right, tip)
    
    Controls.optionIndex = Controls.optionIndex + 1
    local isActive = OptionManager:IsSelected()

    -- Calculate scrolling window
    if Controls.optionIndex == 1 then
        local layout = UI.Layout
        local availableHeight = OptionManager.menuH - layout.OptionPaddingY * 2
        OptionManager.maxVisible = math.max(1, math.floor(availableHeight / (layout.OptionHeight + layout.ItemSpacing.y)))
        OptionManager.startOpt = math.floor((Controls.currentOption - 1) / OptionManager.maxVisible) * OptionManager.maxVisible + 1
        OptionManager.endOpt = OptionManager.startOpt + OptionManager.maxVisible - 1
    end

    if Controls.optionIndex < OptionManager.startOpt or Controls.optionIndex > OptionManager.endOpt then
        return false
    end

    local layout = UI.Layout
    local colors = UI.Colors

    -- Position
    local relIndex = Controls.optionIndex - OptionManager.startOpt
    local x = OptionManager.menuX + layout.OptionPaddingX
    local y = OptionManager.menuY + layout.OptionPaddingY + relIndex * (layout.OptionHeight + layout.ItemSpacing.y)
    local w = OptionManager.menuW - layout.OptionPaddingX * 2
    local h = layout.OptionHeight
    local fontY = y + (h - 18) * 0.5

    -- Smooth highlight
    if isActive then
        OptionManager.smoothY = OptionManager.smoothY + (y - OptionManager.smoothY) * UI.Animation.SmoothSpeed
    end

    -- Background
    if isActive then
        DrawHelpers.RectFilled(x, OptionManager.smoothY, w, h, colors.Highlight, layout.FrameRounding)
    else
        DrawHelpers.RectFilled(x, y, w, h, colors.FrameBg, layout.FrameRounding)
    end

    -- Text
    if left and left ~= "" then 
        DrawHelpers.Text(x + layout.LabelOffsetX, fontY, colors.Text, left)
    end
if right and right ~= "" then
    local isIcon = OptionManager.IsIconGlyph(right)
    local fontSize = isIcon and 25 or 16
    local textWidth = ImGui.CalcTextSize(right)
    local rightX = x + w - layout.LabelOffsetX - textWidth
    DrawHelpers.Text(rightX, fontY, colors.Text, right, fontSize)
end

    -- Selection
    if isActive and Controls.selectPressed then
        print("Option selected:", left, right)
        return true
    end

    return false
end

function OptionManager.Toggle(label, toggleRef, tip)
    local icon = toggleRef.value and IconGlyphs.ToggleSwitch or IconGlyphs.ToggleSwitchOff
    local clicked = OptionManager.Option(label, icon, tip)

    if clicked then
        toggleRef.value = not toggleRef.value
    end
end



return OptionManager
