local PlayerDevelopment = {}
local Logger = require("Core/Logger")
local Draw = require("UI")


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
    data:SetLevel(profType, level, telemetryLevelGainReason.Gameplay, true)
    Logger.Log(string.format("[EasyTrainerPlayerDevelopment] Level set: %s = %d", tostring(profType), level))
end
function PlayerDevelopment.GetMaxLevel(profType)
    local data = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    if not data then return 60 end 
    return data:GetProficiencyAbsoluteMaxLevel(profType)
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

function PlayerDevelopment.HasPerk(perkType)
    local player = Game.GetPlayer()
    if not player then return false end
    return PlayerDevelopmentSystem.GetData(player):IsNewPerkBought(perkType) > 0
end

function PlayerDevelopment.IsPerkUnlocked(perkType)
    local player = Game.GetPlayer()
    if not player then return false end
    return PlayerDevelopmentSystem.GetData(player):IsNewPerkUnlocked(perkType)
end

function PlayerDevelopment.BuyPerk(perkType, force)
    local data = GetPlayerData()
    if not data then return false end
    local success = data:BuyNewPerk(perkType, force or false)
    if success then
        Draw.Notifier.Push(string.format("Perk bought: %s", tostring(perkType)))
    else
        Draw.Notifier.Push(string.format("Failed to buy perk: %s\nYou may need to unlock earlier perks first.", tostring(perkType)))
        -- Later in the data extractor I'll look into adding a check to see what park needs to be purchased prior and then adjust the notification accordingly
    end
    return success
end


function PlayerDevelopment.GetPerkMaxLevel(perkType)
    local data = PlayerDevelopmentSystem.GetData(Game.GetPlayer())
    if not data then return 1 end
    return data:GetNewPerkMaxLevel(perkType)
end


function PlayerDevelopment.RemovePerk(perkType)
    local data = GetPlayerData()
    if not data then return false end
    local success, level = data:ForceSellNewPerk(perkType)
    if success then
        Draw.Notifier.Push(string.format("Perk removed: %s | Level Removed: %d", tostring(perkType), level))
    else
        Draw.Notifier.Push(string.format("Failed to remove perk: %s", tostring(perkType)))
    end
    return success, level
end

function PlayerDevelopment.UnlockPerksForAttribute(attributeType)
    local data = GetPlayerData()
    if not data then return end
    data:UnlockFreeNewPerks(attributeType)
    Logger.Log(string.format("[EasyTrainerPlayerDevelopment] Unlocked perks for attribute: %s", tostring(attributeType)))
end



return PlayerDevelopment
