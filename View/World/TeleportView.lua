local Draw = require("UI")

local Teleport = require("Features/Teleports/Teleport")
local TeleportLocations = require("Features/Teleports/TeleportLocations")

local selectedCreator = { index = 1, expanded = false }
local currentTeleportCategory = ""

local creatorList = {}

local function BuildCreatorList()
    local seen = {}
    table.insert(creatorList, L("teleport.creator_all")) 
    for _, loc in ipairs(TeleportLocations.GetAll()) do
        if not seen[loc.creator] then
            table.insert(creatorList, loc.creator)
            seen[loc.creator] = true
        end
    end
    table.sort(creatorList, function(a, b)
        if a == L("teleport.creator_all") then return true end
        if b == L("teleport.creator_all") then return false end
        return a < b
    end)
end

function FilteredCategoryView()
    local creator = creatorList[selectedCreator.index or 1]

    for _, loc in ipairs(TeleportLocations.GetAll()) do
        if loc.category == currentTeleportCategory and (creator == L("teleport.creator_all") or loc.creator == creator) then
            if Draw.Buttons.OptionExtended(
                tip("teleport.teleportoption.label", { location_name = loc.name }),
                "",
                IconGlyphs.MapMarker,
                tip("teleport.teleportoption.tip", { creator = loc.creator, location_name = loc.name, category = loc.category })
            ) then
                Teleport.TeleportEntity(Game.GetPlayer(), loc.position)
            end
        end
    end
end

local filteredCategorySubmenu = { title = "teleport.selectedteleports.label", view = FilteredCategoryView }

local function GetFilteredCategories()
    local seen = {}
    local filtered = {}
    local creator = creatorList[selectedCreator.index or 1]

    for _, loc in ipairs(TeleportLocations.GetAll()) do
        if creator == L("teleport.creator_all") or loc.creator == creator then
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

    Draw.Buttons.Int(L("teleport.forwarddistance.label"), forwardRef, L("teleport.forwarddistance.tip"))
    
    if Draw.Buttons.Option(L("teleport.teleportforward.label"), L("teleport.teleportforward.tip")) then
        local pos = Teleport.GetForwardOffset(forwardRef.value)
        Teleport.TeleportEntity(Game.GetPlayer(), pos)
    end

    Draw.Buttons.Dropdown(L("teleport.creator.label"), selectedCreator, creatorList, L("teleport.creator.tip"))

    Draw.Buttons.Break("", L("teleport.categoriesbreak.label"))

    for _, category in ipairs(GetFilteredCategories()) do
        Draw.Buttons.Submenu(
            tip("teleport.categorysubmenu.label", { category = category }),
            filteredCategorySubmenu,
            tip("teleport.categorysubmenu.tip", { category = category }),
            function()
                currentTeleportCategory = category
            end
        )
    end
end

local TeleportView = { title = "teleport.title", view = TeleportMenuView }

return TeleportView
