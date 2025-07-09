local VehicleSpawner = {}
local JsonHelper = require("Func/Core/JsonHelper")

local sharePath = "Shared/SharedFeature.json"

-- Spawns the vehicle in front of the player
function VehicleSpawner.Spawn(tweakDBIDStr, spawnDist)
    local player = Game.GetPlayer()
    if not player then
        print("[VehicleSpawner] Error: Player not found.")
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
    print(string.format("[VehicleSpawner] Requesting vehicle '%s' at (%.2f, %.2f, %.2f)",
        tweakDBIDStr, spawnPos.x, spawnPos.y, spawnPos.z))

    Game.GetPreventionSpawnSystem():RequestUnitSpawn(vehicleID, transform)
end

-- Reads the spawn request from SharedFeature.json and spawns the vehicle
function VehicleSpawner.HandleVehicleSpawnRequest()
    local config = JsonHelper.ReadJson(sharePath)
    if not config or not config.VehicleSpawn then return end

    local vs = config.VehicleSpawn
    if vs.ShouldSpawn and vs.SpawnTweakID then
        local distance = tonumber(vs.SpawnDistance) or 8.0

        print(string.format("[VehicleSpawner] Spawning vehicle '%s' at distance %.1f", vs.SpawnTweakID, distance))
        VehicleSpawner.Spawn(vs.SpawnTweakID, distance)

        config.VehicleSpawn.ShouldSpawn = false
        JsonHelper.WriteJson(sharePath, config)

        print("[VehicleSpawner] Spawn flag reset.")
    end
end

return VehicleSpawner
