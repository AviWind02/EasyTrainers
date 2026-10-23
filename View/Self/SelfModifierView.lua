local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Self = require("Features/Self")

local Modifiers = Self.StatModifiers
local Cooldown = Modifiers.Cooldown
local Enhancements = Modifiers.Enhancements

local function ModifiersView()
    Buttons.Toggle(L("modifiers.infinitestamina.label"), Enhancements.InfiniteStamina, tip("modifiers.infinitestamina.tip"))
    Buttons.Toggle(L("modifiers.infiniteoxygen.label"), Enhancements.InfiniteOxygen, tip("modifiers.infiniteoxygen.tip"))
    Buttons.Toggle(L("modifiers.refillstamina.label"), Enhancements.RefillStamina, tip("modifiers.refillstamina.tip"))
    Buttons.Toggle(L("modifiers.refilloxygen.label"), Enhancements.RefillOxygen, tip("modifiers.refilloxygen.tip"))

    Buttons.Break(L("modifiers.cooldowns"))
    Buttons.Toggle(L("modifiers.cooldownheal.label"), Cooldown.Heal, tip("modifiers.cooldownheal.tip"))
    Buttons.Toggle(L("modifiers.cooldowngrenade.label"), Cooldown.Grenade, tip("modifiers.cooldowngrenade.tip"))
    Buttons.Toggle(L("modifiers.cooldownprojectile.label"), Cooldown.Projectile, tip("modifiers.cooldownprojectile.tip"))
    Buttons.Toggle(L("modifiers.cooldowncloak.label"), Cooldown.Cloak, tip("modifiers.cooldowncloak.tip"))
    Buttons.Toggle(L("modifiers.cooldownsande.label"), Cooldown.Sandevistan, tip("modifiers.cooldownsande.tip"))
    Buttons.Toggle(L("modifiers.cooldownberserk.label"), Cooldown.Berserk, tip("modifiers.cooldownberserk.tip"))
    Buttons.Toggle(L("modifiers.cooldownkeren.label"), Cooldown.Kerenzikov, tip("modifiers.cooldownkeren.tip"))
    Buttons.Toggle(L("modifiers.cooldownoverclock.label"), Cooldown.Overclock, tip("modifiers.cooldownoverclock.tip"))
    Buttons.Toggle(L("modifiers.cooldownquickhacks.label"), Cooldown.Quickhack, tip("modifiers.cooldownquickhacks.tip"))

    Buttons.Break(L("modifiers.memorystats"))
    Buttons.Toggle(L("modifiers.reducequickhackcost.label"), Cooldown.HackCost, tip("modifiers.reducequickhackcost.tip"))
    Buttons.Toggle(L("modifiers.memoryregen.label"), Cooldown.MemoryRegen, tip("modifiers.memoryregen.tip"))
    Buttons.Float(L("modifiers.setmemorystat.label"), Enhancements.MemoryStat, tip("modifiers.setmemorystat.tip"))

    Buttons.Break(L("modifiers.mobility"))
    Buttons.Toggle(L("modifiers.airthrusterboots.label"), Self.AirThrusterBoots.Enabled, tip("modifiers.airthrusterboots.tip"))
    Buttons.Toggle(L("modifiers.airhover.label"), Self.AdvancedMobility.AirHover, tip("modifiers.airhover.tip"))
    Buttons.Int(L("modifiers.carrycapacity.label"), Modifiers.Utility.CarryCapacity, tip("modifiers.carrycapacity.tip"))

    Buttons.Break(L("modifiers.sandevistan"))
    Buttons.Float(L("modifiers.sandevistanduration.label"), Modifiers.Movement.SandevistanDuration, tip("modifiers.sandevistanduration.tip"))
    Buttons.Float(L("modifiers.sandevistanscale.label"), Modifiers.Movement.SandevistanTimeScale, tip("modifiers.sandevistanscale.tip"))
end

return Submenu.Create("modifiers.title", ModifiersView)
