local Input = require("Core/Input")
local Lifecycle = require("Core/Lifecycle")
local StatusEffect = require("Utils/StatusEffect")
local Teleport = require("Utils/Teleport")
local Bindings = require("Controls/Bindings")

local NoClip = {}

NoClip.Enabled = { value = false }
NoClip.MoveSpeed = { value = 1.5, min = 0.25, max = 10.0, step = 0.25 }
NoClip.VerticalSpeed = { value = 1.0, min = 0.25, max = 5.0, step = 0.25 }
NoClip.BoostMultiplier = { value = 2.5, min = 1.0, max = 8.0, step = 0.25 }
NoClip.PrecisionMultiplier = { value = 0.7, min = 0.1, max = 1.0, step = 0.05 }
NoClip.GamepadDeadzone = { value = 7849, min = 0, max = 16000, step = 250 }

local OWNER = "NoClip"

local RESTRICTIONS = {
    "GameplayRestriction.NoZooming",
    "GameplayRestriction.NoMovement",
    "GameplayRestriction.NoCombat",
    "GameplayRestriction.InDaClub",
    "GameplayRestriction.NoJump",
    "GameplayRestriction.NoFallDamage"
}

local s_Active = false
local s_Yaw = 0

local function SetRestrictions(enabled)
    for _, effect in ipairs(RESTRICTIONS) do StatusEffect.Set(effect, enabled, OWNER) end
end

local function WrapYaw(yaw)
    if yaw < 0 then return yaw + 360 end
    if yaw > 360 then return yaw - 360 end
    return yaw
end

function NoClip.HandleMouseLook(action)
    if not s_Active then return end
    if Game.NameToString(action:GetName(action)) ~= "CameraMouseX" then return end

    local sensitivity = Game.GetSettingsSystem():GetVar("/controls/fppcameramouse", "FPP_MouseX"):GetValue() / 2.9
    s_Yaw = s_Yaw - (action:GetValue(action) / 35) * sensitivity
end

local function ReadStick()
    local deadzone = NoClip.GamepadDeadzone.value
    local lx = Input.GetGamepadAxis(Input.GP_AXIS.LEFT_X)
    local ly = -Input.GetGamepadAxis(Input.GP_AXIS.LEFT_Y)
    local rx = Input.GetGamepadAxis(Input.GP_AXIS.RIGHT_X)

    if math.abs(lx) < deadzone then lx = 0 end
    if math.abs(ly) < deadzone then ly = 0 end
    if math.abs(rx) <= deadzone then rx = 0 end

    return lx, ly, rx
end

local function Stop()
    if not s_Active then return end
    SetRestrictions(false)
    s_Active = false
end

function NoClip.Tick()
    if not NoClip.Enabled.value then
        Stop()
        return
    end

    local player = Game.GetPlayer()
    if not player then return end

    if not s_Active then
        s_Yaw = player:GetWorldOrientation():ToEulerAngles().yaw
        SetRestrictions(true)
        s_Active = true
    end

    local lx, ly, rx = ReadStick()
    if rx ~= 0 then
        local sensitivity = Game.GetSettingsSystem():GetVar("/controls/fppcamerapad", "FPP_PadX"):GetValue() / 10
        s_Yaw = s_Yaw - (rx / 32768) * 1.7 * sensitivity
    end
    s_Yaw = WrapYaw(s_Yaw)

    local boost = Bindings.IsActionDown("NOCLIP_BOOST")
    local multiplier = boost and NoClip.BoostMultiplier.value or NoClip.PrecisionMultiplier.value
    local speed = NoClip.MoveSpeed.value * multiplier
    local verticalSpeed = NoClip.VerticalSpeed.value * multiplier

    local position = player:GetWorldPosition()
    local offsets = {
        { Bindings.IsActionDown("NOCLIP_FORWARD") or ly < 0, Teleport.GetForwardOffset, speed },
        { Bindings.IsActionDown("NOCLIP_BACKWARD") or ly > 0, Teleport.GetForwardOffset, -speed },
        { Bindings.IsActionDown("NOCLIP_RIGHT") or lx > 0, Teleport.GetRightOffset, -speed },
        { Bindings.IsActionDown("NOCLIP_LEFT") or lx < 0, Teleport.GetRightOffset, speed }
    }

    for _, offset in ipairs(offsets) do
        if offset[1] then
            local target = offset[2](offset[3], s_Yaw)
            position.x, position.y = target.x, target.y
        end
    end

    if Bindings.IsActionDown("NOCLIP_UP") then position.z = position.z + verticalSpeed end
    if Bindings.IsActionDown("NOCLIP_DOWN") then position.z = position.z - verticalSpeed end

    local rotation = player:GetWorldOrientation():ToEulerAngles()
    rotation.yaw = s_Yaw
    Teleport.TeleportEntity(player, Vector4.new(position.x, position.y, position.z, 1.0), rotation)
end

Lifecycle.Register("NoClip", {
    OnSessionEnd = function() s_Active = false end
})

return NoClip
