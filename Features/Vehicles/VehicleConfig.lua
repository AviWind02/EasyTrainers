local ConfigManager = require("Config/OptionConfig")
local VehicleViewStates = require("Features/Vehicles/VehicleViewStates")

local function RegisterAllVehicleOptions()

    ConfigManager.Register("vehicle.spawner.deletelast", VehicleViewStates.deleteLastVehicle, true)
    ConfigManager.Register("vehicle.spawner.mountonspawn", VehicleViewStates.mountOnSpawn, true)
    ConfigManager.Register("vehicle.spawner.preview", VehicleViewStates.previewVehicle, true)
    
end

return RegisterAllVehicleOptions
