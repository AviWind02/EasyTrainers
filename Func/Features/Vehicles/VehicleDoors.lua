
local VehicleDoors = {}

local EVehicleDoor = {
    FrontLeft = 0,   
    FrontRight = 1,
    RearLeft = 2,
    RearRight = 3,
    Trunk = 4,
    Hood = 5,
    Count = 6,
    Invalid = 7 
}
local VehicleDoorState = {
    Closed = 0,
    Open = 1
}

local function GetVehicleComponent(vehicle)
    if vehicle and vehicle:GetClassName() == "VehicleObject" then
        return vehicle:GetVehicleComponent()
    end
    return nil
end

-- Base function to set door state
function VehicleDoors.SetDoorState(vehicle, doorIndex, open)
    local gvc = GetVehicleComponent(vehicle)
    if gvc then
        local state = open and VehicleDoorState.Open or VehicleDoorState.Closed
        gvc:SetDoorAnimFeatureData(doorIndex, state)
        print(("[VehicleDoors] Set door %d to state %s"):format(doorIndex, open and "OPEN" or "CLOSED"))
    else
        print("[VehicleDoors] Failed to get VehicleComponent.")
    end
end

-- Helper functions for each door
function VehicleDoors.OpenFrontLeftDoor(vehicle)  VehicleDoors.SetDoorState(vehicle, EVehicleDoor.FrontLeft, true) end
function VehicleDoors.CloseFrontLeftDoor(vehicle) VehicleDoors.SetDoorState(vehicle, EVehicleDoor.FrontLeft, false) end

function VehicleDoors.OpenFrontRightDoor(vehicle)  VehicleDoors.SetDoorState(vehicle, EVehicleDoor.FrontRight, true) end
function VehicleDoors.CloseFrontRightDoor(vehicle) VehicleDoors.SetDoorState(vehicle, EVehicleDoor.FrontRight, false) end

function VehicleDoors.OpenRearLeftDoor(vehicle)  VehicleDoors.SetDoorState(vehicle, EVehicleDoor.RearLeft, true) end
function VehicleDoors.CloseRearLeftDoor(vehicle) VehicleDoors.SetDoorState(vehicle, EVehicleDoor.RearLeft, false) end

function VehicleDoors.OpenRearRightDoor(vehicle)  VehicleDoors.SetDoorState(vehicle, EVehicleDoor.RearRight, true) end
function VehicleDoors.CloseRearRightDoor(vehicle) VehicleDoors.SetDoorState(vehicle, EVehicleDoor.RearRight, false) end

function VehicleDoors.OpenHood(vehicle)  VehicleDoors.SetDoorState(vehicle, EVehicleDoor.Hood, true) end
function VehicleDoors.CloseHood(vehicle) VehicleDoors.SetDoorState(vehicle, EVehicleDoor.Hood, false) end

function VehicleDoors.OpenTrunk(vehicle)  VehicleDoors.SetDoorState(vehicle, EVehicleDoor.Trunk, true) end
function VehicleDoors.CloseTrunk(vehicle) VehicleDoors.SetDoorState(vehicle, EVehicleDoor.Trunk, false) end

return VehicleDoors
