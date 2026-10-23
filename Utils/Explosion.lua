local Logger = require("Core/Logger")

local Explosion = {}

function Explosion.SpawnAtPos(position, attackName, instigator, source, weapon, duration)
    if not position then return false end

    local attackSystem = GetSingleton("gameAttack_GameEffect")
    if not attackSystem then
        Logger.Log("Explosion: gameAttack_GameEffect not available")
        return false
    end

    local record = TweakDB:GetRecord(attackName or "Attacks.LegendaryFragGrenade")
    if not record then
        Logger.Log("Explosion: invalid attack record " .. tostring(attackName))
        return false
    end

    local player = Game.GetPlayer()
    attackSystem:SpawnExplosionAttack(
        record,
        weapon or (player and player:GetActiveWeapon() or nil),
        instigator or player,
        source or player,
        position,
        duration or 3.0
    )
    return true
end

return Explosion
