local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local SidePanel = require("UI/Panels/SidePanel/SidePanel")
local Inventory = require("Utils/Inventory")
local WeaponLoader = require("Utils/DataExtractors/WeaponLoader")

local MODE = {
    Iconic = "weaponsitems.onlyiconic.label",
    Wall = "weaponsitems.onlywall.label",
    Inventory = "weaponsitems.onlyinventory.label"
}
local MODE_OPTIONS = { MODE.Iconic, MODE.Wall, MODE.Inventory }

local ACTION_REMOVE = "weaponsitems.removeweapon"
local ACTION_OPTIONS = { "weaponsitems.addweapon", ACTION_REMOVE }

local SORT = {
    QuantityHigh = "weaponsitems.quantityH",
    QuantityLow = "weaponsitems.quantityL",
    Rarity = "weaponsitems.rarity"
}
local SORT_OPTIONS = { SORT.QuantityHigh, SORT.QuantityLow, SORT.Rarity }

local s_Mode = { index = 1 }
local s_Action = { index = 1 }
local s_Sort = { index = 1 }
local s_Quantity = { value = 1, min = 1, max = 50, step = 1 }
local s_ShowTech = { value = true }
local s_ShowSmart = { value = true }
local s_ShowPower = { value = true }

local s_Owned = {}
local s_SortedBy = nil
local s_Types = nil
local s_Iconic = nil
local s_Wall = nil
local s_Category = ""

local function IsRemoving()
    return ACTION_OPTIONS[s_Action.index or 1] == ACTION_REMOVE
end

local function ActionSummary()
    return (IsRemoving() and "-" or "+") .. tostring(s_Quantity.value)
end

local function ApplyWeapon(weapon, amount)
    amount = amount or s_Quantity.value
    if IsRemoving() then return Inventory.RemoveItem(weapon.id, amount) end
    return Inventory.GiveItem(weapon.id, amount)
end

local function SubmitWeaponInfo(weapon)
    local technology = weapon.isSmart and "Smart" or weapon.isTech and "Tech" or weapon.isPower and "Power" or "Standard"
    SidePanel.SubmitInfo("weapon-record", {
        Eyebrow = weapon.iconic and "ICONIC WEAPON" or "WEAPON DATABASE",
        Title = weapon.displayName or "Unknown Weapon",
        Rows = {
            { Label = "Type", Value = weapon.type or "Miscellaneous" },
            { Label = "Rarity", Value = weapon.rarity or "Standard" },
            { Label = "Technology", Value = technology },
            { Label = "Manufacturer", Value = weapon.manufacturer or "Unlisted" },
            { Label = "Stash wall", Value = weapon.onWall and "Yes" or "No" }
        },
        Description = weapon.id
    }, { Width = 320 })
end

local function DrawActionControls()
    Buttons.Dropdown(L("weaponsitems.actionmode.label"), s_Action, ACTION_OPTIONS, L("weaponsitems.actionmode.tip"))
    Buttons.Int("Quantity", s_Quantity, "Number of copies to add or remove per selection.")
end

local function WeaponOption(weapon, value, action)
    local _, data = Buttons.OptionExtended(weapon.displayName, "", value, "Apply the selected inventory action.", action)
    if data and data.Visible and (data.Selected or data.Hovered) then SubmitWeaponInfo(weapon) end
end

local function RefreshOwned()
    local counts = {}
    for _, item in ipairs(Inventory.GetAllItems() or {}) do
        if WeaponLoader:GetById(item.id) then counts[item.id] = (counts[item.id] or 0) + (item.quantity or 1) end
    end

    s_Owned = {}
    for id, count in pairs(counts) do
        table.insert(s_Owned, { weapon = WeaponLoader:GetById(id), count = count })
    end
    s_SortedBy = nil
end

local function SortOwned()
    local mode = SORT_OPTIONS[s_Sort.index or 1]
    if s_SortedBy == mode then return end
    s_SortedBy = mode

    table.sort(s_Owned, function(a, b)
        local left, right
        if mode == SORT.Rarity then
            left, right = WeaponLoader:GetRarityWeight(b.weapon), WeaponLoader:GetRarityWeight(a.weapon)
        elseif mode == SORT.QuantityLow then
            left, right = a.count, b.count
        else
            left, right = b.count, a.count
        end
        if left == right then return a.weapon.displayName < b.weapon.displayName end
        return left < right
    end)
