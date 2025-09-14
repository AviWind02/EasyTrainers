-- Controls/Restrictions.lua
local Logger = require("Core/Logger")
local Input = require("Core/Input")
local State = require("Controls/State")

local StatusEffect = require("Utils/StatusEffect")

local Restrictions = {}

local controllerRestrictions = {
    "GameplayRestriction.NoPhone",
    "GameplayRestriction.VehicleNoSummoning",
    "GameplayRestriction.PhoneCall",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.NoJump",
    "GameplayRestriction.InDaClub" -- Go shorty, it’s your birthday. | blocks cyberware dash
}

-- we don't need to block much when the player is using a keyboard the arrow keys drive
-- This is of course assuming they use default controls
local keyboardOnlyRestriction = "GameplayRestriction.NoDriving"

local mouseRestrictions = {
    "GameplayRestriction.NoZooming",
    "GameplayRestriction.NoWeapons",
    "GameplayRestriction.NoCameraControl",
    "GameplayRestriction.NoCombat",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.BinocularView"
}

local typingRestrictions = {
    "GameplayRestriction.BlockAllHubMenu",
    "GameplayRestriction.NoDriving",
    "GameplayRestriction.Melee",
    "GameplayRestriction.NoPhone",
    "GameplayRestriction.VehicleNoSummoning",
    "GameplayRestriction.PhoneCall",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.NoJump",
    "GameplayRestriction.NoMovement",
    "GameplayRestriction.NoPhotoMode",
    "GameplayRestriction.NoQuickMelee",
    "GameplayRestriction.NoScanning",
    "GameplayRestriction.NoSprint",
}

local lastMenuOpen = false
local lastWasController = false
local lastMouseEnabled = false
local lastTypingEnabled = false

function Restrictions.Update()
    local menuOpen = State.IsMenuOpen()
    Input.UpdateDevice()
    local usingController = Input.IsController()
    local mouseEnabled = State.mouseEnabled
    local typingEnabled = State.typingEnabled

    -- short-circuit if nothing changed
    if menuOpen == lastMenuOpen and usingController == lastWasController and mouseEnabled == lastMouseEnabled then
        return
    end

    if menuOpen then
        if usingController ~= lastWasController then
            local msg = usingController and "Controller restrictions applied" or "Keyboard restrictions applied"
            Logger.Log(msg)
        end
        if mouseEnabled ~= lastMouseEnabled then
            local msg = mouseEnabled and "Mouse restrictions applied" or "Mouse restrictions cleared"
            Logger.Log(msg)
        end
        if typingEnabled ~= lastTypingEnabled then
            local msg = typingEnabled and "Typing restrictions applied" or "Typing restrictions cleared"
            Logger.Log(msg)
        end
    end

    -- keyboard restrictions disabled if mouse mode is active allowing players to drive while in this mode
    StatusEffect.Set(keyboardOnlyRestriction, menuOpen and not usingController and not mouseEnabled)

    for _, effect in ipairs(controllerRestrictions) do
        StatusEffect.Set(effect, menuOpen and usingController)
    end

    for _, effect in ipairs(mouseRestrictions) do
        StatusEffect.Set(effect, menuOpen and mouseEnabled)
    end

    for _, effect in ipairs(typingRestrictions) do
        StatusEffect.Set(effect, menuOpen and typingEnabled)
    end

    lastMenuOpen = menuOpen
    lastWasController = usingController
    lastMouseEnabled = mouseEnabled
    lastTypingEnabled = typingEnabled
end

function Restrictions.Clear()
    StatusEffect.Set(keyboardOnlyRestriction, false)
    for _, effect in ipairs(controllerRestrictions) do
        StatusEffect.Set(effect, false)
    end
    for _, effect in ipairs(mouseRestrictions) do
        StatusEffect.Set(effect, false)
    end
end

return Restrictions
