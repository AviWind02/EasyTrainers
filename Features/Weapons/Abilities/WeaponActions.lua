local Logger = require("Core/Logger")
local Inventory = require("Utils/Inventory")
local WeaponLoader = require("Utils/DataExtractors/WeaponLoader")

local WeaponActions = {}

local function GiveAll(weapons)
    for _, weapon in ipairs(weapons) do Inventory.GiveItem(weapon.id, 1) end
    return #weapons
end

local function SameText(a, b)
    return (a or ""):lower() == (b or ""):lower()
end

function WeaponActions.GiveAllWallWeapons()
    Logger.Log(string.format("WeaponActions: gave %d wall weapons", GiveAll(WeaponLoader:GetWall())))
end

function WeaponActions.GiveAllIconicWeapons()
    Logger.Log(string.format("WeaponActions: gave %d iconic weapons", GiveAll(WeaponLoader:GetIconic())))
end

function WeaponActions.GiveWeaponsByCategory(category)
    local count = GiveAll(WeaponLoader:Filter(function(weapon) return weapon.type == category end))
    Logger.Log(string.format("WeaponActions: gave %d weapons in category %s", count, tostring(category)))
end

function WeaponActions.GiveWeaponsByRarity(rarity)
    local count = GiveAll(WeaponLoader:Filter(function(weapon) return SameText(weapon.rarity, rarity) end))
    Logger.Log(string.format("WeaponActions: gave %d %s weapons", count, tostring(rarity)))
end

function WeaponActions.RemoveAllWeapons(rarity)
    local removed = 0
    for _, item in ipairs(Inventory.GetAllItems()) do
        local weapon = item.id and WeaponLoader:GetById(item.id) or nil
        if weapon and (not rarity or SameText(weapon.rarity, rarity)) then
            if Inventory.RemoveItem(item.id, item.quantity or 1) then removed = removed + 1 end
        end
    end
    Logger.Log(string.format("WeaponActions: removed %d weapons (%s)", removed, rarity or "all"))
end

function WeaponActions.RemoveBaseWeapons()
    WeaponActions.RemoveAllWeapons("Common")
    WeaponActions.RemoveAllWeapons("Base")
end

return WeaponActions
