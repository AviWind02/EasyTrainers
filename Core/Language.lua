local json = {
    decode = json.decode,
    encode = json.encode
}

local Language = {}

Language.currentLang = "en"
Language.translations = {}

local function splitKey(key)
    local parts = {}
    for part in string.gmatch(key, "[^%.]+") do
        table.insert(parts, part)
    end
    return parts
end

function Language.Load(langCode)
    Language.currentLang = langCode or "en"
    local path = string.format("lang/%s.json", Language.currentLang)

    local file = io.open(path, "r")
    if not file then
        print("[Language] Failed to open: " .. path)
        return false
    end

    local content = file:read("*a")
    file:close()

    local ok, data = pcall(function()
        return json.decode(content)
    end)

    if ok and type(data) == "table" then
        Language.translations = data
        return true
    else
        print("[Language] Failed to parse: " .. path)
        return false
    end
end

function Language.Get(key)
    local val = Language.translations
    local lastStr = nil
    local lastPart = nil

    for part in string.gmatch(key, "[^%.]+") do
        lastPart = part 

        if type(val) == "table" then
            val = val[part]
            if type(val) == "string" then
                lastStr = val
            end
        else
            break
        end
    end

    return lastStr or lastPart or key
end



function Language.tip(key, placeholders)
    local tipText = Language.Get(key)

    if type(placeholders) == "table" then
        for placeholder, value in pairs(placeholders) do
            local resolved = Language.Get(value) or value
            tipText = tipText:gsub("{" .. placeholder .. "}", resolved)
        end
    end

    return tipText
end

L = function(key) return Language.Get(key) end
tip = function(key, placeholders) return Language.tip(key, placeholders) end



return Language
