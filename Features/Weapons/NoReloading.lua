local Draw = require("UI")


local StatModifiers = require("Gameplay").StatModifiers
local logger = require("Core/Logger")
local WeaponGameplay = require("Gameplay").WeaponInput

local NoReloading = {}

NoReloading.handle = nil
NoReloading.appliedToWeaponID = nil 
NoReloading.toggleNoReloading = { value = false }
NoReloading.lastWeaponID = nil
NoReloading.lastCheckTime = 0
NoReloading.checkInterval = 1 
function NoReloading.SetNoReloading(remove)
    local _, itemData, itemID = WeaponGameplay.GetEquippedRightHandWeapon()
    if not itemID then
        logger.Log("[EasyTrainerWeapon] NoReload - No weapon equipped")
        return
    end

    if remove then
        if NoReloading.handle and NoReloading.appliedToWeaponID then
            StatModifiers.RemoveFromWeapon(NoReloading.handle, NoReloading.appliedToWeaponID)
            NoReloading.handle = nil
            NoReloading.appliedToWeaponID = nil
        end
        logger.Log("[EasyTrainerWeapon] NoReload - Disabled")
    else
        NoReloading.handle = StatModifiers.Create(gamedataStatType.NumShotsToFire, gameStatModifierType.Multiplier, 0)
        StatModifiers.AddToWeapon(NoReloading.handle, itemID)
        NoReloading.appliedToWeaponID = itemID  -- track the weapon we applied it to
        logger.Log("[EasyTrainerWeapon] NoReload - Enabled")
    end
end

-- TODO: Move tick logic out of individual modules into a central manager later
function NoReloading.Tick(deltaTime)
    if not NoReloading.toggleNoReloading.value then return end

    NoReloading.lastCheckTime = NoReloading.lastCheckTime + deltaTime
    if NoReloading.lastCheckTime < NoReloading.checkInterval then return end
    NoReloading.lastCheckTime = 0

    local _, itemData, itemID = WeaponGameplay.GetEquippedRightHandWeapon()
    if not itemID then return end

    if itemID ~= NoReloading.lastWeaponID then
        logger.Log("[EasyTrainerWeapon] NoReload - Weapon changed, reapplying modifier")
        NoReloading.lastWeaponID = itemID

        if itemData then
            if itemData:HasTag(CName("RangedWeapon")) then
                NoReloading.SetNoReloading(true)
                NoReloading.SetNoReloading(false)
            else
                -- Draw.Notifier.Push("This is not a ranged weapon. No Reload won't apply.", 3.5, "Auto", "warning")
            end
        end
    end
end

return NoReloading
