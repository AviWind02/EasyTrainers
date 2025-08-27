local JsonHelper = {}

function JsonHelper.Read(path)
    local file = io.open(path, "r")
    if not file then return nil, "Could not open file: " .. path end

    local content = file:read("*a")
    file:close()

    local ok, result = pcall(json.decode, content)
    if not ok then
        return nil, "Invalid JSON format in: " .. path
    end
    return result, nil
end

function JsonHelper.Write(path, data)
    local file = io.open(path, "w")
    if not file then return false, "Could not open file for writing: " .. path end

    local ok, content = pcall(json.encode, data)
    if not ok then return false, "Failed to encode JSON" end

    file:write(content)
    file:close()
    return true
end

function JsonHelper.Update(path, key, value)
    local data = JsonHelper.Read(path) or {}
    data[key] = value
    return JsonHelper.Write(path, data)
end

return JsonHelper
