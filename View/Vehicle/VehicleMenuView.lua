local Vehicle = require("Features/Vehicle")
local Buttons = require("UI").Buttons

local VehicleListView = require("View/Vehicle/VehicleListView")
local VehicleHeadLightView = require("View/Vehicle/VehicleHeadLightView")
local VehicleFeaures = require("Features/Vehicle")

local Gameplay = require("Gameplay")

local doorStateRef = { index = 1, expanded = false }
local doorStateOptions = { L("vehiclemenu.vehicledoormenu.doorstateoptions.open"), L("vehiclemenu.vehicledoormenu.doorstateoptions.closed"), L("vehiclemenu.vehicledoormenu.doorstateoptions.detached") }

local function VehicleDoorViewFunction()
    Buttons.Dropdown(L("vehiclemenu.vehicledoormenu.doorstate.label"), doorStateRef, doorStateOptions, L("vehiclemenu.vehicledoormenu.doorstate.tip"))
    Buttons.Break(L("vehiclemenu.vehicledoormenu.selectdoor"))

    local selectedStateKey = doorStateOptions[doorStateRef.index]
    local selectedState = VehicleFeaures.Doors.VehicleDoorState[selectedStateKey]

    local doorTargets = {
        { key = "frontleft", id = VehicleFeaures.Doors.EVehicleDoor.FrontLeft },
        { key = "frontright", id = VehicleFeaures.Doors.EVehicleDoor.FrontRight },
        { key = "rearleft", id = VehicleFeaures.Doors.EVehicleDoor.RearLeft },
        { key = "rearright", id = VehicleFeaures.Doors.EVehicleDoor.RearRight },
        { key = "hood", id = VehicleFeaures.Doors.EVehicleDoor.Hood },
        { key = "trunk", id = VehicleFeaures.Doors.EVehicleDoor.Trunk }
    }

    for _, door in ipairs(doorTargets) do
        local label = L("vehiclemenu.vehicledoormenu.doors." .. door.key)
        local tipText = tip("vehiclemenu.vehicledoormenu.doortips.set", { door = label, state = string.lower(selectedStateKey) })
        Buttons.Option(label, tipText, function() VehicleFeaures.Doors.SetDoorState(door.id, selectedState) end)
    end
end

local VehicleDoorView = { title = L("vehiclemenu.vehicledoormenu.title"), view = VehicleDoorViewFunction }

function test()
    local player = Game.GetPlayer()
    local vehicle = Game.GetMountedVehicle(player)
    vehicle:EnableAirControl(true)
end

local function VehicleViewFunction()
    if Buttons.Submenu(L("vehiclemenu.vehiclelist.label"), VehicleListView, L("vehiclemenu.vehiclelist.tip")) then VehicleFeaures.enableVehicleSpawnerMode = false end
    if Buttons.Submenu(L("vehiclemenu.vehiclespawner.label"), VehicleListView, L("vehiclemenu.vehiclespawner.tip")) then VehicleFeaures.enableVehicleSpawnerMode = true end
    Buttons.Submenu(L("vehiclemenu.vehicleheadlights.label"), VehicleHeadLightView, L("vehiclemenu.vehicleheadlights.tip"))
    Buttons.Submenu(L("vehiclemenu.vehicledoors.label"), VehicleDoorView, L("vehiclemenu.vehicledoors.tip"))
    Buttons.Option(L("vehiclemenu.repairvehicle.label"), L("vehiclemenu.repairvehicle.tip"), Vehicle.Repairs.Tick)
    Buttons.Option(L("vehiclemenu.basilisk.name"), L("vehiclemenu.basilisk.tip"), function()
        VehicleFeaures.Spawner.RequestVehicle("Vehicle.v_militech_basilisk_militech", 5)
    end)
    -- Buttons.Toggle(L("vehiclemenu.vehiclenoclip.label"), VehicleFeaures.VehicleNoClip.toggleNoClip, L("vehiclemenu.vehiclenoclip.tip"))
end

local VehicleView = { title = L("vehiclemenu.title"), view = VehicleViewFunction }

return VehicleView
