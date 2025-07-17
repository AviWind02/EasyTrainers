
local Draw = require("UI")
local SelfView = require("View/Self/SelfMenuView")
local TeleportView = require("View/World/TeleportView")
local WeaponView = require("View/Weapon/WeaponMenuView")

local MainMenu = {}

local testToggle = { value = false }
local testInt    = { value = 5, min = 0, max = 10 }
local testFloat  = { value = 0.5, min = 0.0, max = 1.0, step = 0.1, enabled = true }
local languageRef = { index = 2, expanded = false }
local languages = { "English", "French", "Spanish", "German", "Japanese" }
local dropdownRef = { index = 2, expanded = false }
local weaponTypes = { "Pistol", "SMG", "Rifle", "Shotgun", "Sniper" }


local function SecondaryView()
    Draw.Options.Option("Basic Option", nil, nil, "Tip: Basic Option")
    Draw.Options.Option(nil, "Centered Option", nil, "Tip: Centered Option")
    Draw.Options.Break("Section Break", nil, nil)
    Draw.Options.Option("Option 1", nil, "Right")
    Draw.Options.Dropdown("Weapon Type", dropdownRef, weaponTypes)
    Draw.Options.Dropdown("Language", languageRef, languages)
    Draw.Options.Toggle("Test Toggle", testToggle, "Tip: Test Toggle")
    Draw.Options.IntToggle("Test IntToggle", testInt, "Tip: Test IntToggle")
    Draw.Options.FloatToggle("Test FloatToggle", testFloat, "Tip: Test FloatToggle")
end

local testMenu = { title = "Test Menu", view = SecondaryView }

local function MainMenuView()
    Draw.Options.Submenu("Self Menu", SelfView, "Modify player stats, movement, stealth, and health behavior.")
    Draw.Options.Submenu("Teleport Menu", TeleportView, "Teleport instantly to preset locations in Night City.")
    Draw.Options.Submenu("Weapon Menu", WeaponView, "Access various weapon-related features including special abilities, projectile behavior, and customization.")
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
