local Draw = require("UI")
local Logger = require("Core/Logger")
local Inventory = require("Gameplay").Inventory
local WeaponLoader = require("Features/DataExtractors/WeaponLoader")

local Buttons = Draw.Buttons

local selectedMode = { index = 1, expanded = false }
local modeOptions = {
    "weaponsitems.categories.label",
    "weaponsitems.onlyiconic.label",
    "weaponsitems.onlywall.label",
    "weaponsitems.onlyinventory.label"
}

local actionMode = { index = 1, expanded = false }
local actionOptions = { "Add Weapon (+1)", "Remove Weapon (-1)" } -- could be localized if desired

local selectedSort = { index = 1, expanded = false }
local sortModes = { "Quantity (High to Low)", "Quantity (Low to High)" }

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
        end
    end

    for _, weapon in pairs(weaponMap) do
        table.insert(matchedWeapons, weapon)
    end
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

    if hasTech then Buttons.Toggle(L("weaponsitems.categorytoggle_tech.label"), showTech, tip("weaponsitems.categorytoggle_tech.tip", { category = selectedCategory })) end
    if hasSmart then Buttons.Toggle(L("weaponsitems.categorytoggle_smart.label"), showSmart, tip("weaponsitems.categorytoggle_smart.tip", { category = selectedCategory })) end
    if hasPower then Buttons.Toggle(L("weaponsitems.categorytoggle_power.label"), showPower, tip("weaponsitems.categorytoggle_power.tip", { category = selectedCategory })) end

    local weapons = WeaponLoader:Filter(function(w)
        if w.type ~= selectedCategory then return false end
        if not showTech.value and w.isTech then return false end
        if not showSmart.value and w.isSmart then return false end
        if not showPower.value and w.isPower then return false end
        return true
    end)

    Buttons.Break("", tip("weaponsitems.categorybreak.tip", { category = selectedCategory }))

    for _, w in ipairs(weapons) do
        local tipData = {
            id = w.id,
            type = w.type,
            rarity = w.rarity,
            manufacturer = w.manufacturer,
            iconic = w.iconic and "\nIconic Weapon" or "",
            wall = w.onWall and "\nWall-Mountable" or ""
        }
        Buttons.OptionExtended(w.displayName, "", "(" .. w.rarity .. ")", tip("weaponsitems.weaponentry.tip", tipData), function()
            Inventory.GiveItem(w.id, 1)
        end)
    end
end

