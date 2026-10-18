local State = {}
local UIConfig = require("Config/UIConfig")

local Persisted = {
    Initialized = false,
    MenuOpen = true,
    MouseEnabled = false,
}
UIConfig.RegisterSection("MenuState", Persisted)

State.menuOpen = Persisted.MenuOpen
State.mouseEnabled = Persisted.MouseEnabled
State.overlayOpen = false
State.typingEnabled = false

State.optionIndex = 0
State.currentOption = 1
State.maxVisible = 0

State.upPressed = false
State.downPressed = false
State.leftPressed = false
State.rightPressed = false
State.selectPressed = false
State.backPressed = false
State.miscPressed = false

State.bindingKey = false

function State.IsMenuOpen()
    return State.menuOpen
end

function State.ToggleMenu()
    State.menuOpen = not State.menuOpen
    State.SyncTracking()
    return State.menuOpen
end


function State.IsMouseEnabled()
    return State.mouseEnabled
end


function State.ToggleMouse()
    State.mouseEnabled = not State.mouseEnabled
    State.SyncTracking()
    return State.mouseEnabled
end

function State.SyncTracking()
    Persisted.MenuOpen = State.menuOpen
    Persisted.MouseEnabled = State.mouseEnabled
    UIConfig.Save()
end

function State.InitializeTracking()
    if not Persisted.Initialized then
        local OptionConfig = require("Config/OptionConfig")
        local legacy = OptionConfig.Registry.LoadedValues or {}
        if legacy["toggle.trackMenuOpen"] ~= nil then
            Persisted.MenuOpen = legacy["toggle.trackMenuOpen"] == true
        end
        if legacy["toggle.trackMouseOn"] ~= nil then
            Persisted.MouseEnabled = legacy["toggle.trackMouseOn"] == true
        end
        Persisted.Initialized = true
        UIConfig.Save()
    end

    State.menuOpen = Persisted.MenuOpen ~= false
    State.mouseEnabled = Persisted.MouseEnabled == true
end


return State
