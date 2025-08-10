local VehicleLightControl = require("Features/Vehicle/VehicleHeadlights")
local Buttons = require("UI").Buttons

local lightTypes = {
    { name = "vehiclelights.head", type = vehicleELightType.Head },
    { name = "vehiclelights.brake", type = vehicleELightType.Brake },
    { name = "vehiclelights.left", type = vehicleELightType.LeftBlinker },
    { name = "vehiclelights.right", type = vehicleELightType.RightBlinker },
    { name = "vehiclelights.reverse", type = vehicleELightType.Reverse },
    { name = "vehiclelights.interior", type = vehicleELightType.Interior },
    { name = "vehiclelights.utility", type = vehicleELightType.Utility },
    { name = "vehiclelights.default", type = vehicleELightType.Default },
    { name = "vehiclelights.blinkers", type = vehicleELightType.Blinkers }
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
    Buttons.Color(L("vehiclelights.setallcolor.label"), globalColorRef, L("vehiclelights.setallcolor.tip"))

    if Buttons.Option(L("vehiclelights.applyallcolor.label"), L("vehiclelights.applyallcolor.tip")) then
        VehicleLightControl.SetAllLightsColor(Color.new(globalColorRef))
    end

    if Buttons.Option(L("vehiclelights.resetallcolor.label"), L("vehiclelights.resetallcolor.tip")) then
        VehicleLightControl.ResetAllLightColors()
    end

    if Buttons.Option(L("vehiclelights.disableall.label"), L("vehiclelights.disableall.tip")) then
        VehicleLightControl.DisableAllLights()
    end

    Buttons.Toggle(L("vehiclelights.rgbfade.label"), VehicleLightControl.toggleRGBFade, L("vehiclelights.rgbfade.tip"))

    Buttons.Break(L("vehiclelights.adjustselected"))
    Buttons.Dropdown(L("vehiclelights.lighttype.label"), selectedLightRef, lightNames, L("vehiclelights.lighttype.tip"))

    local selectedLight = lightTypes[selectedLightRef.index]
    local lightKey = selectedLight.name
    local lightLabel = L(lightKey)
    local lightConfig = lightSettings[selectedLight.type]

    Buttons.Color(L("vehiclelights.color.label"), lightConfig.color, tip("vehiclelights.color.tip", { light = lightLabel }))

    if Buttons.Option(L("vehiclelights.applycolor.label"), tip("vehiclelights.applycolor.tip", { light = lightLabel })) then
        VehicleLightControl.SetLightColor(selectedLight.type, Color.new(lightConfig.color))
    end

    Buttons.Float(L("vehiclelights.strength.label"), lightConfig.strength, tip("vehiclelights.strength.tip", { light = lightLabel }))

    if Buttons.Option(L("vehiclelights.applystrength.label"), tip("vehiclelights.applystrength.tip", { light = lightLabel })) then
        VehicleLightControl.SetLightStrength(selectedLight.type, lightConfig.strength.value)
    end

    if Buttons.Option(L("vehiclelights.resetcolor.label"), tip("vehiclelights.resetcolor.tip", { light = lightLabel })) then
        VehicleLightControl.ResetLightColor(selectedLight.type)
    end

    if Buttons.Option(L("vehiclelights.resetstrength.label"), tip("vehiclelights.resetstrength.tip", { light = lightLabel })) then
        VehicleLightControl.ResetLightStrength(selectedLight.type)
    end

    if Buttons.Option(L("vehiclelights.resetall.label"), tip("vehiclelights.resetall.tip", { light = lightLabel })) then
        VehicleLightControl.ResetLightParameters(selectedLight.type)
    end

    if Buttons.Option(L("vehiclelights.toggleon.label"), tip("vehiclelights.toggleon.tip", { light = lightLabel })) then
        VehicleLightControl.ToggleLights(true, selectedLight.type)
    end

    if Buttons.Option(L("vehiclelights.toggleoff.label"), tip("vehiclelights.toggleoff.tip", { light = lightLabel })) then
        VehicleLightControl.ToggleLights(false, selectedLight.type)
    end
end

return {
    title = "vehiclelights.title",
    view = VehicleLightControlViewFunction
}
