local StatusEffect = require("Utils/StatusEffect")
local Lifecycle = require("Core/Lifecycle")

local GodMode = {}

GodMode.Enabled = { value = false }

local EFFECT = "BaseStatusEffect.Invulnerable"
local OWNER = "GodMode"
local CHECK_INTERVAL = 1.0

local s_Applied = false
local s_NextCheck = 0

function GodMode.DisableFallFX(_, context, _)
    if not GodMode.Enabled.value then return end
    context:SetPermanentFloatParameter("RegularLandingFallingSpeed", -6000, true)
    context:SetPermanentFloatParameter("SafeLandingFallingSpeed", -7000, true)
    context:SetPermanentFloatParameter("HardLandingFallingSpeed", -8000, true)
    context:SetPermanentFloatParameter("VeryHardLandingFallingSpeed", -9000, true)
    context:SetPermanentFloatParameter("DeathLandingFallingSpeed", -10000, true)
end

function GodMode.Tick()
    if not GodMode.Enabled.value then
        if s_Applied then
            StatusEffect.Set(EFFECT, false, OWNER)
            s_Applied = false
        end
        return
    end

    local now = os.clock()
    if s_Applied and now < s_NextCheck then return end
    s_NextCheck = now + CHECK_INTERVAL

    StatusEffect.Reapply(EFFECT, OWNER)
    s_Applied = true
end

Lifecycle.Register("GodMode", {
    OnSessionEnd = function() s_Applied = false end
})

return GodMode
