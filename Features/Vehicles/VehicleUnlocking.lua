local Logger = require("Core/Logger")

local VehicleUnlockSystem = {}

function VehicleUnlockSystem.IsUnlocked(vehicleID)
    local vs = Game.GetVehicleSystem()
    if not vs then return false end
    local recordID = TweakDBID.new(vehicleID)
    return vs:IsVehiclePlayerUnlocked(recordID)
end

function VehicleUnlockSystem.SetPlayerVehicleState(vehicleID, enable)
    local vs = Game.GetVehicleSystem()
    if not vs then return false end
    local result = vs:EnablePlayerVehicle(vehicleID, enable, not enable)
    Logger.Log(string.format("VehicleUnlock: set state for %s : %s",
        tostring(vehicleID), enable and "Unlocked" or "Locked"))
    return result
end

function VehicleUnlockSystem.Unlock(vehicleID)
    return VehicleUnlockSystem.SetPlayerVehicleState(vehicleID, true)
end

function VehicleUnlockSystem.Disable(vehicleID)
    return VehicleUnlockSystem.SetPlayerVehicleState(vehicleID, false)
end

function VehicleUnlockSystem.UnlockAll()
    local vs = Game.GetVehicleSystem()
    if not vs then return false end
    vs:EnableAllPlayerVehicles()
    Logger.Log("VehicleUnlock: all vehicles unlocked")
    return true
end

return VehicleUnlockSystem
