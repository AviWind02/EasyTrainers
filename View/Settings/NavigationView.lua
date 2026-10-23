local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Handler = require("Controls/Handler")
local Bindings = require("Controls/Bindings")
local NavigationConfig = require("Config/NavigationConfig")

local MENU_BINDINGS = {
    { "openmenu", "TOGGLE" },
    { "togglemouse", "TOGGLE_MOUSE" },
    { "up", "UP" },
    { "down", "DOWN" },
    { "left", "LEFT" },
    { "right", "RIGHT" },
    { "select", "SELECT" },
    { "back", "BACK" },
    { "misc", "MISC" }
}

local SPEED_FIELDS = {
    { Field = "ScrollDelayBase", Key = "scrolldelay", Min = 50, Max = 1000 },
    { Field = "ScrollMinDelay", Key = "scrollmindelay", Min = 1, Max = 200 },
    { Field = "AccelThreshold", Key = "accelthreshold", Min = 100, Max = 5000 },
    { Field = "AccelStep", Key = "accelstep", Min = 1, Max = 100 }
}

local s_SpeedRefs = {}
for _, field in ipairs(SPEED_FIELDS) do
    s_SpeedRefs[field.Field] = { value = Handler[field.Field], min = field.Min, max = field.Max }
end

local function NavigationView()
    Buttons.Option(L("settings.navigation.save.label"), tip("settings.navigation.save.tip"), NavigationConfig.Save)
    Buttons.Option(L("settings.navigation.load.label"), tip("settings.navigation.load.tip"), NavigationConfig.Load)
    Buttons.Option(L("settings.navigation.reset.label"), tip("settings.navigation.reset.tip"), NavigationConfig.Reset)
    Buttons.Option(L("settings.navigation.resetbindings.label"), tip("settings.navigation.resetbindings.tip"), Bindings.ResetAll)

    Buttons.Break(L("settings.navigation.bindings.label"))
    for _, binding in ipairs(MENU_BINDINGS) do
        local key = "settings.navigation.bindings." .. binding[1]
        Buttons.Bind(L(key .. ".label"), binding[2], tip(key .. ".tip"))
    end

    Buttons.Break(L("settings.navigation.speed.label"))
    for _, field in ipairs(SPEED_FIELDS) do
        local ref = s_SpeedRefs[field.Field]
        local key = "settings.navigation.speed." .. field.Key
        ref.value = Handler[field.Field]
        Buttons.Int(L(key .. ".label"), ref, tip(key .. ".tip"), function(value) Handler[field.Field] = value end)
    end
end

return Submenu.Create("settings.navigation.title", NavigationView)
