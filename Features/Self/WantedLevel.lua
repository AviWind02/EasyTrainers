local Gameplay = require("Gameplay")
local Draw = require("UI")

local logger = require("Core/Logger")

local WantedLevel = {}

WantedLevel.tickNeverWanted = { value = false }
WantedLevel.tickClearWanted = { value = false }

WantedLevel.heldWantedLevel = { enabled = false, value = 1, min = 1, max = 5 }

local wasSystemDisabled = false
local wasHeldActive = false

function WantedLevel.Tick()
    if WantedLevel.tickClearWanted.value then
        Gameplay.PreventionSystem.SetPoliceDisabled(true)
        WantedLevel.heldWantedLevel.value = 0
        WantedLevel.heldWantedLevel.enabled = false
        WantedLevel.tickClearWanted.value = false
        Gameplay.PreventionSystem.SetPoliceDisabled(false)

        logger.Log("WantedLevel - Clear Wanted used")
    end

    if WantedLevel.tickNeverWanted.value then
        if not wasSystemDisabled then
            Gameplay.PreventionSystem.SetPoliceDisabled(true)
            wasSystemDisabled = true
            logger.Log("[EasyTrainerSelf] WantedLevel - Never Wanted enabled")
        end
        WantedLevel.heldWantedLevel.value = 0
    else
        if wasSystemDisabled then
            Gameplay.PreventionSystem.SetPoliceDisabled(false)
            wasSystemDisabled = false
            logger.Log("[EasyTrainerSelf] WantedLevel - Never Wanted disabled")
        end
    end

if WantedLevel.heldWantedLevel.enabled and WantedLevel.heldWantedLevel.value >= 1 then
    if not wasHeldActive then
        logger.Log("[EasyTrainerSelf] WantedLevel - Hold Wanted Level enabled (" .. WantedLevel.heldWantedLevel.value .. ")")
        wasHeldActive = true
    end

    if WantedLevel.tickNeverWanted.value then
        WantedLevel.tickNeverWanted.value = false
        Draw.Notifier.Push("Disabled: Never Wanted")
    end

    Gameplay.PreventionSystem.SetWantedLevel(WantedLevel.heldWantedLevel.value)
    Gameplay.PreventionSystem.SetPoliceDisabled(false)
else
    if wasHeldActive then
        logger.Log("[EasyTrainerSelf] WantedLevel - Hold Wanted Level disabled")
        wasHeldActive = false
    end
end

end

function WantedLevel.SetNeverWantedLevel(enabled)
    if enabled and  WantedLevel.heldWantedLevel.enabled then
        WantedLevel.heldWantedLevel.enabled = false
        Draw.Notifier.Push("Disabled: Hold Wanted Level")
    end
    WantedLevel.tickNeverWanted = enabled
end

function WantedLevel.SetHoldWantedLevel(enabled)
    if enabled and WantedLevel.tickNeverWanted then
        WantedLevel.tickNeverWanted = false
       Draw.Notifier.Push("Disabled: Never Wanted")
    end
    WantedLevel.heldWantedLevel.enabled = enabled
end

return WantedLevel
