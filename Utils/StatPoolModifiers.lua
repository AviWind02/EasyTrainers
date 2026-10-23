local StatPoolModifiers = {}

local function GetContext()
    local player = Game.GetPlayer()
    local poolSystem = Game.GetStatPoolsSystem()
    if not player or not poolSystem then return nil, nil end
    return player, poolSystem
end

function StatPoolModifiers.Get(poolType)
    local player, poolSystem = GetContext()
    if not player then return nil end
    return poolSystem:GetStatPoolValue(player:GetEntityID(), poolType, true)
end

function StatPoolModifiers.Set(poolType, value)
    local player, poolSystem = GetContext()
    if not player then return false end
    poolSystem:RequestSettingStatPoolValue(player:GetEntityID(), poolType, value, player, true, true)
    return true
end

function StatPoolModifiers.Refill(poolType)
    local value = StatPoolModifiers.Get(poolType)
    if not value or value >= 98.0 then return end
    StatPoolModifiers.Set(poolType, 100.0)
end

return StatPoolModifiers
