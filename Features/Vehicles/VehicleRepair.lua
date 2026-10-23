local Logger = require("Core/Logger")
local Notification = require("UI/Panels/Notification/Notification")
local Vehicle = require("Utils/Vehicle")

local VehicleRepair = {}

local DESTRUCTION_PARTS = {
    "hood_destruction",
    "wheel_f_l_destruction",
    "wheel_f_r_destruction",
    "bumper_b_destruction",
    "bumper_f_destruction",
    "door_f_l_destruction",
    "door_f_r_destruction",
    "trunk_destruction",
    "bumper_b_destruction_side_2",
    "bumper_f_destruction_side_2"
}

function VehicleRepair.IsVehicleDamaged()
    local vehicle = Vehicle.GetMountedVehicleSafe()
    local persistentState = vehicle and vehicle:GetVehiclePS() or nil
    return persistentState and persistentState:GetIsDestroyed() or false
end

local function ResetBodyParts(vehicle, component)
    local vehicleType = vehicle:GetVehicleType()
    if vehicleType and vehicleType.value == "Bike" then return end

    component.bumperFrontState = 0
    component.bumperBackState = 0
    for _, part in ipairs(DESTRUCTION_PARTS) do
        AnimationControllerComponent.SetInputFloat(vehicle, part, 0.0)
    end
end

function VehicleRepair.RepairMounted()
    local vehicle = Vehicle.GetMountedVehicleSafe()
    if not vehicle then
        Notification.Info("No mounted vehicle to repair")
        return false
    end

    local persistentState = vehicle:GetVehiclePS()
    local component = vehicle:GetVehicleComponent()
    if not persistentState or not component then
        Logger.Log("VehicleRepair: missing VehiclePS or VehicleComponent")
        return false
    end

    component.damageLevel = 0
    ResetBodyParts(vehicle, component)

    if vehicle:GetFlatTireIndex() >= 0 then
        for i = 0, 3 do vehicle:ToggleBrokenTire(i, false) end
    end

    vehicle:DestructionResetGrid()
    vehicle:DestructionResetGlass()
    component:UpdateDamageEngineEffects()
    component:RepairVehicle()
    component:VehicleVisualDestructionSetup()

    persistentState:CloseAllVehDoors(true)
    persistentState:CloseAllVehWindows()
    persistentState:ForcePersistentStateChanged()

    Logger.Log("VehicleRepair: repaired mounted vehicle")
    return true
end

return VehicleRepair
