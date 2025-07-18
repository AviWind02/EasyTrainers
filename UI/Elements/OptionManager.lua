local OptionManager = {}

local UI = require("UI/Core/Style")
local DrawHelpers = require("UI/Core/DrawHelpers")
local Controls = require("UI/Gamepad/InputHandler")
local Submenus = require("UI/Core/SubmenuManager")

local InfoBox = require("UI/Elements/InfoBox")

OptionManager.smoothY = 0
OptionManager.menuX, OptionManager.menuY, OptionManager.menuW, OptionManager.menuH = 0, 0, 0, 0
OptionManager.maxVisible, OptionManager.startOpt, OptionManager.endOpt = 0, 1, 1



function OptionManager.IsSelected()
    return Submenus.optionIndex == Submenus.currentOption
end

function OptionManager.SetMenuBounds(x, y, w, h)
    --print(string.format("SetMenuBounds = X: %.1f, Y: %.1f, W: %.1f, H: %.1f", x, y, w, h))
    OptionManager.menuX, OptionManager.menuY, OptionManager.menuW, OptionManager.menuH = x, y, w, h
end


function OptionManager._updateScroll()
    local L = UI.Layout
    local avail = OptionManager.menuH - L.OptionPaddingY * 2 - (UI.Header.Height or 0) - (UI.Footer.Height or 0)
    OptionManager.maxVisible = math.max(1, math.floor(avail / (L.OptionHeight + L.ItemSpacing.y)))
    local cur = Submenus.currentOption - 1
    OptionManager.startOpt = math.floor(cur / OptionManager.maxVisible) * OptionManager.maxVisible + 1
    OptionManager.endOpt = OptionManager.startOpt + OptionManager.maxVisible - 1
end

function OptionManager._calcPosition()
    if Submenus.optionIndex == 1 then OptionManager._updateScroll() end
    if Submenus.optionIndex < OptionManager.startOpt or Submenus.optionIndex > OptionManager.endOpt then
        return nil
    end

    local L = UI.Layout
    local relIndex = Submenus.optionIndex - OptionManager.startOpt
    local x = OptionManager.menuX + L.OptionPaddingX
    local y = OptionManager.menuY + L.OptionPaddingY + (UI.Header.Height or 0) + relIndex * (L.OptionHeight + L.ItemSpacing.y)
    local w = OptionManager.menuW - L.OptionPaddingX * 2
    local h = L.OptionHeight
    local fontY = y + (h - ImGui.GetFontSize()) * 0.5
    local isActive = Submenus.optionIndex == Submenus.currentOption

    if isActive then
        OptionManager.smoothY = OptionManager.smoothY + (y - OptionManager.smoothY) * UI.Animation.SmoothSpeed
    end

    return { x = x, y = y, w = w, h = h, fontY = fontY, isActive = isActive }
end


function OptionManager.RawOption(left, center, right, textColor, highlightColor)
    Submenus.optionIndex = Submenus.optionIndex + 1
    local pos = OptionManager._calcPosition()
    if not pos then return false end

    -- Draw highlight first
    if pos.isActive then
        DrawHelpers.RectFilled(
            pos.x,
            OptionManager.smoothY,
            pos.w,
            pos.h,
            highlightColor,
            UI.Layout.FrameRounding
        )
    end

    -- Draw left-aligned text
    if left and left ~= "" then
        DrawHelpers.Text(pos.x + UI.Layout.LabelOffsetX, pos.fontY, textColor, left)
    end

    -- Draw center-aligned text
    if center and center ~= "" then
        local textW = ImGui.CalcTextSize(center)
        local centerX = pos.x + (pos.w - textW) * 0.5
        DrawHelpers.Text(centerX, pos.fontY, textColor, center)
    end

    -- Draw right-aligned text
    if right and right ~= "" then
        local textW = ImGui.CalcTextSize(right)
        local rightX = pos.x + pos.w - UI.Layout.LabelOffsetX - textW
        DrawHelpers.Text(rightX, pos.fontY, textColor, right)
    end

    return pos.isActive and Controls.selectPressed
end


function OptionManager.Option(left, center, right, tip)
    local clicked = OptionManager.RawOption(left, center, right, UI.Colors.Text, UI.Colors.Highlight)
    if OptionManager.IsSelected() then
        InfoBox.SetText(tip or "")
    end
    return clicked
end

