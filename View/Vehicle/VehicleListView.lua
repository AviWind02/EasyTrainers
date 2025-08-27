local Draw = require("UI")
local Logger = require("Core/Logger")
local VehicleLoader = require("Features/DataExtractors/VehicleLoader")

local VehicleFeatures = require("Features/Vehicle")
local VehicleSystem = VehicleFeatures.VehicleUnlocker
local VehicleSpawner = VehicleFeatures.Spawner

local Buttons = Draw.Buttons

local filterModes = {
    L("vehiclelist.mode_all"),
    L("vehiclelist.mode_player"),
    L("vehiclelist.mode_category"),
    L("vehiclelist.mode_manufacturer"),
    L("vehiclelist.mode_affiliation")
}

local productionYearsList = { L("vehiclelist.year_all") }
local visibilityModes = {
    L("vehiclelist.visibility_all"),
    L("vehiclelist.visibility_unlocked"),
    L("vehiclelist.visibility_locked")
}

local categoryOrder = {
    ["Add-On Vehicles(Modded)"] = 1,
    ["Hypercars"] = 2,
    ["Sports Cars"] = 3,
    ["Motorcycles"] = 4,
    ["Police/Emergency"] = 5,
    ["Corpo"] = 6,
    ["Pickups & SUVs"] = 7,
    ["Vans & Couriers"] = 8,
    ["Compacts"] = 9,
    ["Utility"] = 10,
    ["Special"] = 11
}

local selectedVisibility = { index = 1, expanded = false }
local selectedProductionYear = { index = 1, expanded = false }
local selectedMode = { index = 3, expanded = false }
local selectedValue = ""
local initialized = false

local categories, manufacturers, affiliations = {}, {}, {}
local vehicleSpawnDis = { value = 7.0, min = 3.0, max = 25.0, step = 0.5 }

local function BuildFilters()
    categories, manufacturers, affiliations = {}, {}, {}
    productionYearsList = { L("vehiclelist.year_all") }

    local seenCat, seenMan, seenAff, seenYears = {}, {}, {}, {}

    for _, vehicle in ipairs(VehicleLoader:GetAll()) do
        if vehicle.category and not seenCat[vehicle.category] then
            seenCat[vehicle.category] = true
            table.insert(categories, vehicle.category)
        end
        if vehicle.manufacturer and not seenMan[vehicle.manufacturer] then
            seenMan[vehicle.manufacturer] = true
            table.insert(manufacturers, vehicle.manufacturer)
        end
        if vehicle.faction and not seenAff[vehicle.faction] then
            seenAff[vehicle.faction] = true
            table.insert(affiliations, vehicle.faction)
        end

        local yearStr = vehicle.productionYear
        if yearStr and yearStr:match("^%d+$") then
            local year = tonumber(yearStr)
            if not seenYears[year] then
                seenYears[year] = true
                table.insert(productionYearsList, year)
            end
        end
    end

    table.sort(productionYearsList, function(a, b)
        if a == L("vehiclelist.year_all") then return true end
        if b == L("vehiclelist.year_all") then return false end
        return a < b
    end)

    table.sort(categories, function(a, b)
        local pa = categoryOrder[a] or 999
        local pb = categoryOrder[b] or 999
        if pa == pb then
            return a < b
        end
        return pa < pb
    end)

    -- table.sort(categories)

    table.sort(manufacturers)
    table.sort(affiliations)
end

local function DrawVehicleRow(vehicle)
    local detailsTip = tip("vehiclelist.vehicledetails", {
        id = vehicle.id,
        manufacturer = vehicle.manufacturer or "Unknown",
        category = vehicle.category or "Unknown",
        faction = vehicle.faction or "Unknown",
        year = vehicle.productionYear or "Unknown",
        description = vehicle.description or "None"
    })

    if VehicleFeatures.enableVehicleSpawnerMode then
        Buttons.Option(vehicle.displayName, tip("vehiclelist.spawntip", { details = detailsTip }), function()
            VehicleSpawner.RequestVehicle(vehicle.id, vehicleSpawnDis.value)
        end)
    else
        local state = { value = VehicleSystem.IsVehicleUnlocked(vehicle.id) }
        Buttons.GhostToggle(vehicle.displayName, state, tip("vehiclelist.unlockedtip", { details = detailsTip }), function()
            local current = VehicleSystem.IsVehicleUnlocked(vehicle.id)
            VehicleSystem.SetPlayerVehicleState(vehicle.id, not current)
        end)
    end
