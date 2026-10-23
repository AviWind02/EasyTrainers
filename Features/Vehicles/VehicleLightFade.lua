local Vehicle = require("Utils/Vehicle")
local VehicleLights = require("Features/Vehicles/VehicleLights")

local VehicleLightFade = {}

VehicleLightFade.Enabled = { value = false }

local STEP_MS = 5

local s_Elapsed = 0
local s_Red = 255
local s_Green = 0
local s_Blue = 0
local s_Active = false

local function Advance()
    if s_Red > 0 and s_Blue == 0 then
        s_Red, s_Green = s_Red - 1, s_Green + 1
    elseif s_Green > 0 and s_Red == 0 then
        s_Green, s_Blue = s_Green - 1, s_Blue + 1
    elseif s_Blue > 0 and s_Green == 0 then
        s_Red, s_Blue = s_Red + 1, s_Blue - 1
    end
end

function VehicleLightFade.Tick(deltaTime)
    if not VehicleLightFade.Enabled.value then
        if s_Active then
            VehicleLights.ResetAllLightColors()
            s_Active = false
        end
        return
    end

    if not Vehicle.GetMountedVehicleSafe() then
        s_Active = false
        return
    end

    s_Active = true
    s_Elapsed = s_Elapsed + deltaTime * 1000
    if s_Elapsed <= STEP_MS then return end
    s_Elapsed = 0

    Advance()
    VehicleLights.SetAllLightsColor(Color.new({ Red = s_Red, Green = s_Green, Blue = s_Blue, Alpha = 255 }))
end

return VehicleLightFade
