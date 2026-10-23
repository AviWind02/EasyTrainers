local JsonHelper = require("Core/JsonHelper")
local Bindings = require("Controls/Bindings")
local Logger = require("Core/Logger")

local BindingsConfig = {
    FilePath = "Config/JSON/Bindings.json"
}

function BindingsConfig.Load()
    local data, _, err = JsonHelper.LoadOrCreate(BindingsConfig.FilePath, Bindings.Actions)
    if type(data) ~= "table" then
        Logger.Log("BindingsConfig: failed to load bindings (" .. tostring(err) .. ")")
        return false
    end

    for action, binding in pairs(data) do
        if type(binding) == "table" then Bindings.Rebind(action, binding) end
    end

    Logger.Log("BindingsConfig: bindings loaded")
    return true
end

function BindingsConfig.Save()
    local ok, err = JsonHelper.Write(BindingsConfig.FilePath, Bindings.Actions)
    if not ok then
        Logger.Log("BindingsConfig: failed to save bindings (" .. tostring(err) .. ")")
        return false
    end
    return true
end

return BindingsConfig
