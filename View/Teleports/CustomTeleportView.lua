local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Notification = require("UI/Panels/Notification/Notification")
local JsonHelper = require("Core/JsonHelper")
local World = require("Utils/World")
local TeleportLocations = require("Features/Teleports/TeleportLocations")

local DEFAULT_CATEGORY = "Custom"

local s_Name = { value = L("teleport.customteleportview.defaults.name"), capturing = false }
local s_Creator = { value = L("teleport.customteleportview.defaults.creator"), capturing = false }
local s_Category = { index = 1 }
local s_Categories = nil

local function BuildCategories()
    s_Categories = { DEFAULT_CATEGORY }
    local seen = { [DEFAULT_CATEGORY] = true }
    for _, location in ipairs(TeleportLocations.GetAll()) do
        if location.category and not seen[location.category] then
            table.insert(s_Categories, location.category)
            seen[location.category] = true
        end
    end
end

local function BuildEntry(position)
    local parent, child = World.GetCurrentDistrictName()
    return {
        name = s_Name.value,
        position = { x = position.x, y = position.y, z = position.z },
        parentDistrict = parent or L("teleport.customteleportview.defaults.parentDistrict"),
        childDistrict = child or L("teleport.customteleportview.defaults.childDistrict"),
        category = s_Categories[s_Category.index or 1] or DEFAULT_CATEGORY,
        creator = s_Creator.value ~= "" and s_Creator.value or L("teleport.customteleportview.defaults.creator")
    }
end

local function WriteEntry(entry)
    local data = JsonHelper.LoadOrCreate(TeleportLocations.FilePath, { teleports = {} })
    if type(data) ~= "table" then data = { teleports = {} } end
    if type(data.teleports) ~= "table" then data.teleports = {} end

    table.insert(data.teleports, entry)
    return JsonHelper.Write(TeleportLocations.FilePath, data)
end

local function SaveCustomTeleport()
    if not s_Name.value or s_Name.value == "" then
        Notification.Error("Please enter a name for the teleport")
        return
    end

    local player = Game.GetPlayer()
    local position = player and player:GetWorldPosition() or nil
    if not position then return end

    local entry = BuildEntry(position)
    if not WriteEntry(entry) then
        Notification.Error("Failed to save custom teleport")
        return
    end

    TeleportLocations.Reload()
    BuildCategories()
    Notification.Success(tip("teleport.customteleportview.notifications.saved", {
        name = entry.name,
        parent = entry.parentDistrict,
        child = entry.childDistrict,
        x = string.format("%.2f", entry.position.x),
        y = string.format("%.2f", entry.position.y),
        z = string.format("%.2f", entry.position.z)
    }))
end

local function CustomTeleportView()
    if not s_Categories then BuildCategories() end

    Buttons.Text(L("teleport.customteleportview.name.label"), s_Name, L("teleport.customteleportview.name.tip"))
    Buttons.Text(L("teleport.customteleportview.creator.label"), s_Creator, L("teleport.customteleportview.creator.tip"))
    Buttons.StringCycler(L("teleport.customteleportview.category.label"), s_Category, s_Categories, L("teleport.customteleportview.category.tip"))
    Buttons.Option(L("teleport.customteleportview.save.label"), L("teleport.customteleportview.save.tip"), SaveCustomTeleport)
end

return Submenu.Create("teleport.customteleportview.title", CustomTeleportView)
