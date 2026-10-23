local StatModifiers = require("Utils/StatModifiers")

local PlayerModifiers = {
    Movement = require("Features/Self/StatModifiers/Movement"),
    Cooldown = require("Features/Self/StatModifiers/Cooldown"),
    Enhancements = require("Features/Self/StatModifiers/Enhancements"),
    Stealth = require("Features/Self/StatModifiers/Stealth"),
    Utility = require("Features/Self/StatModifiers/Utility")
}

local GROUPS = {
    PlayerModifiers.Movement,
    PlayerModifiers.Cooldown,
    PlayerModifiers.Enhancements,
    PlayerModifiers.Stealth,
    PlayerModifiers.Utility
}

local function BuildStatic(definition)
    return definition.Modifiers
end

local function BuildDynamic(definition)
    return definition.Dynamic(definition.Ref.value)
end

local function Sync(definition, playerID)
    if definition.Dynamic then
        StatModifiers.Sync(definition, definition.Ref.enabled, definition.Ref.value, playerID, BuildDynamic)
        return
    end
    StatModifiers.Sync(definition, definition.Ref.value, "on", playerID, BuildStatic)
end

function PlayerModifiers.Tick(playerID)
    for _, group in ipairs(GROUPS) do
        for _, definition in ipairs(group.Definitions) do Sync(definition, playerID) end
    end
    PlayerModifiers.Enhancements.TickRefills()
end

return PlayerModifiers
