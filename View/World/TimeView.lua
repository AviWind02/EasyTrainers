local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local WorldTime = require("Features/World/WorldTime")

local s_Hour = { value = 12, min = 0, max = 23, step = 1 }
local s_Minute = { value = 0, min = 0, max = 59, step = 1 }
local s_Second = { value = 0, min = 0, max = 59, step = 1 }
local s_SkipDays = { value = 1, min = 1, max = 100, step = 1 }
local s_SkipStep = { value = 500, min = 100, max = 5000, step = 100 }

local function ApplyCustomTime()
    WorldTime.SetGameTime(s_Hour.value, s_Minute.value, s_Second.value)
end

local function Format24(hour, minute, second)
    return string.format("%02d:%02d:%02d", hour, minute, second)
end

local function Format12(hour, minute, second)
    local hour12 = hour % 12
    if hour12 == 0 then hour12 = 12 end
    return string.format("%02d:%02d:%02d %s", hour12, minute, second, hour < 12 and "AM" or "PM")
end

local function ExclusiveToggle(label, ref, tipText)
    Buttons.Toggle(label, ref, tipText, function(enabled) WorldTime.SetExclusiveMode(ref, enabled) end)
end

local function TimeView()
    local time = WorldTime.GetTime()
    s_Hour.value = time.hours
    s_Minute.value = time.minutes

    Buttons.OptionExtended(L("worldtime.currenttime24.label"), "", Format24(time.hours, time.minutes, time.seconds), L("worldtime.currenttime24.tip"))
    Buttons.OptionExtended(L("worldtime.currenttime12.label"), "", Format12(time.hours, time.minutes, time.seconds), L("worldtime.currenttime12.tip"))

    Buttons.Break("Set Custom Time")
    Buttons.Int(L("worldtime.hour.label"), s_Hour, tip("worldtime.hour.tip", { formatted_time = Format12(s_Hour.value, 0, 0) }), ApplyCustomTime)
    Buttons.Int(L("worldtime.minute.label"), s_Minute, L("worldtime.minute.tip"), ApplyCustomTime)
    Buttons.Int(L("worldtime.second.label"), s_Second, L("worldtime.second.tip"), ApplyCustomTime)

    Buttons.Break(L("worldtime.quickset.label"))
    Buttons.Option(L("worldtime.setmorning.label"), L("worldtime.setmorning.tip"), WorldTime.SetTimeMorning)
    Buttons.Option(L("worldtime.setnoon.label"), L("worldtime.setnoon.tip"), WorldTime.SetTimeNoon)
    Buttons.Option(L("worldtime.setafternoon.label"), L("worldtime.setafternoon.tip"), WorldTime.SetTimeAfternoon)
    Buttons.Option(L("worldtime.setevening.label"), L("worldtime.setevening.tip"), WorldTime.SetTimeEvening)
    Buttons.Option(L("worldtime.setnight.label"), L("worldtime.setnight.tip"), WorldTime.SetTimeNight)

    Buttons.Break(L("worldtime.skipmultiplier.label"))
    Buttons.Int(L("worldtime.skipdays.label"), s_SkipDays, L("worldtime.skipdays.tip"))
    Buttons.Int(L("worldtime.skipstepspeed.label"), s_SkipStep, L("worldtime.skipstepspeed.tip"))
    Buttons.Option(L("worldtime.startskipping.label"), L("worldtime.startskipping.tip"), function()
        WorldTime.SkipDays(s_SkipDays.value, s_SkipStep.value)
    end)

    Buttons.Break(L("worldtime.freezefast.label"))
    ExclusiveToggle(L("worldtime.freezetime.label"), WorldTime.FreezeTime, L("worldtime.freezetime.tip"))
    ExclusiveToggle(L("worldtime.synctopc.label"), WorldTime.SyncToSystemClock, L("worldtime.synctopc.tip"))
    Buttons.Float(L("worldtime.fasterdayspeed.label"), WorldTime.DaySpeed, L("worldtime.fasterdayspeed.tip"))
    Buttons.Float(L("worldtime.fasternightspeed.label"), WorldTime.NightSpeed, L("worldtime.fasternightspeed.tip"))

    Buttons.Break(L("worldtime.timelapse.label"))
    ExclusiveToggle(L("worldtime.enabletimelapse.label"), WorldTime.TimeLapse, L("worldtime.enabletimelapse.tip"))
    Buttons.Int(L("worldtime.timelapsemultiplier.label"), WorldTime.TimeLapseMultiplier, L("worldtime.timelapsemultiplier.tip"))
end

return Submenu.Create("worldtime.title", TimeView)
