local Logger = require("Core/Logger")
local JsonHelper = require("Core/JsonHelper")

local TeleportLocations = {}

local apartments = { -- Hard coded apartments for a quick filter
    { name = "Corpo Plaza", category = "V's Apartment", position = { x = -1598.990723, y = 359.183655, z = 48.620003 } },
    { name = "Dogtown", category = "V's Apartment", position = { x = -2232.448486, y = -2560.21875, z = 80.270355 } },
    { name = "The Glen", category = "V's Apartment", position = { x = -1524.231445, y = -985.826355, z = 86.940002 } },
    { name = "H10 Megabuilding", category = "V's Apartment", position = { x = -1378.424927, y = 1273.94043, z = 123.033356 } },
    { name = "Japantown", category = "V's Apartment", position = { x = -785.826416, y = 987.398376, z = 28.209541 } },
    { name = "Northside", category = "V's Apartment", position = { x = -1507.223022, y = 2232.709229, z = 22.2108 } },
}


local cache = {
    all = {},
    vendors = {},
    apartments = apartments
}
local TeleportFile = "Features/Teleports/TeleportLocations.json"

local function isVendor(entry)
    return entry.category and entry.category:lower():find("vendor")
end




function TeleportLocations.LoadAll()
    local data, err = JsonHelper.Read(TeleportFile)
    if not data then
        Logger.Log(string.format("[EasyTrainerTeleportLocations] Failed to load '%s': %s", TeleportFile, tostring(err)))
        cache.all = {}
        cache.vendors = {}
        return
    end

    cache.all = data
    cache.vendors = {}

    for _, entry in ipairs(data) do
        if isVendor(entry) then
            local cat = entry.category
            cache.vendors[cat] = cache.vendors[cat] or {}
            table.insert(cache.vendors[cat], entry)
        end
    end

    Logger.Log(string.format(
        "[EasyTrainerTeleportLocations] Loaded %d teleports (%d vendor categories).",
        #cache.all,
        Utils.Count(cache.vendors)
    ))
end

function TeleportLocations.GetAll()
    return cache.all
end

function TeleportLocations.GetVendors()
    return cache.vendors
end


function TeleportLocations.GetApartments()
    return cache.apartments
end

function TeleportLocations.Reload()
    Logger.Log("[EasyTrainerTeleportLocations] Reloading teleport locations...")
    TeleportLocations.LoadAll()
end

return TeleportLocations
