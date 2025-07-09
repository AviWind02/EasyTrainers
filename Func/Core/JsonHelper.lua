local sharePath = "Shared/SharedFeature.json"

local JsonHelper = {}

-- Reads and decodes JSON from a file
function JsonHelper.ReadJson(path)
    local file = io.open(path, "r")
    if not file then
        -- print("[EasyTrainerJSON] Failed to open file: " .. path)
        return nil
    end

    local content = file:read("*a")
    file:close()

    local ok, data = pcall(function() return json.decode(content) end)
    if not ok or type(data) ~= "table" then
        print("[EasyTrainerJSON] JSON parse error or invalid structure")
        return nil
    end

    return data
end

-- Encodes and writes JSON to a file
function JsonHelper.WriteJson(path, data)
    local file = io.open(path, "w")
    if not file then
        print("[EasyTrainerJSON] Failed to open file for writing: " .. path)
        return
    end
    file:write(json.encode(data, { indent = true }))
    file:close()
    print("[EasyTrainerJSON] Saved changes to: " .. path)
end

-- Gets a boolean value from a section/key
function JsonHelper.GetBoolValue(section, key)
    local data = JsonHelper.ReadJson(sharePath)
    if not data then return false end

    local sectionData = data[section]
    if type(sectionData) == "table" then
        return sectionData[key] == true
    end

    return false
end

-- Sets a boolean value in a section/key and saves it
function JsonHelper.SetBoolValue(section, key, value)
    local data = JsonHelper.ReadJson(sharePath)
    if not data then data = {} end

    if type(data[section]) ~= "table" then
        data[section] = {}
    end

    data[section][key] = value == true

    JsonHelper.WriteJson(sharePath, data)
end


-- Checks for vehicle spawn request and executes it
function JsonHelper.HandleVehicleSpawnRequest()
    local config = JsonHelper.ReadJson(sharePath)
    if not config or not config.VehicleSpawn then return end

    local vs = config.VehicleSpawn
    if vs.ShouldSpawn and vs.SpawnTweakID then
        local distance = tonumber(vs.SpawnDistance) or 8.0

        -- Spawn and log
        print(string.format("[EasyTrainerJSON] Spawning vehicle '%s' at distance %.1f", vs.SpawnTweakID, distance))
        spawnVehicle(vs.SpawnTweakID, distance)

        -- Reset spawn flag
        config.VehicleSpawn.ShouldSpawn = false
        JsonHelper.WriteJson(sharePath, config)

        print("[EasyTrainerJSON] Spawn flag reset.")
    end
end

return JsonHelper
