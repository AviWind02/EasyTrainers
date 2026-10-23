local Logger = require("Core/Logger")

local StatModifiers = {}

local s_Applied = {}

local function OwnerName(owner)
    return type(owner) == "table" and tostring(owner.Name or owner) or tostring(owner)
end

local function Create(entry)
    local modifier = RPGManager.CreateStatModifier(entry[1], entry[2], entry[3])
    if not modifier then
        Logger.Log(string.format("StatModifiers: failed to create %s %s %s", tostring(entry[1]), tostring(entry[2]), tostring(entry[3])))
    end
    return modifier
end

function StatModifiers.Remove(owner)
    local applied = s_Applied[owner]
    if not applied then return false end

    s_Applied[owner] = nil

    local stats = Game.GetStatsSystem()
    if not stats then return false end

    for _, modifier in ipairs(applied.Modifiers) do
        stats:RemoveModifier(applied.TargetID, modifier)
    end

    Logger.Log(string.format("StatModifiers: removed %d from %s", #applied.Modifiers, OwnerName(owner)))
    return true
end

function StatModifiers.Add(owner, targetID, key, entries)
    StatModifiers.Remove(owner)

    local stats = Game.GetStatsSystem()
    if not stats or not targetID then return false end

    local modifiers = {}
    for _, entry in ipairs(entries) do
        local modifier = Create(entry)
        if modifier then
            stats:AddModifier(targetID, modifier)
            table.insert(modifiers, modifier)
        end
    end

    s_Applied[owner] = { TargetID = targetID, Key = key, Modifiers = modifiers }
    Logger.Log(string.format("StatModifiers: applied %d to %s (%s)", #modifiers, OwnerName(owner), tostring(key)))
    return true
end

function StatModifiers.Sync(owner, enabled, key, targetID, build)
    local applied = s_Applied[owner]

    if not enabled then
        if applied then StatModifiers.Remove(owner) end
        return
    end

    if applied and applied.Key == key then return end
    StatModifiers.Add(owner, targetID, key, build(owner))
end

function StatModifiers.GetKey(owner)
    local applied = s_Applied[owner]
    return applied and applied.Key or nil
end

function StatModifiers.IsApplied(owner)
    return s_Applied[owner] ~= nil
end

function StatModifiers.RemoveAll()
    local owners = {}
    for owner in pairs(s_Applied) do table.insert(owners, owner) end
    for _, owner in ipairs(owners) do StatModifiers.Remove(owner) end
    return #owners
end

function StatModifiers.Forget()
    s_Applied = {}
end

return StatModifiers
