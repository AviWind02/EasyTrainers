local Explosion = require("Utils/Explosion")
local Weapon = require("Utils/Weapon")

local ExplosiveKnives = {}

ExplosiveKnives.Enabled = { value = false }

local COOLDOWN = 0.1
local ATTACK = "Attacks.LegendaryFragGrenade"

local s_LastExplosion = -1

function ExplosiveKnives.OnProjectileHit(eventData)
    if not ExplosiveKnives.Enabled.value or not eventData then return end
    if Weapon.IsRangedEquipped() then return end

    local now = os.clock()
    if now - s_LastExplosion < COOLDOWN then return end

    local player = Game.GetPlayer()
    if not player then return end

    for _, hit in ipairs(eventData.hitInstances or {}) do
        if hit and hit.position then
            Explosion.SpawnAtPos(hit.position, ATTACK, player, player, nil, 3.0)
            s_LastExplosion = now
        end
    end
end

return ExplosiveKnives
