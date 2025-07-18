local VehicleSpawner = {}
local JsonHelper = require("Func/Core/JsonHelper")

local sharePath = "Shared/SharedFeature.json"

-- Spawns the vehicle in front of the player
function VehicleSpawner.Spawn(tweakDBIDStr, spawnDist)
    local player = Game.GetPlayer()
    if not player then
        print("[EasyTrainerVehicleSpawner] Error: Player not found.")
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
    print(string.format("[EasyTrainerVehicleSpawner] Requesting vehicle '%s' at (%.2f, %.2f, %.2f)",
        tweakDBIDStr, spawnPos.x, spawnPos.y, spawnPos.z))

    Game.GetPreventionSpawnSystem():RequestUnitSpawn(vehicleID, transform)
end

function VehicleSpawner.TestSpawnAndMount(tweakDBIDStr, spawnDist)
    local player = Game.GetPlayer()
    if not player then
        print("[EasyTrainerVehicleSpawner] Error: Player not found.")
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

    Game.GetWorkspotSystem():MountToVehicle(entity,  Game.GetPlayer().GetEntity(), 0, 0, "OccupantSlots", "seat_front_left")

end






return VehicleSpawner
