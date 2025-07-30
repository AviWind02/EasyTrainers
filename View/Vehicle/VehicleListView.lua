local Draw = require("UI")
local Logger = require("Core/Logger")
local VehicleLoader = require("Features/DataExtractors/VehicleLoader")

local VehicleFeaures = require("Features/Vehicle")
local VehicleSystem = VehicleFeaures.VehicleUnlocker
local VehicleSpawner = VehicleFeaures.Spawner

local VehicleListView = {}

local Buttons = Draw.Buttons

local filterModes = {
    "All Vehicles",
    "Player Vehicles",
    "By Category",
    "By Manufacturer",
    "By Affiliation"
}
local productionYearsList = { "All Years" }
local visibilityModes = {
    "All Vehicles",
    "Unlocked Only",
    "Locked Only"
}

local filterModeTip = "Filter Modes:\n" ..
"- All Vehicles: Shows all vehicles (Can be laggy)\n" ..
"- Player Vehicles: Classified as player-ownable\n" ..
"- By Category: Filter by vehicle category\n" ..
"- By Manufacturer: Filter by vehicle brand\n" ..
"- By Affiliation: Filter by faction or group"

local selectedVisibility = { index = 1, expanded = false }
local selectedProductionYear = { index = 1, expanded = false }
local selectedMode = { index = 2, expanded = false }
local selectedValue = ""
local initialized = false

local categories = {}
local manufacturers = {}
local affiliations = {}
local vehicleSpawnDis = { value = 7.0, min = 3.0, max = 25.0, step = 0.5 }

local function BuildFilters()
    local seenCat, seenMan, seenAff = {}, {}, {}
    for _, vehicle in ipairs(VehicleLoader:GetAll()) do
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
    end

    local seenYears = {}

    for _, vehicle in ipairs(VehicleLoader:GetAll()) do
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
        if a == "All Years" then return true end
        if b == "All Years" then return false end
        return a < b
    end)



    table.sort(categories)
    table.sort(manufacturers)
    table.sort(affiliations)
end


local function DrawVehicleRow(vehicle)
    local name = vehicle.displayName

    local tip = table.concat({
        "TweakDBID: " .. vehicle.id,
        "Manufacturer: " .. (vehicle.manufacturer or "Unknown"),
        "Category: " .. (vehicle.category or "Unknown"),
        "Affiliation: " .. (vehicle.faction or "Unknown"),
        "Production Year: " .. (vehicle.productionYear or "Unknown"),
        "Description: " .. (vehicle.description or "None")
    }, "\n")

    if VehicleFeaures.enableVehicleSpawnerMode then
        local spawnTip = "Note: You may need to click twice to request the vehicle.\n\n" .. tip 
        Buttons.Option(name, spawnTip, function()
            VehicleSpawner.RequestVehicle(vehicle.id, vehicleSpawnDis.value)
        end)
    else
        local state = { value = VehicleSystem.IsVehicleUnlocked(vehicle.id) }
        local unlockTip = "Note: Enabled vehicles are unlocked and appear in your owned menu. Click to toggle them on or off.\n\n" .. tip

        local function onClick()
            local current = VehicleSystem.IsVehicleUnlocked(vehicle.id)
            VehicleSystem.SetPlayerVehicleState(vehicle.id, not current)
        end

        Buttons.Toggle(name, state, unlockTip, onClick)
    end
end


local function YearMatches(vehicleYearStr, selectedYear)
    if selectedYear == "All Years" or not vehicleYearStr then
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

    -- Only show dropdowns here for filtered modes

    
   

    if mode ~= "All Vehicles" and mode ~= "Player Vehicles" then
        Buttons.Dropdown("Year", selectedProductionYear, productionYearsList, "Filter by production year")
        Buttons.Dropdown("Visibility", selectedVisibility, visibilityModes, "Show unlocked/locked vehicles")
        if VehicleFeaures.enableVehicleSpawnerMode then
            Buttons.Int("Spawn Distance", vehicleSpawnDis, "Distance the vehicle spawns in front of the player")
        end
        Buttons.Break("", "Filtered Vehicle List")
    end

    local selectedYear = productionYearsList[selectedProductionYear.index or 1]
    local visibilityFilter = visibilityModes[selectedVisibility.index or 1]

    local vehicles = VehicleLoader:Filter(function(v)
        if mode == "Player Vehicles" and v.faction ~= "Player" then
            return false
        end
        if mode == "By Category" and v.category ~= selectedValue then
            return false
        end
        if mode == "By Manufacturer" and v.manufacturer ~= selectedValue then
            return false
        end
        if mode == "By Affiliation" and v.faction ~= selectedValue then
            return false
        end

      if not YearMatches(v.productionYear, productionYearsList[selectedProductionYear.index or 1]) then
        return false
        end

        local isUnlocked = VehicleSystem.IsVehicleUnlocked(v.id)
        if visibilityFilter == "Unlocked Only" and not isUnlocked then return false end
        if visibilityFilter == "Locked Only" and isUnlocked then return false end

        return true
    end)

    if #vehicles == 0 then
        Buttons.Break("", "No matching vehicles found.")
        return
    end

    for _, vehicle in ipairs(vehicles) do
        DrawVehicleRow(vehicle)
    end
end

local filteredSubmenu = {
    title = "Filtered Vehicles",
    view = VehicleFilteredSubmenuView
}

local function VehicleMainView()
    if not initialized then
        BuildFilters()
        initialized = true
    end

    Buttons.Dropdown("Mode", selectedMode, filterModes, filterModeTip)

    local mode = filterModes[selectedMode.index or 1]
    if mode == "All Vehicles" or mode == "Player Vehicles" then
        Buttons.Dropdown("Year", selectedProductionYear, productionYearsList, "Filter by production year")
        Buttons.Dropdown("Visibility", selectedVisibility, visibilityModes, "Show unlocked/locked vehicles")
        if VehicleFeaures.enableVehicleSpawnerMode then
            Buttons.Int("Spawn Distance", vehicleSpawnDis, "Distance the vehicle spawns in front of the player")
        end
        Buttons.Break("", "Filtered Vehicle List")
    end

    -- For By Category / Manufacturer / Affiliation: show submenu links
    local list = nil
    local labelPrefix = ""

    if mode == "By Category" then
        list = categories
        labelPrefix = "Category: "
    elseif mode == "By Manufacturer" then
        list = manufacturers
        labelPrefix = "Manufacturer: "
    elseif mode == "By Affiliation" then
        list = affiliations
        labelPrefix = "Affiliation: "
    end

    if list then
        for _, value in ipairs(list) do
            Buttons.Submenu(value, filteredSubmenu, labelPrefix .. value, function()
                selectedValue = value
            end)
        end
    else
        -- always render list here (for All/Player Vehicles)
        VehicleFilteredSubmenuView()
    end
end


local VehicleListView = { title = "Vehicle List", view = VehicleMainView}

return VehicleListView
