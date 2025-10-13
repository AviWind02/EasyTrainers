local Buttons = require("UI").Buttons

local Speedometer = {
    enabled = { value = false },
    size = { value = 200, min = 100, max = 800, step = 5 },
    needleScale = { value = 75, min = 10, max = 100, step = 1 },
    useKmh = { value = true },
    dialColor = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
    needleColor = { Red = 255, Green = 0, Blue = 0, Alpha = 255 },
    shadowColor = { Red = 0, Green = 0, Blue = 0, Alpha = 180 },
}

-- vehicle data cache
local vehicleData = {
    speed = 0.0,
    rpm   = 0.0,
    gear  = 0,
    debug = ""
}

-- cached handler
local ETSpeedo = nil
local function GetETSpeedo()
    if not ETSpeedo then ETSpeedo = EasySpeedometerHandler.new() end
    return ETSpeedo
end

local function Menu()
    local et = GetETSpeedo()
    if not et then return end

    Buttons.Toggle("Enable Speedometer", Speedometer.enabled, "Toggle the HUD speedometer", function()
        et:Enable(Speedometer.enabled.value)
    end)

    Buttons.Toggle("Use Kilometers (toggle MPH off)", Speedometer.useKmh, "Switch between km/h and mph", function()
        if Speedometer.useKmh.value then
            et:UseKilometers(true)
        else
            et:UseMiles(true)
        end
    end)

    Buttons.Int("Size", Speedometer.size, "Adjust overall size", function()
        et:SetSize(Speedometer.size.value)
    end)

    Buttons.Int("Needle Scale", Speedometer.needleScale, "Adjust needle length/scale", function()
        et:SetNeedleScale(Speedometer.needleScale.value / 100.0)
    end)

    Buttons.Break("Colors")

    if Buttons.Color("Dial Color", Speedometer.dialColor, "Adjust dial color") then
        local c = Speedometer.dialColor
        et:SetDialColor(c.Red / 255, c.Green / 255, c.Blue / 255, c.Alpha / 255)
    end

    if Buttons.Color("Needle Color", Speedometer.needleColor, "Adjust needle color") then
        local c = Speedometer.needleColor
        et:SetNeedleColor(c.Red / 255, c.Green / 255, c.Blue / 255, c.Alpha / 255)
    end

    if Buttons.Color("Shadow Color", Speedometer.shadowColor, "Adjust shadow color") then
        local c = Speedometer.shadowColor
        et:SetShadowColor(c.Red / 255, c.Green / 255, c.Blue / 255, c.Alpha / 255)
    end

    Buttons.Break("Debug Info")
    Buttons.OptionExtended("Speed", string.format("%.0f", vehicleData.speed), Speedometer.useKmh.value and "km/h" or "mph")
    Buttons.OptionExtended("RPM", string.format("%.0f", vehicleData.rpm), "")
    Buttons.OptionExtended("Gear", tostring(vehicleData.gear), "")
    Buttons.OptionExtended("Debug", vehicleData.debug or "", "")
end

Speedometer.SubMenu = { title = "Speedometer", view = Menu }

function Speedometer.UpdateVehicleData()
    local et = GetETSpeedo()
    if not et then return end

    vehicleData.debug = ""

    local player = Game.GetPlayer()
    if not player then
        vehicleData.speed, vehicleData.rpm, vehicleData.gear = 0.0, 0.0, 0
        vehicleData.debug = "No player"
        return
    end

    local veh = player:GetMountedVehicle()
    if not veh then
        vehicleData.speed, vehicleData.rpm, vehicleData.gear = 0.0, 0.0, 0
        vehicleData.debug = "No vehicle"
        return
    end

    local rawSpeed = veh:GetCurrentSpeed() or 0.0
    local stats = Game.GetStatsDataSystem()
    if stats then
        local multiplier = stats:GetValueFromCurve("vehicle_ui", rawSpeed, "speed_to_multiplier")
        local mph = rawSpeed * multiplier

        if Speedometer.useKmh.value then
            vehicleData.speed = mph * 1.61
        else
            vehicleData.speed = mph
        end
    else
        if Speedometer.useKmh.value then
            vehicleData.speed = rawSpeed * 3.6
        else
            vehicleData.speed = rawSpeed * 2.23694
        end
    end

    local bb = veh:GetBlackboard()
    if not bb then
        vehicleData.debug = "No Vehicle Blackboard"
    else
        local defs = GetAllBlackboardDefs().Vehicle
        if defs then
            vehicleData.rpm  = bb:GetFloat(defs.RPMValue) or 0.0
            vehicleData.gear = bb:GetInt(defs.GearValue) or 0
        else
            vehicleData.debug = "No defs.Vehicle"
        end
    end

    et:SetSpeed(vehicleData.speed)
end

return Speedometer
