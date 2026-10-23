local Logger = require("Core/Logger")

local Vehicle = {}

function Vehicle.IsValidVehicle(entity)
    return entity ~= nil and entity:GetVehicleComponent() ~= nil
end

function Vehicle.GetMountedVehicleSafe()
    local player = Game.GetPlayer()
    if not player then return nil end

    local vehicle = player:GetMountedVehicle()
    if not Vehicle.IsValidVehicle(vehicle) then return nil end
    return vehicle
end

function Vehicle.UnmountPlayer(force)
    local player = Game.GetPlayer()
    local vehicle = Vehicle.GetMountedVehicleSafe()
    if not player or not vehicle then
        Logger.Log("Vehicle: no vehicle to unmount")
        return false
    end

    local workspot = Game.GetWorkspotSystem()
    if not workspot then return false end

    workspot:UnmountFromVehicle(vehicle, player, force or false)
    return true
end

function Vehicle.MountPlayer(vehicle, seat)
    if not Vehicle.IsValidVehicle(vehicle) then
        Logger.Log("Vehicle: invalid vehicle for mount")
        return false
    end

    local component = vehicle:GetVehicleComponent()
    local player = Game.GetPlayer()
    if not component or not player then return false end

    component:MountEntityToSlot(vehicle:GetEntityID(), player:GetEntityID(), CName.new(seat or "seat_front_left"))
    return true
end

function Vehicle.GetController()
    local vehicle = Vehicle.GetMountedVehicleSafe()
    return vehicle and vehicle:GetAccessoryController() or nil
end

function Vehicle.GetSpawnTransform(player, distance)
    local forward = player:GetWorldForward()
    local transform = player:GetWorldTransform()
    local position = transform.Position:ToVector4()
    local spawnPosition = Vector4.new(
        position.x + forward.x * distance,
        position.y + forward.y * distance,
        position.z + 0.5,
        1.0
    )

    transform:SetPosition(transform, spawnPosition)
    return transform, spawnPosition
end

return Vehicle
