local FlyingThunderGod = {}

-- Teleport player to hit position of Projectile (Flying Thunder God)
function FlyingThunderGod.Handle(eventData)
    local instances = eventData.hitInstances
    if instances and #instances > 0 then
        for _, hit in ipairs(instances) do
            local pos = hit.position
            Game.GetTeleportationFacility():Teleport(Game.GetPlayer(), pos, EulerAngles.new(0, 0, 0))
        end
    end
end

return FlyingThunderGod
