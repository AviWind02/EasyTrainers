local VehicleLightControl = require("Features/Vehicle/VehicleHeadlights")
local Buttons = require("UI").Buttons

local lightTypes = {
    { name = "Headlights", type = vehicleELightType.Head },
    { name = "Brake Lights", type = vehicleELightType.Brake },
    { name = "Left Blinker", type = vehicleELightType.LeftBlinker },
    { name = "Right Blinker", type = vehicleELightType.RightBlinker },
    { name = "Reverse Lights", type = vehicleELightType.Reverse },
    { name = "Interior Lights", type = vehicleELightType.Interior },
    { name = "Utility Lights", type = vehicleELightType.Utility },
    { name = "Default Lights", type = vehicleELightType.Default },
    { name = "Blinkers (All)", type = vehicleELightType.Blinkers },
}

-- Per-light config refs
local lightSettings = {}
for _, lt in ipairs(lightTypes) do
    lightSettings[lt.type] = {
        color = {
            Red = 255,
            Green = 255,
            Blue = 255,
            Alpha = 255
        },
        strength = { value = 1.0 }
    }
end

-- Global light color
local globalColorRef = {
    Red = 255,
    Green = 255,
    Blue = 255,
    Alpha = 255
}

local selectedLightRef = { index = 1, expanded = false }
local lightNames = {}
for _, lt in ipairs(lightTypes) do table.insert(lightNames, lt.name) end

local function VehicleLightControlViewFunction()

    Buttons.Color("Set All Lights Color", globalColorRef, "Applies the selected color to all light types.")
    if Buttons.Option("Apply All Light Colors", "Sets all lights to the selected color.") then
        VehicleLightControl.SetAllLightsColor(Color.new(globalColorRef))
    end

    if Buttons.Option("Reset All Light Colors", "Resets the color of all lights.") then
        VehicleLightControl.ResetAllLightColors()
    end

    if Buttons.Option("Disable All Lights", "Turns off all vehicle lights.") then
        VehicleLightControl.DisableAllLights()
    end
    Buttons.Toggle("RGB Fade Lights", VehicleLightControl.toggleRGBFade, "Automatically cycles light colors through an RGB fade effect.")

    Buttons.Break("Adjust Selected Light")
    Buttons.Dropdown("Light Type", selectedLightRef, lightNames, "Choose which light type to configure.")

    local selectedLight = lightTypes[selectedLightRef.index]
    local lightConfig = lightSettings[selectedLight.type]

    Buttons.Color("Color", lightConfig.color, "Color for " .. selectedLight.name)
    if Buttons.Option("Apply Color", "Applies color to " .. selectedLight.name) then
        VehicleLightControl.SetLightColor(selectedLight.type, Color.new(lightConfig.color))
    end

    Buttons.Float("Strength", lightConfig.strength, "Brightness of " .. selectedLight.name)
    if Buttons.Option("Apply Strength", "Sets strength for " .. selectedLight.name) then
        VehicleLightControl.SetLightStrength(selectedLight.type, lightConfig.strength.value)
    end

    if Buttons.Option("Reset Color", "Resets color for " .. selectedLight.name) then
        VehicleLightControl.ResetLightColor(selectedLight.type)
    end
    if Buttons.Option("Reset Strength", "Resets strength for " .. selectedLight.name) then
        VehicleLightControl.ResetLightStrength(selectedLight.type)
    end
    if Buttons.Option("Reset Parameters", "Resets all parameters for " .. selectedLight.name) then
        VehicleLightControl.ResetLightParameters(selectedLight.type)
    end

    if Buttons.Option("Toggle On", "Turns on " .. selectedLight.name) then
        VehicleLightControl.ToggleLights(true, selectedLight.type)
    end
    if Buttons.Option("Toggle Off", "Turns off " .. selectedLight.name) then
        VehicleLightControl.ToggleLights(false, selectedLight.type)
    end

end

local VehicleLightView = { title = "Vehicle Light Controls", view = VehicleLightControlViewFunction }
return VehicleLightView
