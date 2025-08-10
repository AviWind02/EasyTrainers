local OptionManager = {}
-- To do add variables into style sheet To be edited later in the settings menu
-- Also need to move each option into its own file
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

    local mouseX, mouseY = ImGui.GetMousePos()
    local hovered = mouseX >= pos.x and mouseX <= (pos.x + pos.w) and
                    mouseY >= pos.y and mouseY <= (pos.y + pos.h)

    if Controls.overlayOpen then
        if hovered and ImGui.IsMouseClicked(0) then
            Submenus.currentOption = Submenus.optionIndex
        end
    end


    if hovered and Controls.overlayOpen then
        DrawHelpers.RectFilled(pos.x, pos.y, pos.w, pos.h, UI.Colors.MutedText, UI.Layout.FrameRounding)
    end

    if OptionManager.IsSelected() then
        OptionManager.smoothY = OptionManager.smoothY + (pos.y - OptionManager.smoothY) * UI.Animation.SmoothSpeed
        DrawHelpers.RectFilled(pos.x, OptionManager.smoothY, pos.w, pos.h, highlightColor, UI.Layout.FrameRounding)
    end

    if left and left ~= "" then
        DrawHelpers.Text(pos.x + UI.Layout.LabelOffsetX, pos.fontY, textColor, left)
    end

    if center and center ~= "" then
        local textW = ImGui.CalcTextSize(center)
        local centerX = pos.x + (pos.w - textW) * 0.5
        DrawHelpers.Text(centerX, pos.fontY, textColor, center)
    end

    if right and right ~= "" then
        local textW = ImGui.CalcTextSize(right)
        local rightX = pos.x + pos.w - UI.Layout.LabelOffsetX - textW
        DrawHelpers.Text(rightX, pos.fontY, textColor, right)
    end

    return OptionManager.IsSelected() and (Controls.selectPressed or (Controls.overlayOpen and (hovered and ImGui.IsMouseClicked(0))))
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
    local keyTip = L("optionmanager.dropdown_tip")
    local fullTip = keyTip .. (tip and ("\n\n" .. tip) or "")
    local arrow = ref.expanded and IconGlyphs.CircleExpand or IconGlyphs.ArrowExpandAll
    local selectedLabel = L(options[ref.index or 1]) or L("optionmanager.none")
    local clicked = OptionManager.Option(label, nil, selectedLabel .. " " .. arrow, fullTip)

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
            local label = "- " .. L(options[i])
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
        local stateText = ref.value and L("optionmanager.on") or L("optionmanager.off")
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
    local keyTip = L("optionmanager.inttoggle_tip")
    local fullTip = keyTip .. (tip and ("\n\n" .. tip) or "")
    local clicked = OptionManager.Option(label, "", "", fullTip)
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

    local originalValue = ref.value
    local originalEnabled = ref.enabled

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

    local valueChanged = (ref.value ~= originalValue) or (ref.enabled ~= originalEnabled)
    return clicked or valueChanged
end




function OptionManager.FloatToggle(label, ref, tip)
    local keyTip = L("optionmanager.float_toggle_tip")
    local fullTip = keyTip .. (tip and ("\n\n" .. tip) or "")
    local clicked = OptionManager.Option(label, "", "", fullTip)
    local pos = OptionManager._calcPosition()
	if not pos then return false end

	local Layout, Colors = UI.Layout, UI.Colors
	local toggleSize = 18
	local toggleSpacing = 10
	local framePadding = 6
	local textPadding = 3
	local decimalPlaces = 2

	local oldValue = ref.value
	local oldEnabled = ref.enabled

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

	local minVal = ref.min or 0
	local maxVal = ref.max or 1
	ref.value = math.max(minVal, math.min(maxVal, tonumber(string.format("%.2f", ref.value))))
	local valueText = string.format("%." .. decimalPlaces .. "f / %.2f", ref.value, maxVal)
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

	local valueChanged = (ref.value ~= oldValue) or (ref.enabled ~= oldEnabled)
	return clicked or valueChanged
end



function OptionManager.Submenu(label, submenu, tip)
    if OptionManager.Option(label, "", IconGlyphs.ArrowRight, tip) and submenu then
        Submenus.OpenSubmenu(submenu)
        return true
    end
    return false
end


function OptionManager.Radio(label, ref, options, tip)


    local changed = false
    for i, option in ipairs(options) do
        local isSelected = (ref.index == i)
        local clicked = OptionManager.Option(option, "", "", tip)

        local pos = OptionManager._calcPosition()
        if pos then
            local radius = 6
            local cx = pos.x + pos.w - UI.Layout.LabelOffsetX - radius
            local cy = pos.y + (pos.h / 2)

            local drawlist = ImGui.GetWindowDrawList()
            if isSelected then
                ImGui.ImDrawListAddCircleFilled(drawlist, cx, cy, radius, UI.Toggle.OnColor)
            else
                ImGui.ImDrawListAddCircle(drawlist, cx, cy, radius, UI.Colors.Text, 20, 1.5)
            end

            if clicked then
                ref.index = i
                changed = true
            end
        end
    end
    return changed
end

