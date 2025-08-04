local PerkLoader = require("Features/DataExtractors/PerkLoader")
local PlayerDevelopment = require("Gameplay").PlayerDevelopment
local Inventory = require("Gameplay").Inventory
local Buttons = require("UI").Buttons

local selectedAttribute = { index = 1, expanded = false }
local attributeOptions = { "Body", "Cool", "Intelligence", "Reflexes", "Technical Ability", "Relic" }

local attributeLevel = { value = 5, min = 1, max = 20 }
local showActiveOnly = { value = false }
local showInactiveOnly = { value = false }
local lastSelectedIndex = -1

local statTypeMap = {
    ["Body"] = gamedataStatType.Strength,
    ["Cool"] = gamedataStatType.Cool,
    ["Intelligence"] = gamedataStatType.Intelligence,
    ["Reflexes"] = gamedataStatType.Reflexes,
    ["Technical Ability"] = gamedataStatType.TechnicalAbility,
    ["Relic"] = gamedataStatType.Espionage
}


local initializedLevelInit = false

local profLevels = {}

local Proficiencies = {
    { name = "Player Level", type = gamedataProficiencyType.Level },
    { name = "Street Cred", type = gamedataProficiencyType.StreetCred },
    { name = "Assault", type = gamedataProficiencyType.Assault },
    { name = "Athletics", type = gamedataProficiencyType.Athletics },
    { name = "Brawling", type = gamedataProficiencyType.Brawling },
    { name = "Cold Blood", type = gamedataProficiencyType.ColdBlood },
    { name = "Combat Hacking", type = gamedataProficiencyType.CombatHacking },
    { name = "Cool", type = gamedataProficiencyType.CoolSkill },
    { name = "Crafting", type = gamedataProficiencyType.Crafting },
    { name = "Demolition", type = gamedataProficiencyType.Demolition },
    { name = "Engineering", type = gamedataProficiencyType.Engineering },
    { name = "Espionage", type = gamedataProficiencyType.Espionage },
    { name = "Gunslinger", type = gamedataProficiencyType.Gunslinger },
    { name = "Hacking", type = gamedataProficiencyType.Hacking },
    { name = "Intelligence", type = gamedataProficiencyType.IntelligenceSkill },
    { name = "Kenjutsu", type = gamedataProficiencyType.Kenjutsu },
    { name = "Reflexes", type = gamedataProficiencyType.ReflexesSkill },
    { name = "Stealth", type = gamedataProficiencyType.Stealth },
    { name = "Strength", type = gamedataProficiencyType.StrengthSkill },
    { name = "Technical Ability", type = gamedataProficiencyType.TechnicalAbilitySkill },
}

local function LevelInit()
    if initializedLevelInit then return end
    initializedLevelInit = true

    for _, prof in ipairs(Proficiencies) do
        local value = PlayerDevelopment.GetLevel(prof.type)
        local max = PlayerDevelopment.GetMaxLevel(prof.type)
        profLevels[prof.name] = {
            ref = { value = value or 1, min = 0, max = max, step = 1 },
            type = prof.type
        }
    end
end
local function PlayerLevelView()
    LevelInit()

    for _, prof in ipairs(Proficiencies) do
        local entry = profLevels[prof.name]
        Buttons.Int(prof.name, entry.ref, "Set level for " .. prof.name, function()
            PlayerDevelopment.SetLevel(entry.type, entry.ref.value)
        end)
    end
end

local PlayerLevelView = {
    title = "Proficiencies Levels",
    view = PlayerLevelView
}

local function AddMoney(amount)
    Inventory.GiveItem("Items.money", amount)
end

local function RemoveMoney(amount)
    Inventory.RemoveItem("Items.money", amount)
end

local eddieInput = { value = 1000, min = 1, max = 1000000, step = 100 }
local perkInput = { value = 1, min = 1, max = 100, step = 1 }
local attrInput = { value = 1, min = 1, max = 100, step = 1 }

