local StatModifiers = require("Gameplay").StatModifiers
local WeaponInput = require("Gameplay").WeaponInput
local Buttons = require("UI").Buttons
local SubmenuManager = require("UI/Core/SubmenuManager")
local StatNames = require("Features/Self/StatModifiers/StatNames")

local ModifierManager = {}

local Modes = {
    "custommodifiers.modes1",
    "custommodifiers.modes2",
    "custommodifiers.modes3"
}
local Filters = {
    "custommodifiers.filters1", "custommodifiers.filters2",
    "custommodifiers.filters3", "custommodifiers.filters4", "custommodifiers.filters5",
    "custommodifiers.filters6", "custommodifiers.filters7", "custommodifiers.filters8",
    "custommodifiers.filters9", "custommodifiers.filters10", "custommodifiers.filters11",
    "custommodifiers.filters12", "custommodifiers.filters13", "custommodifiers.filters14",
    "custommodifiers.filters15", "custommodifiers.filters16", "custommodifiers.filters17",
    "custommodifiers.filters18", "custommodifiers.filters19", "custommodifiers.filters20",
    "custommodifiers.filters21", "custommodifiers.filters22", "custommodifiers.filters23",
    "custommodifiers.filters24", "custommodifiers.filters25", "custommodifiers.filters26",
    "custommodifiers.filters27", "custommodifiers.filters28"
}
local Targets = {
    "custommodifiers.targets1",
    "custommodifiers.targets2",
    "custommodifiers.targets3"
}
local Types = {
    "custommodifiers.types1",
    "custommodifiers.types2",
    "custommodifiers.types3"
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
            Buttons.OptionExtended(L("custommodifiers.selectedmodifier.label"), "", statName)
            Buttons.Dropdown(L("custommodifiers.target.label"), selectedTarget, Targets)
            Buttons.Dropdown(L("custommodifiers.modifiertype.label"), selectedType, Types)
            Buttons.Float(L("custommodifiers.value.label"), valueInput, tip("custommodifiers.value.tip"))
            Buttons.Option(
                L("custommodifiers.apply.label"),
                tip("custommodifiers.apply.tip"),
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
                L("custommodifiers.active.label"),
                { value = entry.enabled },
                tip("custommodifiers.active.tip"),
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
                L("custommodifiers.modifiertype.label"),
                selectedType, Types,
                tip("custommodifiers.modifiertype.tip")
            )

            Buttons.Float(
                L("custommodifiers.value.label"),
                valueSlider,
                tip("custommodifiers.valueadjust.tip"),
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
                L("custommodifiers.remove.label"),
                tip("custommodifiers.remove.tip"),
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
    Buttons.Dropdown(L("custommodifiers.mode.label"), selectedMode, Modes)

    local mode = selectedMode.index

    if mode == 1 then
        Buttons.StringCycler(
            L("custommodifiers.filter.label"),
            selectedFilter, Filters,
            tip("custommodifiers.filter.tip")
        )
    end

    Buttons.Break(L("custommodifiers.statmodifiers.label"))

    if mode == 1 then
        for _, statName in ipairs(GetFilteredStats(StatNames)) do
            Buttons.Submenu(
                statName,
                CreateModifierConfig(statName),
                tip("custommodifiers.create.tip")
            )
        end
    elseif mode == 2 then
        if #customModifiers == 0 then
            Buttons.Text(L("custommodifiers.nomodifiers.label"), tip("custommodifiers.nomodifiers.tip"))
            return
        end

        for _, entry in ipairs(customModifiers) do
            Buttons.Submenu(
                entry.name,
                CreateModifierEditor(entry),
                tip("custommodifiers.edit.tip")
            )
        end
    elseif mode == 3 then
        local names = {}
        for statName in pairs(recentStats) do
            table.insert(names, statName)
        end

        if #names == 0 then
            Buttons.Text(L("custommodifiers.norecent.label"), tip("custommodifiers.norecent.tip"))
            return
        end

        table.sort(names)
        for _, statName in ipairs(names) do
            Buttons.Submenu(
                statName,
                CreateModifierConfig(statName),
                tip("custommodifiers.recreate.tip")
            )
        end
    end
end

return {
    title = "custommodifiers.title",
    view = ModifierManager.View
}
