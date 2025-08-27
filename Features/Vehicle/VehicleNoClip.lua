local logger = require("Core/Logger")
local Teleport = require("Features/Teleports/Teleport")

local function GetETInput()
    if not ETInput then
        ETInput = EasyInputHandler.new()
    end
    return ETInput
end

local VehicleNoclip = {}
VehicleNoclip.toggleNoClip = { value = false }

local yaw = 0
local moveSpeed = 5.0  
local boostMult = 3.0
local slowMult = 0.7
local deadzone = 7849

local VK_W = 87
local VK_S = 83
local VK_A = 65
local VK_D = 68
local VK_SPACE = 32
local VK_CTRL = 17
local VK_SHIFT = 16

local XINPUT_GAMEPAD_LEFT_SHOULDER = 0x0100
local XINPUT_GAMEPAD_RIGHT_SHOULDER = 0x0200
local XINPUT_GAMEPAD_LEFT_THUMB = 0x0040

local AXIS_LX = 0
local AXIS_LY = 1
local AXIS_RX = 2

local function GetRightOffset(entity, distance)
    local pos = entity:GetWorldPosition()
    local rot = entity:GetWorldOrientation():ToEulerAngles()

    local yawRight = rot.yaw + 90
    local yawRad = math.rad(yawRight)

    local xOffset = distance * math.sin(yawRad) * -1.0
    local yOffset = distance * math.cos(yawRad)

    return Vector4.new(pos.x + xOffset, pos.y + yOffset, pos.z, 1.0)
end

local noclipWasOn = false
local function RemoveRestriction()
    if not VehicleNoclip.toggleNoClip.value then
        if noclipWasOn then
            noclipWasOn = false
        end
        return
    end
end

function VehicleNoclip.Tick()
    RemoveRestriction()

    if not VehicleNoclip.toggleNoClip.value then return end

    noclipWasOn = true
    local player = Game.GetPlayer()
    if not player then return end

    local vehicle = player:GetMountedVehicle()
    if not vehicle then return end

    local et = GetETInput()
    if not et then return end

    local lx = et:GetGamepadAxis(AXIS_LX)
    local ly = et:GetGamepadAxis(AXIS_LY)
    if math.abs(lx) < deadzone then lx = 0 end
    if math.abs(ly) < deadzone then ly = 0 end

    local rx = et:GetGamepadAxis(AXIS_RX)
    if math.abs(rx) >= deadzone then
        local sens = Game.GetSettingsSystem():GetVar("/controls/fppcamerapad", "FPP_PadX"):GetValue() / 10
        yaw = yaw - (rx / 32768) * 1.7 * sens
    end

    local goUp = et:IsKeyPressed(VK_SPACE) or et:IsGamepadButtonPressed(XINPUT_GAMEPAD_RIGHT_SHOULDER)
    local goDown = et:IsKeyPressed(VK_CTRL) or et:IsGamepadButtonPressed(XINPUT_GAMEPAD_LEFT_SHOULDER)
    local speedBoost = et:IsKeyPressed(VK_SHIFT) or et:IsGamepadButtonPressed(XINPUT_GAMEPAD_LEFT_THUMB)

    local forward = et:IsKeyPressed(VK_W) or ly > 0
    local backward = et:IsKeyPressed(VK_S) or ly < 0
    local strafeRight = et:IsKeyPressed(VK_A) or lx < 0
    local strafeLeft = et:IsKeyPressed(VK_D) or lx > 0

    local frameSpeed = moveSpeed * (speedBoost and boostMult or slowMult)

    local pos = vehicle:GetWorldPosition()
    if forward then
        local fwd = Teleport.GetForwardOffset(frameSpeed, vehicle)
        pos.x, pos.y = fwd.x, fwd.y
    end

    if backward then
        local back = Teleport.GetForwardOffset(-frameSpeed, vehicle)
        pos.x, pos.y = back.x, back.y
    end

    if strafeRight then
        local right = GetRightOffset(vehicle, frameSpeed)
        pos.x, pos.y = right.x, right.y
    end

    if strafeLeft then
        local left = GetRightOffset(vehicle, -frameSpeed)
        pos.x, pos.y = left.x, left.y
    end

    if goUp then pos.z = pos.z + frameSpeed end
    if goDown then pos.z = pos.z - frameSpeed end

    if yaw < 0 then yaw = yaw + 360 end
    if yaw > 360 then yaw = yaw - 360 end

    local rot = vehicle:GetWorldOrientation():ToEulerAngles()
    rot.yaw = yaw

    Teleport.TeleportEntity(vehicle, Vector4.new(pos.x, pos.y, pos.z, 1.0), rot)
end

return VehicleNoclip