local function ResourceView()
    -- local eddies = Inventory.GetItemCount("Items.money") or 0
    local perkPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Primary) or 0
    local attrPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Attribute) or 0
    local relicPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Espionage) or 0

    -- Buttons.OptionExtended("Eddies:", "", tostring(eddies))
    Buttons.OptionExtended("Available Perk Points:", "", tostring(perkPoints),
        "Available points to spend on perks. You can add or remove points using the options below.")
    Buttons.OptionExtended("Available Attribute Points:", "", tostring(attrPoints),
        "Available points to spend on attributes. You can add or remove points using the options below.")
    Buttons.OptionExtended("Available Relic Points:", "", tostring(relicPoints),
        "Available points to unlock Relic-based perks.")


    Buttons.Break("Eurodollar")
    Buttons.Option("Add 1,000 Eddies", "Feeling broke? Here's lunch money.", function() AddMoney(1000) end)
    Buttons.Option("Add 10,000 Eddies", "Treat yourself. You earned it (maybe).", function() AddMoney(10000) end)
    Buttons.Option("Add 100,000 Eddies", "Because sometimes crime does pay.", function() AddMoney(100000) end)
    Buttons.Int("Custom Eddie Amount", eddieInput, "Set custom amount to add/remove")
    Buttons.Option("Add Eddies (Custom)", "Adds the specified amount", function() AddMoney(eddieInput.value) end)
    Buttons.Option("Remove Eddies (Custom)", "Removes the specified amount", function() RemoveMoney(eddieInput.value) end)

    Buttons.Break("Perk Points")

    Buttons.Option("Add 1 Perk Point", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, 1)
    end)

    Buttons.Option("Remove 1 Perk Point", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, -1)
    end)

    Buttons.Int("Custom Perk Points", perkInput)
    Buttons.Option("Add Perk Points (Custom)", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, perkInput.value)
    end)
    Buttons.Option("Remove Perk Points (Custom)", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, -perkInput.value)
    end)

    Buttons.Break("Attribute Points")

    Buttons.Option("Add 1 Attribute Point", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, 1)
    end)

    Buttons.Option("Remove 1 Attribute Point", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, -1)
    end)

    Buttons.Int("Custom Attribute Points", attrInput)
    Buttons.Option("Add Attribute Points (Custom)", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, attrInput.value)
    end)
    Buttons.Option("Remove Attribute Points (Custom)", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, -attrInput.value)
    end)
    Buttons.Break("Relic Points")
    Buttons.Option("Add 1 Relic Point", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Espionage, 1)
    end)
    Buttons.Option("Remove 1 Relic Point", "", function()
        PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Espionage, -1)
    end)
end

local PlayerResourceView = {
    title = "Resources",
    view = ResourceView
}


local perkLevels = {}
local perkLevelCache = {}

local function DrawPerksForAttribute(attr)
    local perks = PerkLoader.attribute[attr] or {}

    for id, perk in pairs(perks) do
        local maxLevel = PlayerDevelopment.GetPerkMaxLevel(perk.type)
        local isActive = PlayerDevelopment.HasPerk(perk.type)

        if not perkLevels[id] then
            perkLevels[id] = { value = 1, min = 1, max = maxLevel, step = 1 }
        end

        perkLevels[id].max = maxLevel

        if perkLevelCache[id] == nil then
            perkLevelCache[id] = isActive and maxLevel or 0
        end

        local tip
        if maxLevel > 1 then
            perkLevels[id].enabled = perkLevelCache[id] > 0
            tip = string.format("%s\nCategory: %s\n\nThis perk has %d levels. Use Arrow keys to adjust the level.", perk.description, perk.category, maxLevel)

            Buttons.Int(perk.name, perkLevels[id], tip, function()
                local cached = perkLevelCache[id]
                local target = perkLevels[id].value

                if target > cached then
                    for _ = 1, (target - cached) do
                        if PlayerDevelopment.BuyPerk(perk.type, true) then
                            cached = cached + 1
                        else
                            break
                        end
                    end
                elseif target < cached then
                    for _ = 1, (cached - target) do
                        if PlayerDevelopment.RemovePerk(perk.type) then
                            cached = cached - 1
                        else
                            break
                        end
                    end
                end

                perkLevelCache[id] = cached
                perkLevels[id].value = cached
                perkLevels[id].enabled = cached > 0
            end)
        else
            tip = string.format("%s\nCategory: %s\n\nThis perk only has 1 level. Toggle on/off to apply or remove it.", perk.description, perk.category)

            Buttons.Toggle(perk.name, { value = isActive }, tip, function()
                if isActive then
                    PlayerDevelopment.RemovePerk(perk.type)
                    perkLevelCache[id] = 0
                else
                    if PlayerDevelopment.BuyPerk(perk.type, true) then
                        perkLevelCache[id] = 1
                    end
                end
            end)
        end
    end
end

local function PlayerDevView()
    if selectedAttribute.index ~= lastSelectedIndex then
        lastSelectedIndex = selectedAttribute.index

        local selectedAttr = attributeOptions[selectedAttribute.index]
        local stat = statTypeMap[selectedAttr]
        if stat then
            attributeLevel.value = PlayerDevelopment.GetAttribute(stat)
        end
    end

    Buttons.Submenu("Proficiencies Levels", PlayerLevelView, "Edit your level values and XP tracks for every Proficiency.")
    Buttons.Submenu("Resources", PlayerResourceView, "Add or remove money, perk points, and attribute points.")

    Buttons.Break("Attributes Perks")

    Buttons.Dropdown("Attribute", selectedAttribute, attributeOptions, "Select attribute to manage")

    Buttons.Int("Set Attribute Level", attributeLevel, "Set base level for this attribute", function()
        local stat = statTypeMap[attributeOptions[selectedAttribute.index]]
        if stat then
            PlayerDevelopment.SetAttribute(stat, attributeLevel.value)
        end
    end)

    Buttons.Toggle("Show Only Active Perks", showActiveOnly)
    Buttons.Toggle("Show Only Inactive Perks", showInactiveOnly)

    Buttons.Break("Perks")
    DrawPerksForAttribute(attributeOptions[selectedAttribute.index])
end

return {
    title = "Player Development",
    view = PlayerDevView
}
