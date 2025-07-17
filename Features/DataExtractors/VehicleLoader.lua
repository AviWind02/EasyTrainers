local Logger = require("Core/Logger")


local VehicleLoader = {
    vehicles = {},       -- VehicleData[]
    indexById = {}       -- map id -> VehicleData
}

local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

-- Escape backslashes and quotes
local function escapeString(s)
    if type(s) ~= "string" or s == "" then
        return "Unknown"
    end
    return s:gsub("([\\\"])", "\\%1")
end

local function getTags(record)
    local raw = safeCall(function() return record:Tags() end)
    if type(raw) ~= "table" then
        return {}
    end
    local out = {}
    for _, tag in ipairs(raw) do
        if tag.value then
            table.insert(out, tag.value)
        end
    end
    return out
end

local function inferCategory(tags)
    for _, t in ipairs(tags) do
        if t:lower():find("bike") then
            return "Sport Bike"
        end
    end
    for _, t in ipairs(tags) do
        if t:lower():find("sport") then
            return "Sport Vehicle"
        end
    end
    for _, t in ipairs(tags) do
        if t:lower():find("utility") then
            return "Utility Vehicle"
        end
    end
    return "Standard"
end

local function inferFaction(record, id)
    local faction = nil
    local aff = safeCall(function() return record:Affiliation() end)
    if aff then
        local key = safeCall(function() return aff:LocalizedName() end)
        if key then
            local text = Game.GetLocalizedTextByKey(key)
            if text and text ~= "Label Not Found" and text ~= "No Affiliation" then
                faction = escapeString(text)
            end
        end
    end
    if not faction then
        local groups = {
            tyger = "Tyger Claws",
            maelstrom = "Maelstrom",
            voodoo = "Voodoo Boys",
            mox = "Moxes",
            netwatch = "NetWatch",
            animal = "Animals",
            militech = "Militech",
            nomad = "Nomads",
            player = "Player",
            ncpd = "Police",
            max = "Maxtac",
            arasaka = "Arasaka",
            barghest = "Barghest",
            sixth = "Sixth Street",
            valentino = "Valentinos",
            scavengers = "Scavs"
        }
        for key, label in pairs(groups) do
            if id:lower():find(key) then
                faction = label
                break
            end
        end
    end
    return faction or "No Affiliation"
end

local function getVehicleInfoLore(record)
    local info = { description = "No Description Available", productionYear = nil }
    local ui = safeCall(function() return record:VehicleUIData() end)
    if ui then
        local rawDesc = safeCall(function() return ui:Info() end)
        if rawDesc then
            local text = Game.GetLocalizedText(rawDesc)
            if text and text ~= "Label Not Found" then
                info.description = escapeString(text)
            end
        end
        local year = safeCall(function() return ui:ProductionYear() end)
        if year then
            info.productionYear = tostring(year)
        end
    end
    return info
end

local function getDisplayName(record)
    local key = safeCall(function() return record:DisplayName() end)
    if key then
        local text = Game.GetLocalizedTextByKey(key)
        if text and text ~= "" and text ~= "Label Not Found" then
            return escapeString(text)
        end
    end
    return "Unknown"
end

local function getManufacturer(record)
    local mfr = safeCall(function() return record:Manufacturer() end)
    if mfr then
        local name = safeCall(function() return mfr:EnumName() end)
        if name and name ~= "" then
            return escapeString(name)
        end
    end
    return "Unlisted"
end

-- Injects vehicles into player vehicle list by adding it to their list in TweakDB on start up.
function VehicleLoader:InjectVehicle(id)
    local listID = TweakDBID.new("Vehicle.vehicle_list.list")

    local currentList = TweakDB:GetFlat(listID)
    if type(currentList) ~= "table" then
        Logger.Log("[EasyTrainerInjectVehicle] Failed to read vehicle list.")
        return false
    end

    for _, existing in ipairs(currentList) do
        if existing.value == id then
            return false
        end
    end

    table.insert(currentList, TweakDBID.new(id))

    local success = TweakDB:SetFlat(listID, currentList)
    if not success then
        Logger.Log("[EasyTrainerInjectVehicle] Failed to write updated vehicle list.")
        return false
    end

    --Logger.Log("[EasyTrainerInjectVehicle] Injected vehicle: " .. id)
    return true
end


function VehicleLoader:LoadAll()
    local records = TweakDB:GetRecords("gamedataVehicle_Record")
    if not records or #records == 0 then
        Logger.Log("[EasyTrainerVehicleLoader] No vehicle records found.")
        return
    end

    local injectedCount = 0

    for _, rec in ipairs(records) do
        local id = safeCall(function() return rec:GetID().value end)
        if id and id:find("^Vehicle%.v_") then
            local tags = getTags(rec)
            local lore = getVehicleInfoLore(rec)
            local data = {
                id = id,
                displayName = getDisplayName(rec),
                manufacturer = getManufacturer(rec),
                category = inferCategory(tags),
                faction = inferFaction(rec, id),
                tags = tags,
                description = lore.description,
                productionYear = lore.productionYear
            }
            table.insert(self.vehicles, data)
            self.indexById[id] = data

            if self:InjectVehicle(id) then
                injectedCount = injectedCount + 1
            end
        end
    end

    Logger.Log(string.format("[EasyTrainerVehicleLoader] Loaded %d vehicles (Injected %d new).", #self.vehicles, injectedCount))
end




function VehicleLoader:GetAll()
    return self.vehicles
end


function VehicleLoader:GetById(id)
    return self.indexById[id]
end


function VehicleLoader:Filter(fn)
    local out = {}
    for _, v in ipairs(self.vehicles) do
        if fn(v) then
            table.insert(out, v)
        end
    end
    return out
end

return VehicleLoader
