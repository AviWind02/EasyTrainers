local StatModifiers = require("Gameplay").StatModifiers
local WeaponInput = require("Gameplay").WeaponInput
local Buttons = require("UI").Buttons
local SubmenuManager = require("UI/Core/SubmenuManager")
local StatNames = require("Features/Self/StatModifiers/StatNames")

local ModifierManager = {}

local Modes = {
    "Create New Modifier",
    "View Existing Modifiers",
    "Recently Used Modifiers"
}

local Targets = { "Player", "Right Weapon", "Vehicle" }
local Types = { "Additive", "Multiplier", "Percentage" }

local Filters = {
    "A to Z",
    "Z to A",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
    "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
    "U", "V", "W", "X", "Y", "Z"
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
            Buttons.OptionExtended("Selected Modifier", "", statName)

            Buttons.Dropdown("Target", selectedTarget, Targets)
            Buttons.Dropdown("Modifier Type", selectedType, Types)
            Buttons.Float("Value", valueInput, "Amount to apply")

            Buttons.Option("Apply Modifier", "Create and apply this modifier", function()
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
            end)
        end
    }
end

local function CreateModifierEditor(entry)
    local valueSlider = { value = entry.value, min = -10000, max = 10000, step = 0.5 }
    local selectedType = { index = (function()
        for i, v in ipairs(Types) do if v == entry.modifierType then return i end end
        return 1
    end)(), expanded = false }

    return {
        title = "Modify " .. entry.name,
        view = function()
            Buttons.Toggle("Active", { value = entry.enabled }, "Enable/Disable modifier", function()
                if entry.enabled then
                    RemoveModifier(entry)
                    entry.enabled = false
                else
                    ApplyModifier(entry)
                    entry.enabled = true
                end
            end)

            Buttons.Dropdown("Modifier Type", selectedType, Types, "Change modifier calculation type")
            Buttons.Float("Value", valueSlider, "Adjust modifier value", function()
                entry.value = valueSlider.value
                entry.modifierType = Types[selectedType.index or 1]
                if entry.enabled then
                    RemoveModifier(entry)
                    ApplyModifier(entry)
                end
            end)

            Buttons.Option("Remove Modifier", "Delete this modifier", function()
                RemoveModifier(entry)
                entry.enabled = false
                for i = #customModifiers, 1, -1 do
                    if customModifiers[i] == entry then
                        table.remove(customModifiers, i)
                        break
                    end
                end
                SubmenuManager.CloseSubmenu()
            end)
        end
    }
end

local function GetFilteredStats(sourceList)
    local filter = Filters[selectedFilter.index or 1]
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
    Buttons.Dropdown("Mode", selectedMode, Modes)
    local mode = selectedMode.index

    if mode == 1 then
        Buttons.StringCycler("Filter", selectedFilter, Filters, "Filter stat names")
    end

    Buttons.Break("Stat Modifiers")

    if mode == 1 then
        for _, statName in ipairs(GetFilteredStats(StatNames)) do
            Buttons.Submenu(statName, CreateModifierConfig(statName), "Configure a custom modifier for this stat")
        end

    elseif mode == 2 then
        if #customModifiers == 0 then
            Buttons.Text("No modifiers created", "Switch to 'Create' mode to add new ones.")
            return
        end

        for _, entry in ipairs(customModifiers) do
            Buttons.Submenu(entry.name, CreateModifierEditor(entry), "Edit or delete this modifier")
        end

    elseif mode == 3 then
        local names = {}
        for statName in pairs(recentStats) do
            table.insert(names, statName)
        end

        if #names == 0 then
            Buttons.Text("No recent modifiers", "Create or delete a modifier to track it here.")
            return
        end

        table.sort(names)
        for _, statName in ipairs(names) do
            Buttons.Submenu(statName, CreateModifierConfig(statName), "Re-create modifier for this stat")
        end
    end
end

return {
    title = "Custom Modifiers",
    view = ModifierManager.View
}
