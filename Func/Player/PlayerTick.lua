local StatModifiers = require("GamePlay/StatModifiers")
local Movement = require("StatModifiers/Movement")
local Cooldown = require("StatModifiers/Cooldown")

local PlayerTick = {}

function PlayerTick.TickMovement()
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleSpeed, Movement.speedMultiplier, Movement.SetMaxSpeed)
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleJump, Movement.jumpMultiplier, Movement.SetSuperJump)
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleSandeTimeScale, Movement.timeScaleMultiplier, Movement.SetSandevistanTimeScale)
    StatModifiers.HandleDynamicStatModifierToggle(Movement.toggleSandeDuration, Movement.durationMultiplier, Movement.SetSandevistanDuration)
end

function PlayerTick.TickCooldown()
    StatModifiers.HandleToggle(Cooldown.toggleHeal, Cooldown.SetHealCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleGrenade, Cooldown.SetGrenadeCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleProjectile, Cooldown.SetProjectileCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleCloak, Cooldown.SetCloakCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleSande, Cooldown.SetSandevistanCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleBerserk, Cooldown.SetBerserkCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleKeren, Cooldown.SetKerenzikovCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleOverclock, Cooldown.SetOverclockCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleQuickhack, Cooldown.SetQuickhackCooldown)
    StatModifiers.HandleToggle(Cooldown.toggleHackCost, Cooldown.SetQuickhackCost)
    StatModifiers.HandleToggle(Cooldown.toggleMemoryRegen, Cooldown.SetMemoryRegeneration)
end

function PlayerTick.Tick()
    PlayerTick.TickMovement()
    PlayerTick.TickCooldown()
end

return PlayerTick
