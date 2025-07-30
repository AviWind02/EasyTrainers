local WorldTime = require("Features/World").WorldTime
local Draw = require("UI")
local Buttons = Draw.Buttons

-- Declare UI-only controls
WorldTime.customHour = { value = 12, min = 0, max = 23, step = 1 }
WorldTime.customMinute = { value = 0, min = 0, max = 59, step = 1 }
WorldTime.customSecond = { value = 0, min = 0, max = 59, step = 1 }
WorldTime.customTimeEdited = false

WorldTime.skipDaysAmount = { value = 1, min = 1, max = 100, step = 1 }
WorldTime.skipStepSize = { value = 500, min = 100, max = 5000, step = 100 }



function WorldTime.ApplyCustomGameTime()
    WorldTime.SetGameTime(WorldTime.customHour.value, WorldTime.customMinute.value, WorldTime.customSecond.value)
end

local function OnCustomTimeChanged()
    WorldTime.customTimeEdited = true
    WorldTime.ApplyCustomGameTime()
end

local function FormatTime24(hour, minute, second)
    return string.format("%02d:%02d:%02d", hour, minute, second)
end

local function FormatTime12(hour, minute, second)
    local hour12 = hour % 12
    if hour12 == 0 then hour12 = 12 end
    local ampm = (hour < 12) and "AM" or "PM"
    return string.format("%02d:%02d:%02d %s", hour12, minute, second, ampm)
end

local function WorldTimeViewFunction()
    local time = WorldTime.GetTime()


    if not WorldTime.customTimeEdited then
        WorldTime.customHour.value = time.hours
        WorldTime.customMinute.value = time.minutes
        -- WorldTime.customSecond.value = time.seconds -- Fights User when in use and trying to change to much work to get it right
    end


    -- Buttons.OptionExtended("Current Hour", "", string.format("%02d", time.hours))
    -- Buttons.OptionExtended("Current Minute", "", string.format("%02d", time.minutes))
    -- Buttons.OptionExtended("Current Second", "", string.format("%02d", time.seconds))
    -- Buttons.OptionExtended("Current Day", "", tostring(time.day)) -- not working
    
    local time24 = FormatTime24(time.hours, time.minutes, time.seconds)
    Buttons.OptionExtended("Current Time (24H)", "", time24)

    local time12 = FormatTime12(time.hours, time.minutes, time.seconds)
    Buttons.OptionExtended("Current Time (12H)", "", time12)

    Buttons.Int("Hour", WorldTime.customHour, string.format("Set custom hour value. (%s)", FormatTime12(WorldTime.customHour.value, 0, 0)), OnCustomTimeChanged)
    Buttons.Int("Minute", WorldTime.customMinute, "Set custom minute value.", OnCustomTimeChanged)
    Buttons.Int("Second", WorldTime.customSecond, "Set custom second value.", OnCustomTimeChanged)
    WorldTime.customTimeEdited = false
    
    Buttons.Toggle("Sync to PC Time", WorldTime.toggleSyncToSystemClock, "Matches in-game time to your real-world PC time.")
    
    Buttons.Break("Quick Set")
    Buttons.Option("Set Time: Morning", "Sets time to 6:00 AM", WorldTime.SetTimeMorning)
    Buttons.Option("Set Time: Noon", "Sets time to 12:00 PM", WorldTime.SetTimeNoon)
    Buttons.Option("Set Time: Afternoon", "Sets time to 3:00 PM", WorldTime.SetTimeAfternoon)
    Buttons.Option("Set Time: Evening", "Sets time to 6:00 PM", WorldTime.SetTimeEvening)
    Buttons.Option("Set Time: Night", "Sets time to 10:00 PM", WorldTime.SetTimeNight)

    Buttons.Break("Time Skip & Multiplier")
    Buttons.Int("Skip Days", WorldTime.skipDaysAmount, "How many in-game days to skip.")
    Buttons.Int("Skip Step Speed", WorldTime.skipStepSize, "Controls how fast time skips. Higher = faster.")
    Buttons.Option("Start Skipping", "Begin time skip over the specified number of days", function()
        WorldTime.SkipDays(WorldTime.skipDaysAmount.value, WorldTime.skipStepSize.value)
    end)

    Buttons.Break("Freeze & Fast Forward")
    Buttons.Toggle("Freeze Time", WorldTime.toggleFreezeTime, "Freezes the current game time.")
    Buttons.Float("Faster Day Speed", WorldTime.daySpeedMultiplier, "Enable and set daytime speed multiplier.")
    Buttons.Float("Faster Night Speed", WorldTime.nightSpeedMultiplier, "Enable and set nighttime speed multiplier.")

    
    Buttons.Break("Time Lapse")
    Buttons.Toggle("Enable Time-Lapse", WorldTime.toggleTimeLapse, "Continuously advances time.")
    Buttons.Int("Time-Lapse Multiplier", WorldTime.timeLapseMultiplier, "How fast time speeds forward.")


end

local WorldTimeView = {
    title = "World Time",
    view = WorldTimeViewFunction
}

return WorldTimeView
