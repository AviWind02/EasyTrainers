local StatusEffect = require("Utils").StatusEffect

local GodMode = {}

GodMode.enabled = { value = false }

local wasApplied = false

function GodMode.DisableFallFX(_, context, _)
    if GodMode.enabled.value then
        context:SetPermanentFloatParameter('RegularLandingFallingSpeed', -6000, true )
        context:SetPermanentFloatParameter('SafeLandingFallingSpeed', -7000, true )
        context:SetPermanentFloatParameter('HardLandingFallingSpeed', -8000, true )
        context:SetPermanentFloatParameter('VeryHardLandingFallingSpeed', -9000, true )
        context:SetPermanentFloatParameter('DeathLandingFallingSpeed', -10000, true )
    end
end

function GodMode.Tick()
    local player = Game.GetPlayer()
    local statusSystem = Game.GetStatusEffectSystem()

    if GodMode.enabled.value then
        if not wasApplied then
            StatusEffect.Set("BaseStatusEffect.Invulnerable", true)
            wasApplied = true
        end
    elseif wasApplied then
         StatusEffect.Set("BaseStatusEffect.Invulnerable", false)
        wasApplied = false
    end
end

return GodMode
