local Stealth = {}

Stealth.NonThreat = { value = false }
Stealth.LowTrace = { value = false }

Stealth.Definitions = {
    {
        Name = "Stealth.NonThreat",
        Ref = Stealth.NonThreat,
        Modifiers = {
            { gamedataStatType.Visibility, gameStatModifierType.Multiplier, 0.00001 },
            { gamedataStatType.VisibilityReduction, gameStatModifierType.Multiplier, 0.00001 },
            { gamedataStatType.VisibilityReductionModifierHelper, gameStatModifierType.Additive, 99999999.9 }
        }
    },
    {
        Name = "Stealth.LowTrace",
        Ref = Stealth.LowTrace,
        Modifiers = {
            { gamedataStatType.RevealNetrunnerWhenHacked, gameStatModifierType.Additive, -9999.0 },
            { gamedataStatType.HasICELevelBooster, gameStatModifierType.Additive, 0.0 }
        }
    }
}

return Stealth
