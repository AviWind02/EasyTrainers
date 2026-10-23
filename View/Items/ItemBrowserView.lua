local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local SidePanel = require("UI/Panels/SidePanel/SidePanel")
local Notification = require("UI/Panels/Notification/Notification")
local GeneralLoader = require("Utils/DataExtractors/GeneralLoader")
local Items = require("Features/Items")
local ItemsView = require("View/Items/ItemsView")

local State = Items.BrowserState

local SEARCH_LIMIT = 250

local CATEGORY_GROUPS = {
    { Name = "Cyberware", Keys = { "Cyberware" }, Tip = "Operating systems, implants, optics, and other cyberware." },
    { Name = "Consumables", Keys = { "Consumables" }, Tip = "Food, drinks, medicine, boosters, and inhalers." },
    { Name = "Crafting & Upgrades", Keys = { "CraftingMaterials" }, Tip = "Crafting, quickhack, upgrade, and attachment materials." },
    { Name = "Weapon Mods", Keys = { "WeaponMods" }, Tip = "Attachments and modifications for ranged and melee weapons." },
    { Name = "Skills & Progression", Keys = { "SkillShards", "CyberdeckShards" }, Tip = "Skill books, progression shards, and cyberdeck upgrades." },
    { Name = "Rewards & Currency", Keys = { "Reward" }, Tip = "Currency, reward containers, chips, and payout items." },
    { Name = "Quest Items", Keys = { "Quest" }, Tip = "Items tagged for missions and story progression." },
    { Name = "Readables", Keys = { "Readables" }, Tip = "Shards, fragments, and readable database items." },
    { Name = "Miscellaneous", Keys = { "Miscellaneous" }, Tip = "Junk, props, valuables, and novelty items." },
    { Name = "Advanced", Keys = { "Uncategorized" }, Tip = "Items whose game tags do not fit the curated categories." }
}

local s_Catalog = nil
local s_Quality = { index = 1 }
local s_CraftableOnly = { value = false }
local s_Search = { value = "", capturing = false }
local s_SearchTerm = nil
local s_SearchResults = {}

local function Friendly(value)
    return (tostring(value or "Other"):gsub("_", " "):gsub("(%l)(%u)", "%1 %2"))
end

local function QualityName(value)
    return Friendly(tostring(value or "Standard"):match("([^.]+)$"))
end

local function ByName(a, b)
    return (a.name or a.id or ""):lower() < (b.name or b.id or ""):lower()
end

local function SortedCopy(items)
    local result = {}
    for _, item in ipairs(items or {}) do table.insert(result, item) end
    table.sort(result, ByName)
    return result
end

local function DrawControls()
    Buttons.Dropdown("Inventory Action", State.Action, State.Actions, "Choose whether selecting an item adds it to or removes it from your inventory.")
    Buttons.Int("Quantity", State.Quantity, "Amount applied each time you select an item.")
end

local function SubmitItemInfo(item, category, group)
    SidePanel.SubmitInfo("item-record", {
        Eyebrow = "ITEM DATABASE",
        Title = item.name or item.id or "Unknown Item",
        Rows = {
            { Label = "Category", Value = category or "Other" },
            { Label = "Group", Value = Friendly(group) },
            { Label = "Quality", Value = QualityName(item.quality) },
            { Label = "Owned", Value = tostring(State.GetOwned(item.id)) },
            { Label = "Action", Value = State.GetAction() .. " " .. tostring(State.Quantity.value) }
        },
        Description = item.id
    }, { Width = 320 })
end

local function DrawItem(item, category, group, right)
    local _, data = Buttons.OptionExtended(item.name or item.id, "", right or State.GetSummary(),
        "Apply the selected inventory action to this item.", function() State.Apply(item) end)
    if data and data.Visible and (data.Selected or data.Hovered) then SubmitItemInfo(item, category, group) end
end

local function BuildQualities(items)
    local qualities = {}
    local seen = {}
    for _, item in ipairs(items) do
        local name = QualityName(item.quality)
        if name ~= "Standard" and not seen[name] then
            seen[name] = true
            table.insert(qualities, name)
        end
    end
    table.sort(qualities)
    table.insert(qualities, 1, "All")
    return qualities
end

