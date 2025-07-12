-- File: Func/Weapons/WeaponGlobals.lua

local WeaponGlobals = {
    isAiming = false,
    isShooting = false,
}

function WeaponGlobals.HandleInputAction(action)
    local actionName = Game.NameToString(action:GetName(action))
    local actionType = action:GetType(action).value

    local player = Game.GetPlayer()
    if not player then return end

    -- Update aiming state
    WeaponGlobals.isAiming = player.isAiming

    -- Update shooting state
    if actionName == "RangedAttack" then
        if actionType == "BUTTON_PRESSED" then
            WeaponGlobals.isShooting = true
        elseif actionType == "BUTTON_RELEASED" then
            WeaponGlobals.isShooting = false
        end
    end
end


function WeaponGlobals.IsPlayerAiming()
    return WeaponGlobals.isAiming
end

function WeaponGlobals.IsPlayerShooting()
    return WeaponGlobals.isShooting
end

function WeaponGlobals.IsRangedWeaponEquipped()
    local player = Game.GetPlayer()
    local ts = Game.GetTransactionSystem()
    if not player or not ts then return false end

    local item = ts:GetItemInSlot(player, "AttachmentSlots.WeaponRight")
    if not item then return false end

    local data = item:GetItemData()
    return data and data:HasTag(CName("RangedWeapon")) or false
end

function WeaponGlobals.IsShootingWithRangedWeapon()
    return WeaponGlobals.IsPlayerAiming()
        and WeaponGlobals.IsPlayerShooting()
        and WeaponGlobals.IsRangedWeaponEquipped()
end


return WeaponGlobals
