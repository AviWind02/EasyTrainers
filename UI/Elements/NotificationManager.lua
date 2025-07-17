local NotificationManager = {}

local UI = require("UI/Core/Style")
local DrawHelpers = require("UI/Core/DrawHelpers")
local OptionManager = require("UI/Elements/OptionManager")

NotificationManager.active = {}

local TypeColors = {
    info = UI.ColPalette.SoftWhite,
    success = UI.ColPalette.GlowGreen,
    warning = UI.ColPalette.GlowYellow,
    error = UI.ColPalette.SoftRed 
}

local width, padding, spacing = 300, 15, 6

local function resolveAutoPosition()
    local menuX, menuY = OptionManager.menuX or 0, OptionManager.menuY or 0
    local screenW, screenH = GetDisplayResolution()

    local topHalf = menuY < screenH / 2
    local leftHalf = menuX < screenW / 2

    if topHalf and leftHalf then return "TopRight"
    elseif topHalf then return "TopLeft"
    elseif leftHalf then return "BottomRight"
    else return "BottomLeft" end
end

function NotificationManager.Push(msg, duration, position, type)
    table.insert(NotificationManager.active, {
        msg = msg,
        time = os.clock(),
        duration = duration or 3.0,
        pos = (position == "Auto" or not position) and resolveAutoPosition() or position,
        type = type or "info"
    })
    --Logger.Log(string.format("[EasyTrainerNotificationManager] %s  Type: %s", type or "info", msg))
end

local function EstimateWrappedHeight(text, maxWidth)
    local totalWidth, lines = 0, 1
    for word in text:gmatch("%S+") do
        local wordWidth = ImGui.CalcTextSize(word .. " ")
        totalWidth = totalWidth + wordWidth
        if totalWidth > maxWidth then
            lines = lines + 1
            totalWidth = wordWidth
        end
    end
    return lines * ImGui.GetTextLineHeight()
end

local function GetNotificationPosition(pos, dynamicHeight, stackOffset, screenW, screenH)
    if pos == "TopLeft" then
        return padding, padding + stackOffset
    elseif pos == "TopRight" then
        return screenW - width - padding, padding + stackOffset
    elseif pos == "TopCenter" then
        return (screenW - width) / 2, padding + stackOffset
    elseif pos == "BottomLeft" then
        return padding, screenH - padding - dynamicHeight - stackOffset
    elseif pos == "BottomRight" then
        return screenW - width - padding, screenH - padding - dynamicHeight - stackOffset
    elseif pos == "BottomCenter" then
        return (screenW - width) / 2, screenH - padding - dynamicHeight - stackOffset
    end
    return padding, padding + stackOffset -- fallback
end

local function ApplySlideOffset(pos, x, y, elapsed, remaining)
    local animDuration = 0.2
    local offset = 0

    if elapsed < animDuration then
        offset = (1 - elapsed / animDuration) * 40
    elseif remaining < animDuration then
        offset = (1 - remaining / animDuration) * 40
    end

    if pos:find("Right") then x = x + offset
    elseif pos:find("Left") then x = x - offset
    else y = y - offset end

    return x, y
end

local function DrawNotificationWindow(i, x, y, dynamicHeight, msg, progress, ntype)
    ImGui.SetNextWindowPos(x, y)
    ImGui.SetNextWindowSize(width, dynamicHeight)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 6.0)

    ImGui.Begin("##Notification_" .. i,
        ImGuiWindowFlags.NoDecoration + ImGuiWindowFlags.NoInputs + ImGuiWindowFlags.NoSavedSettings)

    -- Text color based on type
    local color = TypeColors[ntype] or UI.Colors.Text
    local textX = x + padding
    local textY = y + padding
    local wrapWidth = width - padding * 2

    DrawHelpers.TextWrapped(textX, textY, color, msg, wrapWidth)

    ImGui.PushStyleColor(ImGuiCol.PlotHistogram, color)
    ImGui.SetCursorPosY(ImGui.GetWindowHeight() - 2)
    ImGui.ProgressBar(progress, -1, 10, "")
    ImGui.PopStyleColor()

    ImGui.End()
    ImGui.PopStyleVar()
end

function NotificationManager.Render()
    local now = os.clock()
    local screenW, screenH = GetDisplayResolution()
    local positionStacks = {}

    for i = #NotificationManager.active, 1, -1 do
        local n = NotificationManager.active[i]
        local elapsed = now - n.time
        local remaining = n.duration - elapsed

        if remaining <= 0 then
            table.remove(NotificationManager.active, i)
        else
            local progress = math.max(0, remaining / n.duration)
            local pos = n.pos or "TopLeft"
            local stackOffset = positionStacks[pos] or 0

            local textHeight = EstimateWrappedHeight(n.msg, width - padding * 2)
            local dynamicHeight = textHeight + padding * 2 + 8

            local x, y = GetNotificationPosition(pos, dynamicHeight, stackOffset, screenW, screenH)
            x, y = ApplySlideOffset(pos, x, y, elapsed, remaining)

            DrawNotificationWindow(i, x, y, dynamicHeight, n.msg, progress, n.type)

            positionStacks[pos] = stackOffset + dynamicHeight + spacing
        end
    end
end

return NotificationManager
