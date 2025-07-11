local M = {}

local folderPath = "Data"
local fileName = folderPath .. "/GeneralItems.json"
local status = require("Func/Core/SharedStatus")
local Logger = require("Func/Core/Logger")

-- handle quotes properly so JSON doesn't break
local function EscapeString(s)
	if not s then return "Unknown" end
	s = s:gsub("\\", "\\\\")
	s = s:gsub("\"", "\\\"")
	return s
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

-- I actually don't know if I can even get the localized version for some of these items.
-- But I'm just going to put this here just in case this works. I don't think it does.
-- I think the fallback's the only thing really doing anything.
local function GetDisplayName(record, itemType)
	local name = "Unknown"
	local success, key = pcall(function() return record:DisplayName() end)
	if success and key then
		local text = Game.GetLocalizedTextByKey(key)
		if text and text ~= "" and text ~= "Label Not Found" then
			name = EscapeString(text)
		end
	end

	if name == "Unknown" and itemType then
		local fallbackKey = "Items." .. itemType
		local fallbackText = Game.GetLocalizedTextByKey(fallbackKey)
		if fallbackText and fallbackText ~= "" and fallbackText ~= "Label Not Found" then
			name = EscapeString(fallbackText)
		end
	end

	return name
end

local function GetDescription(record)
	local success, key = pcall(function() return record:LocalizedDescription() end)
	if success and key then
		local desc = Game.GetLocalizedTextByKey(key)
		if desc and desc ~= "" and desc ~= "Label Not Found" then
			return EscapeString(desc)
		end
	end
	return "Unknown"
end

local function GetTypeName(record)
	local typeName = "Unknown"
	local typeRaw = nil

	local success, result = pcall(function() return record:ItemType():Name().value end)
	if success and result then
		typeRaw = result

		local itemTypeRecord = TweakDB:GetRecord("ItemTypes." .. result)
		if itemTypeRecord then
			local locKey = itemTypeRecord:LocalizedName() or itemTypeRecord:DisplayName()
			if locKey then
				local text = Game.GetLocalizedTextByKey(locKey)
				if text and text ~= "" and text ~= "Label Not Found" then
					typeName = EscapeString(text)
				end
			end
		end

		if typeName == "Unknown" then
			local fallback = {
				["Cyberware"] = "Cyberware",
				["CyberwareStatsShard"] = "Cyberware Stat Mod",
				["Prt_Mod"] = "Weapon Mod",
				["Prt_Program"] = "Quickhack",
				["Prt_Magazine"] = "Magazine",
				["Prt_Muzzle"] = "Muzzle",
				["Prt_Scope"] = "Scope",
				["Gen_CraftingMaterial"] = "Crafting Material",
				["Gen_Junk"] = "Junk",
				["Gen_Readable"] = "Shard",
				["Gen_Misc"] = "Miscellaneous",
				["Prt_Fragment"] = "Fragment",
				["Prt_Precision_Sniper_RifleMod"] = "Sniper Mod",
				["Prt_BluntMod"] = "Blunt Weapon Mod",
				["Prt_TorsoFabricEnhancer"] = "Armor Mod"
			}
			typeName = fallback[result] or "Unknown"
		end
	end

	return typeName, typeRaw
end

-- I didn't know how to get quality, so we're just going to do it the old fashioned way
local function InferQualityFromID(id)
	local pattern = {
		["LegendaryPlusPlus"] = "Legendary++",
		["LegendaryPlus"] = "Legendary+",
		["Legendary"] = "Legendary",
		["EpicPlus"] = "Epic+",
		["Epic"] = "Epic",
		["RarePlus"] = "Rare+",
		["Rare"] = "Rare",
		["Uncommon"] = "Uncommon",
		["Common"] = "Common",
		["Iconic"] = "Iconic"
	}
	for key, label in pairs(pattern) do
		if id:find(key) then return label end
	end
	return "Unknown"
end

local function GetQuality(id)
	return EscapeString(InferQualityFromID(id))
end

function M.Dump()
    Logger.Log("[EasyTrainerDataGetter] Dumping in-game item records...")

    local file = io.open(fileName, "w")
    if not file then
        Logger.Log("[EasyTrainerDataGetter] Failed to open output file.")
        return
    end

    file:write("[\n")

    local records = TweakDB:GetRecords("gamedataItem_Record")
    local count, first = 0, true

    for _, record in ipairs(records) do
        local success, id = pcall(function() return record:GetID().value end)
        if success and id and id:find("^Items%.") then
            local typeName, typeRaw = GetTypeName(record)
            local name = GetDisplayName(record, typeRaw)
            local description = GetDescription(record)
            local tags = GetTags(record)
            local quality = GetQuality(id)

            if not first then file:write(",\n") else first = false end

            file:write(string.format(
                '  { "id": "%s", "name": "%s", "typeName": "%s", "quality": "%s", "description": "%s", "tags": [%s] }',
                EscapeString(id), name, typeName, quality, description, table.concat(tags, ", ")
            ))

            count = count + 1
        end
    end

    file:write("\n]\n")
    file:close()

    if count > 0 then
        status.SetDumpStatus("GeneralItems", "Complete")
        Logger.Log(string.format("[EasyTrainerDataGetter] Wrote %d items to %s", count, fileName))
    else
        status.SetDumpStatus("GeneralItems", "Error")
        Logger.Log("[EasyTrainerDataGetter] No items found.")
    end
end

return M
