local Invisibility = {}

Invisibility.enabled = { value = false }

local wasApplied = false
local logger = require("Core/Logger")

function Invisibility.Tick()
    local player = Game.GetPlayer()
    local statusSystem = Game.GetStatusEffectSystem()

    if Invisibility.enabled.value then
        if not wasApplied then
            statusSystem:ApplyStatusEffect(player:GetEntityID(), "BaseStatusEffect.Cloaked")
            player:SetInvisible(true)
            player:UpdateVisibility()
            logger.Log("[EasyTrainerSelf] Invisibility - Enabled")
            wasApplied = true
        end
    elseif wasApplied then
        statusSystem:RemoveStatusEffect(player:GetEntityID(), "BaseStatusEffect.Cloaked")
        player:SetInvisible(false)
        player:UpdateVisibility()
        logger.Log("[EasyTrainerSelf] Invisibility - Disabled")
        wasApplied = false
    end
end

return Invisibility
