
local Teleport = {}

function Teleport.TeleportEntity(entity, pos, facing)
    if not entity or not pos then return end
    local targetPos = Vector4.new(pos.x, pos.y, pos.z, pos.w or 1.0)
    local rot = facing or entity:GetWorldOrientation():ToEulerAngles()

    Game.GetTeleportationFacility():Teleport(entity, targetPos, rot)
end

function Teleport.GetPlayerPosition()
    local player = Game.GetPlayer()
    if not player then return nil end
    return player:GetWorldPosition()
end

function Teleport.GetForwardOffset(distance)
    local player = Game.GetPlayer()
    if not player then return nil end

    local pos = player:GetWorldPosition()
    local rot = player:GetWorldOrientation():ToEulerAngles()

    local yaw = rot.yaw
    local yawRad = math.rad(yaw)

    local xOffset = distance * math.sin(yawRad) * -1.0
    local yOffset = distance * math.cos(yawRad)

    return Vector4.new(pos.x + xOffset, pos.y + yOffset, pos.z, 1.0)
end

function Teleport.TeleportPlayerTo(x, y, z)
    local player = Game.GetPlayer()
    if not player then return end
    local facing = player:GetWorldOrientation():ToEulerAngles()
    local pos = Vector4.new(x, y, z, 1.0)
    Game.GetTeleportationFacility():Teleport(player, pos, facing)
end

return Teleport
