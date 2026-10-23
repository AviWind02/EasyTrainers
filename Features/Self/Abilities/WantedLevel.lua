local Prevention = require("Utils/Prevention")
local Notification = require("UI/Panels/Notification/Notification")
local Lifecycle = require("Core/Lifecycle")
local SaveGuard = require("Core/SaveGuard")

local WantedLevel = {}

WantedLevel.NeverWanted = { value = false }
WantedLevel.HeldLevel = { enabled = false, value = 1, min = 1, max = 5 }

local HOLD_INTERVAL = 1.0

local s_PoliceDisabled = false
local s_LastNeverWanted = false
local s_NextHold = 0

local function SetPoliceDisabled(disabled)
    if s_PoliceDisabled == disabled then return end
    if Prevention.SetPoliceDisabled(disabled) then s_PoliceDisabled = disabled end
end

local function ResolveConflicts()
    local neverWanted = WantedLevel.NeverWanted.value
    local held = WantedLevel.HeldLevel.enabled

    if neverWanted and held then
        if not s_LastNeverWanted then
            WantedLevel.HeldLevel.enabled = false
            Notification.Info("Disabled: Hold Wanted Level")
        else
            WantedLevel.NeverWanted.value = false
            Notification.Info("Disabled: Never Wanted")
        end
    end

    s_LastNeverWanted = WantedLevel.NeverWanted.value
end

function WantedLevel.Clear()
    Prevention.SetPoliceDisabled(true)
    Prevention.SetPoliceDisabled(false)
    s_PoliceDisabled = false
    WantedLevel.HeldLevel.enabled = false
end

function WantedLevel.IsPoliceDisabled()
    return s_PoliceDisabled
end

function WantedLevel.Tick()
    ResolveConflicts()

    SetPoliceDisabled(WantedLevel.NeverWanted.value)

    if not WantedLevel.HeldLevel.enabled then return end

    local now = os.clock()
    if now < s_NextHold then return end
    s_NextHold = now + HOLD_INTERVAL
    Prevention.SetWantedLevel(WantedLevel.HeldLevel.value)
end

SaveGuard.Track("WantedLevel", {
    Capture = function() return s_PoliceDisabled end,
    Restore = function(policeDisabled)
        if policeDisabled and not WantedLevel.NeverWanted.value then Prevention.SetPoliceDisabled(false) end
    end
})

Lifecycle.Register("WantedLevel", {
    OnSessionEnd = function() s_PoliceDisabled = false end,
    OnShutdown = function() SetPoliceDisabled(false) end
})

return WantedLevel
