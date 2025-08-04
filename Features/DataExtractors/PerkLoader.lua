local Logger = require("Core/Logger")

local PerkLoader = {
    attribute = {},   
    indexById = {},    
    categoryNames = {}  
}


local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

local function countTable(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end


local perkCatKeys = {
    { key = "Body", value = "Body" },
    { key = "Cool", value = "Cool" },
    { key = "Intelligence", value = "Intelligence" },
    { key = "Reflexes", value = "Reflexes" },
    { key = "Tech", value = "Technical Ability" },
    { key = "Espionage", value = "Relic" },
}

local function GuessAttributeFromID(id)
    if not id then return "Unknown" end
    for _, entry in ipairs(perkCatKeys) do
        if id:find(entry.key, 1, true) then
            return entry.value
        end
    end
    return "Unknown"
end

local function getLocalizedFromLocKey(locKeyStr)
    if not locKeyStr or locKeyStr == "" then return "Unknown" end

    -- Strip "LocKey#" to get the numeric part
    local numID = tostring(locKeyStr):upper():match("LOCKEY#(%d+)")
    if not numID then return locKeyStr end

    local ok, result = pcall(function()
        return Game.GetLocalizedTextByKey(CName.new(tonumber(numID)))
    end)

    return ok and result or locKeyStr
end

local function StripRichTextTags(text)
    if not text then return "" end

    text = text:gsub("{float_%d+}", " ")
    text = text:gsub("{int_%d+}", " ")
    text = text:gsub("<.->", "")
    text = text:gsub("[+%%]+", "") 
    text = text:gsub("%s+", " ") 
    text = text:gsub("^%s*(.-)%s*$", "%1")

    return text
end


function PerkLoader:LoadAll()
    local perkRecords = TweakDB:GetRecords("gamedataNewPerk_Record")
    if not perkRecords or #perkRecords == 0 then
        Logger.Log("[EasyTrainerPerkLoader] No perk records found.")
        return
    end

    for _, rec in ipairs(perkRecords) do
        local id = safeCall(function() return rec:GetID().value end)
        if id then
            local catRecord = rec:Category()
            local catID = catRecord and catRecord:GetID().value or "Unknown"
            local catName = self.categoryNames[catID]
            if not catName and catRecord then
                catName = catRecord:EnumComment() or tostring(catRecord:EnumName())
                self.categoryNames[catID] = catName
            end

            local attribute = GuessAttributeFromID(id)
            local data = {
                id = id,
                name = getLocalizedFromLocKey(rec:Loc_name_key()),
                description = StripRichTextTags(getLocalizedFromLocKey(rec:Loc_desc_key())),
                category = catName or "Uncategorized",
                attribute = attribute,
                type = rec:Type()
            }

            self.attribute[attribute] = self.attribute[attribute] or {}
            self.attribute[attribute][id] = data
            self.indexById[id] = data
        end
    end

    Logger.Log(string.format(
        "[EasyTrainerPerkLoader] Loaded %d perks across %d attributes.",
        countTable(self.indexById),
        countTable(self.attribute)
    ))
end


function PerkLoader:GetAll()
    return self.perks
end

function PerkLoader:GetById(id)
    return self.indexById[id]
end

return PerkLoader
