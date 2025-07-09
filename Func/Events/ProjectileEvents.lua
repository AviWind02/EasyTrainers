local WeaponTick = require("Func/Weapons/WeaponTick")

local ProjectileEvents = {}



function ProjectileEvents.Init()
    Observe("BaseProjectile", "ProjectileHit", function(self, eventData)
        WeaponTick.HandleProjectileHit(self, eventData)
    end)
end

return ProjectileEvents



