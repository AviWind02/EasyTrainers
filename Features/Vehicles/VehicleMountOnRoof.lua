local Logger = require("Core/Logger")
local Notification = require("UI/Panels/Notification/Notification")
local Vehicle = require("Utils/Vehicle")

local VehicleMountOnRoof = {}

function VehicleMountOnRoof.MountOnRoof()
    if not Vehicle.GetMountedVehicleSafe() then
        Notification.Info("No mounted vehicle to mount")
        return false
    end

    Vehicle.UnmountPlayer(true)
    Logger.Log("VehicleMountOnRoof: player placed on top of vehicle roof")
    return true
end

return VehicleMountOnRoof
