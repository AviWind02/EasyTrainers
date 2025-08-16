local OptionManager = {}
local UI = require("UI/Core/Style")
local DrawHelpers = require("UI/Core/DrawHelpers")
local Controls = require("UI/Gamepad/InputHandler")
local Submenus = require("UI/Core/SubmenuManager")
local InfoBox = require("UI/Elements/InfoBox")

OptionManager.smoothY = 0
OptionManager.menuX, OptionManager.menuY, OptionManager.menuW, OptionManager.menuH = 0, 0, 0, 0
OptionManager.maxVisible, OptionManager.startOpt, OptionManager.endOpt = 0, 1, 1

local function _isSelected()
    return Submenus.optionIndex == Submenus.currentOption
end

function OptionManager.IsSelected()
    return _isSelected()
end

function OptionManager.SetMenuBounds(x, y, w, h)
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
    if Submenus.optionIndex < OptionManager.startOpt or Submenus.optionIndex > OptionManager.endOpt then return nil end
    local L = UI.Layout
    local rel = Submenus.optionIndex - OptionManager.startOpt
    local x = OptionManager.menuX + L.OptionPaddingX
    local y = OptionManager.menuY + L.OptionPaddingY + (UI.Header.Height or 0) + rel * (L.OptionHeight + L.ItemSpacing.y)
    local w = OptionManager.menuW - L.OptionPaddingX * 2
    local h = L.OptionHeight
    local fontY = y + (h - ImGui.GetFontSize()) * 0.5
    local active = Submenus.optionIndex == Submenus.currentOption
    if active then OptionManager.smoothY = OptionManager.smoothY + (y - OptionManager.smoothY) * UI.Animation.SmoothSpeed end
    return {x = x, y = y, w = w, h = h, fontY = fontY, isActive = active}
end

local function _mouseHovered(pos)
    local mx, my = ImGui.GetMousePos()
    return mx >= pos.x and mx <= (pos.x + pos.w) and my >= pos.y and my <= (pos.y + pos.h)
end

local function _drawLeft(pos, color, text)
    DrawHelpers.Text(pos.x + UI.Layout.LabelOffsetX, pos.fontY, color, text)
end

local function _drawCenter(pos, color, text)
    local w = ImGui.CalcTextSize(text)
    local cx = pos.x + (pos.w - w) * 0.5
    DrawHelpers.Text(cx, pos.fontY, color, text)
end

local function _drawRight(pos, color, text)
    local w = ImGui.CalcTextSize(text)
    local rx = pos.x + pos.w - UI.Layout.LabelOffsetX - w
    DrawHelpers.Text(rx, pos.fontY, color, text)
end

local function _clickedByMouse(hovered)
    return Controls.overlayOpen and hovered and ImGui.IsMouseClicked(0)
end

function OptionManager.RawOption(left, center, right, textColor, highlightColor)
    Submenus.optionIndex = Submenus.optionIndex + 1
    local pos = OptionManager._calcPosition()
    if not pos then return false end
    local hovered = _mouseHovered(pos)

    if Controls.overlayOpen and hovered and ImGui.IsMouseClicked(0) then
        Submenus.currentOption = Submenus.optionIndex
    end

    if hovered and Controls.overlayOpen then
        DrawHelpers.RectFilled(pos.x, pos.y, pos.w, pos.h, UI.OptionRow.HoverBg, UI.OptionRow.Rounding)
    end

    if _isSelected() then
        OptionManager.smoothY = OptionManager.smoothY + (pos.y - OptionManager.smoothY) * UI.Animation.SmoothSpeed
        DrawHelpers.RectFilled(pos.x, OptionManager.smoothY, pos.w, pos.h, highlightColor, UI.OptionRow.Rounding)
    end

    if left and left ~= "" then _drawLeft(pos, textColor, left) end
    if center and center ~= "" then _drawCenter(pos, textColor, center) end
    if right and right ~= "" then _drawRight(pos, textColor, right) end

    return _isSelected() and (Controls.selectPressed or _clickedByMouse(hovered))
end

function OptionManager.Option(left, center, right, tip)
    local clicked = OptionManager.RawOption(left, center, right, UI.OptionRow.Text, UI.OptionRow.HighlightBg)
    if _isSelected() then InfoBox.SetText(tip or "") end
    return clicked
end

function OptionManager.Break(left, center, right)
    local current = Submenus.currentOption
    OptionManager.RawOption(left, center, right, UI.OptionRow.MutedText, UI.OptionRow.HighlightBg)
    if _isSelected() then
        if Controls.downPressed then Submenus.currentOption = current + 1
        elseif Controls.upPressed then Submenus.currentOption = current - 1 end
    end
    return false
end

