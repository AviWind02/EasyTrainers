-- Based on the Nitrous mod this applies force to the vehicle

function ApplyForce(strength, forwardOnly, useMassScaling)
    local vehicle = Game.GetMountedVehicle(Game.GetPlayer())
    if not vehicle then
        print("[ApplyForce] No vehicle found.")
        return
    end

    local forward = vehicle:GetWorldForward()
    if forwardOnly then
        forward.z = 0
    end
    forward = forward:Normalize()

    local mass = useMassScaling and vehicle:GetTotalMass() or 1.0
    local impulseStrength = strength / mass

    local impulse = Vector3.new(
        forward.x * impulseStrength,
        forward.y * impulseStrength,
        forward.z * impulseStrength
    )

   

    local pos = vehicle:GetWorldPosition()

    local impulsePos = Vector3.new(pos.x, pos.y, pos.z)

    local evt = PhysicalImpulseEvent.new()
    evt.worldImpulse = impulse
    evt.worldPosition = impulsePos
    evt.radius = 2.0
    evt.bodyIndex = 0
    evt.shapeIndex = 0

    vehicle:QueueEvent(evt)

    print(string.format("[ApplyForce] Impulse applied: (%.2f, %.2f, %.2f)", impulse.x, impulse.y, impulse.z))
end
