-- File: Player/StatModifiers/Movement.lua
local StatModifiers = require("GamePlay/StatModifiers")

local Movement = {}

-- Exposed toggles and value refs
Movement.toggleSpeed     = { value = false }
Movement.speedMultiplier = { value = 5.0 }

Movement.toggleJump      = { value = false }
Movement.jumpMultiplier  = { value = 3.0 }

Movement.toggleSandeTimeScale  = { value = false }
Movement.timeScaleMultiplier  = { value = 0.1 }

Movement.toggleSandeDuration  = { value = false }
Movement.durationMultiplier   = { value = 2.5 }

-- Internal modifier handles
Movement.speedHandle = nil
function Movement.SetMaxSpeed(remove, value)
    if remove then
        if Movement.speedHandle then StatModifiers.Remove(Movement.speedHandle) end
    else
        Movement.speedHandle = StatModifiers.Create(gamedataStatType.MaxSpeed, gameStatModifierType.Multiplier, value)
        StatModifiers.Add(Movement.speedHandle)
    end
end

Movement.jumpHandle = nil
function Movement.SetSuperJump(remove, value)
    if remove then
        if Movement.jumpHandle then StatModifiers.Remove(Movement.jumpHandle) end
    else
        Movement.jumpHandle = StatModifiers.Create(gamedataStatType.JumpHeight, gameStatModifierType.Multiplier, value)
        StatModifiers.Add(Movement.jumpHandle)
    end
end

Movement.sandeTimeHandle = nil
function Movement.SetSandevistanTimeScale(remove, value)
    if remove then
        if Movement.sandeTimeHandle then StatModifiers.Remove(Movement.sandeTimeHandle) end
    else
        Movement.sandeTimeHandle = StatModifiers.Create(gamedataStatType.TimeDilationSandevistanTimeScale, gameStatModifierType.Multiplier, value)
        StatModifiers.Add(Movement.sandeTimeHandle)
    end
end

Movement.sandeDurationHandle = nil
function Movement.SetSandevistanDuration(remove, value)
    if remove then
        if Movement.sandeDurationHandle then StatModifiers.Remove(Movement.sandeDurationHandle) end
    else
        Movement.sandeDurationHandle = StatModifiers.Create(gamedataStatType.TimeDilationSandevistanDuration, gameStatModifierType.Multiplier, value)
        StatModifiers.Add(Movement.sandeDurationHandle)
    end
end

return Movement
