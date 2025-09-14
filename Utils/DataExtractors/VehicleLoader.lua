local Logger = require("Core/Logger")
local utils = require("Utils/DataExtractors/DataUtils")

local VehicleLoader = {
    vehicles = {},
    indexById = {}
}

local function InferCategory(tags, id, displayName)
    local idLower = (id or ""):lower()
    local nameLower = (displayName or ""):lower()

    if idLower:find("police") or idLower:find("border") or idLower:find("maxtac") then
        return "Emergency/Police"
    end

    -- Special vehicles (military, unique, or one-offs)
    if idLower:find("basilisk")
        or idLower:find("coach")
        or idLower:find("misile")
        or idLower:find("bmf") then
        return "Special"
    end

    -- Corporation-owned fleets - I feel like this is useless because this already shows up in affiliation
    --[[
        if idLower:find("arasaka")
            or idLower:find("militech")
            or idLower:find("kangtao")
            or idLower:find("zetatech")
            or idLower:find("netwatch")
            or idLower:find("delamain") then
            return "Corpo"
        end
    --]]

    -- based on what I understand of the vehicle grouping this is what I've kind of come up with
    if idLower:find("sport1") then
        return "Hypercars"
    elseif idLower:find("sport2") then
        return "Sports Cars"
    elseif idLower:find("standard3") then
        return "Pickups & SUVs"
    elseif idLower:find("standard25") then
        return "Vans & Couriers"
    elseif idLower:find("standard2") then
        return "Compact"
    end

    -- these two cars end up in sports for some reason But they are hyper cars
    if idLower:find("v_010_v_tek") or idLower:find("v_013_rayfield_aerodnight") then
        return "Hypercars"
    end

    for _, t in ipairs(tags or {}) do
        local tl = t:lower()
        if tl:find("modded") or tl:find("add%-on") then
            return "Add-On Vehicles(Modded)"
        elseif tl:match("%f[%a]sport%f[%A]") then -- just in case any vehicles are not caught or new vehicles come out they're still categorized
            return "Sport Vehicle"
        elseif tl:match("%f[%a]utility%f[%A]") then
            return "Utility"
        elseif tl:match("%f[%a]bike%f[%A]") then
            return "Motorcycle"
        end
    end

    -- final fall back as sometimes the code above doesn't always catch it for some reason hit or miss mainly for utility
    if idLower:match("%f[%a]utility%d*%f[%A]") or nameLower:match("%f[%a]utility%d*%f[%A]") then
        return "Utility"
    elseif idLower:match("%f[%a]bike%f[%A]") or nameLower:match("%f[%a]bike%f[%A]") then
        return "Motorcycle"
    elseif idLower:match("%f[%a]sport%f[%A]") or nameLower:match("%f[%a]sport%f[%A]") then
        return "Sport Vehicle" -- catch-all
    end

    return "Uncategorized"
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
        Logger.Log("VehicleLoader: Failed to read vehicle list.")
        return false
    end

    for _, existing in ipairs(currentList) do
        if existing.value == id then return false end
    end

    table.insert(currentList, TweakDBID.new(id))

    local success = TweakDB:SetFlat(listID, currentList)
    if not success then
        Logger.Log("VehicleLoader: Failed to update vehicle list.")
        return false
    end

    return true
end

-- This function fixes the issue where twin tone wasn't available for all vehicles when set into the list
function VehicleLoader:HandleTwinToneScan(this, wrappedMethod) -- Function taken from Make All Vehicles Unlockable - With TwinTone Fix Created by TheManualEnhancer
    if this.scannedObject ~= nil then
        local obj = this.scannedObject
        if obj and obj:IsVehicle() and obj:GetRecord() then
            local id = utils.SafeCall(function() return obj:GetRecord():GetID().value end)
                or utils.SafeCall(function() return obj:GetRecord():GetRecordID().value end)

            if id and not Game.GetVehicleSystem():IsVehiclePlayerUnlocked(TweakDBID.new(id)) then
                this.twintoneAvailable = true
                return true
            end
        end
    end
    return wrappedMethod()
end

function VehicleLoader:LoadAll()
    local records = TweakDB:GetRecords("gamedataVehicle_Record")
    if not records or #records == 0 then
        Logger.Log("VehicleLoader: No vehicle records found.")
        return
    end

    local injectedCount = 0
    for _, rec in ipairs(records) do
        local id = utils.SafeCall(function() return rec:GetID().value end)
        local idLower = id:lower()

        -- Only include vanilla if Vehicle.v_ these should be all drivable vehicles - should skip out AVs and such
        local isVanilla = id:match("^Vehicle%.v_")

        -- Detect modded by logo suffix - I'm noticing a lot of modded vehicles don't have .v_ but do have _logo
        local manufacturer = GetManufacturer(rec)
        local displayName = utils.GetDisplayName(rec)
        local isModded = manufacturer:lower():match("logo[_%s]*$") or idLower:match("logo[_%s]*$")
        if not isVanilla and not isModded then
            goto continue
        end

        local tags = utils.GetTags(rec)
        local lore = GetVehicleInfoLore(rec)

        local category = InferCategory(tags, id, displayName)

        if isModded then -- I don’t know what tags to call the modded vehicles. I like Add-On Vehicles as well, so I’m keeping both, because I fukin can :)
            table.insert(tags, "Modded Vehicle")
            table.insert(tags, "Add-On Vehicle")
            category = "Add-On Vehicles(Modded)" -- forcing it here because for some reason it only works on some via InferCategory
        end

        -- skip oddballs just in case
        if manufacturer == "Unlisted" or displayName == "Unknown" then goto continue end -- If it doesn't have a display name it might not be drivable
        if idLower:find("_av_") or idLower:match("^av_") or idLower:match("_av$") then goto continue end
        if lore.productionYear and tostring(lore.productionYear):lower():find("lockey") then goto continue end 

        local data = {
            id = id,
            displayName = displayName,
            manufacturer = manufacturer,
            category = category,
            faction = InferFaction(rec, id),
            tags = tags,
            description = lore.description,
            productionYear = lore.productionYear
        }

        table.insert(self.vehicles, data)
        self.indexById[id] = data

        if self:AddVehicleToList(id) then
            injectedCount = injectedCount + 1
        end

        ::continue::
    end



    Logger.Log(string.format("VehicleLoader: Loaded %d vehicles (Added %d new).", #self.vehicles,
        injectedCount))
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
