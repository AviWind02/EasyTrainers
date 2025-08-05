local Vehicle = require("Features/Vehicle")
local Buttons = require("UI").Buttons

local VehicleListView = require("View/Vehicle/VehicleListView")
local VehicleHeadLightView = require("View/Vehicle/VehicleHeadLightView")
local VehicleFeaures = require("Features/Vehicle")

local Gameplay = require("Gameplay").StatModifiers

local doorStateRef = { index = 1, expanded = false }
local doorStateOptions = { "Open", "Closed", "Detached" }

local function VehicleDoorViewFunction()

    Buttons.Dropdown("Door State", doorStateRef, doorStateOptions, "Select the desired state for the door.")
    Buttons.Break("Select Door")

    local selectedState = VehicleFeaures.Doors.VehicleDoorState[doorStateOptions[doorStateRef.index]]

    local doorTargets = {
        { label = "Front Left", id = VehicleFeaures.Doors.EVehicleDoor.FrontLeft },
        { label = "Front Right", id = VehicleFeaures.Doors.EVehicleDoor.FrontRight },
        { label = "Rear Left", id = VehicleFeaures.Doors.EVehicleDoor.RearLeft },
        { label = "Rear Right", id = VehicleFeaures.Doors.EVehicleDoor.RearRight },
        { label = "Hood", id = VehicleFeaures.Doors.EVehicleDoor.Hood },
        { label = "Trunk", id = VehicleFeaures.Doors.EVehicleDoor.Trunk },
    }

    for _, door in ipairs(doorTargets) do
        local label = door.label
        local tip = "Set " .. label:lower() .. " to " .. doorStateOptions[doorStateRef.index]:lower()
        local action = function()
            VehicleFeaures.Doors.SetDoorState(door.id, selectedState)
        end
        Buttons.Option(label, tip, action)
    end
end

local VehicleDoorView = { title = "Vehicle Door Controls", view = VehicleDoorViewFunction }


local function VehicleViewFunction()
    if Buttons.Submenu("Vehicle List", VehicleListView, "View all vehicles and toggle which ones are enabled or disabled in your owned vehicle menu.") then VehicleFeaures.enableVehicleSpawnerMode = false end
    if Buttons.Submenu("Vehicle Spawner", VehicleListView, "Request any vehicles directly in front of the player. Does not add them to your owned list.") then VehicleFeaures.enableVehicleSpawnerMode = true end
    Buttons.Submenu("Vehicle Headlights", VehicleHeadLightView, "Control vehicle headlights and light types.")
    Buttons.Submenu("Vehicle Doors", VehicleDoorView, "Open and close vehicle doors.")
    Buttons.Option("Repair Vehicle", "Repair current vehicle", Vehicle.Repairs.Tick)
end


local VehicleView = { title = "Vehicle Menu", view = VehicleViewFunction }

return VehicleView
