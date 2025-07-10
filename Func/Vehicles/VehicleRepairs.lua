--[[
    Command: fixVehicle
    Source: Categorized All-In-One Command List
    Created by: Silverhandsome
    Uploaded by: bartovalenza
    Description: Fully repairs the player's current vehicle if they're inside one.
]]

local VehicleRepairs = {}

function VehicleRepairs.IsVehicleDamaged()
    local player = Game.GetPlayer()
    local vehicle = Game.GetMountedVehicle(player)

    if not vehicle then return false end

    local gvc = vehicle:GetVehiclePS()
    if not gvc then return false end
    return gvc:GetIsDestroyed()


end


function VehicleRepairs.Tick()
    local player = Game.GetPlayer()
    if not Game.GetWorkspotSystem():IsActorInWorkspot(player) then
        print("[EasyTrainerFixVehicle] You're not in a vehicle!")
        return
    end

    local vehicle = Game['GetMountedVehicle;GameObject'](player)
    if not vehicle then
        print("[EasyTrainerFixVehicle] No mounted vehicle found.")
        return
    end

    local vps = vehicle:GetVehiclePS()
    local vc = vehicle:GetVehicleComponent()
    local name = vehicle:GetDisplayName()
    local type = vehicle:GetVehicleType().value

    print(string.format("[EasyTrainerFixVehicle] Repairing: %s (%s)", name, type))

    -- Reset damage level
    vc.damageLevel = 0

    -- Reset visible damage if not a bike
    if type ~= "Bike" then
        vc.bumperFrontState = 0
        vc.bumperBackState = 0

        local parts = {
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

        for _, part in ipairs(parts) do
            AnimationControllerComponent.SetInputFloat(vehicle, part, 0.0)
            print("[EasyTrainerFixVehicle] Reset part:", part)
        end
    end

    -- Fix all tires if any are flat
    if vehicle:GetFlatTireIndex() >= 0 then
        for i = 0, 3 do
            vehicle:ToggleBrokenTire(i, false)
            print("[EasyTrainerFixVehicle] Repaired tire:", i)
        end
    end

    -- Reset visual and mechanical damage
    vehicle:DestructionResetGrid()
    vehicle:DestructionResetGlass()
    vc:UpdateDamageEngineEffects()
    vc:RepairVehicle()
    vc:VehicleVisualDestructionSetup()

    -- Ensure doors/windows are closed and state is synced
    vps:CloseAllVehDoors(true)
    vps:CloseAllVehWindows()
    vps:ForcePersistentStateChanged()

    print("[EasyTrainerFixVehicle] Repair complete.")
end

return VehicleRepairs

