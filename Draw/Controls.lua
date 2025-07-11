local Controls = {}

-- Constants
local scrollDelayBase = 200
local scrollAcceleration = 20
local scrollMinDelay = 50

-- State
local lastKeyTick = 0
local scrollDelay = scrollDelayBase
local menuOpen = true
local mouseToggle = false

-- Public pressed flags
Controls.leftPressed = false
Controls.rightPressed = false
Controls.selectPressed = false
Controls.miscPressed = false
Controls.currentOption = 1
Controls.optionIndex = 0

-- Key mappings
local function Up()
    return ImGui.IsKeyPressed(ImGuiKey.UpArrow)
end

local function Down()
    return ImGui.IsKeyPressed(ImGuiKey.DownArrow)
end

local function Left()
    return ImGui.IsKeyPressed(ImGuiKey.LeftArrow)
end

local function Right()
    return ImGui.IsKeyPressed(ImGuiKey.RightArrow)
end

local function Select()
    return ImGui.IsKeyPressed(ImGuiKey.Enter)
end

local function Back()
    return ImGui.IsKeyPressed(ImGuiKey.Backspace)
end

local function ToggleMenu()
    return ImGui.IsKeyPressed(ImGuiKey.F4)
end

local function ToggleMouse()
    return ImGui.IsKeyPressed(ImGuiKey.X)
end

local function Misc()
    return ImGui.IsKeyPressed(ImGuiKey.LeftCtrl)
end

-- Main input tick
function Controls.HandleInputTick()
    local now = os.clock() * 1000  -- milliseconds

    Controls.leftPressed = false
    Controls.rightPressed = false
    Controls.selectPressed = false
    Controls.miscPressed = false

    if ToggleMenu() and now - lastKeyTick > scrollDelay then
        menuOpen = not menuOpen
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    end

    if not menuOpen then return end

    if Up() and now - lastKeyTick > scrollDelay then
        Controls.currentOption = (Controls.currentOption > 1) and (Controls.currentOption - 1) or Controls.optionIndex
        lastKeyTick = now
        scrollDelay = math.max(scrollMinDelay, scrollDelay - scrollAcceleration)
    elseif Down() and now - lastKeyTick > scrollDelay then
        Controls.currentOption = (Controls.currentOption < Controls.optionIndex) and (Controls.currentOption + 1) or 1
        lastKeyTick = now
        scrollDelay = math.max(scrollMinDelay, scrollDelay - scrollAcceleration)
    elseif Left() and now - lastKeyTick > scrollDelay then
        Controls.leftPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    elseif Right() and now - lastKeyTick > scrollDelay then
        Controls.rightPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    elseif Select() and now - lastKeyTick > scrollDelay then
        Controls.selectPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    elseif Back() and now - lastKeyTick > scrollDelay then
        -- call submenu close
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    elseif Misc() and now - lastKeyTick > scrollDelay then
        Controls.miscPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    elseif ToggleMouse() and now - lastKeyTick > scrollDelay then
        mouseToggle = not mouseToggle
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    end

    Controls.optionIndex = 0
end

function Controls.IsMenuOpen()
    return menuOpen
end

function Controls.IsMouseEnabled()
    return mouseToggle
end

return Controls
