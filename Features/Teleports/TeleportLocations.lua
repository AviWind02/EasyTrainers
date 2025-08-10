local Logger = require("Core/Logger")
local JsonHelper = require("Core/JsonHelper")

local TeleportLocations = {}
local cache = {}

local TeleportFile = "Features/Teleports/TeleportLocations.json" 

function TeleportLocations.LoadAll()
    local data, err = JsonHelper.Read(TeleportFile)
    if not data then
        Logger.Log(string.format("[EasyTrainerTeleportLocations] Failed to load '%s': %s", TeleportFile, tostring(err)))
        cache = {}
        return
    end
    cache = data
    Logger.Log(string.format("[EasyTrainerTeleportLocations] Loaded %d teleports", #cache))
end

function TeleportLocations.GetAll()
    return cache
end

function TeleportLocations.Reload()
    Logger.Log("[EasyTrainerTeleportLocations] Reloading teleport locations...")
    TeleportLocations.LoadAll()
end


return TeleportLocations
