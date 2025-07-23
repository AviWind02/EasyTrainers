local Logger = require("Core/Logger")


local GeneralLoader = { items = {}, indexById = {} }

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
    if type(raw) ~= "table" then return {} end
    local out = {}
    for _, tag in ipairs(raw) do
        if tag.value then table.insert(out, tag.value) end
    end
    return out
end

local function getDisplayName(record, typeRaw)
    local key = safeCall(function() return record:DisplayName() end)
    local name = nil
    if key then
        local text = Game.GetLocalizedTextByKey(key)
        if text and text ~= "Label Not Found" then name = text end
    end
    if not name and typeRaw then
        local fallbackKey = "Items." .. typeRaw
        local text = Game.GetLocalizedTextByKey(fallbackKey)
        if text and text ~= "Label Not Found" then name = text end
    end
    return escapeString(name or typeRaw)
end

local function getDescription(record)
    local key = safeCall(function() return record:LocalizedDescription() end)
    if key then
        local text = Game.GetLocalizedTextByKey(key)
        if text and text ~= "Label Not Found" then return escapeString(text) end
    end
    return "Unknown"
end

local function getTypeName(record)
    local typeRaw = safeCall(function() return record:ItemType():Name().value end)
    local typeName = nil
    if typeRaw then
        local rec = TweakDB:GetRecord("ItemTypes." .. typeRaw)
        local key = rec and (rec:LocalizedName() or rec:DisplayName())
        if key then
            local text = Game.GetLocalizedTextByKey(key)
            if text and text ~= "Label Not Found" then typeName = text end
        end
        if not typeName then
            local fallback = {
                Cyberware = "Cyberware",
                CyberwareStatsShard = "Cyberware Stat Mod",
                Prt_Mod = "Weapon Mod",
                Prt_Program = "Quickhack",
                Prt_Magazine = "Magazine",
                Prt_Muzzle = "Muzzle",
                Prt_Scope = "Scope",
                Gen_CraftingMaterial = "Crafting Material",
                Gen_Junk = "Junk",
                Gen_Readable = "Shard",
                Gen_Misc = "Miscellaneous",
                Prt_Fragment = "Fragment",
                Prt_Precision_Sniper_RifleMod = "Sniper Mod",
                Prt_BluntMod = "Blunt Weapon Mod",
                Prt_TorsoFabricEnhancer = "Armor Mod"
            }
            typeName = fallback[typeRaw]
        end
    end
    return escapeString(typeName or "Unknown"), typeRaw
end

local function inferQuality(id)
    local patterns = {
        LegendaryPlusPlus = "Legendary++",
        LegendaryPlus = "Legendary+",
        Legendary = "Legendary",
        EpicPlus = "Epic+",
        Epic = "Epic",
        RarePlus = "Rare+",
        Rare = "Rare",
        Uncommon = "Uncommon",
        Common = "Common",
        Iconic = "Iconic"
    }
    for key,label in pairs(patterns) do
        if id:find(key) then return label end
    end
    return "Unknown"
end

local function getQuality(id)
    return escapeString(inferQuality(id))
end

function GeneralLoader:LoadAll()
    local records = TweakDB:GetRecords("gamedataItem_Record")
    if not records or #records == 0 then
        Logger.Log("[EasyTrainerGeneralLoader] No item records found.")
        return
    end
    for _, rec in ipairs(records) do
        local id = safeCall(function() return rec:GetID().value end)
        if id and id:find("^Items%.") then
            local typeName, typeRaw = getTypeName(rec)
            local data = {
                id = id,
                name = getDisplayName(rec, typeRaw),
                typeName = typeName,
                quality = getQuality(id),
                description = getDescription(rec),
                tags = getTags(rec)
            }
            table.insert(self.items, data)
            self.indexById[id] = data
        end
    end
    Logger.Log(string.format("[EasyTrainerGeneralLoader] Loaded %d items.", #self.items))
end

function GeneralLoader:GetAll()
    return self.items
end


function GeneralLoader:GetById(id)
    return self.indexById[id]
end


function GeneralLoader:Filter(fn)
    local out = {}
    for _, item in ipairs(self.items) do
        if fn(item) then table.insert(out, item) end
    end
    return out
end

return GeneralLoader
