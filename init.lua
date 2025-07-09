local generalItems = require("DataExtractors/GeneralItems")
local vehiclesItems = require("DataExtractors/VehiclesItems")
local weaponsItems = require("DataExtractors/WeaponItems")

local status = require("Func/Core/SharedStatus")

local playerEvents = require("Func/Events/PlayerEvents")
local projectileEvents = require("Func/Events/ProjectileEvents")

local weaponsTickEvents = require("Func/Weapons/WeaponTick")
local vehicleTickEvents = require("Func/Vehicles/VehicleTick")

 


registerForEvent("onInit", function()
    print("[EasyTrainerInit] Starting initialization")

    print("[EasyTrainerInit] Resetting dump statuses.")
    status.ResetStatuses({
        "GeneralItems",
        "VehiclesItems",
        "WeaponsItems"
    })

    print("[EasyTrainerInit] Performing data dumps")
    generalItems.Dump()
    vehiclesItems.Dump()
    weaponsItems.Dump()

    print("[EasyTrainerInit] Initializing events")
    playerEvents.Init()
    projectileEvents.Init()


    print("[EasyTrainerInit] Initialization complete.")
end)


registerForEvent("onUpdate", function(delta)
    weaponsTickEvents.TickHandler(delta)
    vehicleTickEvents.TickHandler(delta) 
end)
