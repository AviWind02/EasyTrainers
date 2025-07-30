local VehicleSpawner = {}

local Draw = require("UI")

-- Requests the vehicle in front of the player
function VehicleSpawner.RequestVehicle(tweakDBIDStr, spawnDist)
    local player = Game.GetPlayer()
    if not player then
        return
    end

    local forward = player:GetWorldForward()
    local offset = Vector3.new(forward.x * spawnDist, forward.y * spawnDist, 0.5)

    local transform = player:GetWorldTransform()
    local originalPos = transform.Position:ToVector4()
    local spawnPos = Vector4.new(
        originalPos.x + offset.x,
        originalPos.y + offset.y,
        originalPos.z + offset.z,
        1.0
    )

    transform:SetPosition(transform, spawnPos)

    local vehicleID = TweakDBID.new(tweakDBIDStr)
    Draw.Notifier.Push(string.format("Requesting vehicle '%s' at (%.2f, %.2f, %.2f)", tweakDBIDStr, spawnPos.x, spawnPos.y, spawnPos.z))
    Game.GetPreventionSpawnSystem():RequestUnitSpawn(vehicleID, transform)
end

-- Spawns the vehicle in front of the player
function VehicleSpawner.TestSpawnAndMount(tweakDBIDStr, spawnDist)
    local player = Game.GetPlayer()
    if not player then
        return
    end

    local forward = player:GetWorldForward()
    local offset = Vector3.new(forward.x * spawnDist, forward.y * spawnDist, 0.5)

    local transform = player:GetWorldTransform()
    local pos = transform.Position:ToVector4()
    local spawnPos = Vector4.new(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z, 1.0)
    transform:SetPosition(transform, spawnPos)

    local recordID = TweakDBID.new(tweakDBIDStr)
    local entityID = exEntitySpawner.SpawnRecord(recordID, transform)
    local entity = Game.FindEntityByID(entityID)
    Draw.Notifier.Push(string.format("Spawning vehicle '%s' at (%.2f, %.2f, %.2f)", tweakDBIDStr, spawnPos.x, spawnPos.y, spawnPos.z))

end






return VehicleSpawner
