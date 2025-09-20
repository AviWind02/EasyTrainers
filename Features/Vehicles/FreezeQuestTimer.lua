local Logger = require("Core/Logger")
local Event = require("Core/Event")

local FreezeQuestTimer = {
    enabled = { value = false }
}

local function HandleCountdownTimer(_, _)
    if not FreezeQuestTimer.enabled.value then return end

    local timerDef = GetAllBlackboardDefs().UI_HUDCountdownTimer
    local timerBB = Game.GetBlackboardSystem():Get(timerDef)
    if not timerBB then return end

    local missionTimer = FromVariant(timerBB:GetVariant(timerDef.TimerID))
    if missionTimer then
        Game.GetDelaySystem():CancelTick(missionTimer)
        timerBB:SetFloat(timerDef.Progress, 599.0, true)
    end
end

return FreezeQuestTimer
