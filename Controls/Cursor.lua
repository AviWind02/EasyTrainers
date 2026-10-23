local Input = require("Core/Input")
local State = require("Controls/State")

local Cursor = {}

local s_Visible = false

function Cursor.Update()
    local visible = State.MenuOpen and State.MouseEnabled
    if visible == s_Visible then return end

    Input.ShowCursor(visible)
    s_Visible = visible
end

return Cursor
