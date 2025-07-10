local JsonHelper = require("Func/Core/JsonHelper")
local VehicleRepairs = require("Func/Vehicles/VehicleRepairs")

local VehicleEvents = {}

local vehicleRepairEnabledLooped = false


function VehicleEvents.Init()
    Observe("vehicleBaseObject", "OnHit", function(self, evt)
        vehicleRepairEnabledLooped = JsonHelper.GetBoolValue("VehicleOptions", "RepairVehicleLooped")
        if vehicleRepairEnabledLooped then
            VehicleRepairs.Tick()
        end
    end)
end

return VehicleEvents
