local Prevention = {}

local SOURCE_NAME = "EasyTrainer"

local function GetSystem()
    local player = Game.GetPlayer()
    return player and player:GetPreventionSystem() or nil
end

function Prevention.SetWantedLevel(level)
    local system = GetSystem()
    if not system or not system:IsSystemEnabled() then return false end

    local request = SetWantedLevel.new()
    request.wantedLevel = math.max(0, math.min(level, 5))
    system:QueueRequest(request)
    return true
end

function Prevention.SetPoliceDisabled(disabled)
    local system = GetSystem()
    if not system then return false end

    local request = TogglePreventionSystem.new()
    request.sourceName = CName.new(SOURCE_NAME)
    request.isActive = not disabled
    system:QueueRequest(request)
    system:TogglePreventionSystem(not disabled)
    return true
end

return Prevention
