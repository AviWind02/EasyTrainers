local Self = require("Features/Self")
local Gameplay = require("Gameplay")


local SelfTick = {}
local StatModifiers = Gameplay.StatModifiers


function SelfTick.TickMovement()
   StatModifiers.HandleDynamicStatModifierToggle(Self.StatModifiers.Movement.speedMultiplier, Self.StatModifiers.Movement.SetMaxSpeed)
   StatModifiers.HandleDynamicStatModifierToggle(Self.StatModifiers.Movement.jumpMultiplier, Self.StatModifiers.Movement.SetSuperJump)
   StatModifiers.HandleDynamicStatModifierToggle(Self.StatModifiers.Movement.sandevistanTimeScaleMultiplier, Self.StatModifiers.Movement.SetSandevistanTimeScale)
   StatModifiers.HandleDynamicStatModifierToggle(Self.StatModifiers.Movement.sandevistanDurationMultiplier, Self.StatModifiers.Movement.SetSandevistanDuration)
    
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Movement.toggleQuicksilver, Self.StatModifiers.Movement.SetQuicksilver)
end

function SelfTick.TickCooldown()
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleHeal, Self.StatModifiers.Cooldown.SetHealCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleGrenade, Self.StatModifiers.Cooldown.SetGrenadeCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleProjectile, Self.StatModifiers.Cooldown.SetProjectileCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleCloak, Self.StatModifiers.Cooldown.SetCloakCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleSande, Self.StatModifiers.Cooldown.SetSandevistanCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleBerserk, Self.StatModifiers.Cooldown.SetBerserkCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleKeren, Self.StatModifiers.Cooldown.SetKerenzikovCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleOverclock, Self.StatModifiers.Cooldown.SetOverclockCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleQuickhack, Self.StatModifiers.Cooldown.SetQuickhackCooldown)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleHackCost, Self.StatModifiers.Cooldown.SetQuickhackCost)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Cooldown.toggleMemoryRegen, Self.StatModifiers.Cooldown.SetMemoryRegeneration)
end

function SelfTick.TickEnhancements()
    if Self.StatModifiers.Enhancements.toggleSetHealthFull.value then Self.StatModifiers.Enhancements.SetHealthFull() end
    if Self.StatModifiers.Enhancements.toggleSetStaminaFull.value then Self.StatModifiers.Enhancements.SetStaminaFull() end
    if Self.StatModifiers.Enhancements.toggleSetMemoryFull.value then Self.StatModifiers.Enhancements.SetMemoryFull() end
    if Self.StatModifiers.Enhancements.toggleSetOxygenFull.value then Self.StatModifiers.Enhancements.SetOxygenFull() end

    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleHealthRegen, Self.StatModifiers.Enhancements.SetHealthRegenMods)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleArmor, Self.StatModifiers.Enhancements.SetArmorMods)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleFallDamage, Self.StatModifiers.Enhancements.SetFallDamageMods)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleResistances, Self.StatModifiers.Enhancements.SetDamageResistances)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleCombatRegen, Self.StatModifiers.Enhancements.SetCombatRegenMods)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleInfiniteOxygen, Self.StatModifiers.Enhancements.SetInfiniteOxygen)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Enhancements.toggleInfiniteStamina, Self.StatModifiers.Enhancements.SetInfiniteStamina)

    --StatModifiers.HandleDynamicStatModifierToggle(Self.StatModifiers.Enhancements.toggleSetMemoryStat, Self.StatModifiers.Enhancements.memoryStatValue.enabled, Self.StatModifiers.Enhancements.SetMemoryStat)
end

function SelfTick.TickStealth()
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Stealth.toggleDetection, Self.StatModifiers.Stealth.SetDetectionRatelow)
    StatModifiers.HandleStatModifierToggle(Self.StatModifiers.Stealth.toggleTrace, Self.StatModifiers.Stealth.SetTraceRatelow)
end

function SelfTick.TickUtility()
   StatModifiers.HandleDynamicStatModifierToggle(Self.StatModifiers.Utility.capacityValue, Self.StatModifiers.Utility.SetCarryCapacityHigh)
end

function SelfTick.TickWantedLevel()
    Self.WantedLevel.Tick()
end

function SelfTick.TickOtherFeatures()
    Self.GodMode.Tick()
    Self.Invisibility.Tick()
    Self.SuperSpeed.Tick()
    Self.AirThrusterBoots.Tick()
    Self.AdvancedMobility.Tick()
    Self.NoClip.Tick()
end

function SelfTick.TickHandler()
    SelfTick.TickMovement()
    SelfTick.TickCooldown()
    SelfTick.TickEnhancements()
    SelfTick.TickStealth()
    SelfTick.TickUtility()
    SelfTick.TickWantedLevel()
    SelfTick.TickOtherFeatures()
    
end

return SelfTick
