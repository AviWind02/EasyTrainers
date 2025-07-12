local Controls = require("Draw/Controls")
local OptionManager = require("Draw/OptionManager")
local Notifier = require("Draw/NotificationManager")
local Decorators = require("Draw/Decorators")
local Submenus = require("Draw/SubmenuManager")
local PlayerView = require("Draw/View/PlayerView")

local M = {}



local function MainMenuView()
    OptionManager.Submenu("Self Menu", PlayerView , "Player features")

 
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