local function ItemListView(list)
    s_Quality.index = math.min(s_Quality.index or 1, #list.Qualities)

    DrawControls()
    Buttons.Dropdown("Quality", s_Quality, list.Qualities, "Limit this list to a specific item quality.")
    Buttons.Toggle("Craftable Only", s_CraftableOnly, "Only show records marked as craftable.")

    local quality = list.Qualities[s_Quality.index or 1]
    local visible = {}
    for _, item in ipairs(list.Items) do
        if (quality == "All" or QualityName(item.quality) == quality) and (not s_CraftableOnly.value or item.isCraftable) then
            table.insert(visible, item)
        end
    end

    Buttons.Break(Friendly(list.Group) .. "  /  " .. tostring(#visible))
    for _, item in ipairs(visible) do DrawItem(item, list.Category, list.Group, QualityName(item.quality)) end
end

local function BuildGroup(group, categorized)
    local merged = {}
    for _, key in ipairs(group.Keys) do
        for name, items in pairs(categorized[key] or {}) do
            merged[name] = merged[name] or {}
            for _, item in ipairs(items) do table.insert(merged[name], item) end
        end
    end

    local lists = {}
    local total = 0
    for name, items in pairs(merged) do
        if #items > 0 then
            local list = { Category = group.Name, Group = name, Items = SortedCopy(items), Qualities = BuildQualities(items) }
            list.Menu = Submenu.Create(Friendly(name), function() ItemListView(list) end)
            table.insert(lists, list)
            total = total + #items
        end
    end
    table.sort(lists, function(a, b) return Friendly(a.Group) < Friendly(b.Group) end)

    return {
        Group = group,
        Lists = lists,
        Total = total,
        Menu = Submenu.Create(group.Name, function()
            for _, list in ipairs(lists) do
                Buttons.Submenu(Friendly(list.Group), list.Menu, tostring(#list.Items) .. " available items")
            end
        end)
    }
end

local function BuildCatalog(force)
    if force or #GeneralLoader:GetAll() == 0 then GeneralLoader:LoadAll() end

    local categorized = GeneralLoader:Categorize()
    s_Catalog = {}
    for _, group in ipairs(CATEGORY_GROUPS) do
        local built = BuildGroup(group, categorized)
        if built.Total > 0 then table.insert(s_Catalog, built) end
    end
    s_SearchTerm = nil
end

local function CatalogView()
    for _, entry in ipairs(s_Catalog or {}) do
        Buttons.Submenu(entry.Group.Name, entry.Menu, entry.Group.Tip)
    end
end

local function UpdateSearch(term)
    if term == s_SearchTerm then return end
    s_SearchTerm = term
    s_SearchResults = {}
    if term == "" then return end

    for _, item in ipairs(GeneralLoader:GetAll()) do
        if (item.name or ""):lower():find(term, 1, true) or (item.id or ""):lower():find(term, 1, true) then
            table.insert(s_SearchResults, item)
        end
    end
    table.sort(s_SearchResults, ByName)
end

local function SearchView()
    DrawControls()
    Buttons.Text("Search Name or Item ID", s_Search, "Searches both the display name and the internal item ID.")

    local term = (s_Search.value or ""):lower()
    UpdateSearch(term)

    Buttons.Break(term == "" and "Enter a name or item ID" or (tostring(#s_SearchResults) .. " Results"))
    for index, item in ipairs(s_SearchResults) do
        if index > SEARCH_LIMIT then break end
        DrawItem(item, "Search", "Results", QualityName(item.quality))
    end
end

local function InventoryView()
    DrawControls()
    Buttons.Option("Refresh Inventory", "Refresh item quantities from your current inventory.", function()
        State.RefreshInventory()
        Notification.Info("Inventory refreshed", 2)
    end)

    local owned = State.GetInventory()
    Buttons.Break("Owned Items  /  " .. tostring(#owned))
    for _, entry in ipairs(owned) do
        local item = GeneralLoader:GetById(entry.id) or entry
        DrawItem(item, "Inventory", "Owned", "x" .. tostring(entry.quantity or 1))
    end
end

local CatalogMenu = Submenu.Create("Item Catalog", CatalogView)
local SearchMenu = Submenu.Create("Search Items", SearchView)
local InventoryMenu = Submenu.Create("My Inventory", InventoryView)

local function QuickAdd(label, tipText, give, message)
    Buttons.OptionExtended(label, "", "+" .. tostring(State.Quantity.value), tipText, function()
        give(State.Quantity.value)
        State.RefreshInventory()
        Notification.Success(message, 2)
    end)
end

local function ItemBrowserView()
    if not s_Catalog then BuildCatalog(false) end

    Buttons.Submenu("Essentials", ItemsView, "Quick kits, crafting components, consumables, buffs, and recipes.")
    Buttons.Submenu("Browse Catalog", CatalogMenu, "Browse a curated item catalog by purpose and type.")
    Buttons.Submenu("Search Items", SearchMenu, "Find an item by its display name or internal ID.")
    Buttons.Submenu("My Inventory", InventoryMenu, "Review, add, or remove items you currently own.", function()
        State.Action.index = 2
        State.RefreshInventory()
    end)
    DrawControls()

    Buttons.Break("Quick Add")
    QuickAdd("Crafting Component Kit", "Add every standard crafting component using the selected quantity.", Items.Actions.GiveAllCraftingComponents, "Crafting component kit added")
    QuickAdd("MaxDoc Kit", "Add every MaxDoc tier using the selected quantity.", Items.Actions.GiveMaxDocs, "MaxDoc kit added")

    Buttons.Break("Database")
    Buttons.Option("Reload Item Database", "Rebuild the item catalog from the current game records.", function()
        BuildCatalog(true)
        State.RefreshInventory()
        Notification.Success("Item database reloaded", 2)
    end)
end

return Submenu.Create("Items", ItemBrowserView)
