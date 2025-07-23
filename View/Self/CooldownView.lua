local Cooldown = require("Features/Self").StatModifiers.Cooldown
local Draw = require("UI")

local Buttons = Draw.Buttons

local function CooldownViewFunction()
    Buttons.Toggle("Cooldown: Heal", Cooldown.toggleHeal, "Removes healing item recharge cooldown.")
    Buttons.Toggle("Cooldown: Grenade", Cooldown.toggleGrenade, "Removes grenade recharge cooldown.")
    Buttons.Toggle("Cooldown: Projectile Launcher", Cooldown.toggleProjectile, "Removes projectile launcher cooldown.")
    Buttons.Toggle("Cooldown: Optical Cloak", Cooldown.toggleCloak, "Eliminates optical camo cooldown and boosts regen.")
    Buttons.Toggle("Cooldown: Sandevistan", Cooldown.toggleSande, "Removes cooldown for Sandevistan activations.")
    Buttons.Toggle("Cooldown: Berserk", Cooldown.toggleBerserk, "Greatly increases berserk regeneration rate.")
    Buttons.Toggle("Cooldown: Kerenzikov", Cooldown.toggleKeren, "Reduces Kerenzikov cooldown to near-zero.")
    Buttons.Toggle("Cooldown: Overclock", Cooldown.toggleOverclock, "Boosts Overclock regen and removes cooldown.")
    Buttons.Toggle("Cooldown: Quickhacks", Cooldown.toggleQuickhack, "Reduces all quickhack cooldowns drastically.")
    Buttons.Toggle("Reduce Quickhack Cost", Cooldown.toggleHackCost, "Removes all memory costs from quickhacks.")
    Buttons.Toggle("Memory Regen", Cooldown.toggleMemoryRegen, "Increases memory regeneration rate.")
end

local CooldownView = { title = "Cooldowns Menu", view = CooldownViewFunction }

return CooldownView
