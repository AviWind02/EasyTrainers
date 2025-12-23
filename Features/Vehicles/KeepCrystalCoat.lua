local Vehicle = require("Utils/Vehicle")

local KeepCrystalCoat = {}

KeepCrystalCoat.toggleKeepCrystalCoat = { value = false }

function KeepCrystalCoat:BlockDisable(this, wrappedMethod) -- maybe I'm not coding it right. leaving this out for now since it blocks it from resetting. 
    if not Vehicle.IsValidVehicle(this) then -- Need to look into these methods more. 
        return wrappedMethod()
    end

    local ps = this:GetVehiclePS()
    if not ps then
        return wrappedMethod()
    end

    if not KeepCrystalCoat.toggleKeepCrystalCoat.value then
        if ps.GetIsVehicleApperanceCustomizationInDistanceTermination
            and ps:GetIsVehicleApperanceCustomizationInDistanceTermination() then
            ps:SetVehicleApperanceCustomizationInDistanceTermination(false)
        end

        return wrappedMethod()
    end

    if ps:GetIsVehicleVisualCustomizationActive() then
        return false
    end

    return wrappedMethod()
end

return KeepCrystalCoat
