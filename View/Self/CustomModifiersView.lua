local StatModifiers = require("Gameplay").StatModifiers
local WeaponInput = require("Gameplay").WeaponInput
local Buttons = require("UI").Buttons
local SubmenuManager = require("UI/Core/SubmenuManager")
local StatNames = require("Features/Self/StatModifiers/StatNames")

local ModifierManager = {}

local Modes = {
    "custom_modifiers.modes.1",
    "custom_modifiers.modes.2",
    "custom_modifiers.modes.3"
}

local Targets = {
    "custom_modifiers.targets.1",
    "custom_modifiers.targets.2",
    "custom_modifiers.targets.3"
}

local Types = {
    "custom_modifiers.types.1",
    "custom_modifiers.types.2",
    "custom_modifiers.types.3"
}

local Filters = {
    "custom_modifiers.filters.1", -- A to Z
    "custom_modifiers.filters.2", -- Z to A
    "custom_modifiers.filters.3", "custom_modifiers.filters.4", "custom_modifiers.filters.5", "custom_modifiers.filters.6", "custom_modifiers.filters.7", "custom_modifiers.filters.8",
    "custom_modifiers.filters.9", "custom_modifiers.filters.10", "custom_modifiers.filters.11", "custom_modifiers.filters.12", "custom_modifiers.filters.13", "custom_modifiers.filters.14",
    "custom_modifiers.filters.15", "custom_modifiers.filters.16", "custom_modifiers.filters.17", "custom_modifiers.filters.18", "custom_modifiers.filters.19", "custom_modifiers.filters.20",
    "custom_modifiers.filters.21", "custom_modifiers.filters.22", "custom_modifiers.filters.23", "custom_modifiers.filters.24", "custom_modifiers.filters.25", "custom_modifiers.filters.26",
    "custom_modifiers.filters.27", "custom_modifiers.filters.28"
}

local selectedMode = { index = 1, expanded = false }
local selectedFilter = { index = 1, expanded = false }

local customModifiers = {}
local recentStats = {}

local function ApplyModifier(entry)
    local stat = gamedataStatType[entry.statType]
    local modType = gameStatModifierType[entry.modifierType]
    entry.handle = StatModifiers.Create(stat, modType, entry.value)
    entry.enabled = true

    if entry.target == "Player" then
        StatModifiers.Add(entry.handle)
    elseif entry.target == "Right Weapon" then
        local _, _, id = WeaponInput.GetEquippedRightHandWeapon()
        StatModifiers.AddToWeapon(entry.handle, id)
    elseif entry.target == "Vehicle" then
        StatModifiers.AddToVehicle(entry.handle)
    end
end

local function RemoveModifier(entry)
    if not entry.handle then return end

    if entry.target == "Player" then
        StatModifiers.Remove(entry.handle)
    elseif entry.target == "Right Weapon" then
        local _, _, id = WeaponInput.GetEquippedRightHandWeapon()
        StatModifiers.RemoveFromWeapon(entry.handle, id)
    elseif entry.target == "Vehicle" then
        StatModifiers.Remove(entry.handle)
    end

    entry.handle = nil
end

local function CreateModifierConfig(statName)
    local selectedTarget = { index = 1, expanded = false }
    local selectedType = { index = 1, expanded = false }
    local valueInput = { value = 1.0, min = -10000, max = 10000, step = 0.5 }

    return {
        title = "Configure " .. statName,
        view = function()
            Buttons.OptionExtended(L("custom_modifiers.labels.selected_modifier"), "", statName)
            Buttons.Dropdown(L("custom_modifiers.labels.target"), selectedTarget, Targets)
            Buttons.Dropdown(L("custom_modifiers.labels.modifier_type"), selectedType, Types)
            Buttons.Float(L("custom_modifiers.labels.value"), valueInput, tip("custom_modifiers.tips.value"))
            Buttons.Option(
                L("custom_modifiers.labels.apply"),
                tip("custom_modifiers.tips.apply"),
                function()
                    local entry = {
                        name = statName,
                        statType = statName,
                        modifierType = Types[selectedType.index or 1],
                        target = Targets[selectedTarget.index or 1],
                        value = valueInput.value,
                        enabled = false,
                        handle = nil
                    }
                    ApplyModifier(entry)
                    table.insert(customModifiers, entry)
                    recentStats[statName] = true
                end
            )
        end
    }