function OptionManager.Dropdown(label, ref, options, tip)
    local keyTip = L("optionmanager.dropdown_tip")
    local fullTip = keyTip .. (tip and ("\n\n" .. tip) or "")
    local arrow = ref.expanded and UI.Dropdown.ArrowDown or UI.Dropdown.ArrowRight
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

    if not ref.expanded then return end

    local cur = ImGui.GetFrameCount()
    local fpo = UI.Dropdown.FramesPerOption or UI.Dropdown.RevealFrameDelay or 3
    if (ref.revealProgress or 0) < #options then
        if cur - (ref.lastRevealFrame or 0) >= fpo then
            ref.revealProgress = (ref.revealProgress or 0) + 1
            ref.lastRevealFrame = cur
        end
    end

    for i = 1, (ref.revealProgress or 0) do
        local rowLabel = "- " .. L(options[i])
        local isSel = (ref.index == i)
        if OptionManager.Option(rowLabel, nil, isSel and IconGlyphs.CheckBold or "") then
            ref.index = i
            ref.expanded = false
            ref.revealProgress = nil
            ref.lastRevealFrame = nil
            Submenus.currentOption = Submenus.optionIndex - i
            break
        end
    end
end

function OptionManager.Toggle(label, ref, tip)
    local clicked = OptionManager.Option(label, "", "", tip)
    local pos = OptionManager._calcPosition()
    if not pos then return end

    local size = UI.Toggle.Size
    local tx = pos.x + pos.w - UI.Layout.LabelOffsetX - size
    local ty = pos.y + (pos.h - size) * 0.5

    if pos.isActive then
        local stateText = ref.value and L("optionmanager.on") or L("optionmanager.off")
        local w = ImGui.CalcTextSize(stateText)
        local pad = UI.Toggle.StatePadding
        local spacing = UI.Toggle.StateSpacing
        local sx = tx - w - (pad + spacing)
        local sy = ty - 2
        DrawHelpers.RectFilled(sx - pad, sy, w + pad * 2, size + 4, UI.Toggle.FrameBg, UI.Toggle.Rounding)
        DrawHelpers.Text(sx, pos.fontY, UI.Colors.Text, stateText)
    end

    DrawHelpers.Rect(tx, ty, size, size, UI.Toggle.BorderColor, UI.Toggle.Rounding)
    if ref.value then
        local inset = UI.Toggle.Inset
        DrawHelpers.RectFilled(tx + inset, ty + inset, size - inset * 2, size - inset * 2, UI.Toggle.OnColor, UI.Toggle.Rounding - 2)
    end

    if clicked then ref.value = not ref.value end
    return clicked
end

local function _numericToggleCommon(label, ref, tip, isFloat)
    local keyTip = isFloat and L("optionmanager.float_toggle_tip") or L("optionmanager.inttoggle_tip")
    local fullTip = keyTip .. (tip and ("\n\n" .. tip) or "")
    local clicked = OptionManager.Option(label, "", "", fullTip)
    local pos = OptionManager._calcPosition()
    if not pos then return false end

    local size = UI.Numeric.ToggleSize
    local spacing = UI.Numeric.ToggleSpacing
    local fpad = UI.Numeric.BoxFramePadding
    local tpad = UI.Numeric.BoxTextPadding

    local minVal = ref.min or 0
    local maxVal = ref.max or (isFloat and 1 or 100)
    local step = ref.step or (isFloat and 0.1 or 1)
    local oldVal = ref.value
    local oldEnabled = ref.enabled

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

    if isFloat then
        local d = UI.Numeric.Decimals or 2
        ref.value = tonumber(string.format("%." .. d .. "f", math.max(minVal, math.min(maxVal, ref.value))))
    else
        ref.value = math.max(minVal, math.min(maxVal, ref.value))
    end

    local valueText = isFloat
        and string.format("%." .. (UI.Numeric.Decimals or 2) .. "f / %.2f", ref.value, maxVal)
        or string.format("%d / %d", ref.value, maxVal)

    local vw = ImGui.CalcTextSize(valueText)
    local toggleX = pos.x + pos.w - UI.Layout.LabelOffsetX - (ref.enabled ~= nil and size or 0)
    local valueX = toggleX - vw - (ref.enabled ~= nil and spacing or 0)
    local toggleY = pos.y + (pos.h - size) * 0.5

    local totalW = vw + (ref.enabled ~= nil and size + spacing or 0)
    DrawHelpers.RectFilled(valueX - fpad, pos.y + tpad, totalW + fpad * 2, pos.h - tpad * 2, UI.Numeric.FrameBg, UI.Layout.FrameRounding)

    local txtColor = (ref.enabled == false) and UI.Colors.MutedText or UI.Colors.Text
    DrawHelpers.Text(valueX, pos.fontY, txtColor, valueText)

    if ref.enabled ~= nil then
        DrawHelpers.Rect(toggleX, toggleY, size, size, UI.Colors.Text, UI.Layout.FrameRounding)
        if ref.enabled then
            local inset = UI.Toggle.Inset
            DrawHelpers.RectFilled(toggleX + inset, toggleY + inset, size - inset * 2, size - inset * 2, UI.Toggle.OnColor, UI.Layout.FrameRounding - 2)
        end
    end

    local changed = (ref.value ~= oldVal) or (ref.enabled ~= oldEnabled)
    return clicked or changed
end

function OptionManager.IntToggle(label, ref, tip)
    return _numericToggleCommon(label, ref, tip, false)
