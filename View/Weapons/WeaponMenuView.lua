local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Inventory = require("Utils/Inventory")
local Weapons = require("Features/Weapons")
local WeaponItemsMenu = require("View/Weapons/WeaponsItemView")

local Modifiers = Weapons.StatModifiers

local AMMO_TYPES = {
    { id = "Ammo.HandgunAmmo", label = L("weaponsmenu.ammoitems.types.handgun") },
    { id = "Ammo.ShotgunAmmo", label = L("weaponsmenu.ammoitems.types.shotgun") },
    { id = "Ammo.RifleAmmo", label = L("weaponsmenu.ammoitems.types.rifle") },
    { id = "Ammo.SniperRifleAmmo", label = L("weaponsmenu.ammoitems.types.sniper") },
    { id = "Ammo.Special", label = L("weaponsmenu.ammoitems.types.special") }
}

local s_AddAmounts = {}
local s_RemoveAmounts = {}

for _, ammo in ipairs(AMMO_TYPES) do
    s_AddAmounts[ammo.id] = { step = 10, value = 50, min = 1, max = 999 }
    s_RemoveAmounts[ammo.id] = { step = 10, value = 10, min = 1, max = 999 }
end

local function ForEachAmmo(callback)
    for _, ammo in ipairs(AMMO_TYPES) do callback(ammo) end
end

local function AmmoItemsView()
    Buttons.Option(L("weaponsmenu.ammoitems.giveeach100.label"), tip("weaponsmenu.ammoitems.giveeach100.tip"), function()
        ForEachAmmo(function(ammo) Inventory.GiveItem(ammo.id, 100) end)
    end)
    Buttons.Option(L("weaponsmenu.ammoitems.removeeach25.label"), tip("weaponsmenu.ammoitems.removeeach25.tip"), function()
        ForEachAmmo(function(ammo) Inventory.RemoveItem(ammo.id, 25) end)
    end)

    Buttons.Break(L("weaponsmenu.ammoitems.addammo"))
    ForEachAmmo(function(ammo)
        Buttons.IntClick(ammo.label, s_AddAmounts[ammo.id], tip("weaponsmenu.ammoitems.addtip", { ammo = ammo.label }), function(value)
            Inventory.GiveItem(ammo.id, value)
        end)
    end)

    Buttons.Break(L("weaponsmenu.ammoitems.removeammo"))
    ForEachAmmo(function(ammo)
        Buttons.IntClick(ammo.label, s_RemoveAmounts[ammo.id], tip("weaponsmenu.ammoitems.removetip", { ammo = ammo.label }), function(value)
            Inventory.RemoveItem(ammo.id, value)
        end)
    end)
end

local AmmoItemsMenu = Submenu.Create("weaponsmenu.ammoitems.title", AmmoItemsView)

local function ModifierToggle(key, ref)
    Buttons.Toggle(L("weaponsmenu." .. key .. ".label"), ref, tip("weaponsmenu." .. key .. ".tip"))
end

local function WeaponsView()
    Buttons.Submenu(L("weaponsmenu.weaponitems.label"), WeaponItemsMenu, tip("weaponsmenu.weaponitems.tip"))
    Buttons.Submenu(L("weaponsmenu.ammomanager.label"), AmmoItemsMenu, tip("weaponsmenu.ammomanager.tip"))
    ModifierToggle("infiniteammo", Weapons.InfiniteAmmo.Enabled)
    ModifierToggle("explosivebullets", Weapons.ExplosiveBullets.Enabled)
    ModifierToggle("norecoil", Modifiers.NoRecoil.Enabled)
    ModifierToggle("speedcola", Modifiers.FastReload.Enabled)
    ModifierToggle("noreload", Modifiers.NoReloading.Enabled)
    ModifierToggle("rapidfire", Modifiers.RapidFire.Enabled)

    Buttons.Break(L("weaponsmenu.critandspray.label"))
    ModifierToggle("alwayscrit", Modifiers.AlwaysCrit.Enabled)
    ModifierToggle("insanecritdmg", Modifiers.InsaneCritDmg.Enabled)
    ModifierToggle("shotgunspray", Modifiers.ShotgunSpray.Enabled)

    Buttons.Break(L("weaponsmenu.accuracyrange.label"))
    ModifierToggle("unlimitedrange", Modifiers.UnlimitedRange.Enabled)
    ModifierToggle("penetrationrounds", Modifiers.PenetrationRounds.Enabled)
    ModifierToggle("hipfireaccuracy", Modifiers.HipfireAccuracy.Enabled)
    ModifierToggle("adsaccuracy", Modifiers.AdsAccuracy.Enabled)

    Buttons.Break(L("weaponsmenu.specialweapons.label"))
    ModifierToggle("forcegun", Weapons.ForceGun.Enabled)
    ModifierToggle("gravitygun", Weapons.GravityGun.Enabled)
    ModifierToggle("flyingthundergod", Weapons.FlyingThunderGod.Enabled)
    ModifierToggle("smartbladereturn", Weapons.SmartBlade.Enabled)
    ModifierToggle("teleygun", Weapons.TeleportShot.Enabled)

    Buttons.Break(L("weaponsmenu.melee.label"))
    ModifierToggle("melee_highblock", Modifiers.HighBlock.Enabled)
    ModifierToggle("melee_lowstamina", Modifiers.LowStaminaCost.Enabled)
    ModifierToggle("melee_bladecarnage", Modifiers.BladeCarnage.Enabled)
    ModifierToggle("melee_infinitecombo", Modifiers.InfiniteCombo.Enabled)
    ModifierToggle("explosiveknives", Weapons.ExplosiveKnives.Enabled)

    Buttons.Break(L("weaponsmenu.smartweapons.label"))
    ModifierToggle("smart_fastlock", Modifiers.SmartFastLock.Enabled)
    ModifierToggle("smart_widelock", Modifiers.SmartWideLock.Enabled)
    ModifierToggle("smart_extratargets", Modifiers.SmartExtraTargets.Enabled)
    ModifierToggle("smart_perfectacc", Modifiers.SmartPerfectAcc.Enabled)

    Buttons.Break(L("weaponsmenu.weaponmanagement.label"))
    Buttons.Option(L("weaponsmenu.giveallwallweapons.label"), tip("weaponsmenu.giveallwallweapons.tip"), Weapons.WeaponActions.GiveAllWallWeapons)
    Buttons.Option(L("weaponsmenu.givealliconicweapons.label"), tip("weaponsmenu.givealliconicweapons.tip"), Weapons.WeaponActions.GiveAllIconicWeapons)
    Buttons.Option(L("weaponsmenu.removeallweapons.label"), tip("weaponsmenu.removeallweapons.tip"), function()
        Weapons.WeaponActions.RemoveAllWeapons()
    end)
end

return Submenu.Create("weaponsmenu.title", WeaponsView)
