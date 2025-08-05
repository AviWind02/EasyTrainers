local Submenus = require("UI/Core/SubmenuManager")
local Logger = require("Core/Logger")
local InputHandler = {}

local scrollDelayBase = 200
local scrollAcceleration = 20
local scrollMinDelay = 50

local lastKeyTick = 0
local scrollDelay = scrollDelayBase
local menuOpen = true
local mouseToggle = false
local lastInputDevice = "Keyboard"
local lastMenuOpen = false
local lastWasController = false

InputHandler.leftPressed = false
InputHandler.rightPressed = false
InputHandler.selectPressed = false
InputHandler.miscPressed = false
InputHandler.downPressed = false
InputHandler.upPressed = false
InputHandler.overlayOpen = false


--[[
    [Logged Action] Name: dpad_up | Type: BUTTON_PRESSED | Key: Unknown
    [Logged Action] Name: dpad_left | Type: BUTTON_PRESSED | Key: Unknown
    [Logged Action] Name: dpad_down | Type: BUTTON_PRESSED | Key: Unknown
    [Logged Action] Name: dpad_right | Type: BUTTON_PRESSED | Key: Unknown
    [Logged Action] Name: click | Type: BUTTON_PRESSED | Key: Unknown
    [Logged Action] Name: back | Type: BUTTON_PRESSED | Key: Unknown
]] --

InputHandler.ControllerInput = {
    dpad_up = { value = false },
    dpad_left = { value = false },
    dpad_down = { value = false },
    dpad_right = { value = false },
    close_tutorial = { value = false }, -- (click) this dose all front-end clicking
    cancel = { value = false }          -- (back) this dose all front-end back
}

function InputHandler.HandleControllerInput(action)
    local actionName = Game.NameToString(action:GetName(action))

    if InputHandler.ControllerInput[actionName] then
        if action:IsButtonJustPressed() then
            InputHandler.ControllerInput[actionName].value = true
            -- print("[ControllerInput] " .. actionName .. " just pressed.")
            lastInputDevice = "Controller"
        elseif action:IsButtonJustReleased() then
            InputHandler.ControllerInput[actionName].value = false
            -- print("[ControllerInput] " .. actionName .. " just released.")
        end
    end
end

function InputHandler.UpdateInputDevice()
    if not menuOpen then return end

    if ImGui.IsKeyPressed(ImGuiKey.UpArrow)
        or ImGui.IsKeyPressed(ImGuiKey.DownArrow)
        or ImGui.IsKeyPressed(ImGuiKey.LeftArrow)
        or ImGui.IsKeyPressed(ImGuiKey.RightArrow) then
        lastInputDevice = "Keyboard"
    end
end

local controllerRestrictions = {
    "GameplayRestriction.NoPhone",
    "GameplayRestriction.VehicleNoSummoning",
    "GameplayRestriction.PhoneCall",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.NoJump",
    "GameplayRestriction.InDaClub" -- I absolutely love the name of this restriction This blocks cyberware like dashing
}

local keyboardOnlyRestriction = "GameplayRestriction.NoDriving"

local function ApplyMenuRestrictions()
    InputHandler.UpdateInputDevice()
    local usingController = lastInputDevice == "Controller"

    if menuOpen == lastMenuOpen and usingController == lastWasController then return end

    -- Notify player when input device switches while menu is open
    if menuOpen and usingController ~= lastWasController then
        local msg = usingController and "[EasyTrainerInputHandler] Switched to Controller restrictions" or
        " [EasyTrainerInputHandler] Switched to Keyboard restrictions"
        Logger.Log(msg)
    end

    -- Apply/Remove NoDriving (only matters for keyboard)
    InputHandler.setStatusEffect(keyboardOnlyRestriction, menuOpen and not usingController)

    -- Apply/Remove controller-specific restrictions
    for _, restriction in ipairs(controllerRestrictions) do
        InputHandler.setStatusEffect(restriction, menuOpen and usingController)
    end

    lastMenuOpen = menuOpen
    lastWasController = usingController
end

function InputHandler.ClearMenuRestrictions()
    InputHandler.setStatusEffect(keyboardOnlyRestriction, false)
    for _, restriction in ipairs(controllerRestrictions) do
        InputHandler.setStatusEffect(restriction, false)
    end
end


local function Up() return ImGui.IsKeyPressed(ImGuiKey.UpArrow) or InputHandler.ControllerInput.dpad_up.value end
local function Down() return ImGui.IsKeyPressed(ImGuiKey.DownArrow) or InputHandler.ControllerInput.dpad_down.value end
local function Left() return ImGui.IsKeyPressed(ImGuiKey.LeftArrow) or InputHandler.ControllerInput.dpad_left.value end
local function Right() return ImGui.IsKeyPressed(ImGuiKey.RightArrow) or InputHandler.ControllerInput.dpad_right.value end
local function Select() return ImGui.IsKeyPressed(ImGuiKey.Enter) or InputHandler.ControllerInput.close_tutorial.value end
local function Back() return ImGui.IsKeyPressed(ImGuiKey.Backspace) or InputHandler.ControllerInput.cancel.value end
local function ToggleMenu() return ImGui.IsKeyPressed(ImGuiKey.F4) or
    (InputHandler.ControllerInput.close_tutorial.value and InputHandler.ControllerInput.dpad_right.value) end
local function ToggleMouse() return ImGui.IsKeyPressed(ImGuiKey.X) end
local function Misc() return ImGui.IsKeyPressed(ImGuiKey.LeftCtrl) end

-- This could go into gameplay once I create a status effect menu
function InputHandler.setStatusEffect(effect, enabled)
    local statusSystem = Game.GetStatusEffectSystem()
    local player = Game.GetPlayer()
    local entityID = player:GetEntityID()

    if enabled then
        statusSystem:ApplyStatusEffect(entityID, effect, player:GetRecordID(), entityID)
    else
        statusSystem:RemoveStatusEffect(entityID, effect)
    end
end

function InputHandler.RegisterInput()
    registerHotkey("OpenMenu", "Open Key EasyTrainer (Default: F4)", function()
        menuOpen = not menuOpen
    end)
    registerForEvent("onOverlayOpen", function()
        InputHandler.overlayOpen = true
    end)

    registerForEvent("onOverlayClose", function()
        InputHandler.overlayOpen = false
    end)
end

-- Main input tick
function InputHandler.HandleInputTick()
    local now = os.clock() * 1000 -- ms
    InputHandler.freshlyPressedKeys = {}

    -- I'll make a menu later where restrictions can be turned on and off by the user
    ApplyMenuRestrictions()




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
        if Submenus.IsAtRootMenu() then
            menuOpen = false
        end
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

InputHandler.freshlyPressedKeys = {} -- keyName → true
InputHandler.actionKeyMap = {}       -- actionName → keyName (first used key)
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

--[[
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
]] --
return InputHandler
