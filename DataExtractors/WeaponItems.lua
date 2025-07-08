local M = {}

local folderPath = "Data"
local fileName = folderPath .. "/WeaponsItems.json"
local status = require("Func/Core/SharedStatus")

local function EscapeString(s)
	if not s then return "Unknown" end
	s = s:gsub("\\", "\\\\")
	s = s:gsub("\"", "\\\"")
	return s
end

local wallWeaponIDs = {
	["Items.Preset_Grad_Panam"] = true,
	["Items.Preset_Carnage_Mox"] = true,
	["Items.Preset_Nue_Jackie"] = true,
	["Items.Preset_Katana_Saburo"] = true,
	["Items.Preset_Katana_Takemura"] = true,
	["Items.Preset_Overture_Kerry"] = true,
	["Items.Preset_Liberty_Dex"] = true,
	["Items.Preset_Ajax_Moron"] = true,
	["Items.Preset_Copperhead_Genesis"] = true,
	["Items.Preset_Tactician_Headsman"] = true,
	["Items.Preset_Pulsar_Buzzsaw"] = true,
	["Items.Preset_Igla_Sovereign"] = true,
	["Items.Preset_Dian_Yinglong"] = true,
	["Items.Preset_Nekomata_Breakthrough"] = true,
	["Items.Preset_Burya_Comrade"] = true,
	["Items.Preset_Zhuo_Eight_Star"] = true,
	["Items.mq007_skippy"] = true,
	["Items.Preset_Silverhand_3516"] = true,
	["Items.sq029_rivers_gun"] = true
}

local function GetTags(record)
	local tags = {}
	local ok, result = pcall(function() return record:Tags() end)
	if ok and result then
		for _, tag in ipairs(result) do
			table.insert(tags, tag.value)
		end
	end
	return tags
end

local function EscapeTags(tags)
	local out = {}
	for _, t in ipairs(tags) do
		table.insert(out, "\"" .. EscapeString(t) .. "\"")
	end
	return out
end

local function GetLocalizedDescription(record)
	local ok, cname = pcall(function() return record:GameplayDescription() end)
	if ok and cname then
		local text = Game.GetLocalizedText(cname)
		if text and text ~= "" and text ~= "Label Not Found" then
			return EscapeString(text)
		end
	end
	return "No description"
end

local function IsWallWeapon(id)
	return wallWeaponIDs[id] == true
end

local function GetWeaponLore(record)
	local name = "Unlisted"
	local ok, mfr = pcall(function() return record:Manufacturer() end)
	if ok and mfr then
		local okName, mfrName = pcall(function() return mfr:Name() end)
		if okName and mfrName then
			name = EscapeString(mfrName)
		end
	end
	return { manufacturer = name }
end

local function GetReadableRarity(record, id)
	local value = nil
	local ok, quality = pcall(function() return record:Quality() end)
	if ok and quality and quality:Type() then
		local ok2, val = pcall(function() return quality:Type().value end)
		if ok2 and val and val ~= "" then
			value = val
		end
	end

	local lowerValue = value and value:lower() or ""
	local lowerId = id:lower()

	local readableMap = {
		legendaryplusplus= "Legendary++",
		legendaryplus= "Legendary+",
		legendary= "Legendary",
		epic= "Epic",
		rare= "Rare",
		uncommon= "Uncommon",
		common= "Common",
		base= "Base"
	}

	-- Try matching known rarity patterns
	for key, display in pairs(readableMap) do
		if lowerValue:find(key) then
			return display
		end
	end

	-- Try fallback from ID
	for key, display in pairs(readableMap) do
		if lowerId:find(key) then
			return display
		end
	end

	-- If we got an actual value, return it
	if value then return value end

	-- Default fallback if no data at all
	return "Standard"
end


local function GetWeaponStats(record, tags, id)
	local stats = {
		type = "Miscellaneous",
		rarity = GetReadableRarity(record, id),
		iconic = false,
		isTech = false,
		isSmart = false,
		isPower = false
	}

	local tagMap = {}
	for _, tag in ipairs(tags) do
		tagMap[tag:lower()] = true
	end

	local typeMap = {
		handgun="Handgun",
		revolver="Revolver",
		smg="SMG",
		sniper="Sniper",
		shotgun="Shotgun",
		lmg="LMG",
		hmg="Heavy Machine Gun",
		["rifle assault"]="Assault Rifle",
		["rifle precision"]="Precision Rifle",
		katana="Katana",
		blade="Blade",
		blunt="Blunt",
		machete="Machete",
		chainsword="Chainsword",
		knife="Knife",
		cyberware="Cyberware Melee",
		meleeweapon="Melee"
	}

	for key, label in pairs(typeMap) do
		for tag in pairs(tagMap) do
			if tag:find(key) then
				stats.type = label
				break
			end
		end
		if stats.type ~= "Miscellaneous" then break end
	end

	if stats.type == "Miscellaneous" and tagMap["rangedweapon"] then
		stats.type = "Ranged"
	end

	stats.iconic = tagMap["iconicweapon"] or false
	stats.isTech = tagMap["techweapon"] or false
	stats.isSmart = tagMap["smartweapon"] or false
	stats.isPower = tagMap["powerweapon"] or false

	return stats
end





function M.Dump()
	print("[EasyTrainerDataGetter] Dumping in-game weapon records...")

	local file = io.open(fileName, "w")
	if not file then
		print("[EasyTrainerDataGetter] Failed to open output file.")
		return
	end

	file:write("[\n")

	local records = TweakDB:GetRecords("gamedataWeaponItem_Record")
	local count, first = 0, true

	for _, record in ipairs(records) do
		local ok, id = pcall(function() return record:GetID().value end)
		if ok and id and id:find("^Items%.") then
			local tags = GetTags(record)
			local escapedTags = EscapeTags(tags)
			local stats = GetWeaponStats(record, tags, id)
			local onWall = IsWallWeapon(id)
			local lore = GetWeaponLore(record)

			if not first then file:write(",\n") else first = false end

			file:write(string.format(
				'  { "id": "%s", "onWall": %s, "tags": [%s], "stats": { "type": "%s", "rarity": "%s", "iconic": %s, "isTech": %s, "isSmart": %s, "isPower": %s }, "weaponLore": { "manufacturer": "%s" } }',
				EscapeString(id),
				tostring(onWall),
				table.concat(escapedTags, ", "),
				EscapeString(stats.type),
				EscapeString(stats.rarity),
				tostring(stats.iconic),
				tostring(stats.isTech),
				tostring(stats.isSmart),
				tostring(stats.isPower),
				lore.manufacturer
			))

			count = count + 1
		end
	end

	file:write("\n]\n")
	file:close()

	if count > 0 then
		status.SetDumpStatus("WeaponsItems", "Complete")
		print(string.format("[EasyTrainerDataGetter] Wrote %d weapons to %s", count, fileName))
	else
		status.SetDumpStatus("WeaponsItems", "Error")
		print("[EasyTrainerDataGetter] No weapon records found.")
	end


end

return M
