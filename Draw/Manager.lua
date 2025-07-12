local Controls = require("Draw/Controls")
local OptionManager = require("Draw/OptionManager")
local Notifier = require("Draw/NotificationManager")
local Decorators = require("Draw/Decorators")
local Submenus = require("Draw/SubmenuManager")

local M = {}


local StatModifiers = require("Func/Gameplay/StatModifiers")

local toggleSpeed = { value = false }
local speedHandle = nil

local function SetSpeed(remove)
    if remove then
        if speedHandle then
            StatModifiers.Remove(speedHandle)
        end
    else
        speedHandle = StatModifiers.Create(gamedataStatType.MaxSpeed, gameStatModifierType.Multiplicative, 5.0)
        StatModifiers.Add(speedHandle)
    end
end

function testMenu2()
    
    StatModifiers.HandleStatModifierToggle(toggleSpeed, SetSpeed)

    OptionManager.Toggle("Multiply Max Speed (x5)", toggleSpeed)

    OptionManager.Option("Test Option 1", "Value 1", "This is a test option")
    OptionManager.Option("Test Option 2", "Value 2", "This is another test option")
    OptionManager.Option("Test Option 3", "Value 3", "Yet another test option")

end
local testMenu = { title = "testMenu", view = testMenu2 }

local function MainMenuView()
    OptionManager.Submenu("Self Menu", testMenu, "Player features")
 
end
local mainMenu = { title = "Main Menu", view = MainMenuView }



local initialized = false

-- Menu renderer
function M.DrawMenu(x, y, w, h)
    OptionManager.SetMenuBounds(x, y, w, h)


    if not initialized then
        initialized = true
        Submenus.OpenSubmenu(mainMenu)
        Notifier.Push("EasyTrainer initialized!")
    end

    -- Background
    DrawHelpers.RectFilled(x, y, w, h, 0xFF1A1A1A, 6.0)
    Decorators.DrawTitleBar(x, y, w)

    -- Draw current submenu view
    local view = Submenus.GetCurrentView()
    if view then view() end

    Decorators.DrawFooter(x, y, w, h, OptionManager.maxVisible)

    -- Save total option count
    OptionManager.maxOptions = Controls.optionIndex
end

return M
