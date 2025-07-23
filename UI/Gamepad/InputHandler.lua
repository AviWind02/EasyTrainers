local Submenus = require("UI/Core/SubmenuManager")
local Logger = require("Core/Logger")
local InputHandler = {}

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
InputHandler.leftPressed = false
InputHandler.rightPressed = false
InputHandler.selectPressed = false
InputHandler.miscPressed = false
InputHandler.downPressed = false
InputHandler.upPressed = false

-- Key mappings
local function Up() return ImGui.IsKeyPressed(ImGuiKey.UpArrow) end
local function Down() return ImGui.IsKeyPressed(ImGuiKey.DownArrow) end
local function Left() return ImGui.IsKeyPressed(ImGuiKey.LeftArrow) end
local function Right() return ImGui.IsKeyPressed(ImGuiKey.RightArrow) end
local function Select() return ImGui.IsKeyPressed(ImGuiKey.Enter) end
local function Back() return ImGui.IsKeyPressed(ImGuiKey.Backspace) end
local function ToggleMenu() return ImGui.IsKeyPressed(ImGuiKey.F4) end
local function ToggleMouse() return ImGui.IsKeyPressed(ImGuiKey.X) end
local function Misc() return ImGui.IsKeyPressed(ImGuiKey.LeftCtrl) end

InputHandler.activeMenuKeys = {}
local keyNames = {
    [ImGuiKey.UpArrow] = "UpArrow",
    [ImGuiKey.DownArrow] = "DownArrow",
    [ImGuiKey.LeftArrow] = "LeftArrow",
    [ImGuiKey.RightArrow] = "RightArrow",
    [ImGuiKey.Enter] = "Enter",
    [ImGuiKey.Backspace] = "Backspace",
    [ImGuiKey.F4] = "F4",
    [ImGuiKey.X] = "X",
    [ImGuiKey.LeftCtrl] = "LeftCtrl"
}

InputHandler.freshlyPressedKeys = {}           -- keyName → true
InputHandler.actionKeyMap = {}                 -- actionName → keyName (first used key)
local lastFrameKeyDown = {}
local permanentlyLoggedActions = {} 


local previousKeyDown = {}

function InputHandler.CacheActiveKeys()
    if not menuOpen then return end

    for key, name in pairs(keyNames) do
        local isDown = ImGui.IsKeyDown(key)
        local wasDown = previousKeyDown[key] or false

        -- Only store if newly pressed this frame
        if isDown and not wasDown then
            InputHandler.activeMenuKeys[name] = true
        end

        -- Update previous state
        previousKeyDown[key] = isDown
    end
end

-- Stores active keys from the last UI tick
InputHandler.activeMenuKeys = {}


local permanentlyLoggedActions = {}

function InputHandler.LogAction(actionName, actionType)
    if not menuOpen then return end
    if permanentlyLoggedActions[actionName] then return end

    -- Find matching key from freshly pressed keys
    local pressedKeyName = nil
    for keyName, _ in pairs(InputHandler.freshlyPressedKeys) do
        pressedKeyName = keyName
        break -- take the first one found
    end

    if pressedKeyName then
        Logger.Log(string.format(
            "[Logged Action] Name: %s | Type: %s | Key: %s",
            tostring(actionName),
            tostring(actionType),
            pressedKeyName
        ))
        InputHandler.actionKeyMap[actionName] = pressedKeyName
    else
        Logger.Log(string.format(
            "[Logged Action] Name: %s | Type: %s | Key: Unknown",
            tostring(actionName),
            tostring(actionType)
        ))
    end

    permanentlyLoggedActions[actionName] = true
end


-- Main input tick
function InputHandler.HandleInputTick()
    local now = os.clock() * 1000  -- ms
    InputHandler.freshlyPressedKeys = {}

    if menuOpen then
        for key, name in pairs(keyNames) do
            local isDown = ImGui.IsKeyDown(key)
            local wasDown = lastFrameKeyDown[key] or false

            if isDown and not wasDown then
                InputHandler.freshlyPressedKeys[name] = true
            end

            lastFrameKeyDown[key] = isDown
        end
    end

    
    InputHandler.leftPressed = false
    InputHandler.rightPressed = false
    InputHandler.selectPressed = false
    InputHandler.miscPressed = false
    InputHandler.downPressed = false
    InputHandler.upPressed = false
    
    local isHoldingUp = ImGui.IsKeyDown(ImGuiKey.UpArrow)
    local isHoldingDown = ImGui.IsKeyDown(ImGuiKey.DownArrow)
    local isHoldingLeft = ImGui.IsKeyDown(ImGuiKey.LeftArrow)
    local isHoldingRight = ImGui.IsKeyDown(ImGuiKey.RightArrow)

    if ToggleMenu() and now - lastKeyTick > scrollDelay then
        menuOpen = not menuOpen
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    end

    if not menuOpen then return end

    local acceleratedScroll = scrollAcceleration
    if isHoldingUp or isHoldingDown then
        acceleratedScroll = scrollAcceleration * 2.0
    elseif isHoldingLeft or isHoldingRight then
        acceleratedScroll = scrollAcceleration * 1.5
    end

    if Up() and now - lastKeyTick > scrollDelay then
        Submenus.currentOption = (Submenus.currentOption > 1)
            and (Submenus.currentOption - 1)
            or Submenus.optionIndex
        InputHandler.upPressed = true
        lastKeyTick = now
        scrollDelay = math.max(scrollMinDelay, scrollDelay - acceleratedScroll)

    elseif Down() and now - lastKeyTick > scrollDelay then
        Submenus.currentOption = (Submenus.currentOption < Submenus.optionIndex)
            and (Submenus.currentOption + 1)
            or 1
        InputHandler.downPressed = true
        lastKeyTick = now
        scrollDelay = math.max(scrollMinDelay, scrollDelay - acceleratedScroll)

    elseif Left() and now - lastKeyTick > scrollDelay then
        InputHandler.leftPressed = true
        lastKeyTick = now
        scrollDelay = math.max(scrollMinDelay, scrollDelay - acceleratedScroll)

    elseif Right() and now - lastKeyTick > scrollDelay then
        InputHandler.rightPressed = true
        lastKeyTick = now
        scrollDelay = math.max(scrollMinDelay, scrollDelay - acceleratedScroll)

    elseif Select() and now - lastKeyTick > scrollDelay then
        InputHandler.selectPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase

    elseif Back() and now - lastKeyTick > scrollDelay then
        Submenus.CloseSubmenu()
        lastKeyTick = now
        scrollDelay = scrollDelayBase

    elseif Misc() and now - lastKeyTick > scrollDelay then
        InputHandler.miscPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase

    elseif ToggleMouse() and now - lastKeyTick > scrollDelay then
        mouseToggle = not mouseToggle
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    end

    Submenus.optionIndex = 0
end

function InputHandler.IsMenuOpen()
    return menuOpen
end

function InputHandler.IsMouseEnabled()
    return mouseToggle
end

return InputHandler
