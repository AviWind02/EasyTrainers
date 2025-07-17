local Weapons = require("Features/Weapons")
local Draw = require("UI")
local Inventory = require("Gameplay").Inventory

local WeaponItemsMenu = require("View/Weapon/WeaponsItemsView")

local Buttons = Draw.Buttons

local ammoTypes = {
        { id = "Ammo.HandgunAmmo",     label = "Handgun Ammo" },
        { id = "Ammo.ShotgunAmmo",     label = "Shotgun Ammo" },
        { id = "Ammo.RifleAmmo",       label = "Rifle Ammo" },
        { id = "Ammo.SniperRifleAmmo", label = "Sniper Ammo" },
        { id = "Ammo.Special",         label = "Special Ammo" }
}

local addAmmoValues = {}
local removeAmmoValues = {}

for _, ammo in ipairs(ammoTypes) do
        addAmmoValues[ammo.id] = { step = 10, value = 50, min = 1, max = 999 }
        removeAmmoValues[ammo.id] = { step = 10, value = 10, min = 1, max = 999 }
end

local function AmmoItemsView()
        Buttons.Option("Give 100 of Each Ammo Type", "Adds 100 ammo for each type", function()
                for _, ammo in ipairs(ammoTypes) do
                        Inventory.GiveItem(ammo.id, 100)
                end
        end)
        Buttons.Break("", "Add Ammo")
        for _, ammo in ipairs(ammoTypes) do
                Buttons.Int(ammo.label, addAmmoValues[ammo.id], "Click to add " .. ammo.label, function()
                        Inventory.GiveItem(ammo.id, addAmmoValues[ammo.id].value)
                end)
        end

        Buttons.Break("", "Remove Ammo")
        for _, ammo in ipairs(ammoTypes) do
                Buttons.Int(ammo.label, removeAmmoValues[ammo.id], "Click to remove " .. ammo.label, function()
                        Inventory.RemoveItem(ammo.id, removeAmmoValues[ammo.id].value)
                end)
        end
end

local ammoItemsSubmenu = { title = "Ammo Items", view = AmmoItemsView }



local function WeaponsViewFunction()
        Buttons.Submenu("Weapon Items", WeaponItemsMenu,
                "Add any weapon item to your inventory, including iconic and stash wall variants.")
        Buttons.Submenu("Ammo Manager", ammoItemsSubmenu, "Add or remove ammo types")

        Buttons.Option("Give All Wall Weapons", "Gives you all weapons that can be mounted on your apartment wall.", WeaponItemsMenu.GiveAllWallWeapons)

        Buttons.Toggle("Infinite Ammo", Weapons.InfiniteAmmo.enabled,
                "Your ammo never runs out. Each time you shoot, you instantly get the bullet back.")
        Buttons.Toggle("No Reload", Weapons.NoReloading.toggleNoReloading,
                "Removes reload time. Fire continuously without waiting to reload.")
        Buttons.Toggle("Speed Cola", Weapons.FastReload.toggleFastReload, "Greatly reduces reload time.")
        Buttons.Toggle("No Recoil", Weapons.NoRecoil.toggleNoRecoil,
                "Removes recoil from all weapons. No more shaking when firing.\nTip: Great with Problem Solver.")

        Buttons.Toggle("Flying Thunder God Technique", Weapons.FlyingThunderGod.enabled,
                "Throw a knife to instantly teleport to its location upon impact")
        Buttons.Toggle("Gravity Gun", Weapons.GravityGun.enabled,
                "Pick up and move vehicles or objects by aiming at them.")
        Buttons.Toggle("Smart Blade Return", Weapons.SmartBlade.enabled,
                "Thrown knives or projectiles automatically return to you after hitting a target or surface.")
        Buttons.Toggle("Teley Gun", Weapons.TeleportShot.enabled, "Shoot bullets that teleport you to where they land.")

end


local WeaponsView = { title = "Weapons Menu", view = WeaponsViewFunction }

return WeaponsView
