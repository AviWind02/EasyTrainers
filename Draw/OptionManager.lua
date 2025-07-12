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
local Submenus = require("Draw/SubmenuManager")

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

function OptionManager.Option(left, right, tip)
    Controls.optionIndex = Controls.optionIndex + 1
    local isActive = OptionManager:IsSelected()

    -- Calculate scrolling window
    if Controls.optionIndex == 1 then
        local layout = UI.Layout
        local headerHeight = UI.Header.Height or 0
        local footerHeight = UI.Footer.Height or 0
        local availableHeight = OptionManager.menuH - layout.OptionPaddingY * 2 - headerHeight - footerHeight
        OptionManager.maxVisible = math.max(1, math.floor(availableHeight / (layout.OptionHeight + layout.ItemSpacing.y)))
        OptionManager.startOpt = math.floor((Controls.currentOption - 1) / OptionManager.maxVisible) *
            OptionManager.maxVisible + 1
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
    local y = OptionManager.menuY + layout.OptionPaddingY + UI.Header.Height +
        relIndex * (layout.OptionHeight + layout.ItemSpacing.y)
    local w = OptionManager.menuW - layout.OptionPaddingX * 2
    local h = layout.OptionHeight
    local fontY = y + (h - 18) * 0.5

    -- Smooth highlight
    if isActive then
        OptionManager.smoothY = OptionManager.smoothY + (y - OptionManager.smoothY) * UI.Animation.SmoothSpeed
    end

    -- Background
    --DrawHelpers.RectFilled(x, y, w, h, colors.FrameBg, layout.FrameRounding)

    if isActive then
        DrawHelpers.RectFilled(x, OptionManager.smoothY, w, h, colors.Highlight, layout.FrameRounding)
    end
    -- Text
    if left and left ~= "" then
        DrawHelpers.Text(x + layout.LabelOffsetX, fontY, colors.Text, left)
    end
    if right and right ~= "" then
        local isIcon = OptionManager.IsIconGlyph(right)
        local fontSize = isIcon and 20 or ImGui.GetFontSize()
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
    local clicked = OptionManager.Option(label, "", tip)


    if Controls.optionIndex < OptionManager.startOpt or Controls.optionIndex > OptionManager.endOpt then
        return
    end

    local layout = UI.Layout
    local colors = UI.Colors
    local headerHeight = UI.Header.Height or 0

    local relIndex = Controls.optionIndex - OptionManager.startOpt
    local x = OptionManager.menuX + layout.OptionPaddingX
    local y = OptionManager.menuY + layout.OptionPaddingY + headerHeight +
        relIndex * (layout.OptionHeight + layout.ItemSpacing.y)

    local w = OptionManager.menuW - layout.OptionPaddingX * 2
    local h = layout.OptionHeight

    local boxSize = 18
    local radius = 4

    local boxX = x + w - layout.LabelOffsetX - boxSize
    local boxY = y + (h - boxSize) * 0.5

    -- If hovered, show [ ON ] or [ OFF ] in a pill before the toggle box
    if OptionManager.IsSelected() then
        local stateText = toggleRef.value and "ON" or "OFF"
        local textWidth = ImGui.CalcTextSize(stateText)
        local textX = boxX - textWidth - 14
        local textY = y + (h - 18) * 0.5

        -- Background behind the "ON"/"OFF"
        local panelW = textWidth + 12
        DrawHelpers.RectFilled(textX - 6, boxY - 2, panelW, boxSize + 4, colors.FrameBg, radius)

        -- Text itself
        DrawHelpers.Text(textX, textY, colors.Text, stateText)
    end

    -- Draw toggle box
    DrawHelpers.Rect(boxX, boxY, boxSize, boxSize, colors.Text, radius)
    if toggleRef.value then
        DrawHelpers.RectFilled(boxX + 2, boxY + 2, boxSize - 4, boxSize - 4, UI.Toggle.OnColor, radius - 2)
    end

    if clicked then
        toggleRef.value = not toggleRef.value
    end
end

