local sharePath = "Shared/SharedFeature.json"

function GetBoolValue(section, key)
    local file = io.open(sharePath, "r")
    if not file then
        print("[JsonHelper] Config not found: " .. sharePath)
        return false
    end

    local content = file:read("*a")
    file:close()

    local ok, data = pcall(function() return json.decode(content) end)
    if not ok or type(data) ~= "table" then
        print("[JsonHelper] Failed to parse JSON or invalid structure")
        return false
    end

    local sectionData = data[section]
    if type(sectionData) == "table" then
        return sectionData[key] == true
    end

    return false
end


return {
    GetBoolValue = GetBoolValue
}
