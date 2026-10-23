local Logger = require("Core/Logger")
local DataUtils = require("Utils/DataExtractors/DataUtils")

local GeneralLoader = {
    items = {},
    indexById = {}
}

local OBSOLETE_MARKER = "!OBSOLETE"

local EXCLUDED_IDS = {
    "Left_Hand", "FunctionalTests", "TEST.", "CPO", "KERS", "Tutorial",
    "Items.Inhaler", "Items.Injector", "Items.LongLasting",
    "_Arasaka", "_Oda_S", "BaseDeck", "NPC", "Test", "Silenced",
    "SemiAuto", "_V_", "Generic", "Items.Silverhand_Malorian",
    "Items.SimpleWeaponMod10", "IntrinsicFabricEnhancer",
    "Items.Dummy", "Items.PowerWeaponMod", "Items.TechWeaponMod",
    "Items.SmartWeaponMod", "knuckledusters", "Items.Preset_Knuckles",
    "Smasher_HMG", "HMG_Sasquatch", "HMG_turret", "Minotaur_HMG",
    "HMG_Invisible", "Items.Panzer_", "Items.Panam_Vehicle",
    "Items.Vehicle_", "Items.RareMaterial2",
    "Items.EpicMaterial2", "Items.LegendaryMaterial2"
}

local PARENT_CATEGORIES = {
    WeaponMods = { "ChimeraMod", "ThrowMod", "BluntMod", "BladeMod", "MeleeMod", "RangedMod", "GenericRangedMod", "WeaponMod" },
    Consumables = {
        "PermanentFood", "PermanentHealthFood", "IllegalFood", "Injector", "Inhaler", "Drug", "Medical",
        "Alcohol", "Drink", "Food", "Edible", "InjectorPlus", "InhalerPlus"
    },
    CraftingMaterials = { "CraftingPart", "QuickhackCraftingMaterials", "FabricEnhancer", "DeprecatedFabricEnhancer", "LegendaryAttachment" },
    SkillShards = {
        "MoneyShard", "PerkSkillbook", "LargeSkillbook", "skillbook", "SkillbookReward_Tech", "SkillbookReward_Int",
        "SkillbookReward_Body", "SkillbookReward_Cool", "SkillbookReward_Ref"
    },
    CyberdeckShards = { "Tier6Shard", "Tier4Shard", "Tier3Shard", "Tier2Shard", "Tier1Shard", "Tier0Shard", "pShard", "SoftwareShard" },
    Readables = { "Shard", "Readable", "Fragment" },
    Miscellaneous = { "Jewellery", "SexToy", "Junk", "Prop" },
    Reward = { "CourierReward", "AirDropReward", "MoneyShard", "Currency", "CasinoChip" },
    Quest = { "Quest" },
    Cyberware = { "OperatingSystem", "Skeleton", "Circulatory", "Integumentary", "NervousSystem", "Ocular", "Boosters", "Tattoos", "Misc" }
}

local PARENT_ORDER = {
    "Quest",
    "Consumables",
    "CraftingMaterials",
    "WeaponMods",
    "SkillShards",
    "CyberdeckShards",
    "Reward",
    "Readables",
    "Miscellaneous",
    "Cyberware"
}

local CYBERWARE_BUCKETS = {
    { "OperatingSystem", { "deck", "sandevistan", "berserk", "mk" } },
    { "Skeleton", { "muscle", "marrow", "bone", "joint", "tissue" } },
    { "Circulatory", { "heart", "lung", "blood" } },
    { "Integumentary", { "skin", "armor", "plating" } },
    { "NervousSystem", { "reflex", "perception", "synaptic", "cogito", "neofiber", "kerenzikov" } },
    { "Ocular", { "optics", "kiroshi" } },
    { "Boosters", { "booster", "injector", "memory", "resistance", "capacity" } },
    { "Tattoos", { "tattoo" } }
}

local function Contains(values, wanted)
    for _, value in ipairs(values) do
        if value == wanted then return true end
    end
    return false
end

local function ContainsAny(text, needles)
    for _, needle in ipairs(needles) do
        if text:find(needle, 1, true) then return true end
    end
    return false
end

local function ShallowCopy(source)
    local copy = {}
    for key, value in pairs(source) do copy[key] = value end
    return copy
end

local function GetTags(record)
    local tags = {}
    local count = DataUtils.SafeCall(function() return record:GetTagsCount() end) or 0
    for i = 0, count - 1 do
        local tag = DataUtils.SafeCall(function() return record:GetTagsItem(i).value end)
        if tag then table.insert(tags, tag) end
    end
    return tags
