local logger = require("Core/Logger")
local Teleport = require("Features/Teleports/Teleport")

local function GetETInput()
    if not ETInput then
        ETInput = EasyInputHandler.new()
    end
    return ETInput
end

local Noclip = {}
Noclip.toggleNoClip = { value = false }

local yaw = 0
local moveSpeed = 1.5
local boostMult = 2.5
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

function Noclip.HandleMouseLook(action)
    local actionName = Game.NameToString(action:GetName(action))
    if actionName ~= "CameraMouseX" then
        return
    end

    local x = action:GetValue(action)
    local sens = Game.GetSettingsSystem():GetVar("/controls/fppcameramouse", "FPP_MouseX"):GetValue() / 2.9
    yaw = yaw - (x / 35) * sens
end

-- Move left ot right based on the player's current orientation
local function GetRightOffset(distance)
    local player = Game.GetPlayer()
    if not player then return nil end

    local pos = player:GetWorldPosition()
    local rot = player:GetWorldOrientation():ToEulerAngles()

    local yawRight = rot.yaw + 90
    local yawRad = math.rad(yawRight)

    local xOffset = distance * math.sin(yawRad) * -1.0
    local yOffset = distance * math.cos(yawRad)

    return Vector4.new(pos.x + xOffset, pos.y + yOffset, pos.z, 1.0)
end

-- TODO: Move this into its own restriction utility file later
local function setStatusEffect(effect, enabled)
    local statusSystem = Game.GetStatusEffectSystem()
    local player = Game.GetPlayer()
    local entityID = player:GetEntityID()

    if enabled then
        statusSystem:ApplyStatusEffect(entityID, effect, player:GetRecordID(), entityID)
    else
        statusSystem:RemoveStatusEffect(entityID, effect)
    end
end

-- TODO: Move this into its own restriction utility file later
local function SetNoclipRestrictions(apply)
    setStatusEffect("GameplayRestriction.NoZooming", apply)
    setStatusEffect("GameplayRestriction.NoMovement", apply)
    setStatusEffect("GameplayRestriction.NoCombat", apply)
    setStatusEffect("GameplayRestriction.InDaClub", apply)
end

-- Remove the restrictions once after no clip is toggled off
local noclipWasOn = false
local function RemoveRestriction()
    if not Noclip.toggleNoClip.value then
        if noclipWasOn then
            SetNoclipRestrictions(false)
            noclipWasOn = false
        end
        return
    end
end


function Noclip.Tick()

    RemoveRestriction();

    if not Noclip.toggleNoClip.value then return end

    SetNoclipRestrictions(true) 
    noclipWasOn = true
    local player = Game.GetPlayer()
    if not player then return end

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

    local pos = player:GetWorldPosition()
    if forward then
        local fwd = Teleport.GetForwardOffset(frameSpeed)
        pos.x, pos.y = fwd.x, fwd.y
    end

    if backward then
        local back = Teleport.GetForwardOffset(-frameSpeed)
        pos.x, pos.y = back.x, back.y
    end

    if strafeRight then
        local right = GetRightOffset(frameSpeed)
        pos.x, pos.y = right.x, right.y
    end

    if strafeLeft then
        local left = GetRightOffset(-frameSpeed)
        pos.x, pos.y = left.x, left.y
    end

    if goUp then pos.z = pos.z + frameSpeed end
    if goDown then pos.z = pos.z - frameSpeed end

    if yaw < 0 then yaw = yaw + 360 end
    if yaw > 360 then yaw = yaw - 360 end

    local rot = player:GetWorldOrientation():ToEulerAngles()
    rot.yaw = yaw

    Teleport.TeleportEntity(player, Vector4.new(pos.x, pos.y, pos.z, 1.0), rot)
end

return Noclip
