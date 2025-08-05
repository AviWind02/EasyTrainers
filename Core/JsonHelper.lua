local JsonHelper = {}

function JsonHelper.Read(path)
    local file = io.open(path, "r")
    if not file then return nil, "Could not open file: " .. path end

    local content = file:read("*a")
    file:close()

    local ok, result = pcall(function()
        return json.decode(content)
    end)

    if not ok then
        return nil, "Invalid JSON format in: " .. path
    end

    return result, nil
end

function JsonHelper.Write(path, data)
    local file = io.open(path, "w")
    if not file then return false, "Could not open file for writing: " .. path end

    local content = json.encode(data)
    file:write(content)
    file:close()
    return true
end

return JsonHelper
