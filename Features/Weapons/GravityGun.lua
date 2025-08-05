
local GravityGun = {}
local logger = require("Core/Logger")

local heldObject = nil
local grabDistance = 7.0

GravityGun.enabled = { value = false }

-- Testing with this function to see if I can apply force to the object so it can keep its physics like an actual gravity gun
function ApplyForceToEntity(entity, forceX, forceY, forceZ)
    if not entity then
        logger.Log("[ApplyForce] Invalid entity.")
        return
    end

    -- local position = entity:GetWorldPosition()
    local position = entity:GetWorldCenter()

    local impulse = Vector3.new(forceX, forceY, forceZ)

    local evt = PhysicalImpulseEvent.new()
    evt.worldImpulse = impulse
    evt.worldPosition = position
    evt.radius = 1.0 
    evt.bodyIndex = 0
    evt.shapeIndex = 0

    entity:QueueEvent(evt)

    logger.Log(string.format("[ApplyForce] Applied impulse (%.2f, %.2f, %.2f) to entity.", forceX, forceY, forceZ))
end


function GravityGun.Tick()
    if not GravityGun.enabled.value then
        return
    end

    local player = Game.GetPlayer()
    local targetingSystem = Game.GetTargetingSystem()
    local teleportSystem = Game.GetTeleportationFacility()
    if not player or not targetingSystem or not teleportSystem then return end

    local isAiming = player.isAiming
    if isAiming and not heldObject then
        local obj = targetingSystem:GetLookAtObject(player, true, false)
        if obj then
            heldObject = obj
            print("[EasyTrainerGravityGun] Grabbed object: " .. tostring(obj:GetDisplayName()))
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
            print("[EasyTrainerGravityGun] Released object.")
            heldObject = nil
        end
    end
end



return GravityGun