function OptionManager.IntToggle(label, ref, tip)
    local clicked = OptionManager.Option(label, "", tip)

    if Controls.optionIndex < OptionManager.startOpt or Controls.optionIndex > OptionManager.endOpt then
        return false
    end

    local layout = UI.Layout
    local colors = UI.Colors
    local headerHeight = UI.Header.Height or 0

    local relIndex = Controls.optionIndex - OptionManager.startOpt
    local x = OptionManager.menuX + layout.OptionPaddingX
    local y = OptionManager.menuY + layout.OptionPaddingY + headerHeight +
        relIndex * (layout.OptionHeight + layout.ItemSpacing.y)
    local w = OptionManager.menuW - layout.OptionPaddingX * 2
    local h = layout.OptionHeight

    local boxSize = 18
    local radius = 4

    local hasToggle = ref.enabled ~= nil
    local valueText = string.format("%d / %d", ref.value, ref.max or 100)
    local valueWidth = ImGui.CalcTextSize(valueText)
    local fontY = y + (h - 18) * 0.5

    local toggleX = x + w - layout.LabelOffsetX - (hasToggle and boxSize or 0)
    local toggleY = y + (h - boxSize) * 0.5
    local valueX = toggleX - valueWidth - (hasToggle and 10 or 0)
    local valueY = fontY

    -- Logic
    if OptionManager.IsSelected() then
        if Controls.leftPressed then
            ref.value = ref.value <= (ref.min or 0) and (ref.max or 100) or ref.value - 1
        elseif Controls.rightPressed then
            ref.value = ref.value >= (ref.max or 100) and (ref.min or 0) or ref.value + 1
        elseif hasToggle and Controls.selectPressed then
            ref.enabled = not ref.enabled
        end
    end

    -- Draw panel
    local panelW = valueWidth + (hasToggle and (boxSize + 16) or 10)
    DrawHelpers.RectFilled(valueX - 6, y + 3, panelW, h - 6, colors.FrameBg, radius)

    -- Draw text
    local isEnabled = (not hasToggle) or ref.enabled
    DrawHelpers.Text(valueX, valueY, isEnabled and colors.Text or colors.MutedText, valueText)
    if hasToggle then
        DrawHelpers.Rect(toggleX, toggleY, boxSize, boxSize, colors.Text, radius)
        if ref.enabled then
            DrawHelpers.RectFilled(toggleX + 2, toggleY + 2, boxSize - 4, boxSize - 4, UI.Toggle.OnColor, radius - 2)
        end
    end
end


function OptionManager.FloatToggle(label, ref, tip)
    local clicked = OptionManager.Option(label, "", tip)

    if Controls.optionIndex < OptionManager.startOpt or Controls.optionIndex > OptionManager.endOpt then
        return false
    end

    local layout = UI.Layout
    local colors = UI.Colors
    local headerHeight = UI.Header.Height or 0

    local relIndex = Controls.optionIndex - OptionManager.startOpt
    local x = OptionManager.menuX + layout.OptionPaddingX
    local y = OptionManager.menuY + layout.OptionPaddingY + headerHeight +
        relIndex * (layout.OptionHeight + layout.ItemSpacing.y)
    local w = OptionManager.menuW - layout.OptionPaddingX * 2
    local h = layout.OptionHeight

    local boxSize = 18
    local radius = 4
    local hasToggle = ref.enabled ~= nil

    local valueText = string.format("%.2f / %.2f", ref.value, ref.max or 1.0)
    local valueWidth = ImGui.CalcTextSize(valueText)
    local fontY = y + (h - 18) * 0.5

    local toggleX = x + w - layout.LabelOffsetX - (hasToggle and boxSize or 0)
    local toggleY = y + (h - boxSize) * 0.5
    local valueX = toggleX - valueWidth - (hasToggle and 10 or 0)
    local valueY = fontY

    if OptionManager.IsSelected() then
        if Controls.leftPressed then
            ref.value = ref.value <= (ref.min or 0.0) and (ref.max or 1.0) or ref.value - (ref.step or 0.1)
        elseif Controls.rightPressed then
            ref.value = ref.value >= (ref.max or 1.0) and (ref.min or 0.0) or ref.value + (ref.step or 0.1)
        elseif hasToggle and Controls.selectPressed then
            ref.enabled = not ref.enabled
        end
    end

    -- Clamp precision
    if ref.value then
        ref.value = math.max(ref.min or 0.0, math.min(ref.max or 1.0, tonumber(string.format("%.2f", ref.value))))
    end

    -- Draw background
    local panelW = valueWidth + (hasToggle and (boxSize + 16) or 10)
    DrawHelpers.RectFilled(valueX - 6, y + 3, panelW, h - 6, colors.FrameBg, radius)

    -- Draw text
    local isEnabled = (not hasToggle) or ref.enabled
    DrawHelpers.Text(valueX, valueY, isEnabled and colors.Text or colors.MutedText, valueText)

    if hasToggle then
        DrawHelpers.Rect(toggleX, toggleY, boxSize, boxSize, colors.Text, radius)
        if ref.enabled then
            DrawHelpers.RectFilled(toggleX + 2, toggleY + 2, boxSize - 4, boxSize - 4, UI.Toggle.OnColor, radius - 2)
        end
    end
end

function OptionManager.Submenu(label, submenu, tip)
    local clicked = OptionManager.Option(label, IconGlyphs.ArrowRight, tip)
    if clicked and submenu then
        Submenus.OpenSubmenu(submenu)
    end
    return clicked
end

return OptionManager
