local JsonHelper = {}

function JsonHelper.Read(path)
    local file = io.open(path, "r")
    if not file then return nil, "Could not open file: " .. path end

    local content = file:read("*a")
    file:close()

    local ok, result = pcall(function()
        return load("return " .. content)()
    end)

    if not ok then
        return nil, "Invalid JSON format in: " .. path
    end

    return result, nil
end

local function serialize(tbl, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)

    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return string.format("%q", tbl)
        else
            return tostring(tbl)
        end
    end

    local isArray = #tbl > 0
    local items = {}

    if isArray then
        for _, v in ipairs(tbl) do
            table.insert(items, spacing .. "  " .. serialize(v, indent + 1))
        end
        return "[\n" .. table.concat(items, ",\n") .. "\n" .. spacing .. "]"
    else
        for k, v in pairs(tbl) do
            table.insert(items, spacing .. "  " .. string.format("%q: %s", k, serialize(v, indent + 1)))
        end
        return "{\n" .. table.concat(items, ",\n") .. "\n" .. spacing .. "}"
    end
end

function JsonHelper.Write(path, data)
    local file = io.open(path, "w")
    if not file then return false, "Could not open file for writing: " .. path end

    file:write(serialize(data))
    file:close()
    return true
end

return JsonHelper
