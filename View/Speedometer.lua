local Buttons = require("UI").Buttons
local Notification = require("UI").Notification
local JsonHelper = require("Core/JsonHelper")

local Speedometer = {
    enabled = { value = false },
    size = { value = 200, min = 100, max = 800, step = 5 },
    needleScale = { value = 75, min = 10, max = 100, step = 1 },
    useKmh = { value = true },
    dialColor = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
    needleColor = { Red = 255, Green = 0, Blue = 0, Alpha = 255 },
    shadowColor = { Red = 0, Green = 0, Blue = 0, Alpha = 180 },
}

local vehicleData = {
    speed = 0.0,
    rpm   = 0.0,
    gear  = 0,
    raw   = 0.0,
    debug = ""
}

local ETSpeedo = nil
local configPath = "Config/JSON/speedometer_config.json"

function Speedometer.GetETSpeedo()
    if ETSpeedo ~= nil or Speedometer._handlerChecked then
        return ETSpeedo
    end

    Speedometer._handlerChecked = true

    local ok, instance = pcall(function()
        return EasySpeedometerHandler and EasySpeedometerHandler.new() or nil
    end)

    if ok and instance then
        ETSpeedo = instance
        Notification.Info("EasySpeedometer found and loaded", 3)
    else
        ETSpeedo = nil
    end

    return ETSpeedo
end
local function SaveConfig()
    local ok, err = JsonHelper.Write(configPath, Speedometer)
    if ok then
        Notification.Success("Speedometer settings saved", 3)
    else
        Notification.Error("Failed to save config: " .. tostring(err), 3)
    end
end

local function LoadConfig()
    local data, err = JsonHelper.Read(configPath)
    if not data then
        Notification.Warning("No saved config found", 3)
        return
    end
    for k, v in pairs(data) do
        if Speedometer[k] then
            Speedometer[k] = v
        end
    end
    Notification.Success("Speedometer settings loaded", 3)
end

local function ResetConfig()
    Speedometer.enabled.value = false
    Speedometer.size.value = 200
    Speedometer.needleScale.value = 75
    Speedometer.useKmh.value = true
    Speedometer.dialColor = { Red = 255, Green = 255, Blue = 255, Alpha = 255 }
    Speedometer.needleColor = { Red = 255, Green = 0, Blue = 0, Alpha = 255 }
    Speedometer.shadowColor = { Red = 0, Green = 0, Blue = 0, Alpha = 180 }
    Notification.Info("Speedometer reset to defaults", 3)
end


local function Menu()

    local et = Speedometer.GetETSpeedo()
    if not et then
         Buttons.OptionExtended("Info", "", "Install the EasySpeedometer to enable this feature.")
        Buttons.Break("Handler Missing", "EasySpeedometer not installed")
        return
    end

    Buttons.Toggle("Enable Speedometer", Speedometer.enabled, "Toggle the in-game HUD speedometer", function()
        et:Enable(Speedometer.enabled.value)
    end)

    Buttons.Toggle("Use Kilometers (disable MPH)", Speedometer.useKmh, "Switch between km/h and mph display", function()
        et:UseKilometers(Speedometer.useKmh.value)
    end)

    Buttons.Int("Size", Speedometer.size, "Adjust overall dial size", function()
        et:SetSize(Speedometer.size.value)
    end)

    Buttons.Int("Needle Scale", Speedometer.needleScale, "Adjust needle length / scale", function()
        et:SetNeedleScale(Speedometer.needleScale.value / 100.0)
    end)

    Buttons.Break("Colors")

    if Buttons.Color("Dial Color", Speedometer.dialColor, "Set dial color") then
        local c = Speedometer.dialColor
        et:SetDialColor(c.Red / 255, c.Green / 255, c.Blue / 255, c.Alpha / 255)
    end

    if Buttons.Color("Needle Color", Speedometer.needleColor, "Set needle color") then
        local c = Speedometer.needleColor
        et:SetNeedleColor(c.Red / 255, c.Green / 255, c.Blue / 255, c.Alpha / 255)
    end

    if Buttons.Color("Shadow Color", Speedometer.shadowColor, "Set shadow color") then
        local c = Speedometer.shadowColor
        et:SetShadowColor(c.Red / 255, c.Green / 255, c.Blue / 255, c.Alpha / 255)
    end

    Buttons.Break("Save & Config")

    Buttons.Option("Save Settings", "Save all speedometer options to disk", SaveConfig)
    Buttons.Option("Load Settings", "Load previously saved configuration", LoadConfig)
    Buttons.Option("Reset Defaults", "Reset all settings to default values", ResetConfig)


end

--[[  
    Buttons.Break("Debug Info")
    Buttons.OptionExtended("Speed", string.format("%.0f", vehicleData.speed),
    Speedometer.useKmh.value and "km/h" or "mph")
    Buttons.OptionExtended("Speed (MPH)", string.format("%.0f", vehicleData.speed / 1.61), "")
    Buttons.OptionExtended("Raw Speed", string.format("%.2f", vehicleData.raw), "m/s")
    Buttons.OptionExtended("RPM", string.format("%.0f", vehicleData.rpm), "")
    Buttons.OptionExtended("Gear", tostring(vehicleData.gear), "")
    Buttons.OptionExtended("Debug", vehicleData.debug or "", "")
]]
Speedometer.SubMenu = { title = "Speedometer", view = Menu }

function Speedometer.UpdateVehicleData()
    if not handlerLoaded then return end
    local et = GetETSpeedo()
    if not et then return end

    vehicleData.debug = ""

    local player = Game.GetPlayer()
    if not player then
        vehicleData.speed, vehicleData.rpm, vehicleData.gear, vehicleData.raw = 0, 0, 0, 0
        vehicleData.debug = "No player"
        return
    end

    local veh = player:GetMountedVehicle()
    if not veh then
        vehicleData.speed, vehicleData.rpm, vehicleData.gear, vehicleData.raw = 0, 0, 0, 0
        vehicleData.debug = "No vehicle"
        return
    end

    local rawSpeed = veh:GetCurrentSpeed() or 0.0
    vehicleData.raw = rawSpeed

    local stats = Game.GetStatsDataSystem()
    local mph = 0.0
    if stats then
        local mult = stats:GetValueFromCurve("vehicle_ui", rawSpeed, "speed_to_multiplier")
        mph = rawSpeed * (mult or 1.0)
    else
        mph = rawSpeed * 2.23694
    end

    vehicleData.speed = Speedometer.useKmh.value and mph * 1.61 or mph

    local bb = veh:GetBlackboard()
    if bb then
        local defs = GetAllBlackboardDefs().Vehicle
        if defs then
            vehicleData.rpm  = bb:GetFloat(defs.RPMValue) or 0.0
            vehicleData.gear = bb:GetInt(defs.GearValue) or 0
        else
            vehicleData.debug = "No defs.Vehicle"
        end
    else
        vehicleData.debug = "No Vehicle Blackboard"
    end

    et:SetSpeed(vehicleData.speed)
end

return Speedometer
