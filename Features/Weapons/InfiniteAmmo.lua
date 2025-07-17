local InfiniteAmmo = {}

InfiniteAmmo.enabled = { value = false }

local wasApplied = false
local logger = require("Core/Logger")

function InfiniteAmmo.Tick()
    local player = Game.GetPlayer()
    local statusSystem = Game.GetStatusEffectSystem()

    if InfiniteAmmo.enabled.value then
        if not wasApplied then
            statusSystem:ApplyStatusEffect(player:GetEntityID(), "GameplayRestriction.InfiniteAmmo")
            logger.Log("[EasyTrainerWeapon] InfiniteAmmo - Enabled")
            wasApplied = true
        end
    elseif wasApplied then
        statusSystem:RemoveStatusEffect(player:GetEntityID(), "GameplayRestriction.InfiniteAmmo")
        logger.Log("[EasyTrainerWeapon] InfiniteAmmo - Disabled")
        wasApplied = false
    end
end

return InfiniteAmmo
