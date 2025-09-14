local Logger = require("Core/Logger")

local StatusEffect = {}
local active = {}


function StatusEffect.Set(effect, enable)
    local statusSystem = Game.GetStatusEffectSystem()
    local player = Game.GetPlayer()
    if not (statusSystem and player) then return end

    local entityID = player:GetEntityID()
    if enable then
        if not active[effect] then
            statusSystem:ApplyStatusEffect(entityID, effect, player:GetRecordID(), entityID)
            active[effect] = true
            Logger.Log("StatusEffect: applied " .. effect)
        end
    else
        if active[effect] then
            statusSystem:RemoveStatusEffect(entityID, effect)
            active[effect] = nil
            Logger.Log("StatusEffect: removed " .. effect)
        end
    end
end


function StatusEffect.IsActive(effect)
    return active[effect] == true
end

--- Remove all restrictions we applied
function StatusEffect.ClearAll()
    local statusSystem = Game.GetStatusEffectSystem()
    local player = Game.GetPlayer()
    if not (statusSystem and player) then return end

    local entityID = player:GetEntityID()
    for effect, _ in pairs(active) do
        statusSystem:RemoveStatusEffect(entityID, effect)
        Logger.Log("StatusEffect: cleared " .. effect)
    end
    active = {}
end

return StatusEffect
