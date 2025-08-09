local VehicleLightControl = require("Features/Vehicle/VehicleHeadlights")
local Buttons = require("UI").Buttons

local lightTypes = {
    { name = "vehicle_lights.head", type = vehicleELightType.Head },
    { name = "vehicle_lights.brake", type = vehicleELightType.Brake },
    { name = "vehicle_lights.left", type = vehicleELightType.LeftBlinker },
    { name = "vehicle_lights.right", type = vehicleELightType.RightBlinker },
    { name = "vehicle_lights.reverse", type = vehicleELightType.Reverse },
    { name = "vehicle_lights.interior", type = vehicleELightType.Interior },
    { name = "vehicle_lights.utility", type = vehicleELightType.Utility },
    { name = "vehicle_lights.default", type = vehicleELightType.Default },
    { name = "vehicle_lights.blinkers", type = vehicleELightType.Blinkers }
}

local lightSettings = {}
for _, lt in ipairs(lightTypes) do
    lightSettings[lt.type] = {
        color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
        strength = { value = 1.0 }
    }
end

local globalColorRef = { Red = 255, Green = 255, Blue = 255, Alpha = 255 }
local selectedLightRef = { index = 1, expanded = false }

local lightNames = {}
for _, lt in ipairs(lightTypes) do table.insert(lightNames, lt.name) end

local function VehicleLightControlViewFunction()
    Buttons.Color(L("vehicle_lights.set_all_color.label"), globalColorRef, L("vehicle_lights.set_all_color.tip"))

    if Buttons.Option(L("vehicle_lights.apply_all_color.label"), L("vehicle_lights.apply_all_color.tip")) then
        VehicleLightControl.SetAllLightsColor(Color.new(globalColorRef))
    end

    if Buttons.Option(L("vehicle_lights.reset_all_color.label"), L("vehicle_lights.reset_all_color.tip")) then
        VehicleLightControl.ResetAllLightColors()
    end

    if Buttons.Option(L("vehicle_lights.disable_all.label"), L("vehicle_lights.disable_all.tip")) then
        VehicleLightControl.DisableAllLights()
    end

    Buttons.Toggle(L("vehicle_lights.rgb_fade.label"), VehicleLightControl.toggleRGBFade, L("vehicle_lights.rgb_fade.tip"))

    Buttons.Break(L("vehicle_lights.adjust_selected"))
    Buttons.Dropdown(L("vehicle_lights.light_type.label"), selectedLightRef, lightNames, L("vehicle_lights.light_type.tip"))

    local selectedLight = lightTypes[selectedLightRef.index]
    local lightKey = selectedLight.name
    local lightLabel = L(lightKey)
    local lightConfig = lightSettings[selectedLight.type]

    Buttons.Color(L("vehicle_lights.color.label"), lightConfig.color, tip("vehicle_lights.color.tip", { light = lightLabel }))

    if Buttons.Option(L("vehicle_lights.apply_color.label"), tip("vehicle_lights.apply_color.tip", { light = lightLabel })) then
        VehicleLightControl.SetLightColor(selectedLight.type, Color.new(lightConfig.color))
    end

    Buttons.Float(L("vehicle_lights.strength.label"), lightConfig.strength, tip("vehicle_lights.strength.tip", { light = lightLabel }))

    if Buttons.Option(L("vehicle_lights.apply_strength.label"), tip("vehicle_lights.apply_strength.tip", { light = lightLabel })) then
        VehicleLightControl.SetLightStrength(selectedLight.type, lightConfig.strength.value)
    end

    if Buttons.Option(L("vehicle_lights.reset_color.label"), tip("vehicle_lights.reset_color.tip", { light = lightLabel })) then
        VehicleLightControl.ResetLightColor(selectedLight.type)
    end

    if Buttons.Option(L("vehicle_lights.reset_strength.label"), tip("vehicle_lights.reset_strength.tip", { light = lightLabel })) then
        VehicleLightControl.ResetLightStrength(selectedLight.type)
    end

    if Buttons.Option(L("vehicle_lights.reset_all.label"), tip("vehicle_lights.reset_all.tip", { light = lightLabel })) then
        VehicleLightControl.ResetLightParameters(selectedLight.type)
    end

    if Buttons.Option(L("vehicle_lights.toggle_on.label"), tip("vehicle_lights.toggle_on.tip", { light = lightLabel })) then
        VehicleLightControl.ToggleLights(true, selectedLight.type)
    end

    if Buttons.Option(L("vehicle_lights.toggle_off.label"), tip("vehicle_lights.toggle_off.tip", { light = lightLabel })) then
        VehicleLightControl.ToggleLights(false, selectedLight.type)
    end
end

return {
    title = "vehicle_lights.title",
    view = VehicleLightControlViewFunction
}
