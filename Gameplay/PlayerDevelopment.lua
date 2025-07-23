local PlayerDevelopment = {}
local Logger = require("Core/Logger")

local function GetPlayerData()
    local player = Game.GetPlayer()
    if not player then
        Logger.Log("[EasyTrainerPlayerDevelopment] No player found")
        return nil
    end

    local data = PlayerDevelopmentSystem.GetData(player)
    if not data then
        Logger.Log("[EasyTrainerPlayerDevelopment] No PlayerDevelopmentData found")
        return nil
    end

    return data
end

function PlayerDevelopment.GetLevel(profType)
    local data = GetPlayerData()
    if not data then return -1 end
    return data:GetProficiencyLevel(profType)
end

function PlayerDevelopment.SetLevel(profType, level)
    local data = GetPlayerData()
    if not data then return end
    data:SetLevel(profType, level, telemetryLevelGainReason.DebugCheat, true)
    Logger.Log(string.format("[EasyTrainerPlayerDevelopment] Level set: %s = %d", tostring(profType), level))
end

function PlayerDevelopment.AddXP(profType, amount)
    local data = GetPlayerData()
    if not data then return end
    data:AddExperience(amount, profType, telemetryLevelGainReason.Gameplay, false)
    Logger.Log(string.format("[EasyTrainerPlayerDevelopment] XP added: %d -> %s", amount, tostring(profType)))
end

function PlayerDevelopment.GetAttribute(statType)
    local data = GetPlayerData()
    if not data then return -1 end
    return data:GetAttributeValue(statType)
end

function PlayerDevelopment.SetAttribute(statType, value)
    local data = GetPlayerData()
    if not data then return end
    data:SetAttribute(statType, value)
    Logger.Log(string.format("[EasyTrainerPlayerDevelopment] Attribute set: %s = %.2f", tostring(statType), value))
end

function PlayerDevelopment.AddDevPoints(pointType, amount)
    local data = GetPlayerData()
    if not data then return end
    data:AddDevelopmentPoints(amount, pointType)
    Logger.Log(string.format("[EasyTrainerPlayerDevelopment] DevPoints added: %d -> %s", amount, tostring(pointType)))
end

function PlayerDevelopment.GetDevPoints(pointType)
    local data = GetPlayerData()
    if not data then return -1 end
    return data:GetDevPoints(pointType)
end

return PlayerDevelopment
