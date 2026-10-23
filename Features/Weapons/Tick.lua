local Weapons = require("Features/Weapons")
local Weapon = require("Utils/Weapon")

local WeaponTick = {}

function WeaponTick.TickHandler()
    Weapons.GravityGun.Tick()
    Weapons.TeleportShot.Tick()
    Weapons.InfiniteAmmo.Tick()
    Weapons.ForceGun.Tick()
    Weapons.ExplosiveBullets.Tick()

    if Weapons.StatModifiers.IsActive() then
        Weapon.Tick()
        Weapons.StatModifiers.Tick()
    end
end

function WeaponTick.HandleProjectileHit(projectile, eventData)
    Weapons.FlyingThunderGod.OnProjectileHit(eventData)
    Weapons.ExplosiveKnives.OnProjectileHit(eventData)
    Weapons.SmartBlade.OnProjectileHit(projectile)
end

return WeaponTick
