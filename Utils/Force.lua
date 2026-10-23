local Force = {}

local MINIMUM_NITRO_MASS = 1500.0
local DAMPING_START_KPH = 85
local DAMPING_FULL_KPH = 140
local DAMPING_MINIMUM = 0.6

local function QueueImpulse(entity, impulse, position)
    local event = PhysicalImpulseEvent.new()
    event.worldImpulse = impulse
    event.worldPosition = position
    event.radius = 1.0
    entity:QueueEvent(event)
end

function Force.ApplyImpulse(entity, impulse)
    if not entity or not impulse then return end
    local position = entity:GetWorldPosition()
    QueueImpulse(entity, impulse, Vector3.new(position.x, position.y, position.z))
end

local function SpeedKph(vehicle)
    local blackboard = vehicle:GetBlackboard()
    if not blackboard then return 0 end
    local speedMph = blackboard:GetFloat(GetAllBlackboardDefs().Vehicle.SpeedValue) or 0
    return speedMph * 1.60934
end

-- Nitrous impulse logic adapted from Redscript implementation by MisterChedda
function Force.ApplyNitroImpulse(vehicle, baseForce, multiplier, deltaTime)
    if not vehicle then return end

    local reportedMass = vehicle.GetTotalMass and vehicle:GetTotalMass() or MINIMUM_NITRO_MASS
    local impulse = (baseForce / math.max(reportedMass, MINIMUM_NITRO_MASS)) * multiplier * deltaTime

    local friction = math.max(vehicle.longitudinalFrictionMultiplier or 1.0, 0.1)
    impulse = impulse * math.min(math.max(friction, 0.6), 1.4)

    local speed = SpeedKph(vehicle)
    if speed > DAMPING_START_KPH then
        local progress = math.min((speed - DAMPING_START_KPH) / (DAMPING_FULL_KPH - DAMPING_START_KPH), 1)
        impulse = impulse * (1.0 + (DAMPING_MINIMUM - 1.0) * progress)
    end

    if impulse <= 0.01 then return end

    local forward = vehicle:GetWorldForward()
    local position = vehicle:GetWorldPosition()
    local up = vehicle:GetWorldUp()

    QueueImpulse(
        vehicle,
        Vector3.new(forward.x * impulse, forward.y * impulse, forward.z * impulse),
        Vector3.new(position.x + up.x * 0.1, position.y + up.y * 0.1, position.z + up.z * 0.1)
    )
end

return Force
