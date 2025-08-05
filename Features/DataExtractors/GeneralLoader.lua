local Logger = require("Core/Logger")
local Utils = require("Features/DataExtractors/Utils")

local GeneralLoader = { items = {}, indexById = {} }

local function GetTypeName(record)
    local typeRaw = Utils.SafeCall(function() return record:ItemType():Name().value end)
    local typeName = nil

    if typeRaw then
        local rec = TweakDB:GetRecord("ItemTypes." .. typeRaw)
        local key = rec and (rec:LocalizedName() or rec:DisplayName())
        local text = key and Utils.GetLocalizedSafe(key)

        if text then
            typeName = text
        else
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

    return Utils.EscapeString(typeName or "Unknown"), typeRaw
end

function GeneralLoader:LoadAll()
    local records = TweakDB:GetRecords("gamedataItem_Record")
    if not records or #records == 0 then
        Logger.Log("[EasyTrainerGeneralLoader] No item records found.")
        return
    end

    for _, rec in ipairs(records) do
        local id = Utils.SafeCall(function() return rec:GetID().value end)
        if id and id:find("^Items%.") then
            local typeName, typeRaw = GetTypeName(rec)
            local data = {
                id = id,
                name = Utils.GetDisplayName(rec, typeRaw),
                typeName = typeName,
                quality = Utils.InferQuality(id),
                description = Utils.GetDescription(rec),
                tags = Utils.GetTags(rec)
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
