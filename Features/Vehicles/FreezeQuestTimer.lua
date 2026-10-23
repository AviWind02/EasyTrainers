local FreezeQuestTimer = {}

FreezeQuestTimer.Enabled = { value = false }

local FROZEN_PROGRESS = 599.0

function FreezeQuestTimer.HandleCountdownTimer()
    if not FreezeQuestTimer.Enabled.value then return end

    local timerDef = GetAllBlackboardDefs().UI_HUDCountdownTimer
    local blackboardSystem = Game.GetBlackboardSystem()
    local delaySystem = Game.GetDelaySystem()
    if not timerDef or not blackboardSystem or not delaySystem then return end

    local blackboard = blackboardSystem:Get(timerDef)
    if not blackboard then return end

    local timer = FromVariant(blackboard:GetVariant(timerDef.TimerID))
    if not timer then return end

    delaySystem:CancelTick(timer)
    blackboard:SetFloat(timerDef.Progress, FROZEN_PROGRESS, true)
end

return FreezeQuestTimer
