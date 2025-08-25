local Draw = require("UI")
local Buttons = Draw.Buttons
local Notification = Draw.Notifier

local Teleport = require("Features/Teleports/Teleport")
local TeleportLocations = require("Features/Teleports/TeleportLocations")

local selectedCreator = { index = 1, expanded = false }
local currentTeleportCategory = ""

local creatorList = {}

local quickTeleport = { index = 1, expanded = false }
local quickOptions = {}

local showCategoryDistance = { value = true }
local showQuickDistance = { value = true }

-- Settings view
local function TeleportSettingsView()
    Buttons.Toggle("Show Distance in Categories", showCategoryDistance,
        "If enabled, shows distance next to all teleport category destinations.\n(Minimal performance impact)")
    Buttons.Toggle("Show Distance in Quick Destinations", showQuickDistance,
        "If enabled, shows distance in the Quick Destinations cycler.\n(May have performance impact)")

    Buttons.Break("Auto Teleports")

    Buttons.Toggle("Auto Teleport to Waypoint Marker", Teleport.toggleAutoWaypoint,
        "If enabled, the player will automatically teleport to the set waypoint.(It may also break when inside of buildings)")
    Buttons.Toggle("Auto Teleport to Quest Marker", Teleport.toggleAutoQuest,
        "If enabled, the player will automatically teleport to the tracked quest marker every second.\n\n" ..
        "Important: Some quest objectives may not clear their marker properly, causing you to get stuck looping here. " ..
        "Use with caution :)")
end

local TeleportSettings = { title = "Teleport Settings", view = TeleportSettingsView }

-- Helpers
local function FormatDistance(dist)
    if not dist then return "" end
    if dist >= 1000 then
        return string.format("%.2f km", dist / 1000)
    else
        return string.format("%d m", math.floor(dist))
    end
end

local function GetQuickOptionDistance(selection)
    local player = Game.GetPlayer()
    if not player or not selection then return nil end
    local playerPos = player:GetWorldPosition()

    -- Vendors
    for cat, vendors in pairs(TeleportLocations.GetVendors()) do
        if selection == "Closest " .. cat then
            local nearestDist = math.huge
            for _, v in ipairs(vendors) do
                local dist = Teleport.DistanceBetween(playerPos, v.position)
                if dist < nearestDist then
                    nearestDist = dist
                end
            end
            return nearestDist ~= math.huge and nearestDist or nil
        end
    end

    -- Apartments
    for _, apt in ipairs(TeleportLocations.GetApartments()) do
        if selection == "Apartment: " .. apt.name then
            return Teleport.DistanceFromPlayer(apt.position)
        end
    end

    return nil
end

-- Build Quick Options
local function BuildQuickOptions()
    quickOptions = {}
    for cat, _ in pairs(TeleportLocations.GetVendors()) do
        table.insert(quickOptions, "Closest " .. cat)
    end
    for _, apt in ipairs(TeleportLocations.GetApartments()) do
        table.insert(quickOptions, "Apartment: " .. apt.name)
    end
    table.sort(quickOptions)
end

-- Execute Quick Teleport
local function DoQuickTeleport(selection)
    for cat, vendors in pairs(TeleportLocations.GetVendors()) do
        if selection == "Closest " .. cat then
            local nearest, nearestDist = nil, math.huge
            local playerPos = Game.GetPlayer():GetWorldPosition()
            for _, v in ipairs(vendors) do
                local dist = Teleport.DistanceBetween(playerPos, v.position)
                if dist < nearestDist then
                    nearest = v
                    nearestDist = dist
                end
            end
            if nearest then
                Teleport.TeleportEntity(Game.GetPlayer(), nearest.position)
                Notification.Push("Teleported to closest " .. cat .. " (" .. nearest.name .. ")")
            end
            return
        end
    end

    for _, apt in ipairs(TeleportLocations.GetApartments()) do
        if selection == "Apartment: " .. apt.name then
            Teleport.TeleportEntity(Game.GetPlayer(), apt.position)
            Notification.Push("Teleported to apartment: " .. apt.name)
            return
        end
    end
end

-- Creator List
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

-- Filtered View
function FilteredCategoryView()
    local creator = creatorList[selectedCreator.index or 1]
    local playerPos = Game.GetPlayer() and Game.GetPlayer():GetWorldPosition()

    for _, loc in ipairs(TeleportLocations.GetAll()) do
        if loc.category == currentTeleportCategory and (creator == L("teleport.creator_all") or loc.creator == creator) then
            local dist = playerPos and Teleport.DistanceBetween(playerPos, loc.position) or nil
            local distLabel = (showCategoryDistance.value and FormatDistance(dist)) or ""

            if Buttons.OptionExtended(
                tip("teleport.teleportoption.label", { location_name = loc.name }),
                "",
                distLabel ~= "" and distLabel or IconGlyphs.MapMarker,
                tip("teleport.teleportoption.tip", { creator = loc.creator, location_name = loc.name, category = loc.category })
            ) then
                Teleport.TeleportEntity(Game.GetPlayer(), loc.position)
            end
        end
    end
end

local filteredCategorySubmenu = { title = "teleport.selectedteleports.label", view = FilteredCategoryView }

-- Filtered Categories
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
        BuildQuickOptions()
        onInit = true
    end

    Buttons.Submenu("Teleport Settings", TeleportSettings, "Adjust teleport-related options like distance display and auto-teleports.")

    Buttons.Int(L("teleport.forwarddistance.label"), forwardRef, L("teleport.forwarddistance.tip"))
    
    if Buttons.Option(L("teleport.teleportforward.label"), L("teleport.teleportforward.tip")) then
        local pos = Teleport.GetForwardOffset(forwardRef.value)
        Teleport.TeleportEntity(Game.GetPlayer(), pos)
    end

    Buttons.Break("", "Quick Teleport")
    
    Buttons.Option("Teleport to Quest Marker", "Teleport to the currently tracked quest objective", function()
        Teleport.TeleportToQuestMarker(true)
    end)

    Buttons.Option("Teleport to Waypoint Marker", "Teleport to the currently set map waypoint", function()
        Teleport.TeleportToWaypointMarker(true)
    end)

    local selection = quickOptions[quickTeleport.index]
    local label = "Destinations"

    if showQuickDistance.value and selection then
        local distText = GetQuickOptionDistance(selection)
        if distText then
            label = label .. " (" .. FormatDistance(distText) .. ")"
        end
    end

    if Buttons.StringCycler(label, quickTeleport, quickOptions,
        "Cycle through apartments or nearest vendors.\nClick to teleport instantly.") then
        if selection then DoQuickTeleport(selection) end
    end

    Buttons.Dropdown(L("teleport.creator.label"), selectedCreator, creatorList, L("teleport.creator.tip"))
    Buttons.Break("", L("teleport.categoriesbreak.label"))

    for _, category in ipairs(GetFilteredCategories()) do
        Buttons.Submenu(
            tip("teleport.categorysubmenu.label", { category = category }),
            filteredCategorySubmenu,
            tip("teleport.categorysubmenu.tip", { category = category }),
            function() currentTeleportCategory = category end
        )
    end
end

local TeleportView = { title = "teleport.title", view = TeleportMenuView }
return TeleportView
