local VehicleDoors = {}

VehicleDoors.EVehicleDoor = {
    FrontLeft = vehicleEVehicleDoor.seat_front_left,   
    FrontRight = vehicleEVehicleDoor.seat_front_right,
    RearLeft = vehicleEVehicleDoor.seat_back_left,
    RearRight = vehicleEVehicleDoor.seat_back_right,
    Trunk = vehicleEVehicleDoor.trunk,
    Hood = vehicleEVehicleDoor.hood,
    Count = vehicleEVehicleDoor.count,
    Invalid = vehicleEVehicleDoor.invalid 
}
VehicleDoors.VehicleDoorState = {
    Closed = vehicleVehicleDoorState.Closed,
    Open = vehicleVehicleDoorState.Open,
    Detached = vehicleVehicleDoorState.Detached
}

-- Base function to set door state (no vehicle param needed)
function VehicleDoors.SetDoorState(doorIndex, state)
    local player = Game.GetPlayer()
    local vehicle = Game.GetMountedVehicle(player)
    local gvc = vehicle and vehicle:GetVehicleComponent()
    if gvc then
        gvc:SetDoorAnimFeatureData(doorIndex, state)
        print(("[VehicleDoors] Set door %d to state %s"):format(doorIndex, tostring(state)))
    else
        print("[VehicleDoors] Failed to get VehicleComponent (are you mounted?).")
    end
end

return VehicleDoors
