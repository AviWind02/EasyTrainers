
local GravityGun = {}

local heldObject = nil
local grabDistance = 7.0

-- Hold object in front of player (GravityGun)
function GravityGun.Tick()
    local player = Game.GetPlayer()
    local targetingSystem = Game.GetTargetingSystem()
    local teleportSystem = Game.GetTeleportationFacility()
    if not player or not targetingSystem or not teleportSystem then return end

    local isAiming = player.isAiming
    if isAiming and not heldObject then
        local obj = targetingSystem:GetLookAtObject(player, true, false)
        if obj then
            heldObject = obj
            print("[GravityGun] Grabbed object: " .. tostring(obj:GetDisplayName()))
        end
    end

    if heldObject then
        if isAiming then
            local camOrigin = player:GetWorldPosition()
            local lookAt = targetingSystem:GetLookAtPosition(player, true, false)
            local dir = {
                x = lookAt.x - camOrigin.x,
                y = lookAt.y - camOrigin.y,
                z = lookAt.z - camOrigin.z
            }
            local mag = math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)
            dir.x, dir.y, dir.z = dir.x / mag, dir.y / mag, dir.z / mag

            local targetPos = Vector4.new(
                camOrigin.x + dir.x * grabDistance,
                camOrigin.y + dir.y * grabDistance,
                camOrigin.z + dir.z * grabDistance,
                1.0
            )
            teleportSystem:Teleport(heldObject, targetPos, EulerAngles.new(0, 0, 0))
        else
            print("[GravityGun] Released object.")
            heldObject = nil
        end
    end
end

return GravityGun
