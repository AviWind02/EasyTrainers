local Cooldown = {}

Cooldown.Heal = { value = false }
Cooldown.Grenade = { value = false }
Cooldown.Projectile = { value = false }
Cooldown.Cloak = { value = false }
Cooldown.Sandevistan = { value = false }
Cooldown.Berserk = { value = false }
Cooldown.Kerenzikov = { value = false }
Cooldown.Overclock = { value = false }
Cooldown.Quickhack = { value = false }
Cooldown.HackCost = { value = false }
Cooldown.MemoryRegen = { value = false }

local ADD = gameStatModifierType.Additive
local MULTIPLY = gameStatModifierType.Multiplier

Cooldown.Definitions = {
    { Name = "Cooldown.Heal", Ref = Cooldown.Heal, Modifiers = { { gamedataStatType.HealingItemsChargesRegenMult, ADD, 10000.0 } } },
    { Name = "Cooldown.Grenade", Ref = Cooldown.Grenade, Modifiers = { { gamedataStatType.GrenadesChargesRegenMult, ADD, 10000.0 } } },
    { Name = "Cooldown.Projectile", Ref = Cooldown.Projectile, Modifiers = { { gamedataStatType.ProjectileLauncherChargesRegenMult, ADD, 10000.0 } } },
    {
        Name = "Cooldown.Cloak",
        Ref = Cooldown.Cloak,
        Modifiers = {
            { gamedataStatType.OpticalCamoRechargeDuration, MULTIPLY, 0.01 },
            { gamedataStatType.OpticalCamoChargesRegenRate, ADD, 100.0 }
        }
    },
    { Name = "Cooldown.Sandevistan", Ref = Cooldown.Sandevistan, Modifiers = { { gamedataStatType.TimeDilationSandevistanRechargeDuration, MULTIPLY, 0.01 } } },
    { Name = "Cooldown.Berserk", Ref = Cooldown.Berserk, Modifiers = { { gamedataStatType.BerserkChargesRegenRate, ADD, 100.0 } } },
    { Name = "Cooldown.Kerenzikov", Ref = Cooldown.Kerenzikov, Modifiers = { { gamedataStatType.KerenzikovCooldownDuration, MULTIPLY, 0.01 } } },
    {
        Name = "Cooldown.Overclock",
        Ref = Cooldown.Overclock,
        Modifiers = {
            { gamedataStatType.CyberdeckOverclockRegenRate, ADD, 100.0 },
            { gamedataStatType.CyberdeckOverclockCooldown, MULTIPLY, 0.01 }
        }
    },
    { Name = "Cooldown.Quickhack", Ref = Cooldown.Quickhack, Modifiers = { { gamedataStatType.QuickhacksCooldownReduction, ADD, 1.0 } } },
    { Name = "Cooldown.HackCost", Ref = Cooldown.HackCost, Modifiers = { { gamedataStatType.MemoryCostReduction, ADD, 10000.0 } } },
    { Name = "Cooldown.MemoryRegen", Ref = Cooldown.MemoryRegen, Modifiers = { { gamedataStatType.MemoryRegenRateMult, ADD, 100.0 } } }
}

return Cooldown
