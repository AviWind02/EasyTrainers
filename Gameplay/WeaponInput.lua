local WeaponGameplay = {
    isAiming = false,
    isShooting = false,
}

function WeaponGameplay.HandleInputAction(action)
    local actionName = Game.NameToString(action:GetName(action))
    local actionType = action:GetType(action).value

    local player = Game.GetPlayer()
    if not player then return end

    -- Update aiming state
    WeaponGameplay.isAiming = player.isAiming

    -- Update shooting state
    if actionName == "RangedAttack" then
        if actionType == "BUTTON_PRESSED" then
            WeaponGameplay.isShooting = true
        elseif actionType == "BUTTON_RELEASED" then
            WeaponGameplay.isShooting = false
        end
    end
end

function WeaponGameplay.IsPlayerAiming()
    return WeaponGameplay.isAiming
end

function WeaponGameplay.IsPlayerShooting()
    return WeaponGameplay.isShooting
end

function WeaponGameplay.GetAllRangedWeaponsInInventory()
    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    if not player or not transactionSystem then return {} end

    local success, allItems = transactionSystem:GetItemList(player)
    local rangedWeapons = {}

    if not success or type(allItems) ~= "table" then
        return {}
    end

    for _, itemData in ipairs(allItems) do
        if itemData and itemData:HasTag(CName("Weapon")) and itemData:HasTag(CName("RangedWeapon")) then
            table.insert(rangedWeapons, {
                item = itemData:GetID(),
                data = itemData
            })
        end
    end

    return rangedWeapons
end


function WeaponGameplay.GetEquippedRightHandWeapon()
    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    if not player or not transactionSystem then return nil, nil end

    local item = transactionSystem:GetItemInSlot(player, "AttachmentSlots.WeaponRight")
    if not item then return nil, nil end

    local itemData = item:GetItemData()
    if not itemData then return nil, nil end

    return item, itemData, item:GetItemID()
end

function WeaponGameplay.IsRangedWeaponEquipped()
    local _, itemData = WeaponGameplay.GetEquippedRightHandWeapon()
    return itemData and itemData:HasTag(CName("RangedWeapon")) or false
end

function WeaponGameplay.IsShootingWithRangedWeapon()
    return WeaponGameplay.IsPlayerAiming()
        and WeaponGameplay.IsPlayerShooting()
        and WeaponGameplay.IsRangedWeaponEquipped()
end

return WeaponGameplay
