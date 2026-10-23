local Logger = require("Core/Logger")
local Lifecycle = require("Core/Lifecycle")
local Teleport = require("Utils/Teleport")
local VehicleSpawning = require("Features/Vehicles/VehicleSpawning")
local State = require("Controls/State")

local VehiclePreview = {}

local DISTANCE = 13.0
local SPIN_SPEED = 30.0
local SPAWN_TIMEOUT = 8.0
local HEIGHT_OFFSET = 0.7

local s_EntityID = nil
local s_RecordID = nil
local s_Rotation = 0.0
local s_SpawnWait = 0.0
local s_Active = false

local function IsShowing()
    return s_Active and State.IsMenuOpen()
end

function VehiclePreview.Clear()
    if s_EntityID then
        local entitySystem = Game.GetDynamicEntitySystem()
        if entitySystem then entitySystem:DeleteEntity(s_EntityID) end
        VehicleSpawning.Forget(s_EntityID)
    end

    s_EntityID = nil
    s_RecordID = nil
    s_Rotation = 0
    s_SpawnWait = 0
end

function VehiclePreview.SetActive(active)
    s_Active = active
    if not active then VehiclePreview.Clear() end
end

function VehiclePreview.Spawn(recordID)
    if not IsShowing() then
        VehiclePreview.Clear()
        return
    end

    if s_RecordID == recordID then return end

    VehiclePreview.Clear()
    s_RecordID = recordID
    s_EntityID = VehicleSpawning.SpawnVehicle(recordID, DISTANCE, false, false)
    if not s_EntityID then Logger.Log("VehiclePreview: failed to spawn " .. tostring(recordID)) end
end

local function WaitForSpawn(entitySystem, deltaTime)
    if entitySystem:IsSpawned(s_EntityID) then
        s_SpawnWait = 0
        return true
    end

    s_SpawnWait = s_SpawnWait + deltaTime
    if s_SpawnWait >= SPAWN_TIMEOUT then
        Logger.Log("VehiclePreview: timed out spawning " .. tostring(s_RecordID))
        VehiclePreview.Clear()
    end
    return false
end

function VehiclePreview.Update(deltaTime)
    if not IsShowing() then
        if s_EntityID then VehiclePreview.Clear() end
        return
    end

    if not s_EntityID then return end

    local entitySystem = Game.GetDynamicEntitySystem()
    if not entitySystem or not Game.GetPlayer() then return end
    if not WaitForSpawn(entitySystem, deltaTime) then return end

    local entity = entitySystem:GetEntity(s_EntityID)
    local position = entity and Teleport.GetForwardOffset(DISTANCE) or nil
    if not position then return end

    position.z = position.z + HEIGHT_OFFSET
    s_Rotation = (s_Rotation + SPIN_SPEED * deltaTime) % 360
    Teleport.TeleportEntity(entity, position, EulerAngles.new(0, 0, s_Rotation))
end

Lifecycle.Register("VehiclePreview", {
    OnSessionEnd = function()
        s_EntityID = nil
        s_RecordID = nil
    end,
    OnShutdown = VehiclePreview.Clear
})

return VehiclePreview
