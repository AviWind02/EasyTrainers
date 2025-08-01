local Self = require("Features/Self")
local Draw = require("UI")

local Gameplay = require("Gameplay")

local Buttons = Draw.Buttons

local function SelfViewFunction()
    Buttons.Toggle("God Mode", Self.GodMode.enabled, "Makes you invincible to all forms of damage.")
    Buttons.Toggle("Invisibility", Self.Invisibility.enabled,
        "Applies the optical cloaking effect. Enemies may still detect you if provoked.")
    Buttons.Toggle("Super Speed", Self.SuperSpeed.enabled,
        "Enables rapid movement via time dilation.\nTip: Combine with Player Speed Multiplier for better effect.")
    Buttons.Float("Player Speed Multiplier", Self.StatModifiers.Movement.speedMultiplier,
        "Scales the player's top movement speed.")
    Buttons.Float("Jump Height Multiplier", Self.StatModifiers.Movement.jumpMultiplier,
        "Adjusts how high the player can jump.")
    Buttons.Toggle("Quicksilver's Sandevistan", Self.StatModifiers.Movement.toggleQuicksilver,
        "Modifies your Sandevistan to feel like Quicksilver extreme slowdown when activated.")

    Buttons.Break("Wanted Level")
    Buttons.Toggle("Never Wanted", Self.WantedLevel.tickNeverWanted, "Prevents the police from engaging or pursuing you.")
    Buttons.Int("Wanted Level", Self.WantedLevel.heldWantedLevel, "Set and optionally lock your current wanted level.",
        function()
            if not Self.WantedLevel.heldWantedLevel.enabled then
                Gameplay.PreventionSystem.SetWantedLevel(Self.WantedLevel.heldWantedLevel.value or 0)
            end
        end)
    Buttons.Option("Clear Wanted Level", "Temporarily disables the police system to reset wanted level",
        function() Self.WantedLevel.tickClearWanted.value = true end)

    Buttons.Break("Health & Defense")
    Buttons.Toggle("Refill Health (loop)", Self.StatModifiers.Enhancements.toggleSetHealthFull,
        "Automatically refills health to 100% when it drops below 98%.")
    Buttons.Toggle("Health Regen + Boost", Self.StatModifiers.Enhancements.toggleHealthRegen,
        "Enables extreme passive regeneration and a bonus health buffer.")
    Buttons.Toggle("Armor Boost", Self.StatModifiers.Enhancements.toggleArmor,
        "Applies a massive armor increase for defense.")
    Buttons.Toggle("Damage Resistances", Self.StatModifiers.Enhancements.toggleResistances,
        "Maximizes all resistance stats.")
    Buttons.Toggle("Combat Regen", Self.StatModifiers.Enhancements.toggleCombatRegen,
        "Allows health regeneration during combat.")
    Buttons.Toggle("No Fall Damage", Self.StatModifiers.Enhancements.toggleFallDamage,
        "Eliminates all damage from falling.")

    Buttons.Break("Stealth & Hacking")
    Buttons.Toggle("Non-Threat Status", Self.StatModifiers.Stealth.toggleDetection,
        "Enemies will notice and track you, but won't enter combat unless you interact or attack.")
    Buttons.Toggle("Low Trace Rate", Self.StatModifiers.Stealth.toggleTrace,
        "Reduces the trace speed from enemy netrunners.")
    Buttons.Toggle("Refill Memory (loop)", Self.StatModifiers.Enhancements.toggleSetMemoryFull,
        "Refills cyberdeck memory to 100% if it drops below 98%.")
end



local SelfView = { title = "Self Menu", view = SelfViewFunction }

return SelfView
