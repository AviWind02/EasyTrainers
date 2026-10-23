local StatModifiers = require("Utils/StatModifiers")

local AirThrusterBoots = {}

AirThrusterBoots.Enabled = { value = false }

local s_Owner = { Name = "AirThrusterBoots" }

local function Build()
    return { { "HasAirThrusters", gameStatModifierType.Additive, 1.0 } }
end

function AirThrusterBoots.Tick(playerID)
    StatModifiers.Sync(s_Owner, AirThrusterBoots.Enabled.value, "on", playerID, Build)
end

return AirThrusterBoots
