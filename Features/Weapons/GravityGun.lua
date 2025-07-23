
local GravityGun = {}
local logger = require("Core/Logger")

local heldObject = nil
local grabDistance = 7.0

GravityGun.enabled = { value = false }

function ApplyForceToEntity(entity, forceX, forceY, forceZ)
    if not entity then
        print("[ApplyForce] Invalid entity.")
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
    if not player or not targetingSystem then return end

    local isAiming = player.isAiming
    if isAiming and not heldObject then
        local obj = targetingSystem:GetLookAtObject(player, true, false)
        if obj then
            heldObject = obj
            logger.Log("[EasyTrainerGravityGun] Grabbed object: " .. tostring(obj:GetDisplayName()))
        end
    end

    if heldObject then
        if isAiming then
            local camOrigin = player:GetWorldPosition()
            local lookAt = targetingSystem:GetLookAtPosition(player, true, false)

            -- Get the direction vector from camera to crosshair target
            local dir = {
                x = lookAt.x - camOrigin.x,
                y = lookAt.y - camOrigin.y,
                z = lookAt.z - camOrigin.z
            }
            local mag = math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)
            dir.x, dir.y, dir.z = dir.x / mag, dir.y / mag, dir.z / mag

            -- Target position in front of player based on grab distance
            local targetPos = Vector3.new(
                camOrigin.x + dir.x * grabDistance,
                camOrigin.y + dir.y * grabDistance,
                camOrigin.z + dir.z * grabDistance
            )

            local objectPos = heldObject:GetWorldPosition()
            local delta = {
                x = targetPos.x - objectPos.x,
                y = targetPos.y - objectPos.y,
                z = targetPos.z - objectPos.z
            }

            -- Force multiplier for responsiveness (tweakable)
            local forceStrength = 0.2
            ApplyForceToEntity(heldObject,
                delta.x * forceStrength,
                delta.y * forceStrength,
                delta.z * forceStrength
            )
        else
            logger.Log("[EasyTrainerGravityGun] Released object.")
            heldObject = nil
        end
    end
end


return GravityGun
