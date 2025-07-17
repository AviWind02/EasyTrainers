local Weapons = require("Features/Weapons")
local StatModifiers = require("Gameplay").StatModifiers

local WeaponTick = {}


function WeaponTick.TickHandler(deltaTime)
    Weapons.GravityGun.Tick()
    Weapons.TeleportShot.Tick()
    Weapons.InfiniteAmmo.Tick()
    Weapons.NoReloading.Tick(deltaTime)
    Weapons.FastReload.Tick(deltaTime)
    Weapons.NoRecoil.Tick(deltaTime)

    StatModifiers.HandleStatModifierToggle(Weapons.NoReloading.toggleNoReloading, Weapons.NoReloading.SetNoReloading)
    StatModifiers.HandleStatModifierToggle(Weapons.FastReload.toggleFastReload, Weapons.FastReload.SetNoRecoil)
    StatModifiers.HandleStatModifierToggle(Weapons.NoRecoil.toggleNoRecoil , Weapons.NoRecoil.SetNoRecoil)

end

function WeaponTick.HandleProjectileHit(self, eventData)
    Weapons.FlyingThunderGod.Tick(eventData)
    Weapons.SmartBlade.Tick(self)
end

return WeaponTick