function OptionManager.Break(left, center, right)
    local current = Submenus.currentOption  
    OptionManager.RawOption(left, center, right, UI.Colors.MutedText, UI.Colors.Highlight)

    if OptionManager.IsSelected() then
        if Controls.downPressed then
            Submenus.currentOption = current + 1
        elseif Controls.upPressed then
            Submenus.currentOption = current - 1
        end
    end

    return false
end


function OptionManager.Dropdown(label, ref, options, tip)
    local arrow = ref.expanded and IconGlyphs.CircleExpand or IconGlyphs.ArrowExpandAll
    local selectedLabel = options[ref.index or 1] or "None"
    local clicked = OptionManager.Option(label, nil, selectedLabel .. " " .. arrow, tip)

    if clicked then
        ref.expanded = not ref.expanded
        if ref.expanded then
            ref.revealProgress = 0
            ref.lastRevealFrame = ImGui.GetFrameCount()
        else
            ref.revealProgress = nil
            ref.lastRevealFrame = nil
            Submenus.currentOption = Submenus.optionIndex
        end
    end

    if ref.expanded then
        local currentFrame = ImGui.GetFrameCount()
        local framesPerOption = 3

        if (ref.revealProgress or 0) < #options then
            if currentFrame - (ref.lastRevealFrame or 0) >= framesPerOption then
                ref.revealProgress = (ref.revealProgress or 0) + 1
                ref.lastRevealFrame = currentFrame
            end
        end

        for i = 1, (ref.revealProgress or 0) do
            local label = "- " .. options[i]
            local isSelected = (ref.index == i)

            if OptionManager.Option(label, nil, isSelected and IconGlyphs.CheckBold or "") then
                ref.index = i
                ref.expanded = false
                ref.revealProgress = nil
                ref.lastRevealFrame = nil
                Submenus.currentOption = Submenus.optionIndex - i
                break
            end
        end
    end
end

function OptionManager.Toggle(label, ref, tip)
    local clicked = OptionManager.Option(label, "", "", tip)
    local pos = OptionManager._calcPosition()
    if not pos then return end

    local Layout, Colors = UI.Layout, UI.Colors

    local toggleSize = 18
    local toggleX = pos.x + pos.w - Layout.LabelOffsetX - toggleSize
    local toggleY = pos.y + (pos.h - toggleSize) * 0.5

    if pos.isActive then
        local stateText = ref.value and "ON" or "OFF"
        local stateTextWidth = ImGui.CalcTextSize(stateText)
        local padding = 6
        local spacing = 8
        local stateX = toggleX - stateTextWidth - (padding + spacing)
        local stateY = toggleY - 2

        DrawHelpers.RectFilled(
            stateX - padding, stateY,
            stateTextWidth + padding * 2, toggleSize + 4,
            Colors.FrameBg,
            Layout.FrameRounding
        )
        DrawHelpers.Text(stateX, pos.fontY, Colors.Text, stateText)
    end

    DrawHelpers.Rect(toggleX, toggleY, toggleSize, toggleSize, Colors.Text, Layout.FrameRounding)

    if ref.value then
        local inset = 2
        DrawHelpers.RectFilled(
            toggleX + inset, toggleY + inset,
            toggleSize - inset * 2, toggleSize - inset * 2,
            UI.Toggle.OnColor,
            Layout.FrameRounding - 2
        )
    end

    if clicked then
        ref.value = not ref.value
    end
    
    return clicked
end


