local Logger = require("Core/Logger")
local Input = require("Core/Input")
local State = require("Controls/State")
local StatusEffect = require("Utils/StatusEffect")

local Restrictions = {}

local OWNER = "Menu"

local CONTROLLER = {
    "GameplayRestriction.NoPhone",
    "GameplayRestriction.VehicleNoSummoning",
    "GameplayRestriction.PhoneCall",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.NoJump",
    "GameplayRestriction.InDaClub"
}

local KEYBOARD = {
    "GameplayRestriction.NoDriving"
}

local MOUSE = {
    "GameplayRestriction.NoZooming",
    "GameplayRestriction.NoWeapons",
    "GameplayRestriction.NoCameraControl",
    "GameplayRestriction.NoCombat",
    "GameplayRestriction.NoHealing",
    "GameplayRestriction.BinocularView"
}

local TYPING = {
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
    "GameplayRestriction.NoSprint"
}

local s_Applied = nil
local s_AppliedName = nil

local function SelectSet()
    if Input.IsController() then return CONTROLLER, "controller" end
    if State.TypingEnabled then return TYPING, "typing" end
    if State.MouseEnabled then return MOUSE, "mouse" end
    return KEYBOARD, "keyboard"
end

function Restrictions.Clear()
    if not s_Applied then return end
    for _, effect in ipairs(s_Applied) do StatusEffect.Set(effect, false, OWNER) end
    s_Applied = nil
    s_AppliedName = nil
end

function Restrictions.Update()
    Input.UpdateDevice()

    if not State.IsMenuOpen() then
        Restrictions.Clear()
        return
    end

    local set, name = SelectSet()
    if name == s_AppliedName then return end

    Restrictions.Clear()
    for _, effect in ipairs(set) do StatusEffect.Set(effect, true, OWNER) end
    s_Applied = set
    s_AppliedName = name
    Logger.Log("Restrictions: applied " .. name .. " restrictions")
end

return Restrictions
