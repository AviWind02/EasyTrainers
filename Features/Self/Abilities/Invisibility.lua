local StatusEffect = require("Utils/StatusEffect")
local Lifecycle = require("Core/Lifecycle")

local Invisibility = {}

Invisibility.Enabled = { value = false }

local EFFECT = "BaseStatusEffect.Cloaked"
local OWNER = "Invisibility"

local s_Applied = false

local function SetInvisible(enabled)
    local player = Game.GetPlayer()
    if not player then return false end

    StatusEffect.Set(EFFECT, enabled, OWNER)
    player:SetInvisible(enabled)
    player:UpdateVisibility()
    return true
end

function Invisibility.Tick()
    local enabled = Invisibility.Enabled.value
    if enabled == s_Applied then return end
    if SetInvisible(enabled) then s_Applied = enabled end
end

Lifecycle.Register("Invisibility", {
    OnSessionEnd = function() s_Applied = false end,
    OnShutdown = function()
        if s_Applied then SetInvisible(false) end
        s_Applied = false
    end
})

return Invisibility
