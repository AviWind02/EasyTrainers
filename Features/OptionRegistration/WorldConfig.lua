local ConfigManager = require("Core/ConfigManager")
local World = require("Features/World")

local function RegisterWorldOptions()
    local WorldTime = World.WorldTime
    local WorldWeather = World.WorldWeather

    ConfigManager.Register("toggle.worldtime.synctopc",   WorldTime.toggleSyncToSystemClock, false)
    ConfigManager.Register("toggle.worldtime.freezetime", WorldTime.toggleFreezeTime, false)
    ConfigManager.Register("toggle.worldtime.timelapse",  WorldTime.toggleTimeLapse, false)

    ConfigManager.Register("toggle.worldweather.freeze",  WorldWeather.freezeWeather, false)
end

return RegisterWorldOptions
