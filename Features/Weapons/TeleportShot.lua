local WeaponGlobals = require("Gameplay").WeaponInput

local TeleportShot = {}
local cooldown = 0.5
local lastTeleportTime = -1

TeleportShot.enabled = { value = false }


-- Same as the FlyingThunderGod but since I don't know how to track hitscans in the game this checks where the players looking and then waits for them to shoot
function TeleportShot.Tick()

    if not TeleportShot.enabled.value then
        return
    end

    if not WeaponGlobals.IsShootingWithRangedWeapon() then
        return
    end

    -- Delay to avoid overshooting and repeated Teley while ADS
    local currentTime = os.clock()
    if currentTime - lastTeleportTime < cooldown then
        -- print("[EasyTrainerTeleyGun] cooldown.")
        return
    end

    local player = Game.GetPlayer()
    local targetingSystem = Game.GetTargetingSystem()
    local teleportSystem = Game.GetTeleportationFacility()
    if not player or not targetingSystem or not teleportSystem then return end

    local camOrigin = player:GetWorldPosition()
    local lookAt = targetingSystem:GetLookAtPosition(player, true, false)
    if not lookAt then
        print("[EasyTrainerTeleyGun] Failed to get look-at position.")
        return
    end

    local dir = {
        x = lookAt.x - camOrigin.x,
        y = lookAt.y - camOrigin.y,
        z = lookAt.z - camOrigin.z
    }
    local mag = math.sqrt(dir.x ^ 2 + dir.y ^ 2 + dir.z ^ 2)
    dir.x, dir.y, dir.z = dir.x / mag, dir.y / mag, dir.z / mag

    local teleportPos = Vector4.new(
        lookAt.x,
        lookAt.y,
        lookAt.z,
        1.0
    )
    local facing = player:GetWorldOrientation():ToEulerAngles()

    teleportSystem:Teleport(player, teleportPos, facing)
    lastTeleportTime = currentTime
end

return TeleportShot
