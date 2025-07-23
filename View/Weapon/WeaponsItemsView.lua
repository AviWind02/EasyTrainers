

local Draw = require("UI")
local Logger = require("Core/Logger")
local Inventory = require("Gameplay").Inventory
local WeaponLoader = require("Features/DataExtractors/WeaponLoader")

local Buttons = Draw.Buttons




local selectedMode = { index = 1, expanded = false }
local modeOptions = {
    "Weapon Categories",
    "Show Only Iconic Weapons",
    "Show Only Wall Weapons",
    "Show Only Inventory Weapons"
}

local actionMode = { index = 1, expanded = false }
local actionOptions = { "Add Weapon (+1)", "Remove Weapon (-1)" }

local selectedSort = { index = 1, expanded = false }
local sortModes = { "Quantity (High to Low)", "Quantity (Low to High)"}

local showTech = { value = true }
local showSmart = { value = true }
local showPower = { value = true }


local matchedWeapons = {}

local function MatchInventoryToKnownWeapons()
    matchedWeapons = {}

    local allItems = Inventory.GetAllItems()
    if not allItems then return end

    local knownWeapons = WeaponLoader:GetAll()
    local knownByID = {}
    for _, w in ipairs(knownWeapons) do
        knownByID[w.id] = w
    end

    local weaponMap = {}
    for _, item in ipairs(allItems) do
        local data = knownByID[item.id]
        if data then
            if weaponMap[item.id] then
                weaponMap[item.id].count = weaponMap[item.id].count + (item.quantity or 1)
            else
                weaponMap[item.id] = {
                    name = data.displayName,
                    id = data.id,
                    rarity = data.rarity,
                    manufacturer = data.manufacturer,
                    iconic = data.iconic,
                    onWall = data.onWall,
                    type = data.type,
                    count = item.quantity or 1
                }
            end

            -- Logger.Log(string.format("[EasyTrainerWeapons] Matched item: %s (%s) x%d", data.displayName, data.id, item.quantity or 1))
        end
    end

    for _, weapon in pairs(weaponMap) do
        table.insert(matchedWeapons, weapon)
    end

    Logger.Log(string.format("[EasyTrainerWeapons] Total matched weapons: %d", #matchedWeapons))
    Draw.Notifier.Push(string.format("Loaded %d weapon(s) from inventory.", #matchedWeapons))
end




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


local function DrawWeaponCategories()
    for _, weaponType in ipairs(weaponTypes) do
        Buttons.Submenu(weaponType, categorySubmenu, "View all " .. weaponType .. " weapons", function()
            selectedCategory = weaponType
            showTech.value = true
            showSmart.value = true
            showPower.value = true
        end)
    end
end

local rarityOrder = {
    iconic = 9,
    legendaryplusplus = 8,
    legendaryplus = 7,
    legendary = 6,
    epic = 5,
    rare = 4,
    uncommon = 3,
    common = 2,
    base = 1
}


local function getRarityWeight(weapon)
    if weapon.iconic then
        return rarityOrder["iconic"]
    end
    local rarity = (weapon.rarity or ""):lower()
    return rarityOrder[rarity] or 0
end

local function DrawInventoryWeapons()
    table.sort(matchedWeapons, function(a, b)
        local mode = sortModes[selectedSort.index or 1]

        if mode == "Quantity (High to Low)" then
            if a.count == b.count then
                return a.name < b.name
            end
            return a.count > b.count
        elseif mode == "Quantity (Low to High)" then
            if a.count == b.count then
                return a.name < b.name
            end
            return a.count < b.count
        elseif mode == "Rarity" then -- keeps overlapping for some reason even with a secondary check for name sorting
            local weightA = getRarityWeight(a)
            local weightB = getRarityWeight(b)

            if weightA == weightB then
                return a.name < b.name
            end
            return weightA > weightB
        end
    end)


    for _, w in ipairs(matchedWeapons) do
        local tip = string.format("TweakDBID: %s\nType: %s\nRarity: %s\nManufacturer: %s", w.id, w.type, w.rarity,
            w.manufacturer)
        if w.iconic then tip = tip .. "\nIconic Weapon" end
        if w.onWall then tip = tip .. "\nWall-Mountable" end

        Buttons.OptionExtended(w.name, "", "x" .. tostring(w.count), tip, function()
            local action = actionOptions[actionMode.index or 1]
            if action == "Add Weapon" then
                Inventory.GiveItem(w.id, 1)
                w.count = w.count + 1
            elseif action == "Remove Weapon" then
                if w.count > 0 then
                    Inventory.RemoveItem(w.id, 1)
                    w.count = w.count - 1
                else
                    Draw.Notifier.Push("No more of this item in inventory.")
                end
            end
        end)
    end

    if #matchedWeapons == 0 then
        Buttons.Break("", "No weapons found in inventory.")
    end
end


local function DrawFilteredWeapons(mode)
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


local function WeaponMainView()
    if not initialized then
        BuildWeaponTypeList()
        MatchInventoryToKnownWeapons()
        initialized = true
    end

    Buttons.Dropdown("Mode", selectedMode, modeOptions, "Choose what to display")

    local mode = modeOptions[selectedMode.index or 1]
    if mode == "Show Only Inventory Weapons" then
        Buttons.Dropdown("Inventory Action", actionMode, actionOptions, "Choose whether to add or remove weapons from Inventory")
        Buttons.Option("Refresh Inventory", "Update the weapon list from current inventory.", MatchInventoryToKnownWeapons)
        Buttons.Dropdown("Sort Inventory By", selectedSort, sortModes, "Choose sorting method")
    end

    Buttons.Break("", "Weapon List")

    if mode == "Weapon Categories" then
        DrawWeaponCategories()
    elseif mode == "Show Only Inventory Weapons" then
        DrawInventoryWeapons()
    else
        DrawFilteredWeapons(mode)
    end
end



local function GiveAllWallWeapons()
    local wallWeapons = WeaponLoader:Filter(function(w)
        return w.onWall
    end)

    for _, w in ipairs(wallWeapons) do
        Inventory.GiveItem(w.id, 1)
    end

     Draw.Notifier.Push(string.format("Gave %d wall weapons.", #wallWeapons))
end

local function RemoveAllWeapons(rarity)
    local inventoryItems = Inventory:GetAllItems()
    local removedCount = 0

    for _, item in ipairs(inventoryItems) do
        if item and item.id and tostring(item.id):find("^Items%.") then
            local weaponData = WeaponLoader:GetById(item.id)
            if weaponData then
                local isMatch = false

                if not rarity then
                    isMatch = true
                elseif weaponData.rarity and weaponData.rarity:lower() == rarity:lower() then
                    isMatch = true
                end

                if isMatch then
                    Inventory.RemoveItem(item.id, item.count or 1)
                    removedCount = removedCount + 1
                    Logger.Log(string.format("[RemoveAllWeapons] Removed %s x%d", item.id, item.count or 1))
                end
            end
        end
    end


    if rarity then
        Draw.Notifier.Push(string.format("Removed %d weapons with rarity: %s", removedCount, rarity))
    else
         Draw.Notifier.Push(string.format("Removed %d weapons (all rarities).", removedCount))
    end
end

local function GiveAllIconicWeapons()
    local iconicWeapons = WeaponLoader:Filter(function(w)
        return w.iconic
    end)

    for _, w in ipairs(iconicWeapons) do
        Inventory.GiveItem(w.id, 1)
    end

     Draw.Notifier.Push(string.format("Gave %d iconic weapons.", #iconicWeapons))
end


local function GiveWeaponsByCategory(category)
    local filtered = WeaponLoader:Filter(function(w)
        return w.category == category
    end)

    for _, w in ipairs(filtered) do
        Inventory.GiveItem(w.id, 1)
    end

     Draw.Notifier.Push(string.format("Gave %d weapons in category: %s", #filtered, category))
end

local function GiveWeaponsByRarity(rarity)
    local filtered = WeaponLoader:Filter(function(w)
        return (w.rarity or ""):lower() == rarity:lower()
    end)

    for _, w in ipairs(filtered) do
        Inventory.GiveItem(w.id, 1)
    end

     Draw.Notifier.Push(string.format("Gave %d weapons of rarity: %s", #filtered, rarity))
end

local function RemoveBaseWeapons()
    RemoveAllWeapons("Common")
    RemoveAllWeapons("Base")
    
end

return { -- special return statement one of a kind 
    title = "Weapon Unlocker",
    view = WeaponMainView,
    GiveAllWallWeapons = GiveAllWallWeapons,
    RemoveAllWeapons = RemoveAllWeapons,
    GiveAllIconicWeapons = GiveAllIconicWeapons,
    GiveWeaponsByCategory = GiveWeaponsByCategory,
    GiveWeaponsByRarity = GiveWeaponsByRarity,
    RemoveBaseWeapons = RemoveBaseWeapons
}

