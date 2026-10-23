local Utility = {}

Utility.CarryCapacity = { value = 360, min = 1, max = 5000, step = 50, enabled = false }

Utility.Definitions = {
    {
        Name = "Utility.CarryCapacity",
        Ref = Utility.CarryCapacity,
        Dynamic = function(value) return { { gamedataStatType.CarryCapacity, gameStatModifierType.Additive, value } } end
    }
}

return Utility
