local ConfigManager = require("Core/ConfigManager")
local Weapons = require("Features/Weapons")

local function RegisterWeaponOptions()
    ConfigManager.Register("toggle.weapon.infiniteammo", Weapons.InfiniteAmmo.enabled, false)
    ConfigManager.Register("toggle.weapon.noreload", Weapons.NoReloading.toggleNoReloading, false)
    ConfigManager.Register("toggle.weapon.speedcola", Weapons.FastReload.toggleFastReload, false)
    ConfigManager.Register("toggle.weapon.norecoil", Weapons.NoRecoil.toggleNoRecoil, false)

    ConfigManager.Register("toggle.weapon.flyingthundergod", Weapons.FlyingThunderGod.enabled, false)
    ConfigManager.Register("toggle.weapon.gravitygun", Weapons.GravityGun.enabled, false)
    ConfigManager.Register("toggle.weapon.smartblade", Weapons.SmartBlade.enabled, false)
    ConfigManager.Register("toggle.weapon.teleportshot", Weapons.TeleportShot.enabled, false)
end

return RegisterWeaponOptions
