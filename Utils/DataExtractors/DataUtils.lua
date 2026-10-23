local DataUtils = {}

local QUALITY_PATTERNS = {
    { "legendaryplusplus", "Legendary++" },
    { "legendaryplus", "Legendary+" },
    { "legendary", "Legendary" },
    { "epicplus", "Epic+" },
    { "epic", "Epic" },
    { "rareplus", "Rare+" },
    { "uncommon", "Uncommon" },
    { "rare", "Rare" },
    { "common", "Common" },
    { "iconic", "Iconic" }
}

function DataUtils.SafeCall(callback, ...)
    local ok, result = pcall(callback, ...)
    return ok and result or nil
end

function DataUtils.EscapeString(text)
    if type(text) ~= "string" or text == "" then return "Unknown" end
    return (text:gsub("([\\\"])", "\\%1"))
end

function DataUtils.Count(values)
    local count = 0
    for _ in pairs(values) do count = count + 1 end
    return count
end

function DataUtils.StripRichText(text)
    if not text then return "" end
    text = text:gsub("{float_%d+}", " ")
    text = text:gsub("{int_%d+}", " ")
    text = text:gsub("<.->", "")
    text = text:gsub("[+%%]+", "")
    text = text:gsub("%s+", " ")
    return (text:gsub("^%s*(.-)%s*$", "%1"))
end

function DataUtils.GetLocalizedText(locKey)
    if not locKey or locKey == "" then return "Unknown" end

    local numericID = tostring(locKey):upper():match("LOCKEY#(%d+)")
    if not numericID then return locKey end

    local ok, result = pcall(Game.GetLocalizedTextByKey, CName.new(tonumber(numericID)))
    return ok and result or locKey
end

function DataUtils.GetLocalizedSafe(key)
    local result = DataUtils.SafeCall(Game.GetLocalizedTextByKey, key)
    if not result or result == "Label Not Found" then return nil end
    return result
end

function DataUtils.GetTags(record)
    local raw = DataUtils.SafeCall(function() return record:Tags() end)
    if type(raw) ~= "table" then return {} end

    local tags = {}
    for _, tag in ipairs(raw) do
        if tag.value then table.insert(tags, tag.value) end
    end
    return tags
end

function DataUtils.HasTag(tags, name)
    local lowered = name:lower()
    for _, tag in ipairs(tags) do
        if tag:lower() == lowered then return true end
    end
    return false
end

function DataUtils.InferQuality(id)
    local lowered = id:lower()
    for _, pattern in ipairs(QUALITY_PATTERNS) do
        if lowered:find(pattern[1], 1, true) then return pattern[2] end
    end
    return "Unknown"
end

function DataUtils.GetDisplayName(record, fallbackType)
    local name = nil
    local key = DataUtils.SafeCall(function() return record:DisplayName() end)
    if key then name = DataUtils.GetLocalizedSafe(key) end

    if not name and fallbackType then
        name = DataUtils.GetLocalizedSafe("Items." .. fallbackType)
    end

    return DataUtils.EscapeString(name or fallbackType or "Unknown")
end

function DataUtils.GetDescription(record)
    local key = DataUtils.SafeCall(function() return record:LocalizedDescription() end)
    local text = key and DataUtils.GetLocalizedSafe(key) or nil
    if not text then return "Unknown" end
    return DataUtils.EscapeString(text)
end

function DataUtils.TableMerge(...)
    local result = {}
    for i = 1, select("#", ...) do
        local values = select(i, ...)
        if type(values) == "table" then
            for _, value in ipairs(values) do table.insert(result, value) end
        end
    end
    return result
end

return DataUtils
