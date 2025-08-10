local Logger = require("Core/Logger")
local utils = require("Features/DataExtractors/Utils")

local VehicleLoader = {
    vehicles = {},
    indexById = {}
}

local function InferCategory(tags)
    for _, t in ipairs(tags) do
        if t:lower():find("bike") then return "Sport Bike" end
    end
    for _, t in ipairs(tags) do
        if t:lower():find("sport") then return "Sport Vehicle" end
    end
    for _, t in ipairs(tags) do
        if t:lower():find("utility") then return "Utility Vehicle" end
    end
    return "Standard"
end

local function InferFaction(record, id)
    local faction = nil
    local aff = utils.SafeCall(function() return record:Affiliation() end)
    if aff then
        local key = utils.SafeCall(function() return aff:LocalizedName() end)
        if key then
            local text = Game.GetLocalizedTextByKey(key)
            if text and text ~= "Label Not Found" and text ~= "No Affiliation" then
                faction = utils.EscapeString(text)
            end
        end
    end

    if not faction then
        local groups = {
            tyger = "Tyger Claws", maelstrom = "Maelstrom", voodoo = "Voodoo Boys", mox = "Moxes",
            netwatch = "NetWatch", animal = "Animals", militech = "Militech", nomad = "Nomads",
            player = "Player", ncpd = "Police", max = "Maxtac", arasaka = "Arasaka",
            barghest = "Barghest", sixth = "Sixth Street", valentino = "Valentinos", scavengers = "Scavs"
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

local function GetVehicleInfoLore(record)
    local info = { description = "No Description Available", productionYear = nil }
    local ui = utils.SafeCall(function() return record:VehicleUIData() end)

    if ui then
        local rawDesc = utils.SafeCall(function() return ui:Info() end)
        if rawDesc then
            local text = Game.GetLocalizedText(rawDesc)
            if text and text ~= "Label Not Found" then
                info.description = utils.EscapeString(text)
            end
        end

        local year = utils.SafeCall(function() return ui:ProductionYear() end)
        if year then info.productionYear = tostring(year) end
    end

    return info
end

local function GetManufacturer(record)
    local mfr = utils.SafeCall(function() return record:Manufacturer() end)
    if mfr then
        local name = utils.SafeCall(function() return mfr:EnumName() end)
        if name and name ~= "" then
            return utils.EscapeString(name)
        end
    end
    return "Unlisted"
end

function VehicleLoader:AddVehicleToList(id)
    local listID = TweakDBID.new("Vehicle.vehicle_list.list")
    local currentList = TweakDB:GetFlat(listID)

    if type(currentList) ~= "table" then
        Logger.Log("[EasyTrainerVehicleList] Failed to read vehicle list.")
        return false
    end

    for _, existing in ipairs(currentList) do
        if existing.value == id then return false end
    end

    table.insert(currentList, TweakDBID.new(id))

    local success = TweakDB:SetFlat(listID, currentList)
    if not success then
        Logger.Log("[EasyTrainerVehicleList] Failed to update vehicle list.")
        return false
    end

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
        local id = utils.SafeCall(function() return rec:GetID().value end)
        if id and id:find("^Vehicle%.v_") then
            local tags = utils.GetTags(rec)
            local lore = GetVehicleInfoLore(rec)

            local data = {
                id = id,
                displayName = utils.GetDisplayName(rec),
                manufacturer = GetManufacturer(rec),
                category = InferCategory(tags),
                faction = InferFaction(rec, id),
                tags = tags,
                description = lore.description,
                productionYear = lore.productionYear
            }

            table.insert(self.vehicles, data)
            self.indexById[id] = data

            -- Adding vehicles to the player list is breaking twin tone: Need to look into this
            --if self:AddVehicleToList(id) then
                --injectedCount = injectedCount + 1
            --end
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
        if fn(v) then table.insert(out, v) end
    end
    return out
end

return VehicleLoader
