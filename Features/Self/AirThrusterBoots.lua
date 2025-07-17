local AirThrusterBoots = {}

AirThrusterBoots.enabled = { value = false }

local statId = "HasAirThrusters"
local applied = false
local logger = require("Core/Logger")

function AirThrusterBoots.Tick()
    local stats = Game.GetStatsSystem()
    local player = Game.GetPlayer()
    local entityID = player:GetEntityID()

    local function modifyStat(value)
        stats:AddModifier(entityID, RPGManager.CreateStatModifier(statId, gameStatModifierType.Additive, value))
    end

    if AirThrusterBoots.enabled.value and not applied then
        modifyStat(1.0)
        logger.Log("[EasyTrainerSelf] AirThrusterBoots - Enabled")
        applied = true
    elseif not AirThrusterBoots.enabled.value and applied then
        modifyStat(-1.0)
        logger.Log("[EasyTrainerSelf] AirThrusterBoots - Disabled")
        applied = false
    end
end

return AirThrusterBoots
