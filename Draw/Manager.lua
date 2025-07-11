local Controls = require("Draw/Controls")
local OptionManager = require("Draw/OptionManager")

local M = {}


local test = false

local myToggle = { value = true }


-- Menu renderer
function M.DrawMenu(x, y, w, h)

    OptionManager.SetMenuBounds(x, y, w, h)
    Controls.HandleInputTick()

    -- Background
    DrawHelpers.RectFilled(x, y, w, h, 0xFF1A1A1A, 6.0)

    -- Menu options
    if OptionManager.Option("Start Game", "F5", "Start a new adventure") then end
    if OptionManager.Option("Continue", "F6", "Resume your journey") then end
    if OptionManager.Option("Settings", "", "Change your preferences") then end
    if OptionManager.Option("Credits", "", "See who made this") then end
    if OptionManager.Option("Exit", "Esc", "Close the menu") then end
       OptionManager.Toggle("Godmode", myToggle)
    -- Save total option count for control use
    OptionManager.maxOptions = Controls.optionIndex
end


return M
