local Draw = require("UI")
local logger = require("Core/Logger")

local VehicleSystem = {}

function VehicleSystem.IsVehicleUnlocked(vehicleID)
    local vehicleSystem = Game.GetVehicleSystem()
    if not vehicleSystem then
        logger.Log("[EasyTrainerVehicleSystem] Failed to get VehicleSystem")
        return false
    end

    local recordID = TweakDBID.new(vehicleID)
    return vehicleSystem:IsVehiclePlayerUnlocked(recordID)
end

function VehicleSystem.SetPlayerVehicleState(vehicleID, enable)
    local vehicleSystem = Game.GetVehicleSystem()
    if not vehicleSystem then
        logger.Log("[EasyTrainerVehicleSystem] VehicleSystem not available")
        return false
    end

    if VehicleSystem.IsVehicleUnlocked(vehicleID) == enable then
        logger.Log("[EasyTrainerVehicleSystem] Vehicle already in desired state: " .. vehicleID)
        return true
    end

    -- EnablePlayerVehicle(vehicle: String, enable: Bool, despawnIfDisabling: Bool) → Bool
    local result = vehicleSystem:EnablePlayerVehicle(vehicleID, enable, not enable)

    local message = (enable and "Unlocked" or "Disabled") .. " vehicle: " .. vehicleID
    Draw.Notifier.Push(message, 3.5, "Auto", enable and "success" or "warning")
    logger.Log("[EasyTrainerVehicleSystem] " .. message .. " | Result: " .. tostring(result))

    return result
end


function VehicleSystem.UnlockPlayerVehicle(vehicleID)
    local success = VehicleSystem.SetPlayerVehicleState(vehicleID, true)
    if not success then
        Draw.Notifier.Push("Failed to unlock vehicle: " .. vehicleID, 3.5, "Auto", "error")
        logger.Log("[EasyTrainerVehicleSystem] Failed to unlock: " .. vehicleID)
    end
    return success
end

function VehicleSystem.DisablePlayerVehicle(vehicleID)
    local success = VehicleSystem.SetPlayerVehicleState(vehicleID, false)
    if not success then
        Draw.Notifier.Push("Failed to remove vehicle: " .. vehicleID, 3.5, "Auto", "error")
        logger.Log("[EasyTrainerVehicleSystem] Failed to disable: " .. vehicleID)
    end
    return success
end

function VehicleSystem.EnableAllVehicles()
    local vehicleSystem = Game.GetVehicleSystem()
    if not vehicleSystem then
        logger.Log("[EasyTrainerVehicleSystem] VehicleSystem not available")
        return
    end

    vehicleSystem:EnableAllPlayerVehicles()
    Draw.Notifier.Push("All vehicles unlocked", 3.5, "Auto", "success")
    logger.Log("[EasyTrainerVehicleSystem] Enabled all player vehicles")
end

return VehicleSystem
