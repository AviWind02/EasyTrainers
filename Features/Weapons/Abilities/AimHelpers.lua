local AimHelpers = {}

function AimHelpers.GetAimDirection(player, targeting)
    local origin = player:GetWorldPosition()
    local lookAt = targeting:GetLookAtPosition(player, true, false)
    if not lookAt then return nil, origin end

    local x = lookAt.x - origin.x
    local y = lookAt.y - origin.y
    local z = lookAt.z - origin.z
    local length = math.sqrt(x * x + y * y + z * z)
    if length < 0.001 then return nil, origin end

    return { x = x / length, y = y / length, z = z / length }, origin
end

return AimHelpers
