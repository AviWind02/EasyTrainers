local Welcome = {}
local Draw = require("UI")

local windowW, windowH = 600, 640
local JsonHelper = require("Core/JsonHelper")
local configPath = "config.json"

-- Check once and cache result
local showWelcome = false
do
    local data = JsonHelper.Read(configPath)
    if not data or not data.shown then
        showWelcome = true
    end
end

local info = {
    "Welcome to EasyTrainer (Preview Build)",
    "",
    "Controls:",
    "- Keyboard: Arrow Keys = Navigate | Enter = Confirm | Backspace = Back",
    "- Controller: D-Pad = Navigate | A = Confirm | B = Back",
    "- CET Overlay: Drag to move, resize from window edges",
    "- Default Toggle Key: F4 (can be rebound in CET)",
    "- Controller Open Shortcut: D-Pad Right + A (not configurable)",

    "Notes:",
    "- Some gameplay inputs (e.g., driving) are blocked while navigating with keyboard arrows.",
    "- Controller inputs may override or disable certain in-game actions when the menu is open.",

    "",
    "Menu Tips:",
    "- Integer / Float Inputs: Use Left and Right Arrow keys to adjust values (auto-applies)",
    "- Toggles: Press Enter / A to toggle ON or OFF",
    "- Dropdowns: Press Enter to expand and browse options",
    "- RGB Buttons: Adjust four channels (R, G, B, A) using Left/Right keys for each value",
    "",
    "About EasyTrainer:",
    "An easy and flexible trainer for Cyberpunk 2077.",
    "Built for in-game use with both controller and keyboard support.",
    "Designed to feel familiar to anyone who's used GTA-style trainers.",
    "",
    "Open Source Info:",
    "This project is open-source. Feel free to explore, tweak, or extend it.",
    "Bug reports, ideas, or contributions are welcome.",
    "GitHub: https://github.com/AviWind02/EasyTrainers",
    "",
    "Credits:",
    "- Created by: Avi",
    "- Inspired by: SimpleMenu (Dank Rafft, capncoolio2)",
    "- Special Thanks: LocationKingGRP (Teleport data from Nexus)"
}



function Welcome.Render()
    if not showWelcome then return end

    local resX, resY = GetDisplayResolution()
    local winX, winY = (resX - windowW) / 2, (resY - windowH) / 2

    ImGui.SetNextWindowPos(winX, winY, ImGuiCond.Always)
    ImGui.SetNextWindowSize(windowW, windowH, ImGuiCond.Always)

    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 12.0)
    ImGui.PushStyleColor(ImGuiCol.WindowBg, 0.1, 0.1, 0.1, 0.95)
    ImGui.PushStyleColor(ImGuiCol.Border, 1, 0.75, 0.25, 0.2)

    if ImGui.Begin("EasyTrainerWelcome", ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoMove + ImGuiWindowFlags.NoTitleBar) then
        local centerX = ImGui.GetWindowWidth() / 2

        ImGui.SetCursorPosX(centerX - 100)
        ImGui.TextColored(1, 0.85, 0.35, 1, "Welcome to EasyTrainer")
        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        for _, line in ipairs(info) do
            if line == "" then
                ImGui.Spacing()
            elseif line:match("^https?://") then
                ImGui.TextColored(0.3, 0.7, 1, 1, line)
            else
                ImGui.TextWrapped(line)
            end
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        ImGui.SetCursorPosX(centerX - 100)
        ImGui.TextColored(0.6, 1, 0.6, 1, "Press Enter or A to continue")

        if ImGui.IsKeyPressed(ImGuiKey.Enter) or IsControllerConfirmPressed() then
            Welcome.Dismiss()
        end
    end

    ImGui.End()
    ImGui.PopStyleColor(2)
    ImGui.PopStyleVar()
end

function Welcome.Dismiss()
    showWelcome = false
    JsonHelper.Write(configPath, { shown = true }) 
end

function IsControllerConfirmPressed()
    return Draw.InputHandler.ControllerInput["close_tutorial"] and Draw.InputHandler.ControllerInput["close_tutorial"].value == true
end

return Welcome