local categorySubmenu = {
    title = "weaponsitems.categories.label",
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
        Buttons.Submenu(weaponType, categorySubmenu, tip("weaponsitems.categorybreak.tip", { category = weaponType }), function()
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
            if a.count == b.count then return a.name < b.name end
            return a.count > b.count
        elseif mode == "Quantity (Low to High)" then
            if a.count == b.count then return a.name < b.name end
            return a.count < b.count
        elseif mode == "Rarity" then
            local weightA = getRarityWeight(a)
            local weightB = getRarityWeight(b)
            if weightA == weightB then return a.name < b.name end
            return weightA > weightB
        end
    end)

    for _, w in ipairs(matchedWeapons) do
        local tipData = {
            id = w.id,
            type = w.type,
            rarity = w.rarity,
            manufacturer = w.manufacturer,
            iconic = w.iconic and "\nIconic Weapon" or "",
            wall = w.onWall and "\nWall-Mountable" or ""
        }
        Buttons.OptionExtended(w.name, "", "x" .. tostring(w.count), tip("weaponsitems.weaponentry.tip", tipData), function()
            local action = actionOptions[actionMode.index or 1]
            if action == "Add Weapon (+1)" then
                Inventory.GiveItem(w.id, 1)
                w.count = w.count + 1
            elseif action == "Remove Weapon (-1)" then
                if w.count > 0 then
                    Inventory.RemoveItem(w.id, 1)
                    w.count = w.count - 1
                else
                    Draw.Notifier.Push(L("weaponsitems.noinventoryweapons.label"))
                end
            end
        end)
    end

    if #matchedWeapons == 0 then
        Buttons.Break("", L("weaponsitems.noinventoryweapons.label"))
    end
end

local function DrawFilteredWeapons(mode)
    local filtered = WeaponLoader:Filter(function(w)
        if mode == L("weaponsitems.onlyiconic.label") then
            return w.iconic
        elseif mode == L("weaponsitems.onlywall.label") then
            return w.onWall
        end
        return false
    end)

    for _, w in ipairs(filtered) do
        local tipData = {
            id = w.id,
            type = w.type,
            rarity = w.rarity,
            manufacturer = w.manufacturer,
            iconic = w.iconic and "\nIconic Weapon" or "",
            wall = w.onWall and "\nWall-Mountable" or ""
        }
        Buttons.OptionExtended(w.displayName, "", "(" .. w.rarity .. ")", tip("weaponsitems.weaponentry.tip", tipData), function()
            Inventory.GiveItem(w.id, 1)
        end)
    end

    if #filtered == 0 then
        Buttons.Break("", L("weaponsitems.noweaponsfound.label"))
    end
end

local function WeaponMainView()
    if not initialized then
        BuildWeaponTypeList()
        MatchInventoryToKnownWeapons()
        initialized = true
    end

    Buttons.Dropdown(L("weaponsitems.mode.label"), selectedMode, modeOptions, L("weaponsitems.mode.tip"))

    local mode = modeOptions[selectedMode.index or 1]
    if mode == "weaponsitems.onlyinventory.label" then
        Buttons.Dropdown(L("weaponsitems.actionmode.label"), actionMode, actionOptions, L("weaponsitems.actionmode.tip"))
        Buttons.Option(L("weaponsitems.refreshinventory.label"), L("weaponsitems.refreshinventory.tip"), MatchInventoryToKnownWeapons)
        Buttons.Dropdown(L("weaponsitems.sortinventory.label"), selectedSort, sortModes, L("weaponsitems.sortinventory.tip"))
    end

    Buttons.Break("", L("weaponsitems.title"))

    if mode == "weaponsitems.categories.label" then
        DrawWeaponCategories()
    elseif mode == "weaponsitems.onlyinventory.label" then
        DrawInventoryWeapons()
    else
        DrawFilteredWeapons(L(mode))
    end
end

local function GiveAllWallWeapons()
    local wallWeapons = WeaponLoader:Filter(function(w) return w.onWall end)
    for _, w in ipairs(wallWeapons) do Inventory.GiveItem(w.id, 1) end
end

local function RemoveAllWeapons(rarity)
    local inventoryItems = Inventory:GetAllItems()
    for _, item in ipairs(inventoryItems) do
        if item and item.id and tostring(item.id):find("^Items%.") then
            local weaponData = WeaponLoader:GetById(item.id)
            if weaponData then
                local isMatch = not rarity or (weaponData.rarity and weaponData.rarity:lower() == rarity:lower())
                if isMatch then Inventory.RemoveItem(item.id, item.count or 1) end
            end
        end
    end
end

local function GiveAllIconicWeapons()
    local iconicWeapons = WeaponLoader:Filter(function(w) return w.iconic end)
    for _, w in ipairs(iconicWeapons) do Inventory.GiveItem(w.id, 1) end
end

local function GiveWeaponsByCategory(category)
    local filtered = WeaponLoader:Filter(function(w) return w.category == category end)
    for _, w in ipairs(filtered) do Inventory.GiveItem(w.id, 1) end
end

local function GiveWeaponsByRarity(rarity)
    local filtered = WeaponLoader:Filter(function(w) return (w.rarity or ""):lower() == rarity:lower() end)
    for _, w in ipairs(filtered) do Inventory.GiveItem(w.id, 1) end
end

local function RemoveBaseWeapons()
    RemoveAllWeapons("Common")
    RemoveAllWeapons("Base")
end

return {
    title = "weaponsitems.title",
    view = WeaponMainView,
    GiveAllWallWeapons = GiveAllWallWeapons,
    RemoveAllWeapons = RemoveAllWeapons,
    GiveAllIconicWeapons = GiveAllIconicWeapons,
    GiveWeaponsByCategory = GiveWeaponsByCategory,
    GiveWeaponsByRarity = GiveWeaponsByRarity,
    RemoveBaseWeapons = RemoveBaseWeapons
}
