local PerkLoader = require("Features/DataExtractors/PerkLoader")
local PlayerDevelopment = require("Gameplay").PlayerDevelopment
local Inventory = require("Gameplay").Inventory
local Buttons = require("UI").Buttons

local selectedAttribute = { index = 1, expanded = false }
local attributeOptions = {
    "playerdev.attributes.body",
    "playerdev.attributes.cool",
    "playerdev.attributes.intelligence",
    "playerdev.attributes.reflexes",
    "playerdev.attributes.technical",
    "playerdev.attributes.relic"
}

local attributeIdMap = {
    ["playerdev.attributes.body"] = "Body",
    ["playerdev.attributes.cool"] = "Cool",
    ["playerdev.attributes.intelligence"] = "Intelligence",
    ["playerdev.attributes.reflexes"] = "Reflexes",
    ["playerdev.attributes.technical"] = "Technical Ability",
    ["playerdev.attributes.relic"] = "Relic"
}

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
    { name = "playerdev.proficiencies.playerlevel", type = gamedataProficiencyType.Level },
    { name = "playerdev.proficiencies.streetcred", type = gamedataProficiencyType.StreetCred },
    { name = "playerdev.proficiencies.assault", type = gamedataProficiencyType.Assault },
    { name = "playerdev.proficiencies.athletics", type = gamedataProficiencyType.Athletics },
    { name = "playerdev.proficiencies.brawling", type = gamedataProficiencyType.Brawling },
    { name = "playerdev.proficiencies.coldblood", type = gamedataProficiencyType.ColdBlood },
    { name = "playerdev.proficiencies.combathacking", type = gamedataProficiencyType.CombatHacking },
    { name = "playerdev.proficiencies.cool", type = gamedataProficiencyType.CoolSkill },
    { name = "playerdev.proficiencies.crafting", type = gamedataProficiencyType.Crafting },
    { name = "playerdev.proficiencies.demolition", type = gamedataProficiencyType.Demolition },
    { name = "playerdev.proficiencies.engineering", type = gamedataProficiencyType.Engineering },
    { name = "playerdev.proficiencies.espionage", type = gamedataProficiencyType.Espionage },
    { name = "playerdev.proficiencies.gunslinger", type = gamedataProficiencyType.Gunslinger },
    { name = "playerdev.proficiencies.hacking", type = gamedataProficiencyType.Hacking },
    { name = "playerdev.proficiencies.intelligence", type = gamedataProficiencyType.IntelligenceSkill },
    { name = "playerdev.proficiencies.kenjutsu", type = gamedataProficiencyType.Kenjutsu },
    { name = "playerdev.proficiencies.reflexes", type = gamedataProficiencyType.ReflexesSkill },
    { name = "playerdev.proficiencies.stealth", type = gamedataProficiencyType.Stealth },
    { name = "playerdev.proficiencies.strength", type = gamedataProficiencyType.StrengthSkill },
    { name = "playerdev.proficiencies.technical", type = gamedataProficiencyType.TechnicalAbilitySkill }
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
        Buttons.Int(L(prof.name), entry.ref, tip("Set level for {name}", { name = L(prof.name) }), function()
            PlayerDevelopment.SetLevel(entry.type, entry.ref.value)
        end)
    end
end

local PlayerLevelView = {
    title = "playerdev.submenus.proficiencies.label",
    view = PlayerLevelView
}

local function AddMoney(amount)
    Inventory.GiveItem("Items.money", amount)
end

local eddieInput = { value = 1000, min = 1, max = 1000000, step = 100 }
local perkInput = { value = 1, min = 1, max = 100, step = 1 }
local attrInput = { value = 1, min = 1, max = 100, step = 1 }

