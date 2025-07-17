

local Draw = require("UI")
local Logger = require("Core/Logger")
local Inventory = require("Gameplay").Inventory
local WeaponLoader = require("Features/DataExtractors/WeaponLoader")

local Buttons = Draw.Buttons



local modeOptions = {
    "Weapon Categories",
    "Show Only Iconic Weapons",
    "Show Only Wall Weapons"
}
local selectedMode = { index = 1, expanded = false }

local showTech = { value = true }
local showSmart = { value = true }
local showPower = { value = true }

local selectedCategory = ""


local function WeaponCategorySubmenuView()
    local hasTech, hasSmart, hasPower = false, false, false
    for _, w in ipairs(WeaponLoader:GetAll()) do
        if w.type == selectedCategory then
            if w.isTech then hasTech = true end
            if w.isSmart then hasSmart = true end
            if w.isPower then hasPower = true end
        end
    end

    if hasTech then Buttons.Toggle("Show Tech Weapons", showTech) end
    if hasSmart then Buttons.Toggle("Show Smart Weapons", showSmart) end
    if hasPower then Buttons.Toggle("Show Power Weapons", showPower) end

    local weapons = WeaponLoader:Filter(function(w)
        if w.type ~= selectedCategory then return false end
        if not showTech.value and w.isTech then return false end
        if not showSmart.value and w.isSmart then return false end
        if not showPower.value and w.isPower then return false end
        return true
    end)

    Buttons.Break("", selectedCategory .. " Weapons")

    for _, w in ipairs(weapons) do
        local tip = string.format("TweakDBID: %s\nRarity: %s\nManufacturer: %s", w.id, w.rarity, w.manufacturer)
        if w.iconic then tip = tip .. "\nIconic Weapon" end
        if w.onWall then tip = tip .. "\nWall-Mountable" end
        Buttons.OptionExtended(w.displayName, "", "(" .. w.rarity .. ")", tip, function()
            Inventory.GiveItem(w.id, 1)
        end)
    end
end

local categorySubmenu = {
    title = "Category Weapons",
    view = WeaponCategorySubmenuView
}




local initialized = false
local weaponTypes = {}

local function BuildWeaponTypeList()
    local seen = {}
    for _, w in ipairs(WeaponLoader:GetAll()) do
        if not seen[w.type] then
            seen[w.type] = true
            table.insert(weaponTypes, w.type)
        end
    end
    table.sort(weaponTypes)
end

local function WeaponMainView()
    if not initialized then
        BuildWeaponTypeList()
        initialized = true
    end

    Buttons.Dropdown("Mode", selectedMode, modeOptions, "Choose what to display")

    Buttons.Break("", "Weapon List")

    local mode = modeOptions[selectedMode.index or 1]
    if mode == "Weapon Categories" then
        for _, weaponType in ipairs(weaponTypes) do
            Buttons.Submenu(weaponType, categorySubmenu, "View all " .. weaponType .. " weapons", function()
                selectedCategory = weaponType
                showTech.value = true
                showSmart.value = true
                showPower.value = true
            end)
        end
    else
        local filtered = WeaponLoader:Filter(function(w)
            if mode == "Show Only Iconic Weapons" then
                return w.iconic
            elseif mode == "Show Only Wall Weapons" then
                return w.onWall
            end
            return false
        end)

        for _, w in ipairs(filtered) do
            local tip = string.format("TweakDBID: %s\nType: %s\nRarity: %s\nManufacturer: %s", w.id, w.type, w.rarity, w.manufacturer)
            if w.iconic then tip = tip .. "\nIconic Weapon" end
            if w.onWall then tip = tip .. "\nWall-Mountable" end
            Buttons.OptionExtended(w.displayName, "", "(" .. w.rarity .. ")", tip, function()
                Inventory.GiveItem(w.id, 1)
            end)
        end

        if #filtered == 0 then
            Buttons.Break("", "No weapons found")
        end
    end
end

local function GiveAllWallWeapons()
    local wallWeapons = WeaponLoader:Filter(function(w)
        return w.onWall
    end)

    for _, w in ipairs(wallWeapons) do
        Inventory.GiveItem(w.id, 1)
    end

    Logger.Log(string.format("[EasyTrainerWeaponItemsMenu] Gave %d wall weapons.", #wallWeapons))
end

return {
    title = "Weapon Unlocker",
    view = WeaponMainView,
    GiveAllWallWeapons = GiveAllWallWeapons

}
