local UI = require("UI")
local Logger = require("Core/Logger")

local OptionBOUND = require("UI/Options/Option")
local DrawHelpers = require("UI/Core/DrawHelpers")
local OptionRow = require("UI/Elements/OptionRow")

local Header  = require("UI/Frame/Header")
local Footer  = require("UI/Frame/Footer")

local SelfFeature = require("Features/Self")
local WeaponsFeature = require("Features/Weapons")
local TeleportTester = require("Features/Teleports/TeleportTester")

local TelportConfig = require("Features/Teleports/TeleportConfig")
local VehicleConfig = require("Features/Vehicles/VehicleConfig")

local SelfView = require("View/Self/SelfMenuView")
local SelfDevelopmentView = require("View/Self/SelfDevelopment")
local SelfModifiersView = require("View/Self/SelfModifierView")
local TeleportView = require("View/Teleports/TeleportView")
local WeaponView = require("View/Weapons/WeaponMenuView")
local VehicleMenuView = require("View/Vehicle/VehicleMenuView")
local SettingsView = require("View/Settings/SettingsView")
local TestForceView = require("View/TestForceView")


local testToggle = { value = false }
local testInt = { value = 5, min = 0, max = 10 }
local testFloat = { value = 0.5, min = 0.0, max = 1.0, step = 0.1, enabled = true }
local dropdownRef = { index = 2, expanded = false }
local dropdownRef2 = { index = 2, expanded = false }
local languages = { "English", "French", "Spanish", "German", "Japanese" }
local weaponTypes = { "Pistol", "SMG", "Rifle", "Shotgun", "Sniper" }
local selectedTarget = { index = 1 }
local targetOptions = { "Player", "Weapon", "Vehicle" }
local stringRef = { index = 1 }
local colorRef = { Red = 128, Green = 200, Blue = 255, Alpha = 255 }
local textRef = { value = "" }

local function SecondaryView()
    if UI.Buttons.Option("Basic Option", "This is a basic option") then
        Logger.Log("Basic option clicked")
    end

    UI.Buttons.Option("Centered Option")
    UI.Buttons.Break("Section Break")

    if UI.Buttons.Option("Option 1") then
        Logger.Log("Option 1 clicked")
    end

    if UI.Buttons.Text("Enter Name", textRef, "Type your custom text") then
        Logger.Log("You typed: " .. (textRef.value or ""))
    end

    UI.Buttons.Bind("Open Menu", "TOGGLE", "Rebind the open/close key")
    UI.Buttons.Bind("Up Navigation", "UP", "Rebind menu navigation up")
    UI.Buttons.Bind("Down Navigation", "DOWN", "Rebind menu navigation down")
    UI.Buttons.Bind("Back", "BACK", "Rebind back key")

    UI.Buttons.Color("Pick Color", colorRef, "Adjust RGBA color")
    UI.Buttons.Dropdown("Weapon Type", dropdownRef, weaponTypes, "Pick a weapon type")
    UI.Buttons.Dropdown("Language", dropdownRef2, languages, "Pick a language")
    UI.Buttons.Toggle("Test Toggle", testToggle, "Toggle something")
    UI.Buttons.Int("Test Int", testInt, "Adjust integer")
    UI.Buttons.Float("Test Float", testFloat, "Adjust float value")
    UI.Buttons.Radio("Target", selectedTarget, targetOptions, "Choose target")
    UI.Buttons.StringCycler("Cycle String", stringRef, { "One", "Two", "Three" }, "Cycle through strings")
end

local testMenu = { title = "Test Menu", view = SecondaryView }
local World = require("Utils/World")


local function MainMenuView()
    UI.Buttons.Submenu(L("mainmenu.self.label"), SelfView, tip("mainmenu.self.tip"))
    UI.Buttons.Submenu(L("mainmenu.development.label"), SelfDevelopmentView, tip("mainmenu.development.tip"))
    UI.Buttons.Submenu(L("mainmenu.modifiers.label"), SelfModifiersView, tip("mainmenu.modifiers.tip"))
    UI.Buttons.Submenu(L("mainmenu.teleport.label"), TeleportView, tip("mainmenu.teleport.tip"))
    UI.Buttons.Submenu(L("mainmenu.weapon.label"), WeaponView, tip("mainmenu.weapon.tip"))
    UI.Buttons.Submenu(L("mainmenu.vehicle.label"), VehicleMenuView, tip("mainmenu.vehicle.tip"))
    UI.Buttons.Submenu("Settings", SettingsView, "Try all options here")

end

local MainMenu = { title = "EasyTrainer", view = MainMenuView }
local initialized = false

function MainMenu.Render(x, y, w, h)
    OptionBOUND.SetMenuBounds(x, y, w, h)
    OptionRow.Begin()

    if not initialized then
        initialized = true
        
        UI.SubmenuManager.OpenSubmenu(MainMenu)
        
        SelfFeature.ToggleRegistration()
        WeaponsFeature.ToggleRegistration()
        VehicleConfig()
        TelportConfig()
        UI.Notification.Info("EasyTrainer initialized!")
    end

    DrawHelpers.RectFilled(x, y, w, h, UI.Style.Colors.Background, UI.Style.Layout.FrameRounding)
    Header.Draw(x, y, w)
    local view = UI.SubmenuManager.GetCurrentView()
    if view then view() end
    Footer.Draw(x, y, w, h)
end

return MainMenu
