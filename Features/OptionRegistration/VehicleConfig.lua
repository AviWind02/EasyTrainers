local ConfigManager = require("Core/ConfigManager")
local VehicleLightControl = require("Features/Vehicle/VehicleHeadlights")

local function RegisterVehicleOptions()
    ConfigManager.Register("toggle.vehicle.rgbfade", VehicleLightControl.toggleRGBFade, false)
end

return RegisterVehicleOptions
