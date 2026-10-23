local Handler = require("Controls/Handler")
local JsonHelper = require("Core/JsonHelper")
local Logger = require("Core/Logger")

local NavigationConfig = {
    FilePath = "Config/JSON/Navigation.json"
}

local FIELDS = {
    { "ScrollDelayBase", "scrollDelayBase" },
    { "ScrollMinDelay", "scrollMinDelay" },
    { "AccelThreshold", "accelThreshold" },
    { "AccelStep", "accelStep" }
}

local function CollectData()
    local data = {}
    for _, field in ipairs(FIELDS) do data[field[1]] = Handler[field[1]] end
    return data
end

local function ApplyData(data)
    if type(data) ~= "table" then return end
    for _, field in ipairs(FIELDS) do
        local value = tonumber(data[field[1]] or data[field[2]])
        if value then Handler[field[1]] = value end
    end
end

function NavigationConfig.Save()
    local ok, err = JsonHelper.Write(NavigationConfig.FilePath, CollectData())
    if not ok then
        Logger.Log("NavigationConfig: failed to save navigation (" .. tostring(err) .. ")")
        return false
    end
    return true
end

function NavigationConfig.Load()
    local data, _, err = JsonHelper.LoadOrCreate(NavigationConfig.FilePath, CollectData())
    if not data then
        Logger.Log("NavigationConfig: failed to load navigation (" .. tostring(err) .. ")")
        return false
    end

    ApplyData(data)
    Logger.Log("NavigationConfig: navigation settings loaded")
    return true
end

function NavigationConfig.Reset()
    Handler.ResetDefaults()
    Logger.Log("NavigationConfig: navigation settings reset to defaults")
end

return NavigationConfig
