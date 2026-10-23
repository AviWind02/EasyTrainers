local StatModifiers = require("Utils/StatModifiers")

local AdvancedMobility = {}

AdvancedMobility.DoubleJump = { value = false }
AdvancedMobility.AirHover = { value = false }
AdvancedMobility.ChargeJump = { value = false }

local function Build(ability)
    return { { ability.Stat, gameStatModifierType.Additive, 1.0 } }
end

local ABILITIES = {
    { Name = "DoubleJump", Ref = AdvancedMobility.DoubleJump, Stat = "HasDoubleJump" },
    { Name = "AirHover", Ref = AdvancedMobility.AirHover, Stat = "HasAirHover" },
    { Name = "ChargeJump", Ref = AdvancedMobility.ChargeJump, Stat = "HasChargeJump" }
}

function AdvancedMobility.Tick(playerID)
    for _, ability in ipairs(ABILITIES) do
        StatModifiers.Sync(ability, ability.Ref.value, "on", playerID, Build)
    end
end

return AdvancedMobility
