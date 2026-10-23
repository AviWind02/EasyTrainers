local Logger = require("Core/Logger")

local JsonHelper = {}

function JsonHelper.Read(path, options)
    options = options or {}

    local file, err, code = io.open(path, "r")
    if not file then
        local missing = code == 2 or tostring(err):lower():find("no such file", 1, true) ~= nil
        local status = missing and "missing" or "open_failed"
        if not missing or not options.SilentMissing then
            Logger.Log("JsonHelper: failed to open " .. tostring(path) .. " (" .. tostring(err) .. ")")
        end
        return nil, "Could not open file: " .. path, status
    end

    local content = file:read("*a")
    file:close()

    local ok, result = pcall(json.decode, content)
    if not ok or result == nil then
        Logger.Log("JsonHelper: invalid JSON in " .. tostring(path))
        return nil, "Invalid JSON format in: " .. path, "invalid"
    end

    return result, nil
end

function JsonHelper.ReadOptional(path)
    return JsonHelper.Read(path, { SilentMissing = true })
end

function JsonHelper.LoadOrCreate(path, defaults)
    local data, err, status = JsonHelper.ReadOptional(path)
    if type(data) == "table" then return data, false, nil end
    if status ~= "missing" then return nil, false, err end

    local ok, writeErr = JsonHelper.Write(path, defaults or {})
    if not ok then return nil, false, writeErr end

    Logger.Log("JsonHelper: created default file " .. tostring(path))
    return defaults or {}, true, nil
end

function JsonHelper.Write(path, data)
    local ok, content = pcall(json.encode, data)
    if not ok then
        Logger.Log("JsonHelper: failed to encode " .. tostring(path) .. " (" .. tostring(content) .. ")")
        return false, "Failed to encode JSON: " .. tostring(content)
    end

    local file, err = io.open(path, "w")
    if not file then
        Logger.Log("JsonHelper: failed to open for write " .. tostring(path) .. " (" .. tostring(err) .. ")")
        return false, "Could not open file for writing: " .. path
    end

    file:write(content)
    file:close()
    return true
end

return JsonHelper
