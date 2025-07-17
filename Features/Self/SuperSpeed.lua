local SuperSpeed = {}

SuperSpeed.enabled = { value = false }

local applied = false
local logger = require("Core/Logger")

function SuperSpeed.Tick()
    local timeSystem = Game.GetTimeSystem()
    local isActive = timeSystem:IsTimeDilationActive()

    if SuperSpeed.enabled.value and not applied then
        if isActive then
            timeSystem:SetTimeDilation(CName.new(), 1.0)
        end
        timeSystem:SetTimeDilationOnLocalPlayerZero(CName.new(), 3.0, false)
        logger.Log("[EasyTrainerSelf] SuperSpeed - Enabled")
        applied = true

    elseif not SuperSpeed.enabled.value and applied then
        timeSystem:UnsetTimeDilationOnLocalPlayerZero(CName.new())
        logger.Log("[EasyTrainerSelf] SuperSpeed - Disabled")
        applied = false
    end
end

return SuperSpeed