end

function OptionManager.FloatToggle(label, ref, tip)
    return _numericToggleCommon(label, ref, tip, true)
end

function OptionManager.Submenu(label, submenu, tip)
    if OptionManager.Option(label, "", UI.Submenu.Arrow, tip) and submenu then
        Submenus.OpenSubmenu(submenu)
        return true
    end
    return false
end

function OptionManager.Radio(label, ref, options, tip)
    local changed = false
    for i, option in ipairs(options) do
        local isSel = (ref.index == i)
        local clicked = OptionManager.Option(option, "", "", tip)
        local pos = OptionManager._calcPosition()
        if pos then
            local r = UI.Radio.Radius
            local cx = pos.x + pos.w - UI.Layout.LabelOffsetX - r
            local cy = pos.y + (pos.h * 0.5)
            local dl = ImGui.GetWindowDrawList()
            if isSel then
                ImGui.ImDrawListAddCircleFilled(dl, cx, cy, r, UI.Radio.SelectedColor)
            else
                ImGui.ImDrawListAddCircle(dl, cx, cy, r, UI.Radio.UnselectedColor, UI.Radio.Segments, UI.Radio.LineThickness)
            end
            if clicked then ref.index = i; changed = true end
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

    local idx = ref.index or 1
    local text = L(options[idx]) or "None"
    local tw = ImGui.CalcTextSize(text)
    local fpad = UI.StringCycler.FramePadding
    local tpad = UI.StringCycler.TextPadding
    local bx = pos.x + pos.w - UI.Layout.LabelOffsetX - tw - fpad * 2
    local by = pos.y + tpad
    local bw = tw + fpad * 2
    local bh = pos.h - tpad * 2

    DrawHelpers.RectFilled(bx, by, bw, bh, UI.StringCycler.FrameBg, UI.StringCycler.BoxRounding)
    DrawHelpers.Text(bx + fpad, pos.fontY, UI.StringCycler.ValueColor, text)

    if pos.isActive then
        if Controls.leftPressed then
            ref.index = idx - 1
            if ref.index < 1 then ref.index = #options end
        elseif Controls.rightPressed then
            ref.index = idx + 1
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

    local size = UI.ColorPicker.ChannelBoxSize
    local sx = pos.x + pos.w - UI.Layout.LabelOffsetX - size
    local sy = pos.y + (pos.h - size) * 0.5
    local u32 = ImGui.ColorConvertFloat4ToU32({
        ref.Red / 255, ref.Green / 255, ref.Blue / 255, ref.Alpha / 255
    })
    DrawHelpers.RectFilled(sx, sy, size, size, u32, UI.Layout.FrameRounding)

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

    local names = {"- Red", "- Green", "- Blue", "- Alpha"}
    local keys = {"Red", "Green", "Blue", "Alpha"}
    local changed = false
    local cur = ImGui.GetFrameCount()
    local fpo = UI.Dropdown.FramesPerOption or 3

    if ref._reveal < 4 and cur - ref._lastFrame >= fpo then
        ref._reveal = ref._reveal + 1
        ref._lastFrame = cur
    end

    for i = 1, ref._reveal do
        local k = keys[i]
        local row = names[i]
        local val = ref[k] or 0
        OptionManager.Option(row, "", "", nil)
        local p = OptionManager._calcPosition()
        if not p then break end

        local valueText = string.format("%d / 255", val)
        local vw = ImGui.CalcTextSize(valueText)
        local boxW = vw + 10
        local boxH = p.h - UI.ColorPicker.RowSpacing
        local boxX = p.x + p.w - UI.Layout.LabelOffsetX - UI.ColorPicker.PreviewBoxSize - boxW - UI.ColorPicker.ChannelPadding
        local boxY = p.y + (p.h - boxH) * 0.5
        DrawHelpers.RectFilled(boxX, boxY, boxW, boxH, UI.Colors.FrameBg, UI.Layout.FrameRounding)
        DrawHelpers.Text(boxX + 5, p.fontY, UI.Colors.Text, valueText)

        local px = p.x + p.w - UI.Layout.LabelOffsetX - UI.ColorPicker.PreviewBoxSize
        local py = p.y + (p.h - UI.ColorPicker.PreviewBoxSize) * 0.5
        local prev = {0, 0, 0, 1}
        prev[i] = val / 255
        local u = ImGui.ColorConvertFloat4ToU32(prev)
        DrawHelpers.Rect(px, py, UI.ColorPicker.PreviewBoxSize, UI.ColorPicker.PreviewBoxSize, UI.Colors.Text, UI.Layout.FrameRounding)
        DrawHelpers.RectFilled(px + 2, py + 2, UI.ColorPicker.PreviewBoxSize - 4, UI.ColorPicker.PreviewBoxSize - 4, u, UI.Layout.FrameRounding - 2)

        if p.isActive then
            if Controls.leftPressed then val = val == 0 and 255 or val - 1; changed = true
            elseif Controls.rightPressed then val = val == 255 and 0 or val + 1; changed = true end
            ref[k] = val
        end
    end

    return changed
end

return OptionManager
