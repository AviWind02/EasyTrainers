-- File: Func/Gameplay/StatModifiers.lua
local StatModifiers = {}
local Logger = require("Func/Core/Logger")

local cache = {}
local nextID = 1


function StatModifiers.Create(statType, modifierType, value, outID)
    local mod = RPGManager.CreateStatModifier(statType, modifierType, value)
    if not mod then
        Logger.Log(string.format("[EasyTrainerStatModifiers] Failed to create modifier (%s, %.2f, %s)", tostring(statType), value, tostring(modifierType)))
        return nil
    end

    local id = nextID
    nextID = nextID + 1
    cache[id] = mod

    if outID then
        outID.value = id
    end

    Logger.Log(string.format("[EasyTrainerStatModifiers] Created modifier ID %d: %s %s %.2f", id, tostring(statType), tostring(modifierType), value))
    return mod
end


function StatModifiers.Add(modifier)
    local player = Game.GetPlayer()
    if not player or not modifier then
        Logger.Log("[EasyTrainerStatModifiers] Add failed: missing player or modifier")
        return
    end

    local stats = Game.GetStatsSystem()
    stats:AddModifier(player:GetEntityID(), modifier)
    Logger.Log("[EasyTrainerStatModifiers] Modifier added to player")
end


function StatModifiers.Remove(modifier)
    local player = Game.GetPlayer()
    if not player or not modifier then
        Logger.Log("[EasyTrainerStatModifiers] Remove failed: missing player or modifier")
        return
    end

    local stats = Game.GetStatsSystem()
    stats:RemoveModifier(player:GetEntityID(), modifier)
    Logger.Log("[EasyTrainerStatModifiers] Modifier removed from player")
end


function StatModifiers.Get(statType)
    local stats = Game.GetStatsSystem()
    local player = Game.GetPlayer()
    if not stats or not player then
        Logger.Log("[EasyTrainerStatModifiers] Get failed: missing player or system")
        return -1
    end

    local val = stats:GetStatValue(player:GetEntityID(), statType)
    Logger.Log(string.format("[EasyTrainerStatModifiers] Stat %s = %.2f", tostring(statType), val))
    return val
end

function StatModifiers.ClearAll()
    local stats = Game.GetStatsSystem()
    local player = Game.GetPlayer()
    if not stats or not player then
        Logger.Log("[EasyTrainerStatModifiers] ClearAll failed: context missing")
        return
    end

    for id, mod in pairs(cache) do
        stats:RemoveModifier(player:GetEntityID(), mod)
        Logger.Log(string.format("[EasyTrainerStatModifiers] Removed cached modifier ID %d", id))
    end
    cache = {}
    Logger.Log("[EasyTrainerStatModifiers] Cleared all cached modifiers")
end


local appliedStates = setmetatable({}, { __mode = "k" }) 
function StatModifiers.HandleStatModifierToggle(toggleRef, applyFunc)
    local wasApplied = appliedStates[toggleRef] or false

    if toggleRef.value then
        if not wasApplied then
            applyFunc(false) -- apply
            appliedStates[toggleRef] = true
        end
    else
        if wasApplied then
            applyFunc(true) -- remove
            appliedStates[toggleRef] = false
        end
    end
end
return StatModifiers
