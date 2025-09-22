local PerkLoader = require("Utils/DataExtractors/PerkLoader")
local PlayerDevelopment = require("Utils").PlayerDevelopment
local Inventory = require("Utils").Inventory
local Buttons = require("UI").Buttons
local Logger = require("Core/Logger")
local utils = require("Utils/DataExtractors/DataUtils")


local selectedAttribute = { index = 1, expanded = false }
local attributeOptions = {
    "playerdev.attributes.body",
    "playerdev.attributes.cool",
    "playerdev.attributes.intelligence",
    "playerdev.attributes.reflexes",
    "playerdev.attributes.technical",
    -- "playerdev.attributes.relic"
}

local perkFilter = { index = 1 }
local perkFilterOptions = {
    "playerdev.perks.filter.all",
    "playerdev.perks.filter.active",
    "playerdev.perks.filter.inactive"
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

local initializedLevels = false
local profLevels = {}

local Proficiencies = {
    { name = "playerdev.proficiencies.playerlevel",   type = gamedataProficiencyType.Level },
    { name = "playerdev.proficiencies.streetcred",    type = gamedataProficiencyType.StreetCred },
    { name = "playerdev.proficiencies.assault",       type = gamedataProficiencyType.Assault },
    { name = "playerdev.proficiencies.athletics",     type = gamedataProficiencyType.Athletics },
    { name = "playerdev.proficiencies.brawling",      type = gamedataProficiencyType.Brawling },
    { name = "playerdev.proficiencies.coldblood",     type = gamedataProficiencyType.ColdBlood },
    { name = "playerdev.proficiencies.combathacking", type = gamedataProficiencyType.CombatHacking },
    { name = "playerdev.proficiencies.cool",          type = gamedataProficiencyType.CoolSkill },
    { name = "playerdev.proficiencies.crafting",      type = gamedataProficiencyType.Crafting },
    { name = "playerdev.proficiencies.demolition",    type = gamedataProficiencyType.Demolition },
    { name = "playerdev.proficiencies.engineering",   type = gamedataProficiencyType.Engineering },
    { name = "playerdev.proficiencies.espionage",     type = gamedataProficiencyType.Espionage },
    { name = "playerdev.proficiencies.gunslinger",    type = gamedataProficiencyType.Gunslinger },
    { name = "playerdev.proficiencies.hacking",       type = gamedataProficiencyType.Hacking },
    { name = "playerdev.proficiencies.intelligence",  type = gamedataProficiencyType.IntelligenceSkill },
    { name = "playerdev.proficiencies.kenjutsu",      type = gamedataProficiencyType.Kenjutsu },
    { name = "playerdev.proficiencies.reflexes",      type = gamedataProficiencyType.ReflexesSkill },
    { name = "playerdev.proficiencies.stealth",       type = gamedataProficiencyType.Stealth },
    { name = "playerdev.proficiencies.strength",      type = gamedataProficiencyType.StrengthSkill },
    { name = "playerdev.proficiencies.technical",     type = gamedataProficiencyType.TechnicalAbilitySkill }
}

local function InitProficiencies()
    if initializedLevels then return end
    initializedLevels = true
    for _, prof in ipairs(Proficiencies) do
        local value = PlayerDevelopment.GetLevel(prof.type) or 1
        local max = PlayerDevelopment.GetMaxLevel(prof.type)
        profLevels[prof.name] = { ref = { value = value, min = 0, max = max, step = 1 }, type = prof.type }
    end
end

local function ProficiencyView()
    InitProficiencies()
    for _, prof in ipairs(Proficiencies) do
        local entry = profLevels[prof.name]
        Buttons.Int(L(prof.name), entry.ref, tip("Set level for {name}", { name = L(prof.name) }), function()
            PlayerDevelopment.SetLevel(entry.type, entry.ref.value)
        end)
    end
end

local ProficiencyMenu = {
    title = "playerdev.submenus.proficiencies.label",
    view = ProficiencyView
}

local eddieInput = { value = 1000, min = 1, max = 1000000, step = 100 }
local perkInput = { value = 1, min = 1, max = 100, step = 1 }
local attrInput = { value = 1, min = 1, max = 100, step = 1 }

local function AddMoney(amount) Inventory.GiveItem("Items.money", amount) end

local function ResourceView()
    local perkPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Primary) or 0
    local attrPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Attribute) or 0
    local relicPoints = PlayerDevelopment.GetDevPoints(gamedataDevelopmentPointType.Espionage) or 0

    Buttons.OptionExtended(L("playerdev.perkpoints.available.label"), "", tostring(perkPoints),
        tip("playerdev.perkpoints.available.tip"))
    Buttons.OptionExtended(L("playerdev.attributepoints.available.label"), "", tostring(attrPoints),
        tip("playerdev.attributepoints.available.tip"))
    Buttons.OptionExtended(L("playerdev.relicpoints.available.label"), "", tostring(relicPoints),
        tip("playerdev.relicpoints.available.tip"))

    Buttons.Break(L("playerdev.eddies.label"))
    Buttons.Option(L("playerdev.eddies.add1k.label"), tip("playerdev.eddies.add1k.tip"), function() AddMoney(1000) end)
    Buttons.Option(L("playerdev.eddies.add10k.label"), tip("playerdev.eddies.add10k.tip"), function() AddMoney(10000) end)
    Buttons.Option(L("playerdev.eddies.add100k.label"), tip("playerdev.eddies.add100k.tip"),
        function() AddMoney(100000) end)
    Buttons.Int(L("playerdev.eddies.custom.label"), eddieInput, tip("playerdev.eddies.custom.tip"))
    Buttons.Option(L("playerdev.eddies.addcustom.label"), tip("playerdev.eddies.addcustom.tip"),
        function() AddMoney(eddieInput.value) end)
    Buttons.Option(L("playerdev.eddies.removecustom.label"), tip("playerdev.eddies.removecustom.tip"),
        function() Inventory.RemoveItem("Items.money", eddieInput.value) end)

    Buttons.Break(L("playerdev.perkpoints.label"))
    Buttons.Option(L("playerdev.perkpoints.add1"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, 1) end)
    Buttons.Option(L("playerdev.perkpoints.remove1"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, -1) end)
    Buttons.Int(L("playerdev.perkpoints.custom"), perkInput)
    Buttons.Option(L("playerdev.perkpoints.addcustom"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, perkInput.value) end)
    Buttons.Option(L("playerdev.perkpoints.removecustom"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Primary, -perkInput.value) end)

    Buttons.Break(L("playerdev.attributepoints.label"))
    Buttons.Option(L("playerdev.attributepoints.add1"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, 1) end)
    Buttons.Option(L("playerdev.attributepoints.remove1"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, -1) end)
    Buttons.Int(L("playerdev.attributepoints.custom"), attrInput)
    Buttons.Option(L("playerdev.attributepoints.addcustom"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, attrInput.value) end)
    Buttons.Option(L("playerdev.attributepoints.removecustom"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Attribute, -attrInput.value) end)

    Buttons.Break(L("playerdev.relicpoints.label"))
    Buttons.Option(L("playerdev.relicpoints.add1"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Espionage, 1) end)
    Buttons.Option(L("playerdev.relicpoints.remove1"), "",
        function() PlayerDevelopment.AddDevPoints(gamedataDevelopmentPointType.Espionage, -1) end)
