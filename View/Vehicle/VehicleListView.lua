local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local SidePanel = require("UI/Panels/SidePanel/SidePanel")
local Notification = require("UI/Panels/Notification/Notification")
local VehicleLoader = require("Utils/DataExtractors/VehicleLoader")
local Vehicles = require("Features/Vehicles")

local Spawning = Vehicles.VehicleSpawning
local Unlocking = Vehicles.VehicleUnlocking
local Preview = Vehicles.VehiclePreview
local ViewState = Vehicles.ViewStates

local VISIBILITY_OPTIONS = { "All Vehicles", "Unlocked Only", "Locked Only" }

local CLASS_ORDER = {
    ["Hypercars"] = 1,
    ["Sports"] = 2,
    ["Motorcycles"] = 3,
    ["Executive"] = 4,
    ["Economy"] = 5,
    ["SUV & Off-Road"] = 6,
    ["Utility & Pickups"] = 7,
    ["Police & Emergency"] = 8,
    ["Heavy & Special"] = 9,
    ["Other"] = 10
}

local s_Visibility = { index = 1 }
local s_SpawnDistance = { value = 7.0, min = 3.0, max = 25.0, step = 0.5 }
local s_Search = { value = "", capturing = false }
local s_Variants = {}
local s_DetailMenus = {}
local s_Unlocked = {}
local s_ListCache = {}
local s_GarageRefs = {}

local function InvalidateLists()
    s_ListCache = {}
end

local function IsUnlocked(id)
    if s_Unlocked[id] == nil then s_Unlocked[id] = Unlocking.IsUnlocked(id) end
    return s_Unlocked[id]
end

local function GarageRef(id)
    local ref = s_GarageRefs[id] or {}
    ref.value = IsUnlocked(id)
    s_GarageRefs[id] = ref
    return ref
end

local function SetGarageAccess(id, enabled)
    Unlocking.SetPlayerVehicleState(id, enabled)
    s_Unlocked[id] = enabled
    InvalidateLists()
end

local function VariantRef(vehicle)
    s_Variants[vehicle.id] = s_Variants[vehicle.id] or { index = 1 }
    return s_Variants[vehicle.id]
end

local function SelectedVehicle(vehicle)
    local index = VariantRef(vehicle).index or 1
    local id = index == 1 and vehicle.id or vehicle.variants[index - 1]
    return VehicleLoader:GetById(id) or vehicle, id
end

local function CleanDescription(value)
    return (tostring(value or "No description available."):gsub('\\"', '"'):gsub("\\n", " "):gsub("\n", " "))
end