local function ResourceView()
    local perkPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Primary) or 0
    local attrPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Attribute) or 0
    local relicPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Espionage) or 0

    Buttons.OptionExtended(
        L("playerdev.perkpoints.available.label"), "", tostring(perkPoints),
        tip("playerdev.perkpoints.available.tip")
    )
    Buttons.OptionExtended(
        L("playerdev.attributepoints.available.label"), "", tostring(attrPoints),
        tip("playerdev.attributepoints.available.tip")
    )
    Buttons.OptionExtended(
        L("playerdev.relicpoints.available.label"), "", tostring(relicPoints),
        tip("playerdev.relicpoints.available.tip")
    )

    Buttons.Break(L("playerdev.eddies.label"))
    Buttons.Option(L("playerdev.eddies.add1k.label"), tip("playerdev.eddies.add1k.tip"), function() AddMoney(1000) end)
    Buttons.Option(L("playerdev.eddies.add10k.label"), tip("playerdev.eddies.add10k.tip"), function() AddMoney(10000) end)
    Buttons.Option(L("playerdev.eddies.add100k.label"), tip("playerdev.eddies.add100k.tip"), function() AddMoney(100000) end)
    Buttons.Int(L("playerdev.eddies.custom.label"), eddieInput, tip("playerdev.eddies.custom.tip"))
    Buttons.Option(L("playerdev.eddies.addcustom.label"), tip("playerdev.eddies.addcustom.tip"), function() AddMoney(eddieInput.value) end)
    Buttons.Option(L("playerdev.eddies.removecustom.label"), tip("playerdev.eddies.removecustom.tip"), function() Inventory.RemoveItem("Items.money", eddieInput.value) end)

    Buttons.Break(L("playerdev.perkpoints.label"))
    Buttons.Option(L("playerdev.perkpoints.add1"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, 1) end)
    Buttons.Option(L("playerdev.perkpoints.remove1"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, -1) end)
    Buttons.Int(L("playerdev.perkpoints.custom"), perkInput)
    Buttons.Option(L("playerdev.perkpoints.addcustom"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, perkInput.value) end)
    Buttons.Option(L("playerdev.perkpoints.removecustom"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, -perkInput.value) end)

    Buttons.Break(L("playerdev.attributepoints.label"))
    Buttons.Option(L("playerdev.attributepoints.add1"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, 1) end)
    Buttons.Option(L("playerdev.attributepoints.remove1"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, -1) end)
    Buttons.Int(L("playerdev.attributepoints.custom"), attrInput)
    Buttons.Option(L("playerdev.attributepoints.addcustom"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, attrInput.value) end)
    Buttons.Option(L("playerdev.attributepoints.removecustom"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, -attrInput.value) end)

    Buttons.Break(L("playerdev.relicpoints.label"))
    Buttons.Option(L("playerdev.relicpoints.add1"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Espionage, 1) end)
    Buttons.Option(L("playerdev.relicpoints.remove1"), "", function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Espionage, -1) end)
end

local PlayerResourceView = {
    title = "playerdev.submenus.resources.label",
    view = ResourceView
}

local perkLevels = {}
local perkLevelCache = {}

local function DrawPerksForAttribute(attrKey)
    local attr = attributeIdMap[attrKey]
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

        local info
        if maxLevel > 1 then
            perkLevels[id].enabled = perkLevelCache[id] > 0
            info = tip("playerdev.perks.tipmulti", { category = perk.category, levels = maxLevel })
            Buttons.Int(perk.name, perkLevels[id], info, function()
                local cached = perkLevelCache[id]
                local target = perkLevels[id].value
                if target > cached then
                    for _ = 1, (target - cached) do
                        if PlayerDevelopment.BuyPerk(perk.type, true) then cached = cached + 1 else break end
                    end
                elseif target < cached then
                    for _ = 1, (cached - target) do
                        if PlayerDevelopment.RemovePerk(perk.type) then cached = cached - 1 else break end
                    end
                end
                perkLevelCache[id] = cached
                perkLevels[id].value = cached
                perkLevels[id].enabled = cached > 0
            end)
        else
            info = tip("playerdev.perks.tipsingle", { category = perk.category })
            Buttons.Toggle(perk.name, { value = isActive }, info, function()
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
        local selectedAttr = attributeIdMap[attributeOptions[selectedAttribute.index]]
        local stat = statTypeMap[selectedAttr]
        if stat then
            attributeLevel.value = PlayerDevelopment.GetAttribute(stat)
        end
    end

    Buttons.Submenu(L("playerdev.submenus.proficiencies.label"), PlayerLevelView, tip("playerdev.submenus.proficiencies.tip"))
    Buttons.Submenu(L("playerdev.submenus.resources.label"), PlayerResourceView, tip("playerdev.submenus.resources.tip"))

    Buttons.Break(L("playerdev.perkattributes"))

    Buttons.Dropdown(L("playerdev.attributes.label"), selectedAttribute, attributeOptions, tip("Select attribute to manage"))

    Buttons.Int(L("playerdev.attributes.setlevel.label"), attributeLevel, tip("playerdev.attributes.setlevel.tip"), function()
        local stat = statTypeMap[attributeIdMap[attributeOptions[selectedAttribute.index]]]
        if stat then
            PlayerDevelopment.SetAttribute(stat, attributeLevel.value)
        end
    end)

    Buttons.Toggle(L("playerdev.perks.activeonly"), showActiveOnly)
    Buttons.Toggle(L("playerdev.perks.inactiveonly"), showInactiveOnly)

    Buttons.Break(L("playerdev.perks.header"))
    DrawPerksForAttribute(attributeOptions[selectedAttribute.index])
end

return {
    title = "playerdev.title",
    view = PlayerDevView
}
