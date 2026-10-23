local Logger = require("Core/Logger")
local Lifecycle = require("Core/Lifecycle")
local Vehicle = require("Utils/Vehicle")

local VehicleSpawning = {}

local SPAWN_TAG = "EasyTrainer"
local DEFAULT_SEAT = "seat_front_left"

local s_ActiveSpawns = {}
local s_PendingMounts = {}

local function Despawn(entitySystem, entityID, label)
    if not entitySystem or not entityID then return end
    entitySystem:DeleteEntity(entityID)
    Logger.Log("VehicleSpawning: despawned " .. label .. " " .. tostring(entityID))
end

local function CreateSpec(recordID, position)
    local spec = NewObject("DynamicEntitySpec")
    spec.recordID = TweakDBID.new(recordID)
    spec.position = position
    spec.orientation = Quaternion.new(0, 0, 0, 1)
    spec.persistState = false
    spec.persistSpawn = false
    spec.spawnInView = true
    spec.active = true
    spec.tags = { CName.new(SPAWN_TAG) }
    return spec
end

function VehicleSpawning.RequestVehicle(recordID, distance)
    local player = Game.GetPlayer()
    if not player then return false end

    local transform, position = Vehicle.GetSpawnTransform(player, distance)
    Game.GetPreventionSpawnSystem():RequestUnitSpawn(TweakDBID.new(recordID), transform)
    Logger.Log(string.format("VehicleSpawning: requested '%s' at (%.2f, %.2f, %.2f)", recordID, position.x, position.y, position.z))
    return true
end

function VehicleSpawning.SpawnVehicle(recordID, distance, mount, deleteLast)
    local player = Game.GetPlayer()
    local entitySystem = Game.GetDynamicEntitySystem()
    if not player or not entitySystem then return nil end

    local previousID = deleteLast and s_ActiveSpawns[#s_ActiveSpawns] or nil
    local _, position = Vehicle.GetSpawnTransform(player, distance)
    local entityID = entitySystem:CreateEntity(CreateSpec(recordID, position))
    if not entityID then
        Logger.Log("VehicleSpawning: failed to spawn " .. tostring(recordID))
        return nil
    end

    if previousID and previousID ~= entityID then
        Despawn(entitySystem, previousID, "previous vehicle")
        table.remove(s_ActiveSpawns)
    end

    table.insert(s_ActiveSpawns, entityID)
    if mount then s_PendingMounts[entityID] = DEFAULT_SEAT end
    return entityID
end

function VehicleSpawning.HandlePending()
    if next(s_PendingMounts) == nil then return end

    local entitySystem = Game.GetDynamicEntitySystem()
    if not entitySystem or not Game.GetPlayer() then return end

    for entityID, seat in pairs(s_PendingMounts) do
        if entitySystem:IsSpawned(entityID) then
            s_PendingMounts[entityID] = nil
            local entity = entitySystem:GetEntity(entityID)
            if Vehicle.IsValidVehicle(entity) then
                if Vehicle.GetMountedVehicleSafe() then Vehicle.UnmountPlayer(true) end
                Vehicle.MountPlayer(entity, seat)
            end
        end
    end
end

function VehicleSpawning.Forget(entityID)
    s_PendingMounts[entityID] = nil
    for index = #s_ActiveSpawns, 1, -1 do
        if s_ActiveSpawns[index] == entityID then
            table.remove(s_ActiveSpawns, index)
            return true
        end
    end
    return false
end

function VehicleSpawning.DespawnLast()
    local lastID = table.remove(s_ActiveSpawns)
    if not lastID then
        Logger.Log("VehicleSpawning: no vehicle to despawn")
        return false
    end

    Despawn(Game.GetDynamicEntitySystem(), lastID, "last vehicle")
    return true
end

Lifecycle.Register("VehicleSpawning", {
    OnSessionEnd = function()
        s_ActiveSpawns = {}
        s_PendingMounts = {}
    end
})

return VehicleSpawning
