local Teleport = {}

function Teleport.TeleportEntity(entity, position, facing)
    if not entity or not position then return false end

    local target = Vector4.new(position.x, position.y, position.z, position.w or 1.0)
    local rotation = facing or entity:GetWorldOrientation():ToEulerAngles()

    Game.GetTeleportationFacility():Teleport(entity, target, rotation)
    return true
end

function Teleport.DistanceBetween(a, b)
    if not a or not b then return math.huge end
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = (a.z or 0) - (b.z or 0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Teleport.DistanceFromPlayer(position)
    local player = Game.GetPlayer()
    if not player or not position then return math.huge end
    return Teleport.DistanceBetween(player:GetWorldPosition(), position)
end

function Teleport.GetWaypointPosition()
    local mappinSystem = Game.GetMappinSystem()
    if not mappinSystem then return nil end

    local id = mappinSystem:GetManuallyTrackedMappinID()
    if not id then return nil end

    local mappin = mappinSystem:GetMappin(id)
    if not mappin or not mappin:IsPlayerTracked() then return nil end
    return mappin:GetWorldPosition()
end

function Teleport.GetQuestMarkerPosition()
    local journal = Game.GetJournalManager()
    local tracked = journal and journal:GetTrackedEntry() or nil
    local mappinSystem = Game.GetMappinSystem()
    if not tracked or not mappinSystem then return nil end

    local ok, positions = mappinSystem:GetQuestMappinPositionsByObjective(journal:GetEntryHash(tracked))
    if not ok or not positions or #positions == 0 then return nil end
    return positions[1]
end

function Teleport.ToWaypoint()
    return Teleport.TeleportEntity(Game.GetPlayer(), Teleport.GetWaypointPosition())
end

function Teleport.ToQuestMarker()
    return Teleport.TeleportEntity(Game.GetPlayer(), Teleport.GetQuestMarkerPosition())
end

local function OffsetFromPlayer(distance, yawOffset, yawOverride)
    local player = Game.GetPlayer()
    if not player then return nil end

    local position = player:GetWorldPosition()
    local yaw = yawOverride or player:GetWorldOrientation():ToEulerAngles().yaw
    local radians = math.rad(yaw + yawOffset)

    return Vector4.new(
        position.x - distance * math.sin(radians),
        position.y + distance * math.cos(radians),
        position.z,
        1.0
    )
end

function Teleport.GetForwardOffset(distance, yawOverride)
    return OffsetFromPlayer(distance, 0, yawOverride)
end

function Teleport.GetRightOffset(distance, yawOverride)
    return OffsetFromPlayer(distance, 90, yawOverride)
end

return Teleport
