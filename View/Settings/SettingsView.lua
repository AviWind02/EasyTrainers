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
local TranslationsView = require("View/Settings/TranslationsView")

local ResetUI = require("UI/Core/ResetUI")

local UIConfig = require("Config/UIConfig")
local NavigationConfig = require("Config/NavigationConfig")
local Bindings = require("Controls/Bindings")

local function SettingsViewFunction()
    Buttons.Submenu(L("settingsmenu.navigation.label"), NavigationView, tip("settingsmenu.navigation.tip"))
    Buttons.Submenu(L("settingsmenu.translations.label"), TranslationsView, tip("settingsmenu.translations.tip"))

    Buttons.Break(L("settingsmenu.ui.label"))
    Buttons.Submenu(L("settingsmenu.layout.label"), LayoutView, tip("settingsmenu.layout.tip"))
    Buttons.Submenu(L("settingsmenu.frame.label"), FrameView, tip("settingsmenu.frame.tip"))
    Buttons.Submenu(L("settingsmenu.notifications.label"), NotificationView, tip("settingsmenu.notifications.tip"))
    Buttons.Submenu(L("settingsmenu.infobox.label"), InfoBoxView, tip("settingsmenu.infobox.tip"))
    Buttons.Submenu(L("settingsmenu.simplecontrols.label"), SimpleControlsView, tip("settingsmenu.simplecontrols.tip"))
    Buttons.Submenu(L("settingsmenu.selectioncontrols.label"), SelectionControlsView, tip("settingsmenu.selectioncontrols.tip"))
    Buttons.Submenu(L("settingsmenu.inputcontrols.label"), InputControlsView, tip("settingsmenu.inputcontrols.tip"))
    Buttons.Submenu(L("settingsmenu.textinput.label"), TextInputView, tip("settingsmenu.textinput.tip"))

    if Buttons.Option(L("settingsmenu.resetall.label"), tip("settingsmenu.resetall.tip")) then
        ResetUI.ResetAll()
        NavigationConfig.Reset()
        Bindings.ResetAll()
    end

    if Buttons.Option(L("settingsmenu.saveall.label"), tip("settingsmenu.saveall.tip")) then
        UIConfig.Save()
        NavigationConfig.Save()
    end
end

local SettingsView = { title = "settingsmenu.title", view = SettingsViewFunction }

return SettingsView

