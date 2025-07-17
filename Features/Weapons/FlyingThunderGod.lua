local FlyingThunderGod = {}
FlyingThunderGod.enabled = { value = false }

-- Teleport player to hit position of projectile (Flying Thunder God)
function FlyingThunderGod.Tick(eventData)
    
    if not FlyingThunderGod.enabled.value then
        return
    end 


    local player = Game.GetPlayer()
    local instances = eventData.hitInstances
    if instances and #instances > 0 then
        local playerRotation = player:GetWorldOrientation():ToEulerAngles()

        for _, hit in ipairs(instances) do
            local pos = hit.position
            Game.GetTeleportationFacility():Teleport(player, pos, playerRotation)
        end
    end
end

return FlyingThunderGod
