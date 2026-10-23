local Logger = require("Core/Logger")

local PlayerDevelopment = {}

local function GetData()
    local player = Game.GetPlayer()
    if not player then return nil end

    local data = PlayerDevelopmentSystem.GetData(player)
    if not data then
        Logger.Log("PlayerDevelopment: no PlayerDevelopmentData found")
    end
    return data
end

function PlayerDevelopment.GetLevel(proficiency)
    local data = GetData()
    return data and data:GetProficiencyLevel(proficiency) or nil
end

function PlayerDevelopment.SetLevel(proficiency, level)
    local data = GetData()
    if not data then return false end
    data:SetLevel(proficiency, level, telemetryLevelGainReason.Gameplay, true)
    Logger.Log(string.format("PlayerDevelopment: set level %s = %d", tostring(proficiency), level))
    return true
end

function PlayerDevelopment.GetMaxLevel(proficiency)
    local data = GetData()
    return data and data:GetProficiencyAbsoluteMaxLevel(proficiency) or 60
end

function PlayerDevelopment.GetAttribute(statType)
    local data = GetData()
    return data and data:GetAttributeValue(statType) or nil
end

function PlayerDevelopment.SetAttribute(statType, value)
    local data = GetData()
    if not data then return false end
    data:SetAttribute(statType, value)
    Logger.Log(string.format("PlayerDevelopment: set attribute %s = %.2f", tostring(statType), value))
    return true
end

function PlayerDevelopment.AddDevPoints(pointType, amount)
    local data = GetData()
    if not data then return false end
    data:AddDevelopmentPoints(amount, pointType)
    Logger.Log(string.format("PlayerDevelopment: added %d %s points", amount, tostring(pointType)))
    return true
end

function PlayerDevelopment.GetDevPoints(pointType)
    local data = GetData()
    return data and data:GetDevPoints(pointType) or 0
end

function PlayerDevelopment.HasPerk(perkType)
    local data = GetData()
    return data and data:IsNewPerkBought(perkType) > 0 or false
end

function PlayerDevelopment.GetPerkLevel(perkType)
    local data = GetData()
    return data and data:IsNewPerkBought(perkType) or 0
end

function PlayerDevelopment.GetPerkMaxLevel(perkType)
    local data = GetData()
    return data and data:GetNewPerkMaxLevel(perkType) or 1
end

function PlayerDevelopment.AddPerk(perkType, force)
    local data = GetData()
    if not data then return false end
    return data:BuyNewPerk(perkType, force ~= false)
end

function PlayerDevelopment.RemovePerk(perkType)
    local data = GetData()
    if not data then return false end
    return data:ForceSellNewPerk(perkType)
end

return PlayerDevelopment
