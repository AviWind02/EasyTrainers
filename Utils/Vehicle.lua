local Logger = require("Core/Logger")
local Notification = require("UI").Notification
local Vehicle = {}
local activeSpawns = {}




function Vehicle.MountLastVehicle() -- Testing mounting 
    if #activeSpawns == 0 then
        Logger.Log("Vehicle: no active vehicles to mount")
        return false
    end

    local lastID = activeSpawns[#activeSpawns]
    local des = Game.GetDynamicEntitySystem()
    if not des then
        Logger.Log("Vehicle: DynamicEntitySystem not available")
        return false
    end

    local ent = des:GetEntity(lastID)
    if not ent then
        Logger.Log("Vehicle: last spawned entity not yet available")
        return false
    end

    local comp = ent:GetVehicleComponent()
    if not comp then
        Logger.Log("Vehicle: no VehicleComponent found on entity")
        return false
    end

    local player = Game.GetPlayer()
    if not player then
        Logger.Log("Vehicle: player not found")
        return false
    end

    local playerID = player:GetEntityID()
    comp:MountEntityToSlot(ent:GetEntityID(), playerID, CName.new("seat_front_left"))

    Logger.Log("Vehicle: mounted player into last spawned vehicle")
    return true
end

function Vehicle.GetPlayerSeatSlot()
    local player = Game.GetPlayer()
    if not player then
        Logger.Log("Vehicle: player not found")
        return
    end

    local vehicle = player:GetMountedVehicle()
    if not vehicle then
        Logger.Log("Vehicle: player not mounted in a vehicle")
        return
    end


    local slot = vehicle:GetSlotIdForMountedObject(player)
    if not slot then
        Logger.Log("Vehicle: could not determine player slot")
        return
    end

    Logger.Log("Vehicle: player is mounted in slot " .. tostring(slot))
end

Vehicle.EVehicleDoor = {
    FrontLeft  = vehicleEVehicleDoor.seat_front_left,   
    FrontRight = vehicleEVehicleDoor.seat_front_right,
    RearLeft = vehicleEVehicleDoor.seat_back_left,
    RearRight = vehicleEVehicleDoor.seat_back_right,
    Trunk = vehicleEVehicleDoor.trunk,
    Hood = vehicleEVehicleDoor.hood,
}

Vehicle.DoorState = {
    Closed = vehicleVehicleDoorState.Closed,
    Open = vehicleVehicleDoorState.Open,
    Detached = vehicleVehicleDoorState.Detached
}

function Vehicle.SetDoorState(doorIndex, state)
    local player = Game.GetPlayer()
    local vehicle = player and Game.GetMountedVehicle(player)
    local comp = vehicle and vehicle:GetVehicleComponent()
    if comp then
        comp:SetDoorAnimFeatureData(doorIndex, state)
        return true
    end
    return false
end


local function getLightController()
    local player = Game.GetPlayer()
    local vehicle = player and Game.GetMountedVehicle(player)
    return vehicle and vehicle:GetAccessoryController() or nil
end

function Vehicle.SetLightColor(lightType, color)
    local c = getLightController()
    if c then c:SetLightColor(lightType, color, 0.0) end
end

function Vehicle.SetLightStrength(lightType, strength)
    local c = getLightController()
    if c then c:SetLightStrength(lightType, strength, 0.0) end
end

function Vehicle.SetLightParameters(lightType, strength, color)
    local c = getLightController()
    if c then c:SetLightParameters(lightType, strength, color, 0.0) end
end

function Vehicle.ResetLightColor(lightType)
    local c = getLightController()
    if c then c:ResetLightColor(lightType, 0.0) end
end

function Vehicle.ResetLightStrength(lightType)
    local c = getLightController()
    if c then c:ResetLightStrength(lightType, 0.0) end
end

function Vehicle.ResetLightParameters(lightType)
    local c = getLightController()
    if c then c:ResetLightParameters(lightType, 0.0) end
end

function Vehicle.ToggleLights(on, lightType)
    local c = getLightController()
    if c then c:ToggleLights(on, lightType or nil, 0.0, "", false) end
end

function Vehicle.MountOnRoof()
    local player = Game.GetPlayer()
    if not player then return false end

    local vehicle = player:GetMountedVehicle()
    if not vehicle then
        Notification.Info("No mounted vehicle to mount")
        return false
    end

    Game.GetWorkspotSystem():UnmountFromVehicle(vehicle, player, true) -- Sets the player on top of the roof What a beautiful option
    Logger.Log("Vehicle: player placed on top of vehicle roof")
    return true
end


function Vehicle.RepairMounted()
    local player = Game.GetPlayer()
    local vehicle = player and Game.GetMountedVehicle(player)
    if not vehicle then
        Notification.Info("No mounted vehicle to repair")
        return false
    end

    local vps = vehicle:GetVehiclePS()
    local vc  = vehicle:GetVehicleComponent()
    if not (vps and vc) then
        Logger.Log("Vehicle: missing VehiclePS/VehicleComponent")
        return false
    end

    vc.damageLevel = 0

    local type = vehicle:GetVehicleType().value
    if type ~= "Bike" then
        vc.bumperFrontState = 0
        vc.bumperBackState  = 0

        local parts = {
            "hood_destruction",
            "wheel_f_l_destruction",
            "wheel_f_r_destruction",
            "bumper_b_destruction",
            "bumper_f_destruction",
            "door_f_l_destruction",
            "door_f_r_destruction",
            "trunk_destruction",
            "bumper_b_destruction_side_2",
            "bumper_f_destruction_side_2"
        }

        for _, part in ipairs(parts) do
            AnimationControllerComponent.SetInputFloat(vehicle, part, 0.0)
        end
    end

    if vehicle:GetFlatTireIndex() >= 0 then
        for i = 0, 3 do
            vehicle:ToggleBrokenTire(i, false)
        end
    end

    vehicle:DestructionResetGrid()
    vehicle:DestructionResetGlass()
    vc:UpdateDamageEngineEffects()
    vc:RepairVehicle()
    vc:VehicleVisualDestructionSetup()

    vps:CloseAllVehDoors(true)
    vps:CloseAllVehWindows()
    vps:ForcePersistentStateChanged()

    Logger.Log("Vehicle: fully repaired mounted vehicle")
    return true
end



function Vehicle.IsUnlocked(vehicleID)
    local vs = Game.GetVehicleSystem()
    if not vs then return false end
    local recordID = TweakDBID.new(vehicleID)
    return vs:IsVehiclePlayerUnlocked(recordID)
end

function Vehicle.SetPlayerVehicleState(vehicleID, enable)
    local vs = Game.GetVehicleSystem()
    if not vs then return false end
    return vs:EnablePlayerVehicle(vehicleID, enable, not enable)
end

function Vehicle.Unlock(vehicleID)
    return Vehicle.SetPlayerVehicleState(vehicleID, true)
end

function Vehicle.Disable(vehicleID)
    return Vehicle.SetPlayerVehicleState(vehicleID, false)
end

function Vehicle.UnlockAll()
    local vs = Game.GetVehicleSystem()
    if not vs then return false end
    vs:EnableAllPlayerVehicles()
    Logger.Log("Vehicle: unlocked all player vehicles")
    return true
end


Vehicle.VehicleSpawning = {}

local activeSpawns, pendingMounts, pendingDeletes = {}, {}, {}

-- Helpers
local function GetSpawnTransform(player, dist)
    local forward = player:GetWorldForward()
    local offset  = Vector3.new(forward.x * dist, forward.y * dist, 0.5)

    local transform = player:GetWorldTransform()
    local pos = transform.Position:ToVector4()
    local spawnPos = Vector4.new(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z, 1.0)

    transform:SetPosition(transform, spawnPos)
    return transform, spawnPos
end

local function DespawnEntity(des, entityID, tag)
    if des and entityID then
        des:DeleteEntity(entityID)
        Logger.Log("VehicleSpawning: despawned " .. (tag or "entity") .. " " .. tostring(entityID))
    end
end

-- Request a spawn via Prevention system
function Vehicle.VehicleSpawning.RequestVehicle(tweakDBIDStr, spawnDist)
    local player = Game.GetPlayer()
    if not player then return false end

    local transform, spawnPos = GetSpawnTransform(player, spawnDist)
    local vehicleID = TweakDBID.new(tweakDBIDStr)

    Game.GetPreventionSpawnSystem():RequestUnitSpawn(vehicleID, transform)
    Logger.Log(string.format("VehicleSpawning: requested '%s' at (%.2f, %.2f, %.2f)",
        tweakDBIDStr, spawnPos.x, spawnPos.y, spawnPos.z))
    return true
end

-- Spawn a vehicle via DynamicEntitySystem
---@param tweakDBIDStr string
---@param spawnDist number
---@param mount boolean? queue mounting into driver seat
---@param deleteLast boolean? delete currently mounted vehicle after transferring
---@return EntityID|nil
function Vehicle.VehicleSpawning.SpawnVehicle(tweakDBIDStr, spawnDist, mount, deleteLast)
    local player, des = Game.GetPlayer(), Game.GetDynamicEntitySystem()
    if not player or not des then return nil end

    -- If deleteLast requested, capture currently mounted vehicle for later cleanup
    if deleteLast then
        local currentVehicle = player:GetMountedVehicle()
        if currentVehicle then
            pendingDeletes[#pendingDeletes+1] = currentVehicle:GetEntityID()
            Logger.Log("VehicleSpawning: queued current vehicle for deletion " .. tostring(currentVehicle:GetEntityID()))
        end
    end

    local transform, spawnPos = GetSpawnTransform(player, spawnDist)

    local spec = NewObject("DynamicEntitySpec")
    spec.recordID = TweakDBID.new(tweakDBIDStr)
    spec.position = spawnPos
    spec.orientation = Quaternion.new(0, 0, 0, 1)
    spec.persistState = false
    spec.persistSpawn = false
    spec.spawnInView = true
    spec.active = true
    spec.tags = { CName.new("EasyTrainer") }

    local entityID = des:CreateEntity(spec)
    if not entityID then
        Logger.Log("VehicleSpawning: failed to spawn " .. tostring(tweakDBIDStr))
        return nil
    end

    table.insert(activeSpawns, entityID)
    Logger.Log(string.format("VehicleSpawning: spawned '%s' at (%.2f, %.2f, %.2f)",
        tweakDBIDStr, spawnPos.x, spawnPos.y, spawnPos.z))

    if mount then
        pendingMounts[entityID] = { seat = "seat_front_left" }
        Logger.Log("VehicleSpawning: queued auto-mount for " .. tostring(entityID))
    end

    return entityID
end

-- Handle pending mounts + clean up vehicles
function Vehicle.VehicleSpawning.HandlePending()
    if next(pendingMounts) == nil then return end

    
    local des, ws, player = Game.GetDynamicEntitySystem(), Game.GetWorkspotSystem(), Game.GetPlayer()
    if not (des and ws and player) then return end

    for entityID, opts in pairs(pendingMounts) do
        if des:IsSpawned(entityID) then
            pendingMounts[entityID] = nil
            local ent = des:GetEntity(entityID)
            if not ent then return end

            local comp = ent:GetVehicleComponent()
            if not comp then return end

            -- Transfer player
            ws:UnmountFromVehicle(ent, player, true)
            comp:MountEntityToSlot(ent:GetEntityID(), player:GetEntityID(), CName.new(opts.seat))
            Logger.Log("VehicleSpawning: mounted player into " .. opts.seat)

            -- Now safe to delete any queued old vehicles
            for _, oldID in ipairs(pendingDeletes) do
                if oldID and oldID ~= entityID then
                    DespawnEntity(des, oldID, "previous vehicle")
                end
            end
            pendingDeletes = {}
        end
    end
end

-- Explicit despawn helpers
function Vehicle.VehicleSpawning.DespawnLast()
    local des = Game.GetDynamicEntitySystem()
    local lastID = table.remove(activeSpawns)
    if lastID then
        DespawnEntity(des, lastID, "last vehicle")
        return true
    end
    Logger.Log("VehicleSpawning: no vehicle to despawn")
    return false
end

function Vehicle.VehicleSpawning.DespawnPrevious(currentID)
    local des = Game.GetDynamicEntitySystem()
    if not des or #activeSpawns < 2 then return end

    local prevID = activeSpawns[#activeSpawns - 1]
    if prevID and prevID ~= currentID then
        DespawnEntity(des, prevID, "previous vehicle")
    end
end


return Vehicle
