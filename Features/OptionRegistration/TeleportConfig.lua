local ConfigManager = require("Core/ConfigManager")
local Teleport = require("Features/Teleports/Teleport")

local function RegisterTeleportOptions()
    ConfigManager.Register("toggle.teleport.autowaypoint", Teleport.toggleAutoWaypoint, false)
    ConfigManager.Register("toggle.teleport.autoquest",    Teleport.toggleAutoQuest, false)
end

return RegisterTeleportOptions
