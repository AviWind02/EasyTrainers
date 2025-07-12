local Buttons = require("Draw/OptionManager")
local Movement = require("Func/Features/Player/StatModifiers/Movement")
local Enhancements = require("Func/Features/Player/StatModifiers/Enhancements")
local Stealth = require("Func/Features/Player/StatModifiers/Stealth")
local Utility = require("Func/Features/Player/StatModifiers/Utility")


local function PlayerViewFunction()
    Buttons.Toggle("Refill Health (looped)", Enhancements.toggleSetHealthFull, "Refills health to 100 constantly")
    Buttons.Toggle("Refill Stamina (looped)", Enhancements.toggleSetStaminaFull, "Refills stamina to 100 constantly")
    Buttons.Toggle("Refill Oxygen (looped)", Enhancements.toggleSetOxygenFull, "Refills oxygen to 100 constantly")
    Buttons.Toggle("Refill Memory (looped)", Enhancements.toggleSetMemoryFull, "Refills cyberdeck memory to 100 constantly")

    Buttons.FloatToggle("Player Speed Multiplier", Movement.speedMultiplier, "Multiplies max player speed")
    Buttons.FloatToggle("Jump Height Multiplier", Movement.jumpMultiplier, "Multiplies jump height")
    Buttons.Toggle("Quicksilver Sandevistan", Movement.toggleQuicksilver, "Near-zero time scale & long Sandevistan duration")

    Buttons.Toggle("Health Regen + Boost", Enhancements.toggleHealthRegen, "Extreme passive regen + bonus health")
    Buttons.Toggle("Armor Boost", Enhancements.toggleArmor, "Massive armor value")
    Buttons.Toggle("Damage Resistances", Enhancements.toggleResistances, "Max out all resistances")
    Buttons.Toggle("Combat Regen", Enhancements.toggleCombatRegen, "Enable health regen during combat")

    Buttons.Toggle("No Fall Damage", Enhancements.toggleFallDamage, "Nullify fall damage")
    Buttons.Toggle("Infinite Oxygen", Enhancements.toggleInfiniteOxygen, "Breathe underwater")
    Buttons.Toggle("Infinite Stamina", Enhancements.toggleInfiniteStamina, "Never run out of stamina")

    Buttons.FloatToggle("Set Memory Stat", Enhancements.memoryStatValue, "Override cyberdeck memory stat")

    Buttons.Toggle("Low Detection", Stealth.toggleDetection, "Reduce visibility to AI")
    Buttons.Toggle("Low Trace Rate", Stealth.toggleTrace, "Reduce netrunner trace effects")
    
    Buttons.FloatToggle("Sandevistan Duration", Movement.durationMultiplier, "Multiplies Sandevistan duration")
    Buttons.FloatToggle("Sandevistan Time Scale", Movement.timeScaleMultiplier, "Controls time scale under Sandevistan")

    Buttons.IntToggle("Carry Capacity", Utility.capacityValue, "Override carry capacity")
end

local PlayerView = { title = "Self Menu", view = PlayerViewFunction }

return PlayerView
