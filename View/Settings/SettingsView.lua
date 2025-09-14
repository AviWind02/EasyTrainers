-- View/Settings/SettingsView.lua
local Buttons = require("UI").Buttons

local LayoutView = require("View/Settings/LayoutView")
local FrameView = require("View/Settings/FrameView")
local NotificationView = require("View/Settings/NotificationView")
local InfoBoxView = require("View/Settings/InfoBoxView")
local SimpleControlsView = require("View/Settings/SimpleControlsView")
local SelectionControlsView = require("View/Settings/SelectionControlsView")
local InputControlsView = require("View/Settings/InputControlsView")
local NavigationView = require("View/Settings/NavigationView")
local TextInputView = require("View/Settings/TextInputView")

local ResetUI = require("UI/Core/ResetUI")

local UIConfig = require("Config/UIConfig")
local NavigationConfig = require("Config/NavigationConfig")
local Bindings = require("Controls/Bindings")

local function SettingsViewFunction()
    Buttons.Submenu("Layout & Option Row", LayoutView, "Adjust layout and option row settings")
    Buttons.Submenu("Header & Footer", FrameView, "Adjust header and footer settings")
    Buttons.Submenu("Notifications", NotificationView, "Customize notification settings")
    Buttons.Submenu("Info Box", InfoBoxView, "Adjust info box settings")
    Buttons.Submenu("Simple Buttons", SimpleControlsView, "Configure break row, dropdown, and string cycler")
    Buttons.Submenu("Selection Buttons", SelectionControlsView, "Configure toggle and radio buttons")
    Buttons.Submenu("Input Buttons", InputControlsView, "Configure numeric and color picker controls")
    Buttons.Submenu("Navigation Controls", NavigationView, "Adjust navigation bindings and speed")
    Buttons.Submenu("Text Input", TextInputView, "Adjust text input dialog settings")
    if Buttons.Option("Reset All Settings", "Reset all UI and navigation(bindings) settings to defaults") then
        ResetUI.ResetAll()
        NavigationConfig.Reset()
        Bindings.ResetAll()
    end

    if Buttons.Option("Save All Settings", "Save all UI and navigation settings to config files") then
        UIConfig.Save()
        NavigationConfig.Save()
    end
end

local SettingsView = { title = "Settings", view = SettingsViewFunction }

return SettingsView
