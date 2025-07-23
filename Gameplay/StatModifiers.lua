local StatModifiers = {}
local Logger = require("Core/Logger")

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


function StatModifiers.AddToWeapon(modifier, itemID)
    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    local statsSystem = Game.GetStatsSystem()

    if not player or not modifier or not itemID then
        Logger.Log("[EasyTrainerStatModifiers] AddToWeapon failed: missing player, modifier, or itemID")
        return
    end

    local itemData = transactionSystem:GetItemData(player, itemID)
    if not itemData then
        Logger.Log(string.format("[EasyTrainerStatModifiers] AddToWeapon failed: item data not found for %s", tostring(itemID)))
        return
    end

    local statsID = itemData:GetStatsObjectID()
    statsSystem:AddModifier(statsID, modifier)

    Logger.Log(string.format("[EasyTrainerStatModifiers] Modifier added to weapon %s (%s, %s, %.2f)",
        tostring(itemID), tostring(modifier.statType), tostring(modifier.modifierType), modifier.value))
end

function StatModifiers.RemoveFromWeapon(modifier, itemID)
    local player = Game.GetPlayer()
    local transactionSystem = Game.GetTransactionSystem()
    local statsSystem = Game.GetStatsSystem()

    if not player or not modifier or not itemID then
        Logger.Log("[EasyTrainerStatModifiers] RemoveFromWeapon failed: missing player, modifier, or itemID")
        return
    end

    local itemData = transactionSystem:GetItemData(player, itemID)
    if not itemData then
        Logger.Log(string.format("[EasyTrainerStatModifiers] RemoveFromWeapon failed: item data not found for %s", tostring(itemID)))
        return
    end

    local statsID = itemData:GetStatsObjectID()
    statsSystem:RemoveModifier(statsID, modifier)

    Logger.Log(string.format("[EasyTrainerStatModifiers] Modifier removed from weapon %s (%s, %s, %.2f)",
        tostring(itemID), tostring(modifier.statType), tostring(modifier.modifierType), modifier.value))
end


function StatModifiers.AddToVehicle(modifier)
    local player = Game.GetPlayer()
    local vehicle = Game.GetMountedVehicle(player)
    local statsSystem = Game.GetStatsSystem()

    if not player or not vehicle or not modifier then
        Logger.Log("[EasyTrainerStatModifiers] AddToVehicle failed: missing player, vehicle, or modifier")
        return
    end

    local statsID = vehicle:GetEntityID()
    if not statsID then
        Logger.Log("[EasyTrainerStatModifiers] AddToVehicle failed: vehicle entity ID not found")
        return
    end

    statsSystem:AddModifier(statsID, modifier)

    Logger.Log(string.format("[EasyTrainerStatModifiers] Modifier added to vehicle (%s, %s, %.2f)",
        tostring(modifier.statType), tostring(modifier.modifierType), modifier.value))
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


local dynamicStates = setmetatable({}, { __mode = "k" })

function StatModifiers.HandleDynamicStatModifierToggle(ref, applyFunc)
    local state = dynamicStates[ref]
    if not state then
        state = { applied = false, lastValue = nil }
        dynamicStates[ref] = state
    end

    local toggle = ref.enabled
    local currentValue = ref.value

    if toggle then
        if not state.applied then
            applyFunc(false, currentValue)
            state.applied = true
            state.lastValue = currentValue
        elseif currentValue ~= state.lastValue then
            applyFunc(true, state.lastValue)   -- remove old
            applyFunc(false, currentValue)     -- apply new
            state.lastValue = currentValue
        end
    elseif state.applied then
        applyFunc(true, state.lastValue)
        state.applied = false
    end
end



return StatModifiers
