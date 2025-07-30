local Self = require("Features/Self")
local Cooldown = Self.StatModifiers.Cooldown
local StatModifiers = Self.StatModifiers

local Draw = require("UI")
local Buttons = Draw.Buttons

local CustomModifiersView = require("View/Self/CustomModifiersView")


local function PlayerStatsView()
    Buttons.Submenu("Custom Modifiers (Not Tested Enough)", CustomModifiersView, "Create and manage your own stat modifiers for player, weapons, or vehicles.")

    Buttons.Toggle("Infinite Stamina", StatModifiers.Enhancements.toggleInfiniteStamina, "Removes stamina constraints permanently.")
    Buttons.Toggle("Infinite Oxygen", StatModifiers.Enhancements.toggleInfiniteOxygen, "Allows indefinite underwater breathing.")
    Buttons.Toggle("Refill Stamina (loop)", StatModifiers.Enhancements.toggleSetStaminaFull, "Automatically restores stamina to 100% below 98%.")
    Buttons.Toggle("Refill Oxygen (loop)", StatModifiers.Enhancements.toggleSetOxygenFull, "Automatically restores oxygen when it drops.")

    Buttons.Break("Cooldowns")
    Buttons.Toggle("Heal", Cooldown.toggleHeal, "Removes healing item recharge cooldown.")
    Buttons.Toggle("Grenade", Cooldown.toggleGrenade, "Removes grenade recharge cooldown.")
    Buttons.Toggle("Projectile Launcher", Cooldown.toggleProjectile, "Removes projectile launcher cooldown.")
    Buttons.Toggle("Optical Cloak", Cooldown.toggleCloak, "Eliminates optical camo cooldown and boosts regen.")
    Buttons.Toggle("Sandevistan", Cooldown.toggleSande, "Removes cooldown for Sandevistan activations.")
    Buttons.Toggle("Berserk", Cooldown.toggleBerserk, "Greatly increases berserk regeneration rate.")
    Buttons.Toggle("Kerenzikov", Cooldown.toggleKeren, "Reduces Kerenzikov cooldown to near-zero.")
    Buttons.Toggle("Overclock", Cooldown.toggleOverclock, "Boosts Overclock regen and removes cooldown.")
    Buttons.Toggle("Quickhacks", Cooldown.toggleQuickhack, "Reduces all quickhack cooldowns drastically.")

    Buttons.Break("Memory & Stats")
    Buttons.Toggle("Reduce Quickhack Cost", Cooldown.toggleHackCost, "Removes all memory costs from quickhacks.")
    Buttons.Toggle("Memory Regen", Cooldown.toggleMemoryRegen, "Increases memory regeneration rate.")
    Buttons.Float("Set Memory Stat", StatModifiers.Enhancements.memoryStatValue, "Overrides base memory stat for cyberdeck.")

    Buttons.Break("Mobility")
    Buttons.Toggle("Air Thruster Boots", Self.AirThrusterBoots.enabled, "Hold jump in mid-air to reduce fall damage impact.")
    Buttons.Toggle("Air Hover", Self.AdvancedMobility.toggleAirHover, "Allows hovering in the air after jumping.")
    Buttons.Int("Carry Capacity", Self.StatModifiers.Utility.capacityValue, "Overrides your carry weight capacity.")

    Buttons.Break("Cyberware: Sandevistan")
    Buttons.Float("Sandevistan Duration", StatModifiers.Movement.sandevistanDurationMultiplier,
        "Extends duration of your Sandevistan mode.")
    Buttons.Float("Sandevistan Time Scale", StatModifiers.Movement.sandevistanTimeScaleMultiplier,
        "Controls time dilation while Sandevistan is active.")
end

return {
    title = "Player Stats",
    view = PlayerStatsView
}
