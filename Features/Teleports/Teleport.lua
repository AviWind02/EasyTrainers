
local Teleport = {}
local Notification = require("UI").Notifier

Teleport.toggleAutoWaypoint = { value = false }
Teleport.toggleAutoQuest = { value = false }

function Teleport.TeleportEntity(entity, pos, facing)
    if not entity or not pos then return end
    local targetPos = Vector4.new(pos.x, pos.y, pos.z, pos.w or 1.0)
    local rot = facing or entity:GetWorldOrientation():ToEulerAngles()

    Game.GetTeleportationFacility():Teleport(entity, targetPos, rot)
end

function Teleport.DistanceBetween(posA, posB)
    if not posA or not posB then return math.huge end
    local dx = posA.x - posB.x
    local dy = posA.y - posB.y
    local dz = (posA.z or 0) - (posB.z or 0)
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function Teleport.DistanceFromPlayer(pos)
    local player = Game.GetPlayer()
    if not player or not pos then return math.huge end
    local playerPos = player:GetWorldPosition()
    return Teleport.DistanceBetween(playerPos, pos)
end

function Teleport.GetClosestPosition(list)
    local player = Game.GetPlayer()
    if not player or not list or #list == 0 then return nil end

    local playerPos = player:GetWorldPosition()
    local nearest = nil
    local nearestDist = math.huge

    for i, pos in ipairs(list) do
        local dist = Teleport.DistanceBetween(playerPos, pos)
        if dist < nearestDist then
            nearest = pos
            nearestDist = dist
        end
    end

    return nearest, nearestDist
end


function Teleport.TeleportToWaypointMarker(notify)
    local ms = Game.GetMappinSystem()
    if not ms then return false end

    local id = ms:GetManuallyTrackedMappinID()
    if not id then
        return false
    end

    local m = ms:GetMappin(id)
    if not m or not m:IsPlayerTracked() then
        if notify then Notification.Push("No waypoint set.") end
        return false
    end

    Teleport.TeleportEntity(Game.GetPlayer(), m:GetWorldPosition())
    if notify then Notification.Push("Teleported to waypoint.") end
    return true
end

function Teleport.TeleportToQuestMarker(notify)
    local player = Game.GetPlayer()
    if not player then return false end

    local journal = Game.GetJournalManager()
    local tracked = journal and journal:GetTrackedEntry()
    if not tracked then
        if notify then Notification.Push("No quest objective tracked.") end
        return false
    end

    local mappinSys = Game.GetMappinSystem()
    if not mappinSys then return false end

    local hash = journal:GetEntryHash(tracked)
    local ok, positions = mappinSys:GetQuestMappinPositionsByObjective(hash)
    if not ok or not positions or #positions == 0 then
        if notify then Notification.Push("Tracked quest has no map position.") end
        return false
    end

    local pos = positions[1]
    Teleport.TeleportEntity(player, pos)
    if notify then Notification.Push("Teleported to tracked quest objective.") end
    return true
end

local tickTimer = 0
function Teleport.Tick(delta)
    tickTimer = tickTimer + delta
    if tickTimer < 1.0 then return end  
    tickTimer = 0

    if Teleport.toggleAutoWaypoint.value then
        local success = Teleport.TeleportToWaypointMarker(false)
        if success then Notification.Push("Auto-teleported to waypoint.") end
    end

    if Teleport.toggleAutoWaypoint.value then
        local success = Teleport.TeleportToQuestMarker(false)
        if success then Notification.Push("Auto-teleported to quest objective.") end
    end
end


-- Was messing with trying to get the nearest vendor and kind of just gave up and just used hard coded variables
-- but I found a way to get the nearest drop point! :)
local function GetNearestDropPoint()
    local player = Game.GetPlayer()
    if not player then return nil end

    local playerPos = player:GetWorldPosition()
    local dropPointSystem = Game.GetScriptableSystemsContainer():Get("DropPointSystem")
    if not dropPointSystem then
        print("[DropPoint] No DropPointSystem found")
        return nil
    end

    local mappins = dropPointSystem.mappins or {}
    if #mappins == 0 then
        print("[DropPoint] No mappins registered")
        return nil
    end

    local nearest = nil
    local nearestDist = math.huge

    for _, dp in ipairs(mappins) do
        if dp ~= nil and dp:GetPosition() ~= nil then
            local pos = dp:GetPosition()
            local dx = pos.x - playerPos.x
            local dy = pos.y - playerPos.y
            local dz = pos.z - playerPos.z
            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

            if dist < nearestDist then
                nearest = dp
                nearestDist = dist
            end
        end
    end

    if nearest then
        print(string.format("[DropPoint] Nearest drop point: %.2f units away", nearestDist))
        print("[DropPoint] Position: " .. tostring(nearest:GetPosition()))
        print("[DropPoint] OwnerID: " .. tostring(nearest:GetOwnerID()))
    else
        print("[DropPoint] None found")
    end
end




function Teleport.GetPlayerPosition()
    local player = Game.GetPlayer()
    if not player then return nil end
    return player:GetWorldPosition()
end

function Teleport.GetForwardOffset(distance)
    local player = Game.GetPlayer()
    if not player then return nil end

    local pos = player:GetWorldPosition()
    local rot = player:GetWorldOrientation():ToEulerAngles()

    local yaw = rot.yaw
    local yawRad = math.rad(yaw)

    local xOffset = distance * math.sin(yawRad) * -1.0
    local yOffset = distance * math.cos(yawRad)

    return Vector4.new(pos.x + xOffset, pos.y + yOffset, pos.z, 1.0)
end

function Teleport.TeleportPlayerTo(x, y, z)
    local player = Game.GetPlayer()
    if not player then return end
    local facing = player:GetWorldOrientation():ToEulerAngles()
    local pos = Vector4.new(x, y, z, 1.0)
    Game.GetTeleportationFacility():Teleport(player, pos, facing)
end

return Teleport
