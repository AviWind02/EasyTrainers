local Draw = require("UI")
local Buttons = Draw.Buttons
local WorldWeather = require("Features/World").WorldWeather

local weatherRadio = { index = 1 }

local weatherOptions = {
    "Sunny",
    "Light Clouds",
    "Cloudy",
    "Heavy Clouds",
    "Fog",
    "Rain",
    "Toxic Rain",
    "Pollution",
    "Sandstorm",
    "Deeb Blue",
    "Rain (Light)",
    "Squat Morning",
    "Cloudy (Morning)",
    "Rain (Night)",
    "Clouds (Courier)"
}

local weatherMap = {
    "24h_weather_sunny",
    "24h_weather_light_clouds",
    "24h_weather_cloudy",
    "24h_weather_heavy_clouds",
    "24h_weather_fog",
    "24h_weather_rain",
    "24h_weather_toxic_rain",
    "24h_weather_pollution",
    "24h_weather_sandstorm",
    "q302_deeb_blue",
    "q302_light_rain",
    "q302_squat_morning",
    "q306_epilogue_cloudy_morning",
    "q306_rainy_night",
    "sa_courier_clouds"
}

local function GetCurrentWeatherIndex()
    local current = WorldWeather.GetCurrentWeather()
    for i, id in ipairs(weatherMap) do
        if id == current then
            return i
        end
    end
    return 1
end

local transitionSeconds = { value = 1, min = 1, max = 60, step = 1 }


local function ViewWorldWeather()
    weatherRadio.index = GetCurrentWeatherIndex()

    Buttons.OptionExtended("Current Weather:", "", WorldWeather.GetCurrentWeather())
    Buttons.Toggle("Freeze Weather", WorldWeather.freezeWeather, "Prevents weather from changing naturally.")
    Buttons.Option("Random Weather", "Apply a random weather preset.", WorldWeather.SetRandomWeather)
    Buttons.Option("Reset Weather", "Reset to default dynamic weather system.", WorldWeather.ResetWeather)
    Buttons.Int("Transition Duration (s)", transitionSeconds, "Weather transition time in seconds.")

    Buttons.Break("", "Weather Type")

    Buttons.Radio("Weather Type", weatherRadio, weatherOptions, "Change to this weather type.", function()
        local selectedWeather = weatherMap[weatherRadio.index]
        WorldWeather.SetWeather(selectedWeather, transitionSeconds.value)
    end)
end

local WorldWeatherView = {
    title = "World Weather",
    view = ViewWorldWeather
}

return WorldWeatherView
