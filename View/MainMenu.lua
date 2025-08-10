
local Draw = require("UI")
local Logger = require("Core/Logger")

local SelfView = require("View/Self/SelfMenuView")
local PlayerStatsView = require("View/Self/PlayerStatsView")
local PlayerDevelopmentView = require("View/Self/PlayerDevelopmentView")

local TeleportView = require("View/World/TeleportView")
local WeatherView = require("View/World/WeatherView")
local TimeView = require("View/World/TimeView")
local GameFactsView = require("View/World/FactView")
local TranslationsView = require("View/Settings/Translations")


local Vehicle = require("Features/Vehicle")

local WeaponView = require("View/Weapon/WeaponMenuView")
local VehicleMenuView = require("View/Vehicle/VehicleMenuView")

local Gameplay = require("Gameplay")
local MainMenu = {}

local testToggle = { value = false }
local testInt    = { value = 5, min = 0, max = 10 }
local testFloat  = { value = 0.5, min = 0.0, max = 1.0, step = 0.1, enabled = true }
local languageRef = { index = 2, expanded = false }
local languages = { "English", "French", "Spanish", "German", "Japanese" }
local dropdownRef = { index = 2, expanded = false }
local weaponTypes = { "Pistol", "SMG", "Rifle", "Shotgun", "Sniper" }

local function run()
    local items = Gameplay.Inventory.GetAllCategorizedItems()

    for cat, groups in pairs(items) do
        print("[[" .. cat .. "]]")
        for subcat, list in pairs(groups) do
            print(" - " .. subcat)
            for _, item in ipairs(list) do
                print("\t" .. item.name .. " (" .. item.id .. ")")
            end
        end
    end
end
    local targetOptions = { "Player", "Weapon", "Vehicle" }
local selectedTarget = { index = 1 }


-- Test menu for all the buttons created and sometimes just funcs in here
local function SecondaryView()
    if Draw.Options.Option("Basic Option", nil, nil, "Tip: Basic Option") then
        print("Basic Option selected")
        run()
    end
    Draw.Options.Option(nil, "Centered Option", nil, "Tip: Centered Option")
    Draw.Options.Break("Section Break", nil, nil)
    if Draw.Options.Option("Option 1", nil, "Right") then
        Gameplay.Inventory.SpawnItemDropInFront("Items.TopQualityAlcohol10", 5)

    end
    Draw.Options.Dropdown("Weapon Type", dropdownRef, weaponTypes)
    Draw.Options.Dropdown("Language", languageRef, languages)
    Draw.Options.Toggle("Test Toggle", testToggle, "Tip: Test Toggle")
    Draw.Options.IntToggle("Test IntToggle", testInt, "Tip: Test IntToggle")
    Draw.Options.FloatToggle("Test FloatToggle", testFloat, "Tip: Test FloatToggle")
    Draw.Options.Radio("Modifier Target", selectedTarget, targetOptions, "Choose what the modifier applies to.")
end

local testMenu = { title = "Test Menu", view = SecondaryView }

local function MainMenuView()
    Draw.Options.Submenu(L("mainmenu.self.label"), SelfView, tip("mainmenu.self.tip"))
    Draw.Options.Submenu(L("mainmenu.development.label"), PlayerDevelopmentView, tip("mainmenu.development.tip"))
    Draw.Options.Submenu(L("mainmenu.modifiers.label"), PlayerStatsView, tip("mainmenu.modifiers.tip"))
    Draw.Options.Submenu(L("mainmenu.teleport.label"), TeleportView, tip("mainmenu.teleport.tip"))
    Draw.Options.Submenu(L("mainmenu.weapon.label"), WeaponView, tip("mainmenu.weapon.tip"))
    Draw.Options.Submenu(L("mainmenu.vehicle.label"), VehicleMenuView, tip("mainmenu.vehicle.tip"))
    Draw.Options.Submenu(L("mainmenu.facts.label"), GameFactsView, tip("mainmenu.facts.tip"))
    Draw.Options.Submenu(L("mainmenu.time.label"), TimeView, tip("mainmenu.time.tip"))
    Draw.Options.Submenu(L("mainmenu.weather.label"), WeatherView, tip("mainmenu.weather.tip"))
    Draw.Options.Submenu(L("mainmenu.translations.label"), TranslationsView, tip("mainmenu.translations.tip"))

    -- Draw.Options.Submenu(L("mainmenu.test"), testMenu, tip("mainmenu.test.tip"))
end


local mainMenu = { title = "mainmenu.title", view = MainMenuView }

local initialized = false

function MainMenu.Render(x, y, w, h)
    Draw.Options.SetMenuBounds(x, y, w, h)

    if not initialized then
        initialized = true
        Draw.Submenus.OpenSubmenu(mainMenu)
        Draw.Notifier.Push("EasyTrainer initialized!")
    end

    -- Background and title
    Draw.Helpers.RectFilled(x, y, w, h, 0xFF1A1A1A, 6.0)
    Draw.Decorators.DrawTitleBar(x, y, w)

    -- Render current view
    local view = Draw.Submenus.GetCurrentView()
    if view then view() end

    -- Footer
    Draw.Decorators.DrawFooter(x, y, w, h, Draw.Options.maxVisible)
end

return MainMenu