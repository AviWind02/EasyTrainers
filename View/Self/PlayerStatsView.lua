local Self = require("Features/Self")
local Cooldown = Self.StatModifiers.Cooldown
local StatModifiers = Self.StatModifiers

local Draw = require("UI")
local Buttons = Draw.Buttons

local CustomModifiersView = require("View/Self/CustomModifiersView")

local function PlayerStatsView()
    Buttons.Submenu(L("modifiers.custom.label"), CustomModifiersView, tip("modifiers.custom.tip"))

    Buttons.Toggle(L("modifiers.infinite_stamina.label"), StatModifiers.Enhancements.toggleInfiniteStamina, tip("modifiers.infinite_stamina.tip"))
    Buttons.Toggle(L("modifiers.infinite_oxygen.label"), StatModifiers.Enhancements.toggleInfiniteOxygen, tip("modifiers.infinite_oxygen.tip"))
    Buttons.Toggle(L("modifiers.refill_stamina.label"), StatModifiers.Enhancements.toggleSetStaminaFull, tip("modifiers.refill_stamina.tip"))
    Buttons.Toggle(L("modifiers.refill_oxygen.label"), StatModifiers.Enhancements.toggleSetOxygenFull, tip("modifiers.refill_oxygen.tip"))

    Buttons.Break(L("modifiers.cooldowns"))
    Buttons.Toggle(L("modifiers.cooldown_heal.label"), Cooldown.toggleHeal, tip("modifiers.cooldown_heal.tip"))
    Buttons.Toggle(L("modifiers.cooldown_grenade.label"), Cooldown.toggleGrenade, tip("modifiers.cooldown_grenade.tip"))
    Buttons.Toggle(L("modifiers.cooldown_projectile.label"), Cooldown.toggleProjectile, tip("modifiers.cooldown_projectile.tip"))
    Buttons.Toggle(L("modifiers.cooldown_cloak.label"), Cooldown.toggleCloak, tip("modifiers.cooldown_cloak.tip"))
    Buttons.Toggle(L("modifiers.cooldown_sande.label"), Cooldown.toggleSande, tip("modifiers.cooldown_sande.tip"))
    Buttons.Toggle(L("modifiers.cooldown_berserk.label"), Cooldown.toggleBerserk, tip("modifiers.cooldown_berserk.tip"))
    Buttons.Toggle(L("modifiers.cooldown_keren.label"), Cooldown.toggleKeren, tip("modifiers.cooldown_keren.tip"))
    Buttons.Toggle(L("modifiers.cooldown_overclock.label"), Cooldown.toggleOverclock, tip("modifiers.cooldown_overclock.tip"))
    Buttons.Toggle(L("modifiers.cooldown_quickhacks.label"), Cooldown.toggleQuickhack, tip("modifiers.cooldown_quickhacks.tip"))

    Buttons.Break(L("modifiers.memory_stats"))
    Buttons.Toggle(L("modifiers.reduce_quickhack_cost.label"), Cooldown.toggleHackCost, tip("modifiers.reduce_quickhack_cost.tip"))
    Buttons.Toggle(L("modifiers.memory_regen.label"), Cooldown.toggleMemoryRegen, tip("modifiers.memory_regen.tip"))
    Buttons.Float(L("modifiers.set_memory_stat.label"), StatModifiers.Enhancements.memoryStatValue, tip("modifiers.set_memory_stat.tip"))

    Buttons.Break(L("modifiers.mobility"))
    Buttons.Toggle(L("modifiers.air_thruster_boots.label"), Self.AirThrusterBoots.enabled, tip("modifiers.air_thruster_boots.tip"))
    Buttons.Toggle(L("modifiers.air_hover.label"), Self.AdvancedMobility.toggleAirHover, tip("modifiers.air_hover.tip"))
    Buttons.Int(L("modifiers.carry_capacity.label"), StatModifiers.Utility.capacityValue, tip("modifiers.carry_capacity.tip"))

    Buttons.Break(L("modifiers.sandevistan"))
    Buttons.Float(L("modifiers.sandevistan_duration.label"), StatModifiers.Movement.sandevistanDurationMultiplier, tip("modifiers.sandevistan_duration.tip"))
    Buttons.Float(L("modifiers.sandevistan_scale.label"), StatModifiers.Movement.sandevistanTimeScaleMultiplier, tip("modifiers.sandevistan_scale.tip"))
end

return {
    title = "modifiers.title",
    view = PlayerStatsView
}
