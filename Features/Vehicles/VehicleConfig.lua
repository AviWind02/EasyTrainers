local OptionConfig = require("Config/OptionConfig")
local VehicleViewStates = require("Features/Vehicles/VehicleViewStates")
local VehicleLightFade = require("Features/Vehicles/VehicleLightFade")
local VehicleSpeedometer = require("Features/Vehicles/VehicleSpeedometer")
local FreezeQuestTimer = require("Features/Vehicles/FreezeQuestTimer")

local function Toggle(id, ref, default, metadata)
    metadata.Category = "vehicle"
    return OptionConfig.DefineToggle(id, ref, default, metadata)
end

local function RegisterAllVehicleOptions()
    OptionConfig.RegisterAll({
        Toggle("toggle.spawner.deletelast", VehicleViewStates.DeleteLastVehicle, true, {
            LabelKey = "vehiclelist.deletelast.label",
            TipKey = "vehiclelist.deletelast.tip",
            Keywords = { "spawn", "delete", "last vehicle" }
        }),
        Toggle("toggle.spawner.mountonspawn", VehicleViewStates.MountOnSpawn, true, {
            LabelKey = "vehiclelist.mountonspawn.label",
            TipKey = "vehiclelist.mountonspawn.tip",
            Keywords = { "spawn", "mount", "enter vehicle" }
        }),
        Toggle("toggle.spawner.preview", VehicleViewStates.PreviewVehicle, true, {
            LabelKey = "vehiclelist.previewvehicle.label",
            TipKey = "vehiclelist.previewvehicle.tip",
            Keywords = { "spawn", "preview" }
        }),
        Toggle("toggle.vehicle.rgblights", VehicleLightFade.Enabled, false, {
            LabelKey = "vehiclelights.rgbfade.label",
            TipKey = "vehiclelights.rgbfade.tip",
            Keywords = { "rgb", "lights", "color" }
        }),
        Toggle("toggle.vehicle.speedometer", VehicleSpeedometer.Enabled, false, {
            Label = "Vehicle Speedometer",
            Tip = "Show the analog speedometer while driving.",
            Keywords = { "speed", "speedometer", "rpm", "gear" }
        }),
        Toggle("toggle.vehicle.speedometer.mph", VehicleSpeedometer.UseMPH, false, {
            Label = "Use MPH",
            Tip = "Display vehicle speed in miles per hour instead of kilometers per hour.",
            Keywords = { "speed", "mph", "kph", "units" }
        }),
        Toggle("toggle.vehicle.speedometer.rpm", VehicleSpeedometer.ShowRPM, true, {
            Label = "Show RPM Gauge",
            Tip = "Show the smaller engine RPM gauge.",
            Keywords = { "rpm", "gauge", "engine" }
        }),
        Toggle("toggle.vehicle.speedometer.automaticMax", VehicleSpeedometer.AutomaticMaxSpeed, false, {
            Label = "Automatic Maximum Speed",
            Tip = "Estimate the dial range from the mounted vehicle's highest gear speed.",
            Keywords = { "speedometer", "maximum", "automatic" }
        }),
        Toggle("toggle.vehicle.freezeQuestTimers", FreezeQuestTimer.Enabled, false, {
            Label = "Freeze Vehicle Quest Timers",
            Tip = "Prevent timed vehicle objectives from counting down.",
            Keywords = { "quest", "timer", "freeze" }
        })
    })
end

return RegisterAllVehicleOptions
