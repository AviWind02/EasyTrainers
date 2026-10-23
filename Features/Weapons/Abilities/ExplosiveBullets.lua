local Weapon = require("Utils/Weapon")
local Explosion = require("Utils/Explosion")

local ExplosiveBullets = {}

ExplosiveBullets.Enabled = { value = false }

local COOLDOWN = 0.1
local ATTACK = "Attacks.LegendaryFragGrenade"

local s_LastExplosion = -1

function ExplosiveBullets.Tick()
    if not ExplosiveBullets.Enabled.value or not Weapon.IsShootingRanged() then return end

    local now = os.clock()
    if now - s_LastExplosion < COOLDOWN then return end

    local player = Game.GetPlayer()
    local targeting = Game.GetTargetingSystem()
    if not player or not targeting then return end

    local lookAt = targeting:GetLookAtPosition(player, true, false)
    if not lookAt then return end

    if Explosion.SpawnAtPos(lookAt, ATTACK, player, player, player:GetActiveWeapon(), 3.0) then
        s_LastExplosion = now
    end
end

return ExplosiveBullets