function OptionManager.IntToggle(label, ref, tip)
	local clicked = OptionManager.Option(label, "", "", tip)
	local pos = OptionManager._calcPosition()
	if not pos then return false end

	local Layout, Colors = UI.Layout, UI.Colors

	local toggleSize = 18
	local toggleSpacing = 10
	local framePadding = 6
	local textPadding = 3

	local step = ref.step or 1
	local minVal = ref.min or 0
	local maxVal = ref.max or 100

	if pos.isActive then
		if Controls.leftPressed then
			ref.value = ref.value - step
			if ref.value < minVal then ref.value = maxVal end
		elseif Controls.rightPressed then
			ref.value = ref.value + step
			if ref.value > maxVal then ref.value = minVal end
		elseif ref.enabled ~= nil and Controls.selectPressed then
			ref.enabled = not ref.enabled
		end
	end

	ref.value = math.max(minVal, math.min(maxVal, ref.value))
	local valueText = string.format("%d / %d", ref.value, maxVal)
	local valueTextWidth = ImGui.CalcTextSize(valueText)

	local toggleX = pos.x + pos.w - Layout.LabelOffsetX - (ref.enabled ~= nil and toggleSize or 0)
	local valueX = toggleX - valueTextWidth - (ref.enabled ~= nil and toggleSpacing or 0)
	local toggleY = pos.y + (pos.h - toggleSize) * 0.5

	local totalWidth = valueTextWidth + (ref.enabled ~= nil and toggleSize + toggleSpacing or 0)
	DrawHelpers.RectFilled(
		valueX - framePadding,
		pos.y + textPadding,
		totalWidth + framePadding * 2,
		pos.h - textPadding * 2,
		Colors.FrameBg,
		Layout.FrameRounding
	)

	local textColor = (ref.enabled == false) and Colors.MutedText or Colors.Text
	DrawHelpers.Text(valueX, pos.fontY, textColor, valueText)

	if ref.enabled ~= nil then
		DrawHelpers.Rect(toggleX, toggleY, toggleSize, toggleSize, Colors.Text, Layout.FrameRounding)
		if ref.enabled then
			local inset = 2
			DrawHelpers.RectFilled(
				toggleX + inset,
				toggleY + inset,
				toggleSize - inset * 2,
				toggleSize - inset * 2,
				UI.Toggle.OnColor,
				Layout.FrameRounding - 2
			)
		end
	end

	return clicked
end



function OptionManager.FloatToggle(label, ref, tip)
    local clicked = OptionManager.Option(label, "", "", tip)
    local pos = OptionManager._calcPosition()
    if not pos then return false end

    local Layout, Colors = UI.Layout, UI.Colors

    -- Toggle/float UI config
    local toggleSize = 18
    local toggleSpacing = 10
    local framePadding = 6
    local textPadding = 3
    local decimalPlaces = 2

    -- Clamp and update value if active
    if pos.isActive then
        local minVal = ref.min or 0
        local maxVal = ref.max or 1
        local step = ref.step or 0.1

        if Controls.leftPressed then
            ref.value = ref.value <= minVal and maxVal or ref.value - step
        elseif Controls.rightPressed then
            ref.value = ref.value >= maxVal and minVal or ref.value + step
        elseif ref.enabled ~= nil and Controls.selectPressed then
            ref.enabled = not ref.enabled
        end
    end

    -- Format and clamp value
    local minVal = ref.min or 0
    local maxVal = ref.max or 1
    ref.value = math.max(minVal, math.min(maxVal, tonumber(string.format("%.2f", ref.value))))
    local valueText = string.format("%." .. decimalPlaces .. "f / %.2f", ref.value, maxVal)
    local valueTextWidth = ImGui.CalcTextSize(valueText)

    -- Calculate element positions
    local toggleX = pos.x + pos.w - Layout.LabelOffsetX - (ref.enabled ~= nil and toggleSize or 0)
    local valueX = toggleX - valueTextWidth - (ref.enabled ~= nil and toggleSpacing or 0)
    local toggleY = pos.y + (pos.h - toggleSize) * 0.5

    -- Draw background for value + toggle
    local totalWidth = valueTextWidth + (ref.enabled ~= nil and toggleSize + toggleSpacing or 0)
    DrawHelpers.RectFilled(
        valueX - framePadding,
        pos.y + textPadding,
        totalWidth + framePadding * 2,
        pos.h - textPadding * 2,
        Colors.FrameBg,
        Layout.FrameRounding
    )

    -- Draw value text
    local textColor = (ref.enabled == false) and Colors.MutedText or Colors.Text
    DrawHelpers.Text(valueX, pos.fontY, textColor, valueText)

    -- Draw toggle if enabled
    if ref.enabled ~= nil then
        DrawHelpers.Rect(toggleX, toggleY, toggleSize, toggleSize, Colors.Text, Layout.FrameRounding)
        if ref.enabled then
            local inset = 2
            DrawHelpers.RectFilled(
                toggleX + inset,
                toggleY + inset,
                toggleSize - inset * 2,
                toggleSize - inset * 2,
                UI.Toggle.OnColor,
                Layout.FrameRounding - 2
            )
        end
    end

    return clicked
end


function OptionManager.Submenu(label, submenu, tip)
    if OptionManager.Option(label, "", IconGlyphs.ArrowRight, tip) and submenu then
        Submenus.OpenSubmenu(submenu)
        return true
    end
    return false
end

return OptionManager
