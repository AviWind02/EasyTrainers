local Teleport = require("Utils/Teleport")
local Weapon = require("Utils/Weapon")

local FlyingThunderGod = {}

FlyingThunderGod.Enabled = { value = false }

function FlyingThunderGod.OnProjectileHit(eventData)
    if not FlyingThunderGod.Enabled.value or not eventData then return end
    if Weapon.IsRangedEquipped() then return end

    local player = Game.GetPlayer()
    if not player then return end

    local instances = eventData.hitInstances or {}
    local hit = instances[#instances]
    if hit and hit.position then Teleport.TeleportEntity(player, hit.position) end
end

return FlyingThunderGod
