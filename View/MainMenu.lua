
local Draw = require("UI")
local Logger = require("Core/Logger")

local SelfView = require("View/Self/SelfMenuView")
local CooldownView = require("View/Self/CooldownView")
local TeleportView = require("View/World/TeleportView")
local WeatherView = require("View/World/WeatherView")
local TimeView = require("View/World/TimeView")


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


local function SecondaryView()
    if Draw.Options.Option("Basic Option", nil, nil, "Tip: Basic Option") then
        print("Basic Option selected")
        run()
    end
    Draw.Options.Option(nil, "Centered Option", nil, "Tip: Centered Option")
    Draw.Options.Break("Section Break", nil, nil)
    Draw.Options.Option("Option 1", nil, "Right")
    Draw.Options.Dropdown("Weapon Type", dropdownRef, weaponTypes)
    Draw.Options.Dropdown("Language", languageRef, languages)
    Draw.Options.Toggle("Test Toggle", testToggle, "Tip: Test Toggle")
    Draw.Options.IntToggle("Test IntToggle", testInt, "Tip: Test IntToggle")
    Draw.Options.FloatToggle("Test FloatToggle", testFloat, "Tip: Test FloatToggle")
    Draw.Options.Radio("Modifier Target", selectedTarget, targetOptions, "Choose what the modifier applies to.")
end

local testMenu = { title = "Test Menu", view = SecondaryView }

local function MainMenuView()
    Draw.Options.Submenu("Self Menu", SelfView, "Modify player stats, movement, stealth, and health behavior.")
    Draw.Options.Submenu("Cooldown Menu", CooldownView, "Manage all ability cooldowns and recovery rates such as grenades, cloaking, and quickhacks.")
    Draw.Options.Submenu("Teleport Menu", TeleportView, "Teleport instantly to preset locations in Night City.")
    Draw.Options.Submenu("Weapon Menu", WeaponView, "Access various weapon-related features including special abilities, projectile behavior, and customization.")
    Draw.Options.Submenu("Vehicle Menu", VehicleMenuView, "Manage vehicles, spawn new ones, and control vehicle Elements ")
    Draw.Options.Submenu("Time Menu", TimeView, "Control time of day, time skip, freezing, syncing, and speed multipliers.")
    Draw.Options.Submenu("Weather Menu", WeatherView, "Control world weather, force storms, fog, and more.")
    Draw.Options.Submenu("Test Buttons", testMenu, "Go to test menu")

end

local mainMenu = { title = "Main Menu", view = MainMenuView }

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
