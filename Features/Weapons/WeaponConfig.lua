local OptionConfig = require("Config/OptionConfig")
local Weapons = require("Features/Weapons")

local function Toggle(id, ref, labelKey, keywords)
    return OptionConfig.DefineToggle(id, ref, false, {
        LabelKey = labelKey,
        Category = "weapon",
        Keywords = keywords
    })
end

local function RegisterAllWeaponOptions()
    local Modifiers = Weapons.StatModifiers

    OptionConfig.RegisterAll({
        Toggle("toggle.weapon.infiniteammo", Weapons.InfiniteAmmo.Enabled, "weaponsmenu.infiniteammo.label", { "ammo", "bullets" }),
        Toggle("toggle.weapon.forcegun", Weapons.ForceGun.Enabled, "weaponsmenu.forcegun.label", { "force", "physics" }),
        Toggle("toggle.weapon.flyingthundergod", Weapons.FlyingThunderGod.Enabled, "weaponsmenu.flyingthundergod.label", { "teleport", "knife" }),
        Toggle("toggle.weapon.gravitygun", Weapons.GravityGun.Enabled, "weaponsmenu.gravitygun.label", { "gravity", "physics" }),
        Toggle("toggle.weapon.smartbladereturn", Weapons.SmartBlade.Enabled, "weaponsmenu.smartbladereturn.label", { "knife", "return" }),
        Toggle("toggle.weapon.teleygun", Weapons.TeleportShot.Enabled, "weaponsmenu.teleygun.label", { "teleport", "shot" }),
        Toggle("toggle.weapon.explosivebullets", Weapons.ExplosiveBullets.Enabled, "weaponsmenu.explosivebullets.label", { "explosion", "ammo" }),
        Toggle("toggle.weapon.explosiveknives", Weapons.ExplosiveKnives.Enabled, "weaponsmenu.explosiveknives.label", { "explosion", "knife" }),

        Toggle("toggle.weapon.noreload", Modifiers.NoReloading.Enabled, "weaponsmenu.noreload.label", { "reload", "magazine" }),
        Toggle("toggle.weapon.speedcola", Modifiers.FastReload.Enabled, "weaponsmenu.speedcola.label", { "reload", "speed" }),
        Toggle("toggle.weapon.norecoil", Modifiers.NoRecoil.Enabled, "weaponsmenu.norecoil.label", { "recoil", "accuracy" }),
        Toggle("toggle.weapon.rapidfire", Modifiers.RapidFire.Enabled, "weaponsmenu.rapidfire.label", { "fire rate", "speed" }),
        Toggle("toggle.weapon.shotgunspray", Modifiers.ShotgunSpray.Enabled, "weaponsmenu.shotgunspray.label", { "shotgun", "pellets" }),
        Toggle("toggle.weapon.alwayscrit", Modifiers.AlwaysCrit.Enabled, "weaponsmenu.alwayscrit.label", { "critical", "damage" }),
        Toggle("toggle.weapon.insanecritdmg", Modifiers.InsaneCritDmg.Enabled, "weaponsmenu.insanecritdmg.label", { "critical", "damage" }),

        Toggle("toggle.weapon.melee_highblock", Modifiers.HighBlock.Enabled, "weaponsmenu.melee_highblock.label", { "melee", "block" }),
        Toggle("toggle.weapon.melee_lowstamina", Modifiers.LowStaminaCost.Enabled, "weaponsmenu.melee_lowstamina.label", { "melee", "stamina" }),
        Toggle("toggle.weapon.melee_bladecarnage", Modifiers.BladeCarnage.Enabled, "weaponsmenu.melee_bladecarnage.label", { "melee", "blade", "damage" }),
        Toggle("toggle.weapon.melee_infinitecombo", Modifiers.InfiniteCombo.Enabled, "weaponsmenu.melee_infinitecombo.label", { "melee", "combo" }),

        Toggle("toggle.weapon.smart_fastlock", Modifiers.SmartFastLock.Enabled, "weaponsmenu.smart_fastlock.label", { "smart", "target", "lock" }),
        Toggle("toggle.weapon.smart_widelock", Modifiers.SmartWideLock.Enabled, "weaponsmenu.smart_widelock.label", { "smart", "target", "angle" }),
        Toggle("toggle.weapon.smart_extratargets", Modifiers.SmartExtraTargets.Enabled, "weaponsmenu.smart_extratargets.label", { "smart", "target", "multiple" }),
        Toggle("toggle.weapon.smart_perfectacc", Modifiers.SmartPerfectAcc.Enabled, "weaponsmenu.smart_perfectacc.label", { "smart", "accuracy" }),

        Toggle("toggle.weapon.unlimitedrange", Modifiers.UnlimitedRange.Enabled, "weaponsmenu.unlimitedrange.label", { "range", "distance" }),
        Toggle("toggle.weapon.penetrationrounds", Modifiers.PenetrationRounds.Enabled, "weaponsmenu.penetrationrounds.label", { "wall", "penetration", "ammo" }),
        Toggle("toggle.weapon.hipfireaccuracy", Modifiers.HipfireAccuracy.Enabled, "weaponsmenu.hipfireaccuracy.label", { "hip fire", "accuracy" }),
        Toggle("toggle.weapon.adsaccuracy", Modifiers.AdsAccuracy.Enabled, "weaponsmenu.adsaccuracy.label", { "aim", "sights", "accuracy" }),
    })
end

return RegisterAllWeaponOptions
