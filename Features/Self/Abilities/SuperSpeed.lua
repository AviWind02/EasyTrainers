local Lifecycle = require("Core/Lifecycle")

local SuperSpeed = {}

SuperSpeed.Enabled = { value = false }

local PLAYER_SPEED = 3.0

local s_Applied = false

local function Apply(enabled)
    local timeSystem = Game.GetTimeSystem()
    if not timeSystem then return false end

    if enabled then
        if timeSystem:IsTimeDilationActive() then timeSystem:SetTimeDilation(CName.new(), 1.0) end
        timeSystem:SetTimeDilationOnLocalPlayerZero(CName.new(), PLAYER_SPEED, false)
    else
        timeSystem:UnsetTimeDilationOnLocalPlayerZero(CName.new())
    end
    return true
end

function SuperSpeed.Tick()
    local enabled = SuperSpeed.Enabled.value
    if enabled == s_Applied then return end
    if Apply(enabled) then s_Applied = enabled end
end

Lifecycle.Register("SuperSpeed", {
    OnSessionEnd = function() s_Applied = false end,
    OnShutdown = function()
        if s_Applied then Apply(false) end
        s_Applied = false
    end
})

return SuperSpeed
