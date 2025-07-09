local JsonHelper = require("Func/Core/JsonHelper")
local VehicleSpawner = require("Func/Vehicles/VehicleSpawner")

local VehicleTick = {}

local lastCheck = 0
local vehicleSpawnEnabled = false

function VehicleTick.TickHandler(delta)
    lastCheck = lastCheck + delta
    if lastCheck >= 1.0 then
        lastCheck = 0
        vehicleSpawnEnabled = JsonHelper.GetBoolValue("VehicleSpawn", "ShouldSpawn")
    end

    if vehicleSpawnEnabled then
        VehicleSpawner.HandleVehicleSpawnRequest()
        JsonHelper.SetBoolValue("VehicleSpawn", "ShouldSpawn", false)
        vehicleSpawnEnabled = false
    end
end

return VehicleTick
