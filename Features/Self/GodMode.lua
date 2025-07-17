local GodMode = {}

GodMode.enabled = { value = false }

local wasApplied = false
local logger = require("Core/Logger")

function GodMode.Tick()
    local player = Game.GetPlayer()
    local statusSystem = Game.GetStatusEffectSystem()

    if GodMode.enabled.value then
        if not wasApplied then
            statusSystem:ApplyStatusEffect(player:GetEntityID(), "BaseStatusEffect.Invulnerable")
            logger.Log("[EasyTrainerSelf] GodMode - Enabled")
            wasApplied = true
        end
    elseif wasApplied then
        statusSystem:RemoveStatusEffect(player:GetEntityID(), "BaseStatusEffect.Invulnerable")
        logger.Log("[EasyTrainerSelf] GodMode - Disabled")
        wasApplied = false
    end
end

return GodMode