end

local function CategoryView()
    local hasTech, hasSmart, hasPower = false, false, false
    for _, weapon in ipairs(WeaponLoader:GetAll()) do
        if weapon.type == s_Category then
            hasTech = hasTech or weapon.isTech
            hasSmart = hasSmart or weapon.isSmart
            hasPower = hasPower or weapon.isPower
        end
    end

    local weapons = WeaponLoader:GetByCategory(s_Category, {
        tech = s_ShowTech.value,
        smart = s_ShowSmart.value,
        power = s_ShowPower.value
    })

    local placeholders = { category = s_Category }
    DrawActionControls()
    if hasTech then Buttons.Toggle(L("weaponsitems.categorytoggle_tech.label"), s_ShowTech, tip("weaponsitems.categorytoggle_tech.tip", placeholders)) end
    if hasSmart then Buttons.Toggle(L("weaponsitems.categorytoggle_smart.label"), s_ShowSmart, tip("weaponsitems.categorytoggle_smart.tip", placeholders)) end
    if hasPower then Buttons.Toggle(L("weaponsitems.categorytoggle_power.label"), s_ShowPower, tip("weaponsitems.categorytoggle_power.tip", placeholders)) end

    for _, weapon in ipairs(weapons) do
        WeaponOption(weapon, ActionSummary(), function() ApplyWeapon(weapon) end)
    end

    if #weapons == 0 then
        Buttons.Option(L("weaponsitems.noweaponsfound.label"), "", function() end)
    end
end

local CategoryMenu = Submenu.Create("weaponsitems.categories.label", CategoryView)

local function CategoriesView()
    s_Types = s_Types or WeaponLoader:GetTypes()
    for _, weaponType in ipairs(s_Types) do
        Buttons.Submenu(weaponType, CategoryMenu, tip("weaponsitems.categorybreak.tip", { category = weaponType }), function()
            s_Category = weaponType
            s_ShowTech.value = true
            s_ShowSmart.value = true
            s_ShowPower.value = true
        end)
    end
end

local CategoriesMenu = Submenu.Create("weaponsitems.categories.label", CategoriesView)

local function DrawOwned()
    SortOwned()
    for _, entry in ipairs(s_Owned) do
        WeaponOption(entry.weapon, "x" .. tostring(entry.count), function()
            local amount = IsRemoving() and math.min(s_Quantity.value, entry.count) or s_Quantity.value
            if amount <= 0 or not ApplyWeapon(entry.weapon, amount) then return end
            entry.count = math.max(0, entry.count + (IsRemoving() and -amount or amount))
        end)
    end

    if #s_Owned == 0 then Buttons.Break(L("weaponsitems.noinventoryweapons.label")) end
end

local function DrawFiltered(weapons)
    for _, weapon in ipairs(weapons) do
        WeaponOption(weapon, ActionSummary(), function() ApplyWeapon(weapon) end)
    end

    if #weapons == 0 then Buttons.Break(L("weaponsitems.noweaponsfound.label")) end
end

local function WeaponItemsView()
    local mode = MODE_OPTIONS[s_Mode.index or 1]

    Buttons.Submenu(L("weaponsitems.categories.label"), CategoriesMenu, L("weaponsitems.categories.tip"))
    Buttons.Dropdown(L("weaponsitems.mode.label"), s_Mode, MODE_OPTIONS, L("weaponsitems.mode.tip"), function()
        if MODE_OPTIONS[s_Mode.index] == MODE.Inventory then RefreshOwned() end
    end)
    DrawActionControls()

    if mode == MODE.Inventory then
        Buttons.Option(L("weaponsitems.refreshinventory.label"), L("weaponsitems.refreshinventory.tip"), RefreshOwned)
        Buttons.Dropdown(L("weaponsitems.sortinventory.label"), s_Sort, SORT_OPTIONS, L("weaponsitems.sortinventory.tip"))
    end

    Buttons.Break(L(mode))

    if mode == MODE.Inventory then
        DrawOwned()
    elseif mode == MODE.Iconic then
        s_Iconic = s_Iconic or WeaponLoader:GetIconic()
        DrawFiltered(s_Iconic)
    else
        s_Wall = s_Wall or WeaponLoader:GetWall()
        DrawFiltered(s_Wall)
    end
end

return Submenu.Create("weaponsitems.title", WeaponItemsView)
