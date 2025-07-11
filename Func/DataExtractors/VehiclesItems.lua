local M = {}

local folderPath = "Data"
local fileName = folderPath .. "/VehiclesItems.json"
local status = require("Func/Core/SharedStatus")
local Logger = require("Func/Core/Logger")

local function EscapeString(s)
	if not s then return "Unknown" end
	s = s:gsub("\\", "\\\\")
	s = s:gsub("\"", "\\\"")
	return s
end

-- fallback guess from id for type/category
local function InferVehicleCategoryFromTags(tags)
	for _, tag in ipairs(tags) do
		local lower = tag:lower()
		if lower:find("bike") then return "Sport Bike" end
	end
	for _, tag in ipairs(tags) do
		local lower = tag:lower()
		if lower:find("sport") then return "Sport Vehicle" end
	end
	for _, tag in ipairs(tags) do
		local lower = tag:lower()
		if lower:find("utility") then return "Utility Vehicle" end
	end
	return "Standard"
end

local function InferFaction(record, id)
	local faction = nil

	-- Try getting from Affiliation() → LocalizedName() → Game.GetLocalizedTextByKey()
	local success, aff = pcall(function() return record:Affiliation() end)
	if success and aff then
		local ok, locKey = pcall(function() return aff:LocalizedName() end)
		if ok and locKey then
			local text = Game.GetLocalizedTextByKey(locKey)
			if text and text ~= "" and text ~= "Label Not Found" and text ~= "No Affiliation" then
				faction = EscapeString(text)
			end
		end
	end

	-- Fallback if no valid affiliation (missing or "No Affiliation")
	if not faction then
		local groups = {
			["tyger"] = "Tyger Claws",
			["maelstrom"] = "Maelstrom",
			["voodoo"] = "Voodoo Boys",
			["mox"] = "Moxes",
			["netwatch"] = "NetWatch",
			["animal"] = "Animals",
			["militech"] = "Militech",
			["nomad"] = "Nomads",
			["player"] = "Player",
			["ncpd"] = "Police",
			["max"] = "Maxtac",
			["arasaka"] = "Arasaka",
			["barghest"] = "Barghest",
			["sixth"] = "Sixth Street",
			["valentino"] = "Valentinos",
			["scavengers"] = "Scavs"
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



local function GetTags(record)
	local tags = {}
	local success, result = pcall(function() return record:Tags() end)
	if success and result then
		for _, tag in ipairs(result) do
			table.insert(tags, "\"" .. EscapeString(tag.value) .. "\"")
		end
	end
	return tags
end

local function GetDisplayName(record)
	local success, key = pcall(function() return record:DisplayName() end)
	if success and key then
		local text = Game.GetLocalizedTextByKey(key)
		if text and text ~= "" and text ~= "Label Not Found" then
			return EscapeString(text)
		end
	end
	return "Unknown"
end

local function getVehicleInfoLore(record, id)
	local info = {
		description = "No Description Available",
		productionYear = nil
	}

	local success, ui = pcall(function() return record:VehicleUIData() end)
	if success and ui then
		local okDesc, _ = pcall(function() return ui:Info() end)
		if okDesc then
			local text = Game.GetLocalizedText(ui:Info())
			if text and text ~= "" and text ~= "Label Not Found" then
				info.description = EscapeString(text)
			end
		end

		local okYear, year = pcall(function() return ui:ProductionYear() end)
		if okYear and year then
			info.productionYear = tostring(year)
		end
	end

	return info
end



local function getManufacturerName(record)
	local success, mfr = pcall(function() return record:Manufacturer() end)
	if success and mfr then
		local okName, name = pcall(function() return mfr:EnumName() end)
		if okName and name and name ~= "" then
			return EscapeString(name)
		end
	end
	return "Unlisted"
end


function M.Dump()
    Logger.Log("[EasyTrainerDataGetter] Dumping in-game vehicle records...")

    local file = io.open(fileName, "w")
    if not file then
        Logger.Log("[EasyTrainerDataGetter] Failed to open output file.")
        return
    end

    file:write("[\n")

    local records = TweakDB:GetRecords("gamedataVehicle_Record")
    local count, first = 0, true

    for _, record in ipairs(records) do
        local success, id = pcall(function() return record:GetID().value end)
        if success and id and id:find("^Vehicle%.v_") then
            local name = GetDisplayName(record)
            --name = SanitizeName(name)
            local tags = GetTags(record)
            local category = InferVehicleCategoryFromTags(tags)
            local faction = InferFaction(record, id)
            local vehicleInfoLore = getVehicleInfoLore(record, id)
            local manufacturerName = getManufacturerName(record)

            if not first then file:write(",\n") else first = false end
         file:write(string.format(
			'  { "id": "%s", "name": "%s", "manufacturer": "%s", "category": "%s", "faction": "%s", "tags": [%s], "vehicleInfoLore": { "description": "%s", "productionYear": "%s" } }',
			EscapeString(id), EscapeString(name), manufacturerName, category, faction, table.concat(tags, ", "),
			vehicleInfoLore.description,
			EscapeString(vehicleInfoLore.productionYear or "")
			))

            count = count + 1
        end
    end

    file:write("\n]\n")
    file:close()

    if count > 0 then
        status.SetDumpStatus("VehiclesItems", "Complete")
        Logger.Log(string.format("[EasyTrainerDataGetter] Wrote %d vehicles to %s", count, fileName))
    else
        status.SetDumpStatus("VehiclesItems", "Error")
        Logger.Log("[EasyTrainerDataGetter] No vehicle records found.")
    end
end


return M
