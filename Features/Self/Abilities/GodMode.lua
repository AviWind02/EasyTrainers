local StatusEffect = require("Utils").StatusEffect

local GodMode = {}

GodMode.enabled = { value = false }

local wasApplied = false

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