function OptionManager.StringCycler(label, ref, options, tip)
    local keyTip = L("optionmanager.stringcycler_tip")
    local fullTip = keyTip .. (tip and ("\n\n" .. tip) or "")
    local clicked = OptionManager.Option(label, "", "", fullTip)
    local pos = OptionManager._calcPosition()
    if not pos then return false end

    local Layout, Colors = UI.Layout, UI.Colors

    local currentIndex = ref.index or 1
    local currentText = L(options[currentIndex]) or "None"
    local valueTextWidth = ImGui.CalcTextSize(currentText)

    local framePadding = 6
    local textPadding = 3

    local boxX = pos.x + pos.w - Layout.LabelOffsetX - valueTextWidth - framePadding * 2
    local boxY = pos.y + textPadding
    local boxW = valueTextWidth + framePadding * 2
    local boxH = pos.h - textPadding * 2

    DrawHelpers.RectFilled(boxX, boxY, boxW, boxH, Colors.FrameBg, Layout.FrameRounding)

    DrawHelpers.Text(boxX + framePadding, pos.fontY, Colors.Highlight, currentText)

    -- Navigation logic
    if pos.isActive then
        if Controls.leftPressed then
            ref.index = currentIndex - 1
            if ref.index < 1 then ref.index = #options end
        elseif Controls.rightPressed then
            ref.index = currentIndex + 1
            if ref.index > #options then ref.index = 1 end
        end
    end

    return clicked
end




function OptionManager.Color(label, ref, tip)
    local keyTip = L("optionmanager.color_tip")
    local fullTip = (tip and (tip .. "\n\n") or "") .. keyTip
    local clicked = OptionManager.Option(label, "", "", fullTip)
    local pos = OptionManager._calcPosition()
    if not pos then return false end

    local squareSize = UI.ColorPicker.ChannelBoxSize
    local squareX = pos.x + pos.w - UI.Layout.LabelOffsetX - squareSize
    local squareY = pos.y + (pos.h - squareSize) * 0.5
    local u32 = ImGui.ColorConvertFloat4ToU32({
        ref.Red / 255,
        ref.Green / 255,
        ref.Blue / 255,
        ref.Alpha / 255
    })
    DrawHelpers.RectFilled(squareX, squareY, squareSize, squareSize, u32, UI.Layout.FrameRounding)

    ref._expanded = ref._expanded or false
    ref._reveal = ref._reveal or 0
    ref._lastFrame = ref._lastFrame or 0

    if clicked then
        ref._expanded = not ref._expanded
        if ref._expanded then
            ref._reveal = 0
            ref._lastFrame = ImGui.GetFrameCount()
        end
    end
    if not ref._expanded then return false end

    local channelNames = { "- Red", "- Green", "- Blue", "- Alpha" }
    local channelKeys = { "Red", "Green", "Blue", "Alpha" }

    local changed = false
    local currentFrame = ImGui.GetFrameCount()
    local framesPerOption = 3

    if ref._reveal < 4 then
        if currentFrame - ref._lastFrame >= framesPerOption then
            ref._reveal = ref._reveal + 1
            ref._lastFrame = currentFrame
        end
    end

    for i = 1, ref._reveal do
        local key = channelKeys[i]
        local label = channelNames[i]
        local value = ref[key] or 0
        OptionManager.Option(label, "", "", nil)
        local pos = OptionManager._calcPosition()
        if not pos then break end

        local valueText = string.format("%d / 255", value)
        local valueTextWidth = ImGui.CalcTextSize(valueText)
        local boxW = valueTextWidth + 10
        local boxH = pos.h - UI.ColorPicker.RowSpacing
        local boxX = pos.x + pos.w - UI.Layout.LabelOffsetX - UI.ColorPicker.PreviewBoxSize - boxW - UI.ColorPicker.ChannelPadding
        local boxY = pos.y + (pos.h - boxH) * 0.5
        DrawHelpers.RectFilled(boxX, boxY, boxW, boxH, UI.Colors.FrameBg, UI.Layout.FrameRounding)
        DrawHelpers.Text(boxX + 5, pos.fontY, UI.Colors.Text, valueText)

        local previewX = pos.x + pos.w - UI.Layout.LabelOffsetX - UI.ColorPicker.PreviewBoxSize
        local previewY = pos.y + (pos.h - UI.ColorPicker.PreviewBoxSize) * 0.5

        local previewColor = { 0, 0, 0, 1 }
        previewColor[i] = value / 255
        local u32 = ImGui.ColorConvertFloat4ToU32(previewColor)
        DrawHelpers.Rect(previewX, previewY, UI.ColorPicker.PreviewBoxSize, UI.ColorPicker.PreviewBoxSize, UI.Colors.Text, UI.Layout.FrameRounding)
        DrawHelpers.RectFilled(previewX + 2, previewY + 2, UI.ColorPicker.PreviewBoxSize - 4, UI.ColorPicker.PreviewBoxSize - 4, u32, UI.Layout.FrameRounding - 2)

        if pos.isActive then
            if Controls.leftPressed then
                value = value == 0 and 255 or value - 1
                changed = true
            elseif Controls.rightPressed then
                value = value == 255 and 0 or value + 1
                changed = true
            end
            ref[key] = value
        end
    end

    return changed
end





return OptionManager