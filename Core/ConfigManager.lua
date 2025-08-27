local JsonHelper = require("Core/JsonHelper")
local Logger = require("Core/Logger")

local ConfigManager = {
    filePath = "options.json",
    registry = {},
    _cachedData = nil
}

function ConfigManager.Register(key, ref, default)
    if not ref or type(ref) ~= "table" or ref.value == nil then
        Logger.Log("Tried to register invalid ref: " .. tostring(key))
        return
    end

    if ConfigManager.registry[key] then return end

    ConfigManager.registry[key] = { ref = ref, default = default }

    if ConfigManager._cachedData and ConfigManager._cachedData[key] ~= nil then
        ref.value = ConfigManager._cachedData[key]
    elseif ref.value == nil and default ~= nil then
        ref.value = default
    end
end

function ConfigManager.Save()
    local existing = JsonHelper.Read(ConfigManager.filePath)
    if type(existing) ~= "table" then existing = {} end

    local changed = false
    for key, entry in pairs(ConfigManager.registry) do
        local oldVal = existing[key]
        local newVal = entry.ref.value
        if oldVal ~= newVal then
            existing[key] = newVal
            changed = true
        end
    end

    if changed then
        local ok, err = JsonHelper.Write(ConfigManager.filePath, existing)
        if not ok then
            Logger.Log("Failed to save: " .. tostring(err))
        else
            Logger.Log("Saved " .. ConfigManager.filePath)
        end
    end
end

function ConfigManager.Load()
    local data, err = JsonHelper.Read(ConfigManager.filePath)
    if not data then
        Logger.Log("No " .. ConfigManager.filePath .. " loaded: " .. tostring(err))
        return
    end

    ConfigManager._cachedData = data

    local count = 0
    for _ in pairs(data) do count = count + 1 end
    Logger.Log("Loaded " .. tostring(count) .. " keys from file")

    for key, entry in pairs(ConfigManager.registry) do
        local fileVal = data[key]
        if fileVal ~= nil then
            entry.ref.value = fileVal
        elseif entry.default ~= nil then
            entry.ref.value = entry.default
        end
    end
end

return ConfigManager
