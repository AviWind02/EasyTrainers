local StatModifiers = require("Gameplay").StatModifiers
local logger = require("Core/Logger")
local WeaponGameplay = require("Gameplay").WeaponInput

local FastReload = {}

FastReload.handles = {}
FastReload.appliedToWeaponID = nil
FastReload.lastWeaponID = nil
FastReload.lastCheckTime = 0
FastReload.checkInterval = 1 -- seconds

FastReload.toggleFastReload = { value = false }

function FastReload.SetFastReload(remove)
    local _, itemData, itemID = WeaponGameplay.GetEquippedRightHandWeapon()
    if not itemID then
        logger.Log("[EasyTrainerWeapon] FastReload - No weapon equipped")
        return
    end

    if remove then
        if FastReload.handles and FastReload.appliedToWeaponID then
            for _, handle in ipairs(FastReload.handles) do
                StatModifiers.RemoveFromWeapon(handle, FastReload.appliedToWeaponID)
            end
            FastReload.handles = {}
            FastReload.appliedToWeaponID = nil
        end
        logger.Log("[EasyTrainerWeapon] FastReload - Disabled")
    else
        local modifiers = {
            { gamedataStatType.ReloadTimeBase, gameStatModifierType.Multiplier, 0.2 },
            { gamedataStatType.ReloadEndTime, gameStatModifierType.Multiplier, 0.1 },
            { gamedataStatType.EmptyReloadTime, gameStatModifierType.Multiplier, 0.2 },
            { gamedataStatType.EmptyReloadEndTime, gameStatModifierType.Multiplier, 0.1 }
        }

        for _, mod in ipairs(modifiers) do
            local handle = StatModifiers.Create(mod[1], mod[2], mod[3])
            StatModifiers.AddToWeapon(handle, itemID)
            table.insert(FastReload.handles, handle)
        end

        FastReload.appliedToWeaponID = itemID
        logger.Log("[EasyTrainerWeapon] FastReload - Enabled")
    end
end
-- TODO: Move tick logic out of individual modules into a central manager later
function FastReload.Tick(deltaTime)
    if not FastReload.toggleFastReload.value then return end

    FastReload.lastCheckTime = FastReload.lastCheckTime + deltaTime
    if FastReload.lastCheckTime < FastReload.checkInterval then return end
    FastReload.lastCheckTime = 0

    local _, itemData, itemID = WeaponGameplay.GetEquippedRightHandWeapon()
    if not itemID then return end

    if itemID ~= FastReload.lastWeaponID then
        logger.Log("[EasyTrainerWeapon] FastReload - Weapon changed, reapplying modifier")
        FastReload.lastWeaponID = itemID

        if itemData and itemData:HasTag(CName("RangedWeapon")) then
            FastReload.SetFastReload(true)
            FastReload.SetFastReload(false)
        else
            Draw.Notifier.Push("This is not a ranged weapon. Fast Reload won't apply.", 3.5, "Auto", "warning")
        end
    end
end

return FastReload
