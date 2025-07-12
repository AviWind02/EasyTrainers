local StatPoolModifiers = {}
local Logger = require("Func/Core/Logger")

function StatPoolModifiers.Get(poolType)
    local player = Game.GetPlayer()
    local poolSystem = Game.GetStatPoolsSystem()
    if not player or not poolSystem then
        Logger.Log("[EasyTrainerStatPools] Get failed: missing player or pool system")
        return -1
    end

    local entityID = player:GetEntityID()
    local value = poolSystem:GetStatPoolValue(entityID, poolType, true)

    Logger.Log(string.format("[EasyTrainerStatPools] Pool %s = %.2f", tostring(poolType), value))
    return value
end

function StatPoolModifiers.Set(poolType, value)
    local player = Game.GetPlayer()
    local poolSystem = Game.GetStatPoolsSystem()
    if not player or not poolSystem then
        Logger.Log("[EasyTrainerStatPools] Set failed: missing player or pool system")
        return false
    end

    local entityID = player:GetEntityID()
    poolSystem:RequestSettingStatPoolValue(entityID, poolType, value, player, true, true)

    Logger.Log(string.format("[EasyTrainerStatPools] Set pool %s to %.2f (propagate=%s)", tostring(poolType), value, tostring(propagate)))
    return true
end

return StatPoolModifiers
