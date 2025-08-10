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


local selectedVisibility = { index = 1, expanded = false }
local selectedProductionYear = { index = 1, expanded = false }
local selectedMode = { index = 2, expanded = false }
local selectedValue = ""
local initialized = false

local categories = {}
local manufacturers = {}
local affiliations = {}
local vehicleSpawnDis = { value = 7.0, min = 3.0, max = 25.0, step = 0.5 }

local filterModes = {}
local lastSpawnerMode = nil
-- Temporarily adding this to only show vehicle players that can be unlockable since it was causing issues with Twintone


local function BuildFilters()
    categories = {}
    manufacturers = {}
    affiliations = {}
    productionYearsList = { L("vehiclelist.year_all") }

    local seenCat, seenMan, seenAff = {}, {}, {}
    local seenYears = {}

    for _, vehicle in ipairs(VehicleLoader:GetAll()) do
        -- In unlock mode, skip non-player vehicles entirely
        if VehicleFeatures.enableVehicleSpawnerMode or vehicle.faction == "Player" then
            if not seenCat[vehicle.category] then
                seenCat[vehicle.category] = true
                table.insert(categories, vehicle.category)
            end
            if vehicle.manufacturer and not seenMan[vehicle.manufacturer] then
                seenMan[vehicle.manufacturer] = true
                table.insert(manufacturers, vehicle.manufacturer)
            end
            if vehicle.faction and vehicle.faction ~= "Player" and not seenAff[vehicle.faction] then
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
    end

    table.sort(productionYearsList, function(a, b)
        if a == L("vehiclelist.year_all") then return true end
        if b == L("vehiclelist.year_all") then return false end
        return a < b
    end)

    table.sort(categories)
    table.sort(manufacturers)
    table.sort(affiliations)
end


local function BuildFilterModes()
    filterModes = {}
    BuildFilters()
    if VehicleFeatures.enableVehicleSpawnerMode then
        table.insert(filterModes, L("vehiclelist.mode_all"))
        table.insert(filterModes, L("vehiclelist.mode_player"))
    else
        table.insert(filterModes, L("vehiclelist.mode_all"))
    end
    if #categories > 0 then
        table.insert(filterModes, L("vehiclelist.mode_category"))
    end
    if #manufacturers > 0 then
        table.insert(filterModes, L("vehiclelist.mode_manufacturer"))
    end
    if #affiliations > 0 then
        table.insert(filterModes, L("vehiclelist.mode_affiliation"))
    end
end



local function DrawVehicleRow(vehicle)
    local name = vehicle.displayName
    local detailsTip = tip("vehiclelist.vehicledetails", {
        id = vehicle.id,
        manufacturer = vehicle.manufacturer or "Unknown",
        category = vehicle.category or "Unknown",
        faction = vehicle.faction or "Unknown",
        year = vehicle.productionYear or "Unknown",
        description = vehicle.description or "None"
    })

    if VehicleFeatures.enableVehicleSpawnerMode then
        Buttons.Option(name, tip("vehiclelist.spawntip", { details = detailsTip }), function()
            VehicleSpawner.RequestVehicle(vehicle.id, vehicleSpawnDis.value)
        end)
    else
        local state = { value = VehicleSystem.IsVehicleUnlocked(vehicle.id) }
        Buttons.Toggle(name, state, tip("vehiclelist.unlockedtip", { details = detailsTip }), function()
            local current = VehicleSystem.IsVehicleUnlocked(vehicle.id)
            VehicleSystem.SetPlayerVehicleState(vehicle.id, not current)
        end)
    end
end

local function YearMatches(vehicleYearStr, selectedYear)
    if selectedYear == L("vehiclelist.year_all") or not vehicleYearStr then
        return true
    end

    local selected = tonumber(selectedYear)
    if not selected then return false end

    local startY, endY = vehicleYearStr:match("^(%d+)%D+(%d+)$")
    local exactY = vehicleYearStr:match("^(%d+)$")

    if exactY and tonumber(exactY) == selected then
        return true
    elseif startY and endY then
        local s = tonumber(startY)
        local e = tonumber(endY)
        return selected >= s and selected <= e
    end

    return false
end

