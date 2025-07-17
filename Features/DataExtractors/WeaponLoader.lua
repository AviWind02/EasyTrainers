local Logger = require("Core/Logger")


local WeaponLoader = {
    weapons = {}, -- array of WeaponData
    indexById = {}, -- map id -> WeaponData
    typeMap = {
        handgun = "Handgun",
        revolver = "Revolver",
        smg = "SMG",
        sniper = "Sniper",
        shotgun = "Shotgun",
        lmg = "LMG",
        hmg = "Heavy Machine Gun",
        ["rifle assault"] = "Assault Rifle",
        ["rifle precision"] = "Precision Rifle",
        katana = "Katana",
        blade = "Blade",
        blunt = "Blunt",
        machete = "Machete",
        chainsword = "Chainsword",
        knife = "Knife",
        cyberware = "Cyberware Melee",
        meleeweapon = "Melee"
    },
    rarityMap = {
        legendaryplusplus = "Legendary++",
        legendaryplus = "Legendary+",
        legendary = "Legendary",
        epic = "Epic",
        rare = "Rare",
        uncommon = "Uncommon",
        common = "Common",
        base = "Base"
    },
    wallWeaponIds = {
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
}

-- Local helpers
local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

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

local function getRarity(recordId, record)
    local quality = safeCall(function() return record:Quality() end)
    local val = safeCall(function() return quality:Type().value end) or ""
    val = val:lower()
    for key, label in pairs(WeaponLoader.rarityMap) do
        if val:find(key) then
            return label
        end
    end
    for key, label in pairs(WeaponLoader.rarityMap) do
        if recordId:lower():find(key) then
            return label
        end
    end
    return val ~= "" and val or "Standard"
end

local function getType(tags)
    local lowerTags = {}
    for _, t in ipairs(tags) do
        lowerTags[t:lower()] = true
    end
    for key, label in pairs(WeaponLoader.typeMap) do
        for tag in pairs(lowerTags) do
            if tag:find(key) then
                return label
            end
        end
    end
    return lowerTags.rangedweapon and "Ranged" or "Miscellaneous"
end

local function hasTag(tags, name)
    for _, tag in ipairs(tags) do
        if tag:lower() == name then
            return true
        end
    end
    return false
end

function WeaponLoader:LoadAll()
    local records = TweakDB:GetRecords("gamedataWeaponItem_Record")
    if not records or #records == 0 then
        Logger.Log("[EasyTrainerWeaponLoader] No weapon records found.")
        return
    end
    for _, rec in ipairs(records) do
        local id = safeCall(function() return rec:GetID().value end)
        if id and id:find("^Items%.") then
            local tags = getTags(rec)
            local data = {
                id = id,
                displayName = escapeString(safeCall(function() return Game.GetLocalizedTextByKey(rec:DisplayName()) end) or "Unknown"),
                type = getType(tags),
                rarity = getRarity(id, rec),
                manufacturer = escapeString(safeCall(function() return rec:Manufacturer():Name() end) or "Unlisted"),
                iconic = hasTag(tags, "iconicweapon"),
                isTech = hasTag(tags, "techweapon"),
                isSmart = hasTag(tags, "smartweapon"),
                isPower = hasTag(tags, "powerweapon"),
                onWall = WeaponLoader.wallWeaponIds[id] == true,
                tags = tags
            }
            table.insert(self.weapons, data)
            self.indexById[id] = data
        end
    end
    Logger.Log(string.format("[EasyTrainerWeaponLoader] Loaded %d weapons.", #self.weapons))
end

function WeaponLoader:GetAll()
    return self.weapons
end

function WeaponLoader:GetById(id)
    return self.indexById[id]
end

function WeaponLoader:Filter(fn)
    local out = {}
    for _, w in ipairs(self.weapons) do
        if fn(w) then
            table.insert(out, w)
        end
    end
    return out
end

return WeaponLoader