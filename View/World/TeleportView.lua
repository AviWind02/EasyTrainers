local Draw = require("UI")

local Teleport = require("Features/Teleports/Teleport")
local TeleportLocations = require("Features/Teleports/TeleportLocations")

local selectedCreator = { index = 1, expanded = false }
local currentTeleportCategory = ""

local creatorList = {}

local function BuildCreatorList()
    local seen = {}
    table.insert(creatorList, "All") 
    for _, loc in ipairs(TeleportLocations) do
        if not seen[loc.creator] then
            table.insert(creatorList, loc.creator)
            seen[loc.creator] = true
        end
    end
    table.sort(creatorList, function(a, b)
        if a == "All" then return true end
        if b == "All" then return false end
        return a < b
    end)
end


function FilteredCategoryView()
    local creator = creatorList[selectedCreator.index or 1]

    for _, loc in ipairs(TeleportLocations) do
        if loc.category == currentTeleportCategory and (creator == "All" or loc.creator == creator) then
            if Draw.Buttons.OptionExtended(loc.name, "", IconGlyphs.MapMarker, "Created by: " .. loc.creator .. "\nTeleport to " .. loc.name .. " in " .. loc.category) then
                Teleport.TeleportEntity(Game.GetPlayer(), loc.position)
            end
        end
    end
end
local filteredCategorySubmenu = { title = "Selected Teleport Locations", view = FilteredCategoryView }

local function GetFilteredCategories()
    local seen = {}
    local filtered = {}
    local creator = creatorList[selectedCreator.index or 1]

    for _, loc in ipairs(TeleportLocations) do
        if creator == "All" or loc.creator == creator then
            if not seen[loc.category] then
                table.insert(filtered, loc.category)
                seen[loc.category] = true
            end
        end
    end

    table.sort(filtered)
    return filtered
end

local onInit = false
local forwardRef = { value = 2, min = 1, max = 25 }

function TeleportMenuView()

    if not onInit then
        BuildCreatorList()
        onInit = true
    end


    Draw.Buttons.Int("Forward Distance", forwardRef, "Set how far forward to teleport (in meters).")
    if Draw.Buttons.Option("Teleport Forward", "Teleport forward based on current direction") then
        local pos = Teleport.GetForwardOffset(forwardRef.value)
        Teleport.TeleportEntity(Game.GetPlayer(), pos)
    end

    Draw.Buttons.Dropdown("Creator", selectedCreator, creatorList, "Filter teleport locations by their creator.")

    Draw.Buttons.Break("", "Teleport Categories")

    for _, category in ipairs(GetFilteredCategories()) do

        Draw.Buttons.Submenu(category, filteredCategorySubmenu, "View teleport locations in " .. category, function()
            currentTeleportCategory = category
        end)
    end
end

local TeleportView = { title = "Teleport Menu", view = TeleportMenuView }


return TeleportView
