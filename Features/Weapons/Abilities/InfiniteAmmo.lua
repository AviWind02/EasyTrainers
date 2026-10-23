local StatusEffect = require("Utils/StatusEffect")
local Lifecycle = require("Core/Lifecycle")

local InfiniteAmmo = {}

InfiniteAmmo.Enabled = { value = false }

local EFFECT = "GameplayRestriction.InfiniteAmmo"
local OWNER = "InfiniteAmmo"
local CHECK_INTERVAL = 1.0

local s_Applied = false
local s_NextCheck = 0

function InfiniteAmmo.Tick()
    if not InfiniteAmmo.Enabled.value then
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

Lifecycle.Register("InfiniteAmmo", {
    OnSessionEnd = function() s_Applied = false end
})

return InfiniteAmmo
