local Submenus = require("UI/Core/SubmenuManager")
local Logger = require("Core/Logger")
local InputHandler = {}
-- Created a plugin that exposes native keyboard and gamepad input checks to CET Lua scripts
local ETInput = nil

local function GetETInput()
    if not ETInput then
        ETInput = EasyTrainerInputHandler.new()
    end
    return ETInput
end

-- keyboard VK codes
local VK_UP = 38
local VK_DOWN = 40
local VK_LEFT = 37
local VK_RIGHT = 39
local VK_ENTER = 13
local VK_BACKSPACE = 8
local VK_F4 = 115
local VK_X = 88
local VK_CTRL = 17

-- gamepad codes
local GP_DPAD_UP = 1
local GP_DPAD_DOWN = 2
local GP_DPAD_LEFT = 4
local GP_DPAD_RIGHT = 8
local GP_RIGHT_BUMP = 512
local GP_A = 4096
local GP_B = 8192
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




local controllerRestrictions = {
    "GameplayRestriction.NoPhone",
    "GameplayRestriction.VehicleNoSummoning",
    "GameplayRestriction.PhoneCall",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.NoJump",
    "GameplayRestriction.InDaClub" -- I absolutely love the name of this restriction This blocks cyberware like dashing
}

local keyboardOnlyRestriction = "GameplayRestriction.NoDriving"


function InputHandler.UpdateInputDevice()
    if not menuOpen then return end

    if GetETInput():IsKeyboardActive() then
        lastInputDevice = "Keyboard"
    elseif GetETInput():IsGamepadActive() then
        lastInputDevice = "Controller"
    end
end

local function IsUsingController()
    return lastInputDevice == "Controller"
end

local function ApplyMenuRestrictions()
    InputHandler.UpdateInputDevice()
    local usingController = IsUsingController()

    if menuOpen == lastMenuOpen and usingController == lastWasController then return end

    if menuOpen and usingController ~= lastWasController then
        local msg = usingController and "[EasyTrainerInputHandler] Switched to Controller restrictions"
            or "[EasyTrainerInputHandler] Switched to Keyboard restrictions"
        Logger.Log(msg)
    end

    InputHandler.setStatusEffect(keyboardOnlyRestriction, menuOpen and not usingController)
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



local function Select()
    return GetETInput():IsKeyPressed(VK_ENTER) or GetETInput():IsGamepadButtonPressed(GP_A)
end

local function Back()
    return GetETInput():IsKeyPressed(VK_BACKSPACE) or GetETInput():IsGamepadButtonPressed(GP_B)
end

local function Up()
    return GetETInput():IsKeyPressed(VK_UP) or GetETInput():IsGamepadButtonPressed(GP_DPAD_UP)
end

local function Down()
    return GetETInput():IsKeyPressed(VK_DOWN) or GetETInput():IsGamepadButtonPressed(GP_DPAD_DOWN)
end

local function Left()
    return GetETInput():IsKeyPressed(VK_LEFT) or GetETInput():IsGamepadButtonPressed(GP_DPAD_LEFT)
end

local function Right()
    return GetETInput():IsKeyPressed(VK_RIGHT) or GetETInput():IsGamepadButtonPressed(GP_DPAD_RIGHT)
end

local function ToggleMenu()
    return GetETInput():IsKeyPressed(VK_F4) or
        (GetETInput():IsGamepadButtonPressed(GP_A) and GetETInput():IsGamepadButtonPressed(GP_DPAD_RIGHT))
end

local function ToggleMouse()
    return GetETInput():IsKeyPressed(VK_X)
end

local function Misc()
    return GetETInput():IsKeyPressed(VK_CTRL)
end

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

-- Tuning for scroll speed and acceleration
local kbVertSpeed = scrollAcceleration
local kbHorzSpeed = scrollAcceleration * 2.5
local ctrlVertSpeed = scrollAcceleration * 0.25
local ctrlHorzSpeed = scrollAcceleration * 2.5
local holdMult = 2.0

function InputHandler.HandleInputTick()
    local now = os.clock() * 1000
    InputHandler.freshlyPressedKeys = {}

    ApplyMenuRestrictions()

    InputHandler.leftPressed = false
    InputHandler.rightPressed = false
    InputHandler.selectPressed = false
    InputHandler.miscPressed = false
    InputHandler.downPressed = false
    InputHandler.upPressed = false

    local isUp = Up()
    local isDown = Down()
    local isLeft = Left()
    local isRight = Right()

    if ToggleMenu() and now - lastKeyTick > scrollDelay then
        menuOpen = not menuOpen
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    end

    if not menuOpen then return end

    local function getBaseSpeed(vertical)
        if IsUsingController() then
            return vertical and ctrlVertSpeed or ctrlHorzSpeed
        else
            return vertical and kbVertSpeed or kbHorzSpeed
        end
    end

    if isUp and now - lastKeyTick > scrollDelay then
        Submenus.currentOption = (Submenus.currentOption > 1) and (Submenus.currentOption - 1) or Submenus.optionIndex
        InputHandler.upPressed = true
        lastKeyTick = now
        if not isDown and not isLeft and not isRight then scrollDelay = scrollDelayBase end
        local spd = getBaseSpeed(true)
        if isUp then spd = spd * holdMult end
        scrollDelay = math.max(scrollMinDelay, scrollDelay - spd)
    elseif isDown and now - lastKeyTick > scrollDelay then
        Submenus.currentOption = (Submenus.currentOption < Submenus.optionIndex) and (Submenus.currentOption + 1) or 1
        InputHandler.downPressed = true
        lastKeyTick = now
        if not isUp and not isLeft and not isRight then scrollDelay = scrollDelayBase end
        local spd = getBaseSpeed(true)
        if isDown then spd = spd * holdMult end
        scrollDelay = math.max(scrollMinDelay, scrollDelay - spd)
    elseif isLeft and now - lastKeyTick > scrollDelay then
        InputHandler.leftPressed = true
        lastKeyTick = now
        if not isUp and not isDown and not isRight then scrollDelay = scrollDelayBase end
        local spd = getBaseSpeed(false)
        if isLeft then spd = spd * holdMult end
        scrollDelay = math.max(scrollMinDelay, scrollDelay - spd)
    elseif isRight and now - lastKeyTick > scrollDelay then
        InputHandler.rightPressed = true
        lastKeyTick = now
        if not isUp and not isDown and not isLeft then scrollDelay = scrollDelayBase end
        local spd = getBaseSpeed(false)
        if isRight then spd = spd * holdMult end
        scrollDelay = math.max(scrollMinDelay, scrollDelay - spd)
    elseif Select() and now - lastKeyTick > scrollDelay then
        InputHandler.selectPressed = true
        lastKeyTick = now
        scrollDelay = scrollDelayBase
    elseif Back() and now - lastKeyTick > scrollDelay then
        if Submenus.IsAtRootMenu() then menuOpen = false end
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

return InputHandler
