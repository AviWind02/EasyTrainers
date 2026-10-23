local OptionConfig = require("Config/OptionConfig")
local WorldTime = require("Features/World/WorldTime")
local WorldWeather = require("Features/World/WorldWeather")

local function Toggle(id, ref, key, keywords)
    return OptionConfig.DefineToggle(id, ref, false, {
        LabelKey = key .. ".label",
        TipKey = key .. ".tip",
        Keywords = keywords
    })
end

local function Number(id, ref, default, label)
    return { Id = id, Kind = OptionConfig.Registry.Kind.Number, Ref = ref, Default = default, Label = label, Category = "world" }
end

local function RegisterAllWorldOptions()
    OptionConfig.RegisterAll({
        Toggle("toggle.world.freezeTime", WorldTime.FreezeTime, "worldtime.freezetime", { "clock", "pause" }),
        Toggle("toggle.world.timeLapse", WorldTime.TimeLapse, "worldtime.enabletimelapse", { "clock", "speed" }),
        Toggle("toggle.world.syncSystemClock", WorldTime.SyncToSystemClock, "worldtime.synctopc", { "clock", "computer", "real time" }),
        Toggle("toggle.world.freezeWeather", WorldWeather.Freeze, "worldweather.freeze", { "climate", "rain", "sun" }),
        Number("number.world.timeLapseMultiplier", WorldTime.TimeLapseMultiplier, 2, "Time Lapse Multiplier"),
        Number("number.world.daySpeed", WorldTime.DaySpeed, 2.0, "Day Speed"),
        Number("number.world.nightSpeed", WorldTime.NightSpeed, 2.0, "Night Speed")
    })
end

return RegisterAllWorldOptions
