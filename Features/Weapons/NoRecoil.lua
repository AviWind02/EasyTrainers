local StatModifiers = require("Gameplay").StatModifiers
local WeaponGameplay = require("Gameplay").WeaponInput
local logger = require("Core/Logger")

local NoRecoil = {}

NoRecoil.handles = {}
NoRecoil.appliedToWeaponID = nil
NoRecoil.toggleNoRecoil = { value = false }
NoRecoil.lastWeaponID = nil
NoRecoil.lastCheckTime = 0
NoRecoil.checkInterval = 1 -- seconds

function NoRecoil.SetNoRecoil(remove)
    local _, itemData, itemID = WeaponGameplay.GetEquippedRightHandWeapon()
    if not itemID then
        logger.Log("[EasyTrainerWeapon] NoRecoil - No weapon equipped")
        return
    end

    if remove then
        if #NoRecoil.handles > 0 and NoRecoil.appliedToWeaponID then
            for _, handle in ipairs(NoRecoil.handles) do
                StatModifiers.RemoveFromWeapon(handle, NoRecoil.appliedToWeaponID)
            end
            NoRecoil.handles = {}
            NoRecoil.appliedToWeaponID = nil
        end
        logger.Log("[EasyTrainerWeapon] NoRecoil - Disabled")
    else
        local modifiers = {
            { gamedataStatType.RecoilKickMin, gameStatModifierType.Multiplier, 0 },
            { gamedataStatType.RecoilKickMax, gameStatModifierType.Multiplier, 0 },
            { gamedataStatType.RecoilUseDifferentStatsInADS, gameStatModifierType.Multiplier, 0 }
        }

        for _, mod in ipairs(modifiers) do
            local handle = StatModifiers.Create(mod[1], mod[2], mod[3])
            StatModifiers.AddToWeapon(handle, itemID)
            table.insert(NoRecoil.handles, handle)
        end

        NoRecoil.appliedToWeaponID = itemID
        logger.Log("[EasyTrainerWeapon] NoRecoil - Enabled")
    end
end

function NoRecoil.Tick(deltaTime)
    if not NoRecoil.toggleNoRecoil.value then return end

    NoRecoil.lastCheckTime = NoRecoil.lastCheckTime + deltaTime
    if NoRecoil.lastCheckTime < NoRecoil.checkInterval then return end
    NoRecoil.lastCheckTime = 0

    local _, itemData, itemID = WeaponGameplay.GetEquippedRightHandWeapon()
    if not itemID then return end

    if itemID ~= NoRecoil.lastWeaponID then
        logger.Log("[EasyTrainerWeapon] NoRecoil - Weapon changed, reapplying modifier")
        NoRecoil.lastWeaponID = itemID

        if itemData and itemData:HasTag(CName("RangedWeapon")) then
            NoRecoil.SetNoRecoil(true)
            NoRecoil.SetNoRecoil(false)
        else
            Draw.Notifier.Push("This is not a ranged weapon. No Recoil won't apply.", 3.5, "Auto", "warning")
        end
    end
end

return NoRecoil
