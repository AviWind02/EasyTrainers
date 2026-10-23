local Logger = require("Core/Logger")
local JsonHelper = require("Core/JsonHelper")

local Language = {
    DefaultCode = "en"
}

local s_CurrentCode = "en"
local s_Translations = {}
local s_Fallback = {}

local function IsValidCode(code)
    return type(code) == "string" and code:match("^[%w_%-]+$") ~= nil
end

local function ReadLanguage(code)
    if not IsValidCode(code) then
        return nil, "Invalid language code: " .. tostring(code)
    end

    local path = string.format("lang/%s.json", code)
    local data, err = JsonHelper.Read(path)
    if type(data) ~= "table" then
        return nil, err or ("Unexpected localization format in: " .. path)
    end

    return data
end

local function Lookup(data, key)
    if type(data) ~= "table" or type(key) ~= "string" or key == "" then return nil end

    local value = data
    for part in key:gmatch("[^%.]+") do
        if type(value) ~= "table" then return nil end
        value = value[part]
        if value == nil then return nil end
    end

    return type(value) == "string" and value or nil
end

local function LookupSection(section, code)
    local current = s_Translations[section]
    local fallback = s_Fallback[section]
    return (current and current[tostring(code)]) or (fallback and fallback[tostring(code)])
end

function Language.Load(code)
    local requested = code or Language.DefaultCode
    local fallback, fallbackErr = ReadLanguage(Language.DefaultCode)
    if not fallback then
        Logger.Log("Language: failed to load fallback language (" .. tostring(fallbackErr) .. ")")
        return false
    end

    local data = fallback
    if requested ~= Language.DefaultCode then
        local requestedData, err = ReadLanguage(requested)
        if not requestedData then
            Logger.Log("Language: failed to load '" .. tostring(requested) .. "' (" .. tostring(err) .. ")")
            return false
        end
        data = requestedData
    end

    s_CurrentCode = requested
    s_Translations = data
    s_Fallback = fallback
    Logger.Log("Language: loaded '" .. requested .. "'")
    return true
end

function Language.GetAvailable(folder)
    local languages = {}
    local seen = {}

    for _, entry in ipairs(dir(folder or "lang") or {}) do
        local fileName = type(entry) == "table" and entry.name or entry
        local code = type(fileName) == "string" and fileName:match("^(.+)%.json$") or nil
        if code and IsValidCode(code) and not seen[code] then
            local data = ReadLanguage(code)
            if data then
                local name = Lookup(data, "_meta.name") or Lookup(data, "language.name") or code
                table.insert(languages, { code = code, name = name })
                seen[code] = true
            else
                Logger.Log("Language: ignoring invalid file " .. tostring(fileName))
            end
        end
    end

    table.sort(languages, function(a, b)
        if a.code == Language.DefaultCode then return true end
        if b.code == Language.DefaultCode then return false end
        return a.name:lower() < b.name:lower()
    end)

    return languages
end

function Language.Has(key)
    return Lookup(s_Translations, key) ~= nil or Lookup(s_Fallback, key) ~= nil
end

function Language.Get(key)
    if type(key) ~= "string" then return tostring(key or "") end
    return Lookup(s_Translations, key) or Lookup(s_Fallback, key) or key
end

function Language.GetCurrentCode()
    return s_CurrentCode
end

function Language.GetCurrentName()
    return Lookup(s_Translations, "_meta.name") or Lookup(s_Translations, "language.name") or s_CurrentCode
end

function Language.Tip(key, placeholders)
    local text = Language.Get(key)
    if type(placeholders) ~= "table" then return text end

    for placeholder, value in pairs(placeholders) do
        local resolved = type(value) == "string" and Language.Get(value) or tostring(value)
        text = text:gsub("{" .. placeholder .. "}", function() return resolved end)
    end

    return text
end

function Language.GetInputKey(code)
    return LookupSection("inputkeys", code) or tostring(code)
end

function Language.GetInputButton(code)
    return LookupSection("inputbuttons", code) or "Btn" .. tostring(code)
end

L = Language.Get
tip = Language.Tip

return Language