end

local function IsExcluded(id)
    if not id or not id:find("^Items%.") then return true end
    if id:find("<.+>") then return true end
    return ContainsAny(id, EXCLUDED_IDS)
end

local function IsObsolete(record)
    local displayName = record:DisplayName()
    if displayName == nil then return false end

    local text = Game.GetLocalizedTextByKey(CName.new(tonumber(displayName.hash_lo)))
    return text ~= nil and text:upper() == OBSOLETE_MARKER
end

local function BuildItem(id, name, record)
    return {
        id = id,
        name = name,
        quality = DataUtils.SafeCall(function() return record:Quality():GetID().value end),
        canDrop = DataUtils.SafeCall(function() return record:CanDrop() end) or false,
        isGarment = DataUtils.SafeCall(function() return record:IsGarment() end) or false,
        isCoreCW = DataUtils.SafeCall(function() return record:IsCoreCW() end) or false,
        isCustomizable = DataUtils.SafeCall(function() return record:IsCustomizable() end) or false,
        isCraftable = name:lower():find("craftable", 1, true) ~= nil or id:lower():find("craftable", 1, true) ~= nil,
        tags = GetTags(record)
    }
end

function GeneralLoader:LoadAll()
    self.items = {}
    self.indexById = {}

    local records = DataUtils.TableMerge(
        TweakDB:GetRecords("gamedataItem_Record"),
        TweakDB:GetRecords("gamedataConsumableItem_Record")
    )
    if #records == 0 then
        Logger.Log("GeneralLoader: no item records found")
        return
    end

    for _, record in ipairs(records) do
        local id = DataUtils.SafeCall(function() return record:GetID().value end)
        if not IsExcluded(id) and not self.indexById[id] then
            local name = DataUtils.GetDisplayName(record) or "Unknown"
            if name ~= "Unknown" and not IsObsolete(record) then
                local item = BuildItem(id, name, record)
                table.insert(self.items, item)
                self.indexById[id] = item
            end
        end
    end

    Logger.Log(string.format("GeneralLoader: loaded %d items across %d categories", #self.items, #PARENT_ORDER))
end

function GeneralLoader:GetAll()
    return self.items
end

function GeneralLoader:GetById(id)
    return self.indexById[id]
end

local function AssignToCategory(item, categorized)
    for _, parent in ipairs(PARENT_ORDER) do
        local primary = nil
        local additional = {}

        for _, sub in ipairs(PARENT_CATEGORIES[parent]) do
            if Contains(item.tags, sub) then
                if primary then
                    table.insert(additional, sub)
                else
                    primary = sub
                end
            end
        end

        if primary then
            local entry = ShallowCopy(item)
            if #additional > 0 then entry.AdditionalTags = additional end
            table.insert(categorized[parent][primary], entry)
            return true
        end
    end
    return false
end

local function AssignToUncategorized(item, categorized)
    local parentTag = item.tags[1] or "Unknown"
    local bucket = categorized.Uncategorized[parentTag] or {}
    categorized.Uncategorized[parentTag] = bucket

    local entry = ShallowCopy(item)
    if #item.tags > 1 then
        entry.AdditionalTags = {}
        for i = 2, #item.tags do table.insert(entry.AdditionalTags, item.tags[i]) end
    end
    table.insert(bucket, entry)
end

local function CategorizeCyberware(items)
    local categories = { Misc = {} }
    for _, bucket in ipairs(CYBERWARE_BUCKETS) do categories[bucket[1]] = {} end

    for _, item in ipairs(items) do
        local id = (item.id or ""):lower()
        local target = "Misc"
        for _, bucket in ipairs(CYBERWARE_BUCKETS) do
            if ContainsAny(id, bucket[2]) then
                target = bucket[1]
                break
            end
        end
        table.insert(categories[target], ShallowCopy(item))
    end

    return categories
end

function GeneralLoader:Categorize()
    local categorized = { Uncategorized = {} }
    for _, parent in ipairs(PARENT_ORDER) do
        categorized[parent] = {}
        for _, sub in ipairs(PARENT_CATEGORIES[parent]) do
            categorized[parent][sub] = {}
        end
    end

    local cyberware = {}
    for _, item in ipairs(self.items) do
        if item.tags and #item.tags > 0 then
            if Contains(item.tags, "Cyberware") then
                table.insert(cyberware, item)
            elseif not AssignToCategory(item, categorized) then
                AssignToUncategorized(item, categorized)
            end
        end
    end

    categorized.Cyberware = CategorizeCyberware(cyberware)
    return categorized
end

return GeneralLoader
