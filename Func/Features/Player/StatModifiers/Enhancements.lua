local StatModifiers = require("Func/GamePlay/StatModifiers")
local StatPools = require("Func/GamePlay/StatPoolModifiers")

local Enhancements = {}

Enhancements.toggleSetHealthFull  = { value = false }
Enhancements.toggleSetStaminaFull = { value = false }
Enhancements.toggleSetMemoryFull  = { value = false }
Enhancements.toggleSetOxygenFull  = { value = false }


Enhancements.toggleHealthRegen     = { value = false }
Enhancements.toggleArmor           = { value = false }
Enhancements.toggleFallDamage      = { value = false }
Enhancements.toggleResistances     = { value = false }
Enhancements.toggleCombatRegen     = { value = false }
Enhancements.toggleInfiniteOxygen  = { value = false }
Enhancements.toggleInfiniteStamina = { value = false }

Enhancements.memoryStatValue = {
    value = 20.0,
    min = 1.0,
    max = 100.0,
    step = 1.0,
    enabled = false
}

function Enhancements.SetHealthFull()
    StatPools.Set(gamedataStatPoolType.Health, 100.0)
end

function Enhancements.SetStaminaFull()
    StatPools.Set(gamedataStatPoolType.Stamina, 100.0)
end

function Enhancements.SetMemoryFull()
    StatPools.Set(gamedataStatPoolType.Memory, 100.0)
end

function Enhancements.SetOxygenFull()
    StatPools.Set(gamedataStatPoolType.Oxygen, 100.0)
end


Enhancements.healthRegenHandle = nil
Enhancements.healthBoostHandle = nil
function Enhancements.SetHealthRegenMods(remove)
    if remove then
        StatModifiers.Remove(Enhancements.healthRegenHandle)
        StatModifiers.Remove(Enhancements.healthBoostHandle)
    else
        Enhancements.healthRegenHandle = StatModifiers.Create(gamedataStatType.HealthGeneralRegenRateMult, gameStatModifierType.Additive, 9999.9)
        Enhancements.healthBoostHandle = StatModifiers.Create(gamedataStatType.Health, gameStatModifierType.Additive, 99999.9)
        StatModifiers.Add(Enhancements.healthRegenHandle)
        StatModifiers.Add(Enhancements.healthBoostHandle)
    end
end

Enhancements.armorHandle = nil
function Enhancements.SetArmorMods(remove)
    if remove then
        StatModifiers.Remove(Enhancements.armorHandle)
    else
        Enhancements.armorHandle = StatModifiers.Create(gamedataStatType.Armor, gameStatModifierType.Additive, 99999999.9)
        StatModifiers.Add(Enhancements.armorHandle)
    end
end

Enhancements.fallDamageHandle = nil
function Enhancements.SetFallDamageMods(remove)
    if remove then
        StatModifiers.Remove(Enhancements.fallDamageHandle)
    else
        Enhancements.fallDamageHandle = StatModifiers.Create(gamedataStatType.FallDamageReduction, gameStatModifierType.Additive, 99.9)
        StatModifiers.Add(Enhancements.fallDamageHandle)
    end
end

Enhancements.resistanceHandles = {}
function Enhancements.SetDamageResistances(remove)
    local types = {
        ExplosionResistance = gamedataStatType.ExplosionResistance,
        MeleeResistance = gamedataStatType.MeleeResistance,
        ThermalResistance = gamedataStatType.ThermalResistance,
        ChemicalResistance = gamedataStatType.ChemicalResistance,
        ElectricResistance = gamedataStatType.ElectricResistance,
        PhysicalResistance = gamedataStatType.PhysicalResistance
    }

    for key, statType in pairs(types) do
        if remove then
            if Enhancements.resistanceHandles[key] then
                StatModifiers.Remove(Enhancements.resistanceHandles[key])
                Enhancements.resistanceHandles[key] = nil
            end
        else
            Enhancements.resistanceHandles[key] = StatModifiers.Create(statType, gameStatModifierType.Additive, 99.9)
            StatModifiers.Add(Enhancements.resistanceHandles[key])
        end
    end
end

Enhancements.combatRegenHandle = nil
function Enhancements.SetCombatRegenMods(remove)
    if remove then
        StatModifiers.Remove(Enhancements.combatRegenHandle)
    else
        Enhancements.combatRegenHandle = StatModifiers.Create(gamedataStatType.HealthInCombatRegenEnabled, gameStatModifierType.Additive, 1.0)
        StatModifiers.Add(Enhancements.combatRegenHandle)
    end
end

Enhancements.infiniteOxygenHandle = nil
function Enhancements.SetInfiniteOxygen(remove)
    if remove then
        StatModifiers.Remove(Enhancements.infiniteOxygenHandle)
    else
        Enhancements.infiniteOxygenHandle = StatModifiers.Create(gamedataStatType.CanBreatheUnderwater, gameStatModifierType.Additive, 1.0)
        StatModifiers.Add(Enhancements.infiniteOxygenHandle)
    end
end

Enhancements.infiniteStaminaHandle = nil
function Enhancements.SetInfiniteStamina(remove)
    if remove then
        StatModifiers.Remove(Enhancements.infiniteStaminaHandle)
    else
        Enhancements.infiniteStaminaHandle = StatModifiers.Create(gamedataStatType.CanIgnoreStamina, gameStatModifierType.Additive, 1.0)
        StatModifiers.Add(Enhancements.infiniteStaminaHandle)
    end
end

Enhancements.memoryStatHandle = nil
function Enhancements.SetMemoryStat(remove, value)
    if remove then
        StatModifiers.Remove(Enhancements.memoryStatHandle)
        Enhancements.memoryStatHandle = nil
    else
        local amount = value or Enhancements.memoryStatValue.value or 20.0
        Enhancements.memoryStatHandle = StatModifiers.Create(gamedataStatType.Memory, gameStatModifierType.Additive, amount)
        StatModifiers.Add(Enhancements.memoryStatHandle)
    end
end

return Enhancements
