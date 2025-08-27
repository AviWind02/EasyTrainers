local VehicleFeatures = {}

VehicleFeatures.Doors = require("Features/Vehicle/VehicleDoors")
VehicleFeatures.Headlights = require("Features/Vehicle/VehicleHeadlights")
VehicleFeatures.Repairs = require("Features/Vehicle/VehicleRepairs")
VehicleFeatures.Spawner = require("Features/Vehicle/VehicleSpawner")
VehicleFeatures.VehicleUnlocker = require("Features/Vehicle/VehicleUnlocker")
VehicleFeatures.VehicleNoClip = require("Features/Vehicle/VehicleNoClip")

-- Shared toggle for spawner mode
VehicleFeatures.enableVehicleSpawnerMode = false

return VehicleFeatures