local function VehicleFilteredSubmenuView()
    local mode = filterModes[selectedMode.index or 1]

    if mode ~= L("vehiclelist.mode_all") and mode ~= L("vehiclelist.mode_player") then
        -- Buttons.Dropdown(L("vehiclelist.year.label"), selectedProductionYear, productionYearsList, L("vehiclelist.year.tip"))
        Buttons.StringCycler(L("vehiclelist.year.label"), selectedProductionYear, productionYearsList,
            tip("vehiclelist.year.tip"))
        Buttons.Dropdown(L("vehiclelist.visibility.label"), selectedVisibility, visibilityModes,
            L("vehiclelist.visibility.tip"))
        if VehicleFeatures.enableVehicleSpawnerMode then
            Buttons.Int(L("vehiclelist.spawndistance.label"), vehicleSpawnDis, L("vehiclelist.spawndistance.tip"))
        end
        Buttons.Break("", L("vehiclelist.filteredlist.label"))
    end

    local selectedYear = productionYearsList[selectedProductionYear.index or 1]
    local visibilityFilter = visibilityModes[selectedVisibility.index or 1]

    local vehicles = VehicleLoader:Filter(function(v)
        if not VehicleFeatures.enableVehicleSpawnerMode and v.faction ~= "Player" then
            return false
        end

        if mode == L("vehiclelist.mode_player") and v.faction ~= "Player" then
            return false
        end
        if mode == L("vehiclelist.mode_category") and v.category ~= selectedValue then
            return false
        end
        if mode == L("vehiclelist.mode_manufacturer") and v.manufacturer ~= selectedValue then
            return false
        end
        if mode == L("vehiclelist.mode_affiliation") and v.faction ~= selectedValue then
            return false
        end
        if not YearMatches(v.productionYear, productionYearsList[selectedProductionYear.index or 1]) then
            return false
        end

        local isUnlocked = VehicleSystem.IsVehicleUnlocked(v.id)
        if visibilityFilter == L("vehiclelist.visibility_unlocked") and not isUnlocked then return false end
        if visibilityFilter == L("vehiclelist.visibility_locked") and isUnlocked then return false end

        return true
    end)

    if #vehicles == 0 then
        Buttons.Break("", L("vehiclelist.nofound.label"))
        return
    end

    for _, vehicle in ipairs(vehicles) do
        DrawVehicleRow(vehicle)
    end
end

local filteredSubmenu = {
    title = L("vehiclelist.filteredlist.label"),
    view = VehicleFilteredSubmenuView
}

local function VehicleMainView()
    local currentMode = VehicleFeatures.enableVehicleSpawnerMode
    if lastSpawnerMode ~= currentMode then
        BuildFilterModes()
        selectedMode.index = currentMode and 2 or 1
        lastSpawnerMode = currentMode
    end

    if not initialized then
        BuildFilters()
        initialized = true
    end

    Buttons.Dropdown(L("vehiclelist.mode.label"), selectedMode, filterModes, L("vehiclelist.mode.tip"))

    local mode = filterModes[selectedMode.index or 1]
    if mode == L("vehiclelist.mode_all") or mode == L("vehiclelist.mode_player") then
        --Buttons.Dropdown(L("vehiclelist.year.label"), selectedProductionYear, productionYearsList, L("vehiclelist.year.tip"))
        Buttons.StringCycler(L("vehiclelist.year.label"), selectedProductionYear, productionYearsList,
            tip("vehiclelist.year.tip"))

        Buttons.Dropdown(L("vehiclelist.visibility.label"), selectedVisibility, visibilityModes,
            L("vehiclelist.visibility.tip"))
        if VehicleFeatures.enableVehicleSpawnerMode then
            Buttons.Int(L("vehiclelist.spawndistance.label"), vehicleSpawnDis, L("vehiclelist.spawndistance.tip"))
        end
        Buttons.Break("", L("vehiclelist.filteredlist.label"))
    end

    local list, labelPrefix
    if mode == L("vehiclelist.mode_category") then
        list = categories
        labelPrefix = L("vehiclelist.categoryprefix")
    elseif mode == L("vehiclelist.mode_manufacturer") then
        list = manufacturers
        labelPrefix = L("vehiclelist.manufacturerprefix")
    elseif mode == L("vehiclelist.mode_affiliation") then
        list = affiliations
        labelPrefix = L("vehiclelist.affiliationprefix")
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
