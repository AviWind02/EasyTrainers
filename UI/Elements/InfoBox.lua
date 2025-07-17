
local InfoBox = {}

local UI = require("UI/Core/Style")
local DrawHelpers = require("UI/Core/DrawHelpers")
local OptionManager = require("UI/Elements/OptionManager")

InfoBox.currentText = ""
InfoBox.lastText = ""
InfoBox.animatedText = ""
InfoBox.charIndex = 0
InfoBox.animStartTime = 0.0

local charsPerSecond = 100.0

function InfoBox.SetText(text)
    if text ~= InfoBox.currentText then
        InfoBox.currentText = text
    end
end

function InfoBox.Render(menuX, menuY, menuW, menuH)

    local now = ImGui.GetTime()

    if InfoBox.currentText ~= InfoBox.lastText then
        InfoBox.lastText = InfoBox.currentText
        InfoBox.animatedText = ""
        InfoBox.charIndex = 0
        InfoBox.animStartTime = now
    end

    local targetChars = math.floor((now - InfoBox.animStartTime) * charsPerSecond)
    if targetChars > InfoBox.charIndex then
        InfoBox.charIndex = math.min(targetChars, #InfoBox.currentText)
        InfoBox.animatedText = InfoBox.currentText:sub(1, InfoBox.charIndex)
    end

    local pad = UI.Layout.Padding
    local spacing = 15.0
    local screenW, screenH = GetDisplayResolution()

    
    local boxW = menuW
    local textW, textH = ImGui.CalcTextSize(InfoBox.animatedText, false, boxW - 2 * pad)
    local boxH = textH + 2 * pad

    local belowY = menuY + menuH + spacing
    local aboveY = menuY - boxH - spacing
    local useAbove = (belowY + boxH > screenH)
    local finalY = useAbove and aboveY or belowY
    local finalX = menuX

    ImGui.SetNextWindowPos(finalX, finalY)
    ImGui.SetNextWindowSize(boxW, boxH)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, UI.Layout.FrameRounding)

    ImGui.Begin("##InfoBoxWindow", ImGuiWindowFlags.NoDecoration + ImGuiWindowFlags.NoInputs + ImGuiWindowFlags.NoSavedSettings)
    
    local winX, winY = ImGui.GetWindowPos()
    local wrapWidth = boxW - 2 * pad

    DrawHelpers.TextWrapped(winX + pad, winY + pad, UI.Colors.Text, InfoBox.animatedText, wrapWidth)


    ImGui.End()
    ImGui.PopStyleVar()
end



return InfoBox
