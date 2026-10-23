local Vehicle = require("Utils/Vehicle")

local VehicleLights = {}

local LIGHT_TYPES = {
    vehicleELightType.Head,
    vehicleELightType.Brake,
    vehicleELightType.LeftBlinker,
    vehicleELightType.RightBlinker,
    vehicleELightType.Reverse,
    vehicleELightType.Interior,
    vehicleELightType.Utility,
    vehicleELightType.Default,
    vehicleELightType.Blinkers
}

local function WithController(callback)
    local controller = Vehicle.GetController()
    if controller then callback(controller) end
end

function VehicleLights.SetLightColor(lightType, color)
    WithController(function(controller) controller:SetLightColor(lightType, color, 0.0) end)
end

function VehicleLights.SetAllLightsColor(color)
    WithController(function(controller)
        for _, lightType in ipairs(LIGHT_TYPES) do controller:SetLightColor(lightType, color, 0.0) end
    end)
end

function VehicleLights.SetLightParameters(lightType, strength, color)
    WithController(function(controller) controller:SetLightParameters(lightType, strength, color, 0.0) end)
end

function VehicleLights.SetLightStrength(lightType, strength)
    WithController(function(controller) controller:SetLightStrength(lightType, strength, 0.0) end)
end

function VehicleLights.ResetLightColor(lightType)
    WithController(function(controller) controller:ResetLightColor(lightType, 0.0) end)
end

function VehicleLights.ResetLightParameters(lightType)
    WithController(function(controller) controller:ResetLightParameters(lightType, 0.0) end)
end

function VehicleLights.ResetLightStrength(lightType)
    WithController(function(controller) controller:ResetLightStrength(lightType, 0.0) end)
end

function VehicleLights.ToggleLights(on, lightType)
    WithController(function(controller) controller:ToggleLights(on, lightType, 0.0, "", false) end)
end

function VehicleLights.DisableAllLights()
    VehicleLights.SetAllLightsColor(Color.new({ Red = 0, Green = 0, Blue = 0, Alpha = 255 }))
end

function VehicleLights.ResetAllLightColors()
    WithController(function(controller)
        for _, lightType in ipairs(LIGHT_TYPES) do controller:ResetLightColor(lightType, 0.0) end
    end)
end

return VehicleLights