local function SubmitVehicleInfo(vehicle)
    local selected = SelectedVehicle(vehicle)
    SidePanel.SubmitInfo("vehicle-record", {
        Eyebrow = vehicle.isModded and "ADD-ON VEHICLE" or "AUTOMOTIVE DATABASE",
        Title = selected.displayName or vehicle.displayName,
        Rows = {
            { Label = "Manufacturer", Value = selected.manufacturer or vehicle.manufacturer or "Unknown" },
            { Label = "Class", Value = selected.category or vehicle.category or "Other" },
            { Label = "Year", Value = selected.productionYear or vehicle.productionYear or "Unknown" },
            { Label = "Power", Value = selected.horsepower and tostring(math.floor(selected.horsepower)) .. " hp" or "Unknown" },
            { Label = "Mass", Value = selected.mass and tostring(math.floor(selected.mass)) or "Unknown" },
            { Label = "Drive", Value = selected.driveLayout or vehicle.driveLayout or "Unknown" },
            { Label = "Source", Value = vehicle.source or "Base Game" },
            { Label = "Variants", Value = tostring(1 + #(vehicle.variants or {})) }
        },
        Description = CleanDescription(selected.description or vehicle.description)
    }, { Width = 330 })
end

local function VariantOptions(vehicle)
    local options = { vehicle.displayName }
    for _, id in ipairs(vehicle.variants or {}) do
        local variant = VehicleLoader:GetById(id)
        table.insert(options, variant and variant.displayName or id)
    end
    return options
end

local function SpawnSelected(vehicle)
    local selected, id = SelectedVehicle(vehicle)
    Preview.SetActive(false)
    if Spawning.SpawnVehicle(id, s_SpawnDistance.value, ViewState.MountOnSpawn.value, ViewState.DeleteLastVehicle.value) then
        Notification.Success("Spawned " .. (selected.displayName or vehicle.displayName), 2)
    end
end

local function ShowPreview(vehicle)
    if not ViewState.PreviewVehicle.value then return end
    local _, id = SelectedVehicle(vehicle)
    Preview.SetActive(true)
    Preview.Spawn(id)
end

local function OnFocus(data, vehicle)
    if not data or not data.Visible or not (data.Selected or data.Hovered) then return end
    SubmitVehicleInfo(vehicle)
    ShowPreview(vehicle)
end

local function DetailView(vehicle)
    Buttons.Dropdown("Vehicle Variant", VariantRef(vehicle), VariantOptions(vehicle), "Choose which appearance or dealer variant to use.")

    if ViewState.SpawnerMode then
        Buttons.Option("Spawn Selected Vehicle", "Spawn the selected variant near the player.", function() SpawnSelected(vehicle) end)
        Buttons.Option("Preview Selected Vehicle", "Show the selected variant in the world preview.", function() ShowPreview(vehicle) end)
    else
        local _, id = SelectedVehicle(vehicle)
        Buttons.GhostToggle("Garage Access", GarageRef(id), "Add or remove the selected variant from your garage.", function(value)
            SetGarageAccess(id, value)
        end)
    end

    SubmitVehicleInfo(vehicle)
end

local function DetailMenu(vehicle)
    s_DetailMenus[vehicle.id] = s_DetailMenus[vehicle.id] or Submenu.Create(vehicle.displayName, function() DetailView(vehicle) end)
    return s_DetailMenus[vehicle.id]
end

local function DrawVehicle(vehicle)
    if #(vehicle.variants or {}) > 0 then
        local _, data = Buttons.Submenu(vehicle.displayName, DetailMenu(vehicle), tostring(1 + #vehicle.variants) .. " variants available")
        OnFocus(data, vehicle)
        return
    end

    local data
    if ViewState.SpawnerMode then
        data = select(2, Buttons.OptionExtended(vehicle.displayName, "", "SPAWN", "Spawn this vehicle near the player.", function()
            SpawnSelected(vehicle)
        end))
    else
        data = select(2, Buttons.GhostToggle(vehicle.displayName, GarageRef(vehicle.id), "Toggle whether this vehicle appears in your garage.", function(value)
            SetGarageAccess(vehicle.id, value)
        end))
    end
    OnFocus(data, vehicle)
end

local function VisibilityMatches(vehicle)
    if ViewState.SpawnerMode then return true end
    local mode = VISIBILITY_OPTIONS[s_Visibility.index or 1]
    if mode == "Unlocked Only" then return IsUnlocked(vehicle.id) end
    if mode == "Locked Only" then return not IsUnlocked(vehicle.id) end
    return true
end

local function BuildList(predicate)
    local vehicles = {}
    for _, vehicle in ipairs(VehicleLoader:GetBrowsable()) do
        if (not predicate or predicate(vehicle)) and VisibilityMatches(vehicle) then table.insert(vehicles, vehicle) end
    end
    table.sort(vehicles, function(a, b) return (a.displayName or a.id):lower() < (b.displayName or b.id):lower() end)
    return vehicles
end

local function CachedList(key, predicate)
    local cacheKey = table.concat({ key, tostring(ViewState.SpawnerMode), tostring(s_Visibility.index) }, "|")
    s_ListCache[cacheKey] = s_ListCache[cacheKey] or BuildList(predicate)
    return s_ListCache[cacheKey]
end

local function DrawList(title, predicate, cacheKey)
    Buttons.Toggle("Vehicle Preview", ViewState.PreviewVehicle, "Preview the currently focused vehicle in front of the player.")
    if not ViewState.SpawnerMode then
        Buttons.Dropdown("Garage Filter", s_Visibility, VISIBILITY_OPTIONS, "Show all, unlocked, or locked vehicles.")
    end

    local vehicles = CachedList(cacheKey or title, predicate)
    Buttons.Break(title .. "  /  " .. tostring(#vehicles))

    if #vehicles == 0 then
        Buttons.Option("No Matching Vehicles", "Adjust the current filter or refresh the vehicle database.")
        return
    end

    for _, vehicle in ipairs(vehicles) do DrawVehicle(vehicle) end
end

local function ListMenu(title, predicate)
    return Submenu.Create(title, function() DrawList(title, predicate) end)
end

local function GroupValues(field)
    local counts = {}
    for _, vehicle in ipairs(VehicleLoader:GetBrowsable()) do
        local value = vehicle[field] or "Unknown"
        counts[value] = (counts[value] or 0) + 1
    end

    local values = {}
    for value in pairs(counts) do table.insert(values, value) end
    table.sort(values, function(a, b)
        if field == "category" then
            local first, second = CLASS_ORDER[a] or 999, CLASS_ORDER[b] or 999
            if first ~= second then return first < second end
        end
        return a < b
    end)
    return values, counts
end

local function GroupMenu(title, field)
    local menus = {}
    local values, counts = nil, nil

    return Submenu.Create(title, function()
        if not values then values, counts = GroupValues(field) end
        for _, value in ipairs(values) do
            menus[value] = menus[value] or ListMenu(value, function(vehicle) return (vehicle[field] or "Unknown") == value end)
            Buttons.Submenu(value .. "  [" .. tostring(counts[value]) .. "]", menus[value], "Browse vehicles in " .. value .. ".")
        end
    end)
end

local function MatchesSearch(vehicle, term)
    return (vehicle.displayName or ""):lower():find(term, 1, true)
        or (vehicle.manufacturer or ""):lower():find(term, 1, true)
        or (vehicle.id or ""):lower():find(term, 1, true)
end

local function SearchView()
    Buttons.Text("Search Vehicles", s_Search, "Search by vehicle name, manufacturer, or internal ID.")
    local term = (s_Search.value or ""):lower()
    DrawList("Search Results", function(vehicle)
        return term ~= "" and MatchesSearch(vehicle, term)
    end, "search:" .. term)
end

local NAVIGATION = {
    { Label = "All Vehicles", Menu = ListMenu("All Vehicles"), Tip = "Browse the complete vehicle database." },
    { Label = "By Class", Menu = GroupMenu("Vehicle Classes", "category"), Tip = "Browse vehicle classes such as hypercars, sports, bikes, and utility." },
    { Label = "By Manufacturer", Menu = GroupMenu("Manufacturers", "manufacturer"), Tip = "Browse vehicles by manufacturer." },
    { Label = "By Affiliation", Menu = GroupMenu("Affiliations", "faction"), Tip = "Browse faction, police, corpo, and player vehicles." },
    {
        Label = "Player Vehicles",
        Menu = ListMenu("Player Vehicles", function(vehicle)
            return vehicle.faction == "Player" or vehicle.id:lower():find("_player", 1, true) ~= nil
        end),
        Tip = "Browse vehicles intended for the player garage."
    },
    { Label = "Add-On Vehicles", Menu = ListMenu("Add-On Vehicles", function(vehicle) return vehicle.isModded end), Tip = "Browse vehicles installed by other mods." },
    { Label = "Search Vehicles", Menu = Submenu.Create("Search Vehicles", SearchView), Tip = "Find a vehicle by name, manufacturer, or ID." }
}

local function ReloadDatabase()
    VehicleLoader:LoadAll()
    s_Unlocked = {}
    InvalidateLists()
    Notification.Success("Vehicle database reloaded", 2)
end

local function VehicleListView()
    Preview.SetActive(false)

    for _, entry in ipairs(NAVIGATION) do
        Buttons.Submenu(entry.Label, entry.Menu, entry.Tip, function()
            s_Unlocked = {}
            InvalidateLists()
        end)
    end

    Buttons.Break(ViewState.SpawnerMode and "Vehicle Spawner" or "Garage Manager")
    if ViewState.SpawnerMode then
        Buttons.Int("Spawn Distance", s_SpawnDistance, "Distance in front of the player used for spawning.")
        Buttons.Toggle("Delete Previous Vehicle", ViewState.DeleteLastVehicle, "Delete the previous spawned vehicle after spawning a new one.")
        Buttons.Toggle("Mount on Spawn", ViewState.MountOnSpawn, "Automatically enter the driver seat after spawning.")
    end
    Buttons.Toggle("Vehicle Preview", ViewState.PreviewVehicle, "Preview the focused vehicle before spawning or unlocking it.")
    Buttons.Option("Reload Vehicle Database", "Reload vehicle and add-on records from TweakDB.", ReloadDatabase)
end

return Submenu.Create("Vehicles", VehicleListView)
