local Logger = require("Core/Logger")
local Lifecycle = require("Core/Lifecycle")

local WorldWeather = {}

WorldWeather.Freeze = { value = false }

WorldWeather.States = {
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

local CHECK_INTERVAL = 1.0
local ENFORCE_BLEND = 5

local s_Locked = nil
local s_Enforced = false
local s_NextCheck = 0

function WorldWeather.GetCurrentWeather()
    local system = Game.GetWeatherSystem()
    local state = system and system:GetWeatherState() or nil
    return state and tostring(state.name.value) or "Unknown"
end

function WorldWeather.SetWeather(state, blendSeconds)
    local system = Game.GetWeatherSystem()
    if not system then return end

    blendSeconds = blendSeconds or 1
    system:SetWeather(state, blendSeconds, 1)
    Logger.Log(string.format("WorldWeather: set %s (%ds)", state, blendSeconds))
end

function WorldWeather.SetRandomWeather()
    WorldWeather.SetWeather(WorldWeather.States[math.random(1, #WorldWeather.States)])
end

function WorldWeather.ResetWeather()
    local system = Game.GetWeatherSystem()
    if not system then return end
    system:ResetWeather(true)
    Logger.Log("WorldWeather: reset weather")
end

local function Release()
    if s_Enforced then WorldWeather.ResetWeather() end
    s_Locked = nil
    s_Enforced = false
end

function WorldWeather.Update()
    if not WorldWeather.Freeze.value then
        if s_Locked then Release() end
        return
    end

    if not s_Locked then s_Locked = WorldWeather.GetCurrentWeather() end

    local now = os.clock()
    if now < s_NextCheck then return end
    s_NextCheck = now + CHECK_INTERVAL

    if WorldWeather.GetCurrentWeather() ~= s_Locked then
        WorldWeather.SetWeather(s_Locked, ENFORCE_BLEND)
        s_Enforced = true
    end
end

Lifecycle.Register("WorldWeather", {
    OnSessionEnd = function()
        s_Locked = nil
        s_Enforced = false
    end,
    OnShutdown = Release
})

return WorldWeather
