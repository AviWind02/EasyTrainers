local StatModifiers = require("Func/GamePlay/StatModifiers")

local Movement = require("Func/Features/Player/StatModifiers/Movement")
local Cooldown = require("Func/Features/Player/StatModifiers/Cooldown")
local Enhancements = require("Func/Features/Player/StatModifiers/Enhancements")
local Stealth = require("Func/Features/Player/StatModifiers/Stealth")
local Utility = require("Func/Features/Player/StatModifiers/Utility")

local PlayerTick = {}

function PlayerTick.TickMovement()
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleSpeed, Movement.speedMultiplier, Movement.SetMaxSpeed)
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleJump, Movement.jumpMultiplier, Movement.SetSuperJump)
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleSandeTimeScale, Movement.timeScaleMultiplier, Movement.SetSandevistanTimeScale)
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleSandeDuration, Movement.durationMultiplier, Movement.SetSandevistanDuration)
    
    StatModifiers.HandleStatModifierToggle(Movement.toggleQuicksilver, Movement.SetQuicksilver)
end

function PlayerTick.TickCooldown()
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleHeal, Cooldown.SetHealCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleGrenade, Cooldown.SetGrenadeCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleProjectile, Cooldown.SetProjectileCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleCloak, Cooldown.SetCloakCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleSande, Cooldown.SetSandevistanCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleBerserk, Cooldown.SetBerserkCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleKeren, Cooldown.SetKerenzikovCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleOverclock, Cooldown.SetOverclockCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleQuickhack, Cooldown.SetQuickhackCooldown)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleHackCost, Cooldown.SetQuickhackCost)
    StatModifiers.HandleStatModifierToggle(Cooldown.toggleMemoryRegen, Cooldown.SetMemoryRegeneration)
end

function PlayerTick.TickEnhancements()
    if Enhancements.toggleSetHealthFull.value then Enhancements.SetHealthFull() end
    if Enhancements.toggleSetStaminaFull.value then Enhancements.SetStaminaFull() end
    if Enhancements.toggleSetMemoryFull.value then Enhancements.SetMemoryFull() end
    if Enhancements.toggleSetOxygenFull.value then Enhancements.SetOxygenFull() end

    StatModifiers.HandleStatModifierToggle(Enhancements.toggleHealthRegen, Enhancements.SetHealthRegenMods)
    StatModifiers.HandleStatModifierToggle(Enhancements.toggleArmor, Enhancements.SetArmorMods)
    StatModifiers.HandleStatModifierToggle(Enhancements.toggleFallDamage, Enhancements.SetFallDamageMods)
    StatModifiers.HandleStatModifierToggle(Enhancements.toggleResistances, Enhancements.SetDamageResistances)
    StatModifiers.HandleStatModifierToggle(Enhancements.toggleCombatRegen, Enhancements.SetCombatRegenMods)
    StatModifiers.HandleStatModifierToggle(Enhancements.toggleInfiniteOxygen, Enhancements.SetInfiniteOxygen)
    StatModifiers.HandleStatModifierToggle(Enhancements.toggleInfiniteStamina, Enhancements.SetInfiniteStamina)

    StatModifiers.HandleDynamicStatModifierToggle(Enhancements.toggleSetMemoryStat, Enhancements.memoryStatValue.enabled, Enhancements.SetMemoryStat)
end

function PlayerTick.TickStealth()
    StatModifiers.HandleStatModifierToggle(Stealth.toggleDetection, Stealth.SetDetectionRatelow)
    StatModifiers.HandleStatModifierToggle(Stealth.toggleTrace, Stealth.SetTraceRatelow)
end

function PlayerTick.TickUtility()
    StatModifiers.HandleDynamicStatModifierToggle(Utility.toggleCarry, Utility.capacityValue.enabled, Utility.SetCarryCapacityHigh)
end


function PlayerTick.TickHandler()
    PlayerTick.TickMovement()
    PlayerTick.TickCooldown()
    PlayerTick.TickEnhancements()
    PlayerTick.TickStealth()
    PlayerTick.TickUtility()
end

return PlayerTick
