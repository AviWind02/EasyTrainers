local Logger = require("Core/Logger")
local DataUtils = require("Utils/DataExtractors/DataUtils")

local PerkLoader = {
    attribute = {},
    indexById = {},
    categoryNames = {}
}

local ATTRIBUTE_KEYS = {
    { "Body", "Body" },
    { "Cool", "Cool" },
    { "Intelligence", "Intelligence" },
    { "Reflexes", "Reflexes" },
    { "Tech", "Technical Ability" },
    { "Espionage", "Relic" }
}

local function GuessAttribute(id)
    if not id then return "Unknown" end
    for _, entry in ipairs(ATTRIBUTE_KEYS) do
        if id:find(entry[1], 1, true) then return entry[2] end
    end
    return "Unknown"
end

local function GetRequirements(record)
    local requirements = { perks = {}, prereqId = nil }
    if not record then return requirements end

    for i = 0, record:GetRequiresPerksCount() - 1 do
        local required = record:GetRequiresPerksItem(i)
        if required then
            table.insert(requirements.perks, {
                id = required:GetID().value,
                name = DataUtils.GetLocalizedText(required:Loc_name_key()),
                type = required:Type()
            })
        end
    end

    local prereq = record:Requirement()
    if prereq then requirements.prereqId = prereq:GetID().value end

    return requirements
end

function PerkLoader:CategoryName(categoryRecord)
    local categoryID = categoryRecord and categoryRecord:GetID().value or "Unknown"
    local name = self.categoryNames[categoryID]
    if name or not categoryRecord then return name end

    name = categoryRecord:EnumComment() or tostring(categoryRecord:EnumName())
    self.categoryNames[categoryID] = name
    return name
end

function PerkLoader:LoadAll()
    local records = TweakDB:GetRecords("gamedataNewPerk_Record")
    if not records or #records == 0 then
        Logger.Log("PerkLoader: no perk records found")
        return
    end

    for _, record in ipairs(records) do
        local id = DataUtils.SafeCall(function() return record:GetID().value end)
        if id then
            local attribute = GuessAttribute(id)
            local data = {
                id = id,
                name = DataUtils.GetLocalizedText(record:Loc_name_key()),
                description = DataUtils.StripRichText(DataUtils.GetLocalizedText(record:Loc_desc_key())),
                category = self:CategoryName(record:Category()) or "Uncategorized",
                attribute = attribute,
                type = record:Type(),
                requirements = GetRequirements(record)
            }

            self.attribute[attribute] = self.attribute[attribute] or {}
            self.attribute[attribute][id] = data
            self.indexById[id] = data
        end
    end

    Logger.Log(string.format("PerkLoader: loaded %d perks across %d attributes", DataUtils.Count(self.indexById), DataUtils.Count(self.attribute)))
end

function PerkLoader:GetAll()
    return self.indexById
end

function PerkLoader:GetById(id)
    return self.indexById[id]
end

return PerkLoader
