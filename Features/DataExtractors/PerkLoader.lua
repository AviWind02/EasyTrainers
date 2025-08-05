local Logger = require("Core/Logger")
local utils = require("Features/DataExtractors/Utils")

local PerkLoader = {
    attribute = {},
    indexById = {},
    categoryNames = {}
}

local perkCatKeys = {
    { key = "Body", value = "Body" },
    { key = "Cool", value = "Cool" },
    { key = "Intelligence", value = "Intelligence" },
    { key = "Reflexes", value = "Reflexes" },
    { key = "Tech", value = "Technical Ability" },
    { key = "Espionage", value = "Relic" },
}

local function GuessAttributeFromId(id)
    if not id then return "Unknown" end
    for _, entry in ipairs(perkCatKeys) do
        if id:find(entry.key, 1, true) then
            return entry.value
        end
    end
    return "Unknown"
end

function PerkLoader:LoadAll()
    local perkRecords = TweakDB:GetRecords("gamedataNewPerk_Record")
    if not perkRecords or #perkRecords == 0 then
        Logger.Log("[EasyTrainerPerkLoader] No perk records found.")
        return
    end

    for _, rec in ipairs(perkRecords) do
        local id = utils.SafeCall(function() return rec:GetID().value end)
        if id then
            local catRecord = rec:Category()
            local catId = catRecord and catRecord:GetID().value or "Unknown"
            local catName = self.categoryNames[catId]

            if not catName and catRecord then
                catName = catRecord:EnumComment() or tostring(catRecord:EnumName())
                self.categoryNames[catId] = catName
            end

            local attribute = GuessAttributeFromId(id)
            local data = {
                id = id,
                name = utils.GetLocalizedText(rec:Loc_name_key()),
                description = utils.StripRichText(utils.GetLocalizedText(rec:Loc_desc_key())),
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
        utils.Count(self.indexById),
        utils.Count(self.attribute)
    ))
end

function PerkLoader:GetAll()
    return self.indexById
end

function PerkLoader:GetById(id)
    return self.indexById[id]
end

return PerkLoader
