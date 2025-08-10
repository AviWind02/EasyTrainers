local Weapons = require("Features/Weapons")
local Draw = require("UI")
local Inventory = require("Gameplay").Inventory

local WeaponItemsMenu = require("View/Weapon/WeaponsItemsView")

local Buttons = Draw.Buttons

local ammoTypes = {
    { id = "Ammo.HandgunAmmo", label = L("weaponsmenu.ammoitems.types.handgun") },
    { id = "Ammo.ShotgunAmmo", label = L("weaponsmenu.ammoitems.types.shotgun") },
    { id = "Ammo.RifleAmmo", label = L("weaponsmenu.ammoitems.types.rifle") },
    { id = "Ammo.SniperRifleAmmo", label = L("weaponsmenu.ammoitems.types.sniper") },
    { id = "Ammo.Special", label = L("weaponsmenu.ammoitems.types.special") }
}

local addAmmoValues = {}
local removeAmmoValues = {}

for _, ammo in ipairs(ammoTypes) do
    addAmmoValues[ammo.id] = { step = 10, value = 50, min = 1, max = 999 }
    removeAmmoValues[ammo.id] = { step = 10, value = 10, min = 1, max = 999 }
end

local function AmmoItemsView()
    Buttons.Option(L("weaponsmenu.ammoitems.giveeach100.label"), tip("weaponsmenu.ammoitems.giveeach100.tip"), function()
        for _, ammo in ipairs(ammoTypes) do
            Inventory.GiveItem(ammo.id, 100)
        end
    end)
    Buttons.Option(L("weaponsmenu.ammoitems.removeeach25.label"), tip("weaponsmenu.ammoitems.removeeach25.tip"), function()
        for _, ammo in ipairs(ammoTypes) do
            Inventory.RemoveItem(ammo.id, 25)
        end
    end)
    Buttons.Break("", L("weaponsmenu.ammoitems.addammo"))
    for _, ammo in ipairs(ammoTypes) do
        Buttons.Int(ammo.label, addAmmoValues[ammo.id], tip("weaponsmenu.ammoitems.addtip", { ammo = ammo.label }), function()
            Inventory.GiveItem(ammo.id, addAmmoValues[ammo.id].value)
        end)
    end

    Buttons.Break("", L("weaponsmenu.ammoitems.removeammo"))
    for _, ammo in ipairs(ammoTypes) do
        Buttons.Int(ammo.label, removeAmmoValues[ammo.id], tip("weaponsmenu.ammoitems.removetip", { ammo = ammo.label }), function()
            Inventory.RemoveItem(ammo.id, removeAmmoValues[ammo.id].value)
        end)
    end
end
local ammoItemsSubmenu = { title = L("weaponsmenu.ammoitems.title"), view = AmmoItemsView }

local function WeaponsViewFunction()
    Buttons.Submenu(L("weaponsmenu.weaponitems.label"), WeaponItemsMenu, tip("weaponsmenu.weaponitems.tip"))
    Buttons.Submenu(L("weaponsmenu.ammomanager.label"), ammoItemsSubmenu, tip("weaponsmenu.ammomanager.tip"))

    Buttons.Option(L("weaponsmenu.giveallwallweapons.label"), tip("weaponsmenu.giveallwallweapons.tip"), WeaponItemsMenu.GiveAllWallWeapons)
    Buttons.Option(L("weaponsmenu.givealliconicweapons.label"), tip("weaponsmenu.givealliconicweapons.tip"), WeaponItemsMenu.GiveAllIconicWeapons)
    Buttons.Option(L("weaponsmenu.removeallweapons.label"), tip("weaponsmenu.removeallweapons.tip"), WeaponItemsMenu.RemoveAllWeapons)

    Buttons.Toggle(L("weaponsmenu.infiniteammo.label"), Weapons.InfiniteAmmo.enabled, tip("weaponsmenu.infiniteammo.tip"))
    Buttons.Toggle(L("weaponsmenu.noreload.label"), Weapons.NoReloading.toggleNoReloading, tip("weaponsmenu.noreload.tip"))
    Buttons.Toggle(L("weaponsmenu.speedcola.label"), Weapons.FastReload.toggleFastReload, tip("weaponsmenu.speedcola.tip"))
    Buttons.Toggle(L("weaponsmenu.norecoil.label"), Weapons.NoRecoil.toggleNoRecoil, tip("weaponsmenu.norecoil.tip"))

    Buttons.Toggle(L("weaponsmenu.flyingthundergod.label"), Weapons.FlyingThunderGod.enabled, tip("weaponsmenu.flyingthundergod.tip"))
    Buttons.Toggle(L("weaponsmenu.gravitygun.label"), Weapons.GravityGun.enabled, tip("weaponsmenu.gravitygun.tip"))
    Buttons.Toggle(L("weaponsmenu.smartbladereturn.label"), Weapons.SmartBlade.enabled, tip("weaponsmenu.smartbladereturn.tip"))
    Buttons.Toggle(L("weaponsmenu.teleygun.label"), Weapons.TeleportShot.enabled, tip("weaponsmenu.teleygun.tip"))
end

local WeaponsView = { title = L("weaponsmenu.title"), view = WeaponsViewFunction }

return WeaponsView
