local Logger = require("Core/Logger")

local Prevention = {}

function Prevention.SetWantedLevel(level)
    local ps = Game.GetPlayer():GetPreventionSystem()
    if not ps:IsSystemEnabled() then
        Logger.Log("[EasyTrainerPrevention] Police system is disabled.")
        return
    end

    local clamped = math.max(0, math.min(level, 5))
    local request = SetWantedLevel.new()
    request.wantedLevel = clamped
    ps:QueueRequest(request)

    -- Logger.Log("Set wanted level to " .. clamped)
end

function Prevention.SetPoliceDisabled(disabled)
    local ps = Game.GetPlayer():GetPreventionSystem()
    if not ps then
        Main.Logger.Log("[EasyTrainerPrevention] system not found.")
        return
    end

    local request = TogglePreventionSystem.new()
    request.sourceName = CName.new("SMDisablePolice")
    request.isActive = not disabled
    ps:QueueRequest(request)
    ps:TogglePreventionSystem(not disabled)

    -- Logger.Log("Police system " .. (disabled and "disabled" or "enabled"))
end

return Prevention
