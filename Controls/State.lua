local UIConfig = require("Config/UIConfig")

local State = {}

local s_Persisted = {
    Initialized = false,
    MenuOpen = true,
    MouseEnabled = false
}
UIConfig.RegisterSection("MenuState", s_Persisted)

State.MenuOpen = s_Persisted.MenuOpen
State.MouseEnabled = s_Persisted.MouseEnabled
State.OverlayOpen = false
State.TypingEnabled = false
State.BindingKey = false

State.UpPressed = false
State.DownPressed = false
State.LeftPressed = false
State.RightPressed = false
State.SelectPressed = false
State.BackPressed = false
State.MiscPressed = false

local function Persist()
    s_Persisted.MenuOpen = State.MenuOpen
    s_Persisted.MouseEnabled = State.MouseEnabled
    UIConfig.Save()
end

function State.IsMenuOpen()
    return State.MenuOpen
end

function State.ToggleMenu()
    State.MenuOpen = not State.MenuOpen
    Persist()
    return State.MenuOpen
end

function State.SetMouseEnabled(enabled)
    State.MouseEnabled = enabled == true
    Persist()
end

function State.ToggleMouse()
    State.SetMouseEnabled(not State.MouseEnabled)
    return State.MouseEnabled
end

function State.ClearPresses()
    State.UpPressed = false
    State.DownPressed = false
    State.LeftPressed = false
    State.RightPressed = false
    State.SelectPressed = false
    State.BackPressed = false
    State.MiscPressed = false
end

function State.InitializeTracking()
    if not s_Persisted.Initialized then
        local legacy = require("Config/OptionConfig").Registry.LoadedValues or {}
        if legacy["toggle.trackMenuOpen"] ~= nil then s_Persisted.MenuOpen = legacy["toggle.trackMenuOpen"] == true end
        if legacy["toggle.trackMouseOn"] ~= nil then s_Persisted.MouseEnabled = legacy["toggle.trackMouseOn"] == true end
        s_Persisted.Initialized = true
        UIConfig.Save()
    end

    State.MenuOpen = s_Persisted.MenuOpen ~= false
    State.MouseEnabled = s_Persisted.MouseEnabled == true
end

return State