end

local function YearMatches(vehicleYearStr, selectedYear)
    if selectedYear == L("vehiclelist.year_all") or not vehicleYearStr then return true end
    local selected = tonumber(selectedYear)
    if not selected then return false end

    local startY, endY = vehicleYearStr:match("^(%d+)%D+(%d+)$")
    local exactY = vehicleYearStr:match("^(%d+)$")
    if exactY and tonumber(exactY) == selected then return true end
    if startY and endY then
        local s, e = tonumber(startY), tonumber(endY)
        return selected >= s and selected <= e
    end
    return false
end

local function VehicleFilteredSubmenuView()
    local mode = filterModes[selectedMode.index or 1]

    local selectedYear = productionYearsList[selectedProductionYear.index or 1]
    local visibilityFilter = visibilityModes[selectedVisibility.index or 1]

    local vehicles = VehicleLoader:Filter(function(v)
        if mode == L("vehiclelist.mode_player") and v.faction ~= "Player" then return false end
        if mode == L("vehiclelist.mode_category") and v.category ~= selectedValue then return false end
        if mode == L("vehiclelist.mode_manufacturer") and v.manufacturer ~= selectedValue then return false end
        if mode == L("vehiclelist.mode_affiliation") and v.faction ~= selectedValue then return false end
        if not YearMatches(v.productionYear, selectedYear) then return false end

        local isUnlocked = VehicleSystem.IsVehicleUnlocked(v.id)
        if visibilityFilter == L("vehiclelist.visibility_unlocked") and not isUnlocked then return false end
        if visibilityFilter == L("vehiclelist.visibility_locked") and isUnlocked then return false end

        return true
    end)

    if #vehicles == 0 then
        Buttons.Break("", L("vehiclelist.nofound.label"))
        return
    end

    table.sort(vehicles, function(a, b)
        return (a.displayName or ""):lower() < (b.displayName or ""):lower()
    end)

    for _, vehicle in ipairs(vehicles) do
        DrawVehicleRow(vehicle)
    end
end

local filteredSubmenu = {
    title = L("vehiclelist.filteredlist.label"),
    view = VehicleFilteredSubmenuView
}

local function VehicleMainView()
    if not initialized then
        BuildFilters()
        initialized = true
    end

    Buttons.Dropdown(L("vehiclelist.mode.label"), selectedMode, filterModes, L("vehiclelist.mode.tip"))
    Buttons.StringCycler(L("vehiclelist.year.label"), selectedProductionYear, productionYearsList,
        tip("vehiclelist.year.tip"))
    Buttons.Dropdown(L("vehiclelist.visibility.label"), selectedVisibility, visibilityModes,
        L("vehiclelist.visibility.tip"))
    if VehicleFeatures.enableVehicleSpawnerMode then
        Buttons.Int(L("vehiclelist.spawndistance.label"), vehicleSpawnDis, L("vehiclelist.spawndistance.tip"))
    end
    Buttons.Break("", L("vehiclelist.filteredlist.label"))

    local mode = filterModes[selectedMode.index or 1]
    local list, labelPrefix
    if mode == L("vehiclelist.mode_category") then
        list, labelPrefix = categories, L("vehiclelist.categoryprefix")
    elseif mode == L("vehiclelist.mode_manufacturer") then
        list, labelPrefix = manufacturers, L("vehiclelist.manufacturerprefix")
    elseif mode == L("vehiclelist.mode_affiliation") then
        list, labelPrefix = affiliations, L("vehiclelist.affiliationprefix")
    end

    if list then
        for _, value in ipairs(list) do
            Buttons.Submenu(value, filteredSubmenu, labelPrefix:gsub("{value}", value), function()
                selectedValue = value
            end)
        end
    else
        VehicleFilteredSubmenuView()
    end
end

return {
    title = "vehiclelist.title",
    view = VehicleMainView
}
