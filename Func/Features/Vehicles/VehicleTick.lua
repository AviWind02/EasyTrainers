local JsonHelper = require("Func/Core/JsonHelper")
local VehicleSpawner = require("Func/Vehicles/VehicleSpawner")
local VehicleRepairs = require("Func/Vehicles/VehicleRepairs")

local VehicleTick = {}

local lastCheck = 0
local vehicleSpawnEnabled = false
local vehicleRepairEnabled = false

function VehicleTick.TickHandler(delta)
    lastCheck = lastCheck + delta
    if lastCheck >= 1.0 then
        lastCheck = 0
        vehicleSpawnEnabled = JsonHelper.GetBoolValue("VehicleSpawn", "ShouldSpawn")
        vehicleRepairEnabled = JsonHelper.GetBoolValue("VehicleOptions", "RepairVehicle")
    end

    if vehicleRepairEnabled then
        VehicleRepairs.Tick()
        JsonHelper.SetBoolValue("VehicleOptions", "RepairVehicle", false)
    end

    if  vehicleRepairEnabledLooped then
        if VehicleRepairs.IsVehicleDamaged() then
            VehicleRepairs.Tick()
        end
    end


    if vehicleSpawnEnabled then
        VehicleSpawner.HandleVehicleSpawnRequest()
        JsonHelper.SetBoolValue("VehicleSpawn", "ShouldSpawn", false)
        vehicleSpawnEnabled = false
    end
end

return VehicleTick