end

local function CreateModifierEditor(entry)
    local valueSlider = { value = entry.value, min = -10000, max = 10000, step = 0.5 }
    local selectedType = {
        index = (function()
            for i, v in ipairs(Types) do if v == entry.modifierType then return i end end
            return 1
        end)(),
        expanded = false
    }

    return {
        title = "Modify " .. entry.name,
        view = function()
            Buttons.Toggle(
                L("custom_modifiers.labels.active"),
                { value = entry.enabled },
                tip("custom_modifiers.tips.active"),
                function()
                    if entry.enabled then
                        RemoveModifier(entry)
                        entry.enabled = false
                    else
                        ApplyModifier(entry)
                        entry.enabled = true
                    end
                end
            )

            Buttons.Dropdown(
                L("custom_modifiers.labels.modifier_type"),
                selectedType, Types,
                tip("custom_modifiers.tips.modifier_type")
            )

            Buttons.Float(
                L("custom_modifiers.labels.value"),
                valueSlider,
                tip("custom_modifiers.tips.value_adjust"),
                function()
                    entry.value = valueSlider.value
                    entry.modifierType = Types[selectedType.index or 1]
                    if entry.enabled then
                        RemoveModifier(entry)
                        ApplyModifier(entry)
                    end
                end
            )

            Buttons.Option(
                L("custom_modifiers.labels.remove"),
                tip("custom_modifiers.tips.remove"),
                function()
                    RemoveModifier(entry)
                    entry.enabled = false
                    for i = #customModifiers, 1, -1 do
                        if customModifiers[i] == entry then
                            table.remove(customModifiers, i)
                            break
                        end
                    end
                    SubmenuManager.CloseSubmenu()
                end
            )
        end
    }
end

local function GetFilteredStats(sourceList)
    local filter = L(Filters[selectedFilter.index or 1])
    local filtered = {}

    for _, name in ipairs(sourceList) do
        if filter == "A to Z" or filter == "Z to A" then
            table.insert(filtered, name)
        elseif name:sub(1, 1):lower() == filter:lower() then
            table.insert(filtered, name)
        end
    end

    if filter == "A to Z" then
        table.sort(filtered)
    elseif filter == "Z to A" then
        table.sort(filtered, function(a, b) return a > b end)
    end

    return filtered
end

function ModifierManager.View()
    Buttons.Dropdown(L("custom_modifiers.labels.mode"), selectedMode, Modes)

    local mode = selectedMode.index

    if mode == 1 then
        Buttons.StringCycler(
            L("custom_modifiers.labels.filter"),
            selectedFilter, Filters,
            tip("custom_modifiers.tips.filter")
        )
    end

    Buttons.Break(L("custom_modifiers.labels.stat_modifiers"))

    if mode == 1 then
        for _, statName in ipairs(GetFilteredStats(StatNames)) do
            Buttons.Submenu(
                statName,
                CreateModifierConfig(statName),
                tip("custom_modifiers.tips.create")
            )
        end
    elseif mode == 2 then
        if #customModifiers == 0 then
            Buttons.Text(L("custom_modifiers.labels.no_modifiers"), tip("custom_modifiers.labels.no_modifiers_tip"))
            return
        end

        for _, entry in ipairs(customModifiers) do
            Buttons.Submenu(
                entry.name,
                CreateModifierEditor(entry),
                tip("custom_modifiers.tips.edit")
            )
        end
    elseif mode == 3 then
        local names = {}
        for statName in pairs(recentStats) do
            table.insert(names, statName)
        end

        if #names == 0 then
            Buttons.Text(L("custom_modifiers.labels.no_recent"), tip("custom_modifiers.labels.no_recent_tip"))
            return
        end

        table.sort(names)
        for _, statName in ipairs(names) do
            Buttons.Submenu(
                statName,
                CreateModifierConfig(statName),
                tip("custom_modifiers.tips.recreate")
            )
        end
    end
end

return {
    title = "custom_modifiers.title",
    view = ModifierManager.View
}
