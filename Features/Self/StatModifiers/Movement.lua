local Movement = {}

Movement.SpeedMultiplier = { value = 5.0, min = 1.0, max = 5.0, step = 0.1, enabled = false }
Movement.JumpMultiplier = { value = 3.0, min = 1.0, max = 15.0, step = 0.5, enabled = false }
Movement.SandevistanTimeScale = { value = 0.1, min = 0.001, max = 1.0, step = 0.01, enabled = false }
Movement.SandevistanDuration = { value = 2.5, min = 0.1, max = 30.0, step = 0.5, enabled = false }
Movement.CanJump = { value = false }
Movement.Quicksilver = { value = false }

local function Multiplier(stat)
    return function(value)
        return { { stat, gameStatModifierType.Multiplier, value } }
    end
end

Movement.Definitions = {
    { Name = "Movement.SpeedMultiplier", Ref = Movement.SpeedMultiplier, Dynamic = Multiplier(gamedataStatType.MaxSpeed) },
    { Name = "Movement.JumpMultiplier", Ref = Movement.JumpMultiplier, Dynamic = Multiplier(gamedataStatType.JumpHeight) },
    { Name = "Movement.SandevistanTimeScale", Ref = Movement.SandevistanTimeScale, Dynamic = Multiplier(gamedataStatType.TimeDilationSandevistanTimeScale) },
    { Name = "Movement.SandevistanDuration", Ref = Movement.SandevistanDuration, Dynamic = Multiplier(gamedataStatType.TimeDilationSandevistanDuration) },
    {
        Name = "Movement.CanJump",
        Ref = Movement.CanJump,
        Modifiers = { { gamedataStatType.CanJump, gameStatModifierType.Additive, 1.0 } }
    },
    {
        Name = "Movement.Quicksilver",
        Ref = Movement.Quicksilver,
        Modifiers = {
            { gamedataStatType.TimeDilationSandevistanDuration, gameStatModifierType.Multiplier, 100.0 },
            { gamedataStatType.TimeDilationSandevistanTimeScale, gameStatModifierType.Multiplier, 0.005 }
        }
    }
}

return Movement
