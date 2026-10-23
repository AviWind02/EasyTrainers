local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local VehicleLights = require("Features/Vehicles/VehicleLights")

local LIGHT_TYPES = {
    { Name = "vehiclelights.head", Type = vehicleELightType.Head },
    { Name = "vehiclelights.brake", Type = vehicleELightType.Brake },
    { Name = "vehiclelights.left", Type = vehicleELightType.LeftBlinker },
    { Name = "vehiclelights.right", Type = vehicleELightType.RightBlinker },
    { Name = "vehiclelights.reverse", Type = vehicleELightType.Reverse },
    { Name = "vehiclelights.interior", Type = vehicleELightType.Interior },
    { Name = "vehiclelights.utility", Type = vehicleELightType.Utility },
    { Name = "vehiclelights.default", Type = vehicleELightType.Default },
    { Name = "vehiclelights.blinkers", Type = vehicleELightType.Blinkers }
}

local s_LightNames = {}
local s_Settings = {}
local s_AllColor = { Red = 255, Green = 255, Blue = 255, Alpha = 255 }
local s_Selected = { index = 1, expanded = false }

for _, light in ipairs(LIGHT_TYPES) do
    table.insert(s_LightNames, light.Name)
    s_Settings[light.Type] = {
        Color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
        Strength = { value = 1.0 }
    }
end

local function VehicleLightView()
    Buttons.Color(L("vehiclelights.setallcolor.label"), s_AllColor, L("vehiclelights.setallcolor.tip"))
    Buttons.Option(L("vehiclelights.applyallcolor.label"), L("vehiclelights.applyallcolor.tip"), function()
        VehicleLights.SetAllLightsColor(Color.new(s_AllColor))
    end)
    Buttons.Option(L("vehiclelights.resetallcolor.label"), L("vehiclelights.resetallcolor.tip"), VehicleLights.ResetAllLightColors)
    Buttons.Option(L("vehiclelights.disableall.label"), L("vehiclelights.disableall.tip"), VehicleLights.DisableAllLights)

    Buttons.Break(L("vehiclelights.adjustselected"))
    Buttons.Dropdown(L("vehiclelights.lighttype.label"), s_Selected, s_LightNames, L("vehiclelights.lighttype.tip"))

    local light = LIGHT_TYPES[s_Selected.index or 1]
    local settings = s_Settings[light.Type]
    local placeholders = { light = L(light.Name) }

    Buttons.Color(L("vehiclelights.color.label"), settings.Color, tip("vehiclelights.color.tip", placeholders))
    Buttons.Option(L("vehiclelights.applycolor.label"), tip("vehiclelights.applycolor.tip", placeholders), function()
        VehicleLights.SetLightColor(light.Type, Color.new(settings.Color))
    end)
    Buttons.Float(L("vehiclelights.strength.label"), settings.Strength, tip("vehiclelights.strength.tip", placeholders))
    Buttons.Option(L("vehiclelights.applystrength.label"), tip("vehiclelights.applystrength.tip", placeholders), function()
        VehicleLights.SetLightStrength(light.Type, settings.Strength.value)
    end)
    Buttons.Option(L("vehiclelights.resetcolor.label"), tip("vehiclelights.resetcolor.tip", placeholders), function()
        VehicleLights.ResetLightColor(light.Type)
    end)
    Buttons.Option(L("vehiclelights.resetstrength.label"), tip("vehiclelights.resetstrength.tip", placeholders), function()
        VehicleLights.ResetLightStrength(light.Type)
    end)
    Buttons.Option(L("vehiclelights.resetall.label"), tip("vehiclelights.resetall.tip", placeholders), function()
        VehicleLights.ResetLightParameters(light.Type)
    end)
    Buttons.Option(L("vehiclelights.toggleon.label"), tip("vehiclelights.toggleon.tip", placeholders), function()
        VehicleLights.ToggleLights(true, light.Type)
    end)
    Buttons.Option(L("vehiclelights.toggleoff.label"), tip("vehiclelights.toggleoff.tip", placeholders), function()
        VehicleLights.ToggleLights(false, light.Type)
    end)
end

return Submenu.Create("vehiclelights.title", VehicleLightView)
