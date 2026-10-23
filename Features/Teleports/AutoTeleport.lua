local Teleport = require("Utils/Teleport")
local Notification = require("UI/Panels/Notification/Notification")

local AutoTeleport = {}

AutoTeleport.Waypoint = { value = false }
AutoTeleport.Quest = { value = false }

local INTERVAL = 1.0
local ARRIVED_DISTANCE = 3.0

local s_Elapsed = 0

local function TryTeleport(getPosition, message)
    local position = getPosition()
    if not position or Teleport.DistanceFromPlayer(position) < ARRIVED_DISTANCE then return end
    if Teleport.TeleportEntity(Game.GetPlayer(), position) then Notification.Info(message) end
end

function AutoTeleport.Tick(deltaTime)
    if not AutoTeleport.Waypoint.value and not AutoTeleport.Quest.value then return end

    s_Elapsed = s_Elapsed + deltaTime
    if s_Elapsed < INTERVAL then return end
    s_Elapsed = 0

    if AutoTeleport.Waypoint.value then TryTeleport(Teleport.GetWaypointPosition, "Auto-teleported to waypoint.") end
    if AutoTeleport.Quest.value then TryTeleport(Teleport.GetQuestMarkerPosition, "Auto-teleported to quest objective.") end
end

return AutoTeleport
