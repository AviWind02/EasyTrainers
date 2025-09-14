-- View/Settings/NavigationSettingsView.lua
local Buttons = require("UI").Buttons
local Handler = require("Controls/Handler")
local NavigationConfig = require("Config/NavigationConfig")
local Bindings = require("Controls/Bindings")

local scrollDelayRef = { value = Handler.scrollDelayBase, min = 50, max = 1000 }
local minDelayRef = { value = Handler.scrollMinDelay, min = 1, max = 200 }
local accelThresholdRef = { value = Handler.accelThreshold, min = 100, max = 5000 }
local accelStepRef = { value = Handler.accelStep, min = 1, max = 100 }

local function NavigationSettingsViewFunction()
    Buttons.Option("Save Navigation", "Save navigation speed settings", NavigationConfig.Save)
    Buttons.Option("Load Navigation", "Load saved navigation speed settings", NavigationConfig.Load)
    Buttons.Option("Reset Navigation", "Reset navigation speed settings to defaults", NavigationConfig.Reset)
    Buttons.Option("Reset All Bindings", "Restore all key/controller bindings to defaults", Bindings.ResetAll)

    Buttons.Break("Bindings")

    Buttons.Bind("Open Menu", "TOGGLE", "Rebind the open/close key")
    Buttons.Bind("Toggle Mouse", "TOGGLE_MOUSE", "Rebind toggle mouse key")
    Buttons.Bind("Up Navigation", "UP", "Rebind menu navigation up")
    Buttons.Bind("Down Navigation", "DOWN", "Rebind menu navigation down")
    Buttons.Bind("Left Navigation", "LEFT", "Rebind menu navigation left")
    Buttons.Bind("Right Navigation", "RIGHT", "Rebind menu navigation right")
    Buttons.Bind("Select", "SELECT", "Rebind select/confirm key")
    Buttons.Bind("Back", "BACK", "Rebind back key")
    Buttons.Bind("Misc", "MISC", "Rebind misc/extra key")

    Buttons.Break("Navigation Speed")
    if Buttons.Int("Scroll Delay Base", scrollDelayRef, "Base delay (ms) between repeated inputs when holding a navigation key") then
        Handler.scrollDelayBase = scrollDelayRef.value
    end
    if Buttons.Int("Scroll Min Delay", minDelayRef, "Minimum delay (ms) once accelerated scrolling kicks in") then
        Handler.scrollMinDelay = minDelayRef.value
    end
    if Buttons.Int("Acceleration Threshold", accelThresholdRef, "Time (ms) a key must be held before acceleration starts") then
        Handler.accelThreshold = accelThresholdRef.value
    end
    if Buttons.Int("Acceleration Step", accelStepRef, "How much the delay is reduced per step while holding") then
        Handler.accelStep = accelStepRef.value
    end
end

local NavigationSettingsView = { title = "Navigation Controls", view = NavigationSettingsViewFunction }

return NavigationSettingsView