end

local ResourceMenu = {
    title = "playerdev.submenus.resources.label",
    view = ResourceView
}

local perkLevels = {}
local perkLevelCache = {}

local function DrawPerkEntry(id, perk)
    local maxLevel = PlayerDevelopment.GetPerkMaxLevel(perk.type) or 1
    local current  = PlayerDevelopment.GetCurrPerkLevel(perk.type)

    local display
    if maxLevel > 1 then
        display = string.format("%d / %d", current, maxLevel)
    else
        display = (current > 0) and L("playerdev.perks.equipped") or L("playerdev.perks.unequipped")
    end

    Buttons.OptionExtended(
        perk.name,
        "",
        display,
        tip("playerdev.perks.tipmulti", { category = perk.category, levels = maxLevel }),
        function()
            local base = tostring(perk.type):gsub("(_%d+)$", "")

            if maxLevel == 1 then
                -- Toggle single-rank perk
                if current == 0 then
                    if PlayerDevelopment.BuyPerk(perk.type, true) then
                        Logger.Log(" -> Equipped")
                        current = 1
                    end
                else
                    if PlayerDevelopment.RemovePerk(perk.type) then
                        Logger.Log(" -> Unequipped")
                        current = 0
                    end
                end
            else
                -- Multi-rank: cycle 0 → max
                if current < maxLevel then
                    local nextRank = TweakDBID.new(string.format("%s_%d", base, current + 1))
                    if PlayerDevelopment.BuyPerk(nextRank, true) then
                        current = current + 1
                        Logger.Log(" -> Level increased to " .. current)
                    end
                else
                    -- Reset: remove all ranks
                    for i = current, 1, -1 do
                        local rankId = TweakDBID.new(string.format("%s_%d", base, i))
                        if PlayerDevelopment.RemovePerk(rankId) then
                            Logger.Log(string.format(" -> Removed level %d", i))
                        else
                            Logger.Log(string.format(" -> Failed to remove level %d", i))
                            break
                        end
                    end
                    current = 0
                end
            end
        end
    )
end



local function DrawPerksForAttribute(attrKey)
    local attr  = attributeIdMap[attrKey]
    local perks = PerkLoader.attribute[attr] or {}

    for id, perk in pairs(perks) do
        local current  = PlayerDevelopment.GetCurrPerkLevel(perk.type)
        local isActive = current > 0

        -- Apply filter (all / active / inactive)
        if (perkFilter.index == 2 and not isActive) or
            (perkFilter.index == 3 and isActive) then
            goto continue
        end

        DrawPerkEntry(id, perk)

        ::continue::
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

    Buttons.Submenu(L("playerdev.submenus.proficiencies.label"), ProficiencyMenu,
        tip("playerdev.submenus.proficiencies.tip"))
    Buttons.Submenu(L("playerdev.submenus.resources.label"), ResourceMenu, tip("playerdev.submenus.resources.tip"))

    Buttons.Break(L("playerdev.perkattributes"))
    Buttons.Dropdown(L("playerdev.attributes.label"), selectedAttribute, attributeOptions,
        tip("Select attribute to manage"))
    Buttons.Int(L("playerdev.attributes.setlevel.label"), attributeLevel, tip("playerdev.attributes.setlevel.tip"),
        function()
            local stat = statTypeMap[attributeIdMap[attributeOptions[selectedAttribute.index]]]
            if stat then
                PlayerDevelopment.SetAttribute(stat, attributeLevel.value)
            end
        end)

    Buttons.StringCycler(L("playerdev.perks.filter.label"), perkFilter, perkFilterOptions,
        tip("playerdev.perks.filter.tip"))


    Buttons.Break(L("playerdev.perks.header"))
    DrawPerksForAttribute(attributeOptions[selectedAttribute.index])
end

return {
    title = "playerdev.title",
    view = PlayerDevView
}
