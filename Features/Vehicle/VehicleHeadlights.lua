local VehicleLightControl = {}

-- Internal state
local frametimeRGB = 0
local RGBFadeRed, RGBFadeGreen, RGBFadeBlue = 255, 0, 0

local lightTypes = {
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

local function GetController()
    local player = Game.GetPlayer()
    local vehicle = Game.GetMountedVehicle(player)
    if not vehicle then return nil end
    return vehicle:GetAccessoryController()
end

function VehicleLightControl.SetLightColor(lightType, color, forceOverride)
    local controller = GetController()
    if not controller then return end
    controller:SetLightColor(lightType, color, 0.0, forceOverride or true)
end

function VehicleLightControl.SetAllLightsColor(color)
    local controller = GetController()
    if not controller then return end
    for _, lightType in ipairs(lightTypes) do
        controller:SetLightColor(lightType, color, 0.0, true)
    end
end

function VehicleLightControl.SetLightParameters(lightType, strength, color)
    local controller = GetController()
    if not controller then return end
    controller:SetLightParameters(lightType, strength, color, 0.0)
end

function VehicleLightControl.SetLightStrength(lightType, strength)
    local controller = GetController()
    if not controller then return end
    controller:SetLightStrength(lightType, strength, 0.0)
end

-- Does a simple RGB fade effect on all lights
function VehicleLightControl.UpdateRGB(delta)
    local controller = GetController()
    if not controller then return end

    frametimeRGB = frametimeRGB + (delta * 1000)
    if frametimeRGB > 5 then
        frametimeRGB = 0

        -- Fade logic
        if RGBFadeRed > 0 and RGBFadeBlue == 0 then
            RGBFadeRed = RGBFadeRed - 1
            RGBFadeGreen = RGBFadeGreen + 1
        elseif RGBFadeGreen > 0 and RGBFadeRed == 0 then
            RGBFadeGreen = RGBFadeGreen - 1
            RGBFadeBlue = RGBFadeBlue + 1
        elseif RGBFadeBlue > 0 and RGBFadeGreen == 0 then
            RGBFadeRed = RGBFadeRed + 1
            RGBFadeBlue = RGBFadeBlue - 1
        end

        RGBFadeRed   = math.max(0, math.min(255, RGBFadeRed))
        RGBFadeGreen = math.max(0, math.min(255, RGBFadeGreen))
        RGBFadeBlue  = math.max(0, math.min(255, RGBFadeBlue))

        local color = Color.new({ Red = RGBFadeRed, Green = RGBFadeGreen, Blue = RGBFadeBlue, Alpha = 255 })
        for _, lightType in ipairs(lightTypes) do
            controller:SetLightColor(lightType, color, 0.0, true)
        end
    end
end

function VehicleLightControl.ResetLightColor(lightType)
    local controller = GetController()
    if not controller then return end
    controller:ResetLightColor(lightType, 0.0)
end

function VehicleLightControl.ResetLightParameters(lightType)
    local controller = GetController()
    if not controller then return end
    controller:ResetLightParameters(lightType, 0.0)
end

function VehicleLightControl.ResetLightStrength(lightType)
    local controller = GetController()
    if not controller then return end
    controller:ResetLightStrength(lightType, 0.0)
end

function VehicleLightControl.ToggleLights(on, lightType)
    local controller = GetController()
    if not controller then return end
    controller:ToggleLights(on, lightType or nil, 0.0, nil, false)
end

function VehicleLightControl.DisableAllLights()
    VehicleLightControl.SetAllLightsColor(Color.new({ Red = 0, Green = 0, Blue = 0, Alpha = 255 }))
end

function VehicleLightControl.ResetAllLightColors()
    local controller = GetController()
    if not controller then return end
    for _, lightType in ipairs(lightTypes) do
        controller:ResetLightColor(lightType, 0.0)
    end
end

return VehicleLightControl
