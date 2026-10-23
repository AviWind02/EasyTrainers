local Logger = require("Core/Logger")
local JsonHelper = require("Core/JsonHelper")

local TeleportLocations = {
    FilePath = "Config/JSON/Teleports.json"
}

local APARTMENTS = {
    { name = "Corpo Plaza", category = "V's Apartment", position = { x = -1598.990723, y = 359.183655, z = 48.620003 } },
    { name = "Dogtown", category = "V's Apartment", position = { x = -2232.448486, y = -2560.21875, z = 80.270355 } },
    { name = "The Glen", category = "V's Apartment", position = { x = -1524.231445, y = -985.826355, z = 86.940002 } },
    { name = "H10 Megabuilding", category = "V's Apartment", position = { x = -1378.424927, y = 1273.94043, z = 123.033356 } },
    { name = "Japantown", category = "V's Apartment", position = { x = -785.826416, y = 987.398376, z = 28.209541 } },
    { name = "Northside", category = "V's Apartment", position = { x = -1507.223022, y = 2232.709229, z = 22.2108 } }
}

local UNKNOWN_DISTRICT = "Unknown District"

local s_All = {}
local s_Vendors = {}
local s_Categories = {}
local s_Districts = {}
local s_Priority = {}

local function Count(values)
    local count = 0
    for _ in pairs(values) do count = count + 1 end
    return count
end

local function Append(map, key, entry)
    map[key] = map[key] or {}
    table.insert(map[key], entry)
end

local function IsVendor(entry)
    return entry.category ~= nil and entry.category:lower():find("vendor", 1, true) ~= nil
end

local function Reset()
    s_All, s_Vendors, s_Categories, s_Districts, s_Priority = {}, {}, {}, {}, {}
end

function TeleportLocations.LoadAll()
    Reset()

    local data, err = JsonHelper.Read(TeleportLocations.FilePath)
    if not data then
        Logger.Log(string.format("TeleportLocations: failed to load '%s' (%s)", TeleportLocations.FilePath, tostring(err)))
        return
    end

    s_All = data.teleports or {}
    s_Priority = data.priority or {}

    for _, entry in ipairs(s_All) do
        if IsVendor(entry) then Append(s_Vendors, entry.category, entry) end
        Append(s_Categories, entry.category or "Uncategorized", entry)
        Append(s_Districts, (entry.parentDistrict or UNKNOWN_DISTRICT) .. " / " .. (entry.childDistrict or UNKNOWN_DISTRICT), entry)
    end

    Logger.Log(string.format(
        "TeleportLocations: loaded %d teleports across %d categories and %d districts, %d priority categories",
        #s_All, Count(s_Categories), Count(s_Districts), #s_Priority
    ))
end

function TeleportLocations.GetAll()
    return s_All
end

function TeleportLocations.GetVendors()
    return s_Vendors
end

function TeleportLocations.GetApartments()
    return APARTMENTS
end

function TeleportLocations.GetCategories()
    return s_Categories
end

function TeleportLocations.GetDistricts()
    return s_Districts
end

function TeleportLocations.GetPriority()
    return s_Priority
end

function TeleportLocations.Reload()
    TeleportLocations.LoadAll()
end

return TeleportLocations
