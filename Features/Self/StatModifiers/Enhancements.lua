local StatPools = require("Utils/StatPoolModifiers")

local Enhancements = {}

Enhancements.RefillHealth = { value = false }
Enhancements.RefillStamina = { value = false }
Enhancements.RefillMemory = { value = false }
Enhancements.RefillOxygen = { value = false }

Enhancements.HealthRegen = { value = false }
Enhancements.Armor = { value = false }
Enhancements.NoFallDamage = { value = false }
Enhancements.Resistances = { value = false }
Enhancements.CombatRegen = { value = false }
Enhancements.InfiniteOxygen = { value = false }
Enhancements.InfiniteStamina = { value = false }
Enhancements.MemoryStat = { value = 20.0, min = 1.0, max = 100.0, step = 1.0, enabled = false }

local ADD = gameStatModifierType.Additive
local REFILL_INTERVAL = 0.25

local s_NextRefill = 0

local REFILLS = {
    { Enhancements.RefillHealth, gamedataStatPoolType.Health },
    { Enhancements.RefillStamina, gamedataStatPoolType.Stamina },
    { Enhancements.RefillMemory, gamedataStatPoolType.Memory },
    { Enhancements.RefillOxygen, gamedataStatPoolType.Oxygen }
}

Enhancements.Definitions = {
    {
        Name = "Enhancements.HealthRegen",
        Ref = Enhancements.HealthRegen,
        Modifiers = {
            { gamedataStatType.HealthGeneralRegenRateMult, ADD, 9999.9 },
            { gamedataStatType.Health, ADD, 99999.9 }
        }
    },
    { Name = "Enhancements.Armor", Ref = Enhancements.Armor, Modifiers = { { gamedataStatType.Armor, ADD, 99999999.9 } } },
    { Name = "Enhancements.NoFallDamage", Ref = Enhancements.NoFallDamage, Modifiers = { { gamedataStatType.FallDamageReduction, ADD, 99.9 } } },
    {
        Name = "Enhancements.Resistances",
        Ref = Enhancements.Resistances,
        Modifiers = {
            { gamedataStatType.ExplosionResistance, ADD, 99.9 },
            { gamedataStatType.MeleeResistance, ADD, 99.9 },
            { gamedataStatType.ThermalResistance, ADD, 99.9 },
            { gamedataStatType.ChemicalResistance, ADD, 99.9 },
            { gamedataStatType.ElectricResistance, ADD, 99.9 },
            { gamedataStatType.PhysicalResistance, ADD, 99.9 }
        }
    },
    { Name = "Enhancements.CombatRegen", Ref = Enhancements.CombatRegen, Modifiers = { { gamedataStatType.HealthInCombatRegenEnabled, ADD, 1.0 } } },
    { Name = "Enhancements.InfiniteOxygen", Ref = Enhancements.InfiniteOxygen, Modifiers = { { gamedataStatType.CanBreatheUnderwater, ADD, 1.0 } } },
    { Name = "Enhancements.InfiniteStamina", Ref = Enhancements.InfiniteStamina, Modifiers = { { gamedataStatType.CanIgnoreStamina, ADD, 1.0 } } },
    {
        Name = "Enhancements.MemoryStat",
        Ref = Enhancements.MemoryStat,
        Dynamic = function(value) return { { gamedataStatType.Memory, ADD, value } } end
    }
}

function Enhancements.TickRefills()
    local now = os.clock()
    if now < s_NextRefill then return end
    s_NextRefill = now + REFILL_INTERVAL

    for _, refill in ipairs(REFILLS) do
        if refill[1].value then StatPools.Refill(refill[2]) end
    end
end

return Enhancements
