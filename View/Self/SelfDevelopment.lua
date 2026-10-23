local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Notification = require("UI/Panels/Notification/Notification")
local PerkLoader = require("Utils/DataExtractors/PerkLoader")
local PlayerDevelopment = require("Utils/PlayerDevelopment")
local Inventory = require("Utils/Inventory")

local POINT = gamedataDevelopmentPointType

local ATTRIBUTES = {
    { Key = "playerdev.attributes.body", Name = "Body", Stat = gamedataStatType.Strength },
    { Key = "playerdev.attributes.cool", Name = "Cool", Stat = gamedataStatType.Cool },
    { Key = "playerdev.attributes.intelligence", Name = "Intelligence", Stat = gamedataStatType.Intelligence },
    { Key = "playerdev.attributes.reflexes", Name = "Reflexes", Stat = gamedataStatType.Reflexes },
    { Key = "playerdev.attributes.technical", Name = "Technical Ability", Stat = gamedataStatType.TechnicalAbility },
    { Key = "playerdev.attributes.relic", Name = "Relic", Stat = gamedataStatType.Espionage }
}

local PERK_FILTER = { All = 1, Active = 2, Inactive = 3 }
local PERK_FILTER_OPTIONS = {
    "playerdev.perks.filter.all",
    "playerdev.perks.filter.active",
    "playerdev.perks.filter.inactive"
}

local PROFICIENCIES = {
    { Name = "playerdev.proficiencies.playerlevel", Type = gamedataProficiencyType.Level },
    { Name = "playerdev.proficiencies.streetcred", Type = gamedataProficiencyType.StreetCred },
    { Name = "playerdev.proficiencies.assault", Type = gamedataProficiencyType.Assault },
    { Name = "playerdev.proficiencies.athletics", Type = gamedataProficiencyType.Athletics },
    { Name = "playerdev.proficiencies.brawling", Type = gamedataProficiencyType.Brawling },
    { Name = "playerdev.proficiencies.coldblood", Type = gamedataProficiencyType.ColdBlood },
    { Name = "playerdev.proficiencies.combathacking", Type = gamedataProficiencyType.CombatHacking },
    { Name = "playerdev.proficiencies.cool", Type = gamedataProficiencyType.CoolSkill },
    { Name = "playerdev.proficiencies.crafting", Type = gamedataProficiencyType.Crafting },
    { Name = "playerdev.proficiencies.demolition", Type = gamedataProficiencyType.Demolition },
    { Name = "playerdev.proficiencies.engineering", Type = gamedataProficiencyType.Engineering },
    { Name = "playerdev.proficiencies.espionage", Type = gamedataProficiencyType.Espionage },
    { Name = "playerdev.proficiencies.gunslinger", Type = gamedataProficiencyType.Gunslinger },
    { Name = "playerdev.proficiencies.hacking", Type = gamedataProficiencyType.Hacking },
    { Name = "playerdev.proficiencies.intelligence", Type = gamedataProficiencyType.IntelligenceSkill },
    { Name = "playerdev.proficiencies.kenjutsu", Type = gamedataProficiencyType.Kenjutsu },
    { Name = "playerdev.proficiencies.reflexes", Type = gamedataProficiencyType.ReflexesSkill },
    { Name = "playerdev.proficiencies.stealth", Type = gamedataProficiencyType.Stealth },
    { Name = "playerdev.proficiencies.strength", Type = gamedataProficiencyType.StrengthSkill },
    { Name = "playerdev.proficiencies.technical", Type = gamedataProficiencyType.TechnicalAbilitySkill }
}

local s_Attribute = { index = 1, expanded = false }
local s_AttributeKeys = {}
local s_AttributeLevel = { value = 5, min = 1, max = 20 }
local s_LoadedAttribute = -1
local s_PerkFilter = { index = PERK_FILTER.All }
local s_SortedPerks = {}
local s_ProficiencyRefs = nil
local s_Eddies = { value = 1000, min = 1, max = 1000000, step = 100 }
local s_PerkPoints = { value = 1, min = 1, max = 100, step = 1 }
local s_AttributePoints = { value = 1, min = 1, max = 100, step = 1 }

for _, attribute in ipairs(ATTRIBUTES) do table.insert(s_AttributeKeys, attribute.Key) end

local function ProficiencyView()
    if not s_ProficiencyRefs then
        s_ProficiencyRefs = {}
        for _, proficiency in ipairs(PROFICIENCIES) do
            s_ProficiencyRefs[proficiency.Type] = {
                value = PlayerDevelopment.GetLevel(proficiency.Type) or 1,
                min = 0,
                max = PlayerDevelopment.GetMaxLevel(proficiency.Type),
                step = 1
            }
        end
    end

    for _, proficiency in ipairs(PROFICIENCIES) do
        Buttons.Int(L(proficiency.Name), s_ProficiencyRefs[proficiency.Type], tip("playerdev.proficiencies.tip", { name = L(proficiency.Name) }), function(value)
            PlayerDevelopment.SetLevel(proficiency.Type, value)
        end)
    end
end

local ProficiencyMenu = Submenu.Create("playerdev.submenus.proficiencies.label", ProficiencyView)

local function AddMoney(amount)
    Inventory.GiveItem("Items.money", amount)
end

local function PointOption(key, pointType, amount, tipText)
    Buttons.Option(L(key), tipText, function() PlayerDevelopment.AddDevPoints(pointType, amount()) end)
end

local function Fixed(amount)
    return function() return amount end
end

local function ResourceView()
    Buttons.OptionExtended(L("playerdev.perkpoints.available.label"), "", tostring(PlayerDevelopment.GetDevPoints(POINT.Primary) or 0), tip("playerdev.perkpoints.available.tip"))
    Buttons.OptionExtended(L("playerdev.attributepoints.available.label"), "", tostring(PlayerDevelopment.GetDevPoints(POINT.Attribute) or 0), tip("playerdev.attributepoints.available.tip"))
    Buttons.OptionExtended(L("playerdev.relicpoints.available.label"), "", tostring(PlayerDevelopment.GetDevPoints(POINT.Espionage) or 0), tip("playerdev.relicpoints.available.tip"))

    Buttons.Break(L("playerdev.eddies.label"))
    Buttons.Option(L("playerdev.eddies.add1k.label"), tip("playerdev.eddies.add1k.tip"), function() AddMoney(1000) end)
    Buttons.Option(L("playerdev.eddies.add10k.label"), tip("playerdev.eddies.add10k.tip"), function() AddMoney(10000) end)
    Buttons.Option(L("playerdev.eddies.add100k.label"), tip("playerdev.eddies.add100k.tip"), function() AddMoney(100000) end)
    Buttons.Int(L("playerdev.eddies.custom.label"), s_Eddies, tip("playerdev.eddies.custom.tip"))
    Buttons.Option(L("playerdev.eddies.addcustom.label"), tip("playerdev.eddies.addcustom.tip"), function() AddMoney(s_Eddies.value) end)
    Buttons.Option(L("playerdev.eddies.removecustom.label"), tip("playerdev.eddies.removecustom.tip"), function()
        Inventory.RemoveItem("Items.money", s_Eddies.value)
    end)

    Buttons.Break(L("playerdev.perkpoints.label"))
    PointOption("playerdev.perkpoints.add1", POINT.Primary, Fixed(1), "Adds one perk point.")
    PointOption("playerdev.perkpoints.remove1", POINT.Primary, Fixed(-1), "Removes one perk point.")
    Buttons.Int(L("playerdev.perkpoints.custom"), s_PerkPoints, "Amount used by the custom perk point options.")
    PointOption("playerdev.perkpoints.addcustom", POINT.Primary, function() return s_PerkPoints.value end, "Adds the custom amount of perk points.")
    PointOption("playerdev.perkpoints.removecustom", POINT.Primary, function() return -s_PerkPoints.value end, "Removes the custom amount of perk points.")

    Buttons.Break(L("playerdev.attributepoints.label"))
    PointOption("playerdev.attributepoints.add1", POINT.Attribute, Fixed(1), "Adds one attribute point.")
    PointOption("playerdev.attributepoints.remove1", POINT.Attribute, Fixed(-1), "Removes one attribute point.")
    Buttons.Int(L("playerdev.attributepoints.custom"), s_AttributePoints, "Amount used by the custom attribute point options.")
    PointOption("playerdev.attributepoints.addcustom", POINT.Attribute, function() return s_AttributePoints.value end, "Adds the custom amount of attribute points.")
    PointOption("playerdev.attributepoints.removecustom", POINT.Attribute, function() return -s_AttributePoints.value end, "Removes the custom amount of attribute points.")

    Buttons.Break(L("playerdev.relicpoints.label"))
    PointOption("playerdev.relicpoints.add1", POINT.Espionage, Fixed(1), "Adds one Relic point.")
    PointOption("playerdev.relicpoints.remove1", POINT.Espionage, Fixed(-1), "Removes one Relic point.")
end

local ResourceMenu = Submenu.Create("playerdev.submenus.resources.label", ResourceView)

local function MissingRequirements(perk)
    local missing = {}
    for _, required in ipairs(perk.requirements and perk.requirements.perks or {}) do
        if not PlayerDevelopment.HasPerk(required.type) then table.insert(missing, required.name) end
    end
    return missing
end

local function NotifyMissing(perk, missing)
    Notification.Error(tip("playerdev.perks.notifications.requirement_failed", {
        perk = perk.name,
        requirements = table.concat(missing, ", ")
    }))
end

local function ResetPerk(perk, current)
    local removed = 0
    for _ = 1, current do
        if PlayerDevelopment.RemovePerk(perk.type) then removed = removed + 1 end
    end

    if removed > 0 then
        Notification.Info(tip("playerdev.perks.notifications.reset", { perk = perk.name, count = tostring(removed) }))
    else
        Notification.Error(tip("playerdev.perks.notifications.reset_failed", { perk = perk.name }))
    end
end

local function TogglePerk(perk, current, maxLevel, missing)
    if current >= maxLevel then
        if maxLevel == 1 then
            if PlayerDevelopment.RemovePerk(perk.type) then
                Notification.Info(tip("playerdev.perks.notifications.unequipped", { perk = perk.name }))
            else
                Notification.Error(tip("playerdev.perks.notifications.unequip_failed", { perk = perk.name }))
            end
            return
        end
        ResetPerk(perk, current)
        return
    end

    if #missing > 0 then
        NotifyMissing(perk, missing)
        return
    end

    if not PlayerDevelopment.AddPerk(perk.type, true) then
        local key = maxLevel == 1 and "playerdev.perks.notifications.equip_failed" or "playerdev.perks.notifications.level_failed"
        Notification.Error(tip(key, { perk = perk.name }))
        return
    end

    if maxLevel == 1 then
        Notification.Success(tip("playerdev.perks.notifications.equipped", { perk = perk.name }))
    else
        Notification.Success(tip("playerdev.perks.notifications.level_increased", { perk = perk.name, level = tostring(current + 1) }))
    end
end

local function PerkStatus(current, maxLevel, missing)
    if current == 0 and #missing > 0 then return L("playerdev.perks.locked") end
    if current == 0 then return L("playerdev.perks.unequipped") end
    return L("playerdev.perks.equipped") .. string.format(" %d / %d", current, maxLevel)
end

local function PerkTip(perk, maxLevel, missing)
    local key = maxLevel > 1 and "playerdev.perks.tipmulti" or "playerdev.perks.tipsingle"
    local text = tip(key, { category = perk.category, levels = maxLevel })
    if #missing == 0 then return text end
    return text .. "\n\nRequires: " .. table.concat(missing, ", ")
end

local function SortedPerks(attributeName)
    if s_SortedPerks[attributeName] then return s_SortedPerks[attributeName] end

    local perks = {}
    for _, perk in pairs(PerkLoader.attribute[attributeName] or {}) do table.insert(perks, perk) end
    table.sort(perks, function(a, b) return a.name < b.name end)
    s_SortedPerks[attributeName] = perks
    return perks
end

local function DrawPerk(perk)
    local current = PlayerDevelopment.GetPerkLevel(perk.type)
    if s_PerkFilter.index == PERK_FILTER.Active and current == 0 then return end
    if s_PerkFilter.index == PERK_FILTER.Inactive and current > 0 then return end

    local maxLevel = PlayerDevelopment.GetPerkMaxLevel(perk.type) or 1
    local missing = MissingRequirements(perk)
    Buttons.OptionExtended(perk.name, "", PerkStatus(current, maxLevel, missing), PerkTip(perk, maxLevel, missing), function()
        TogglePerk(perk, current, maxLevel, missing)
    end)
end

local function SetAttributeLevel(value)
    local attribute = ATTRIBUTES[s_Attribute.index or 1]
    PlayerDevelopment.SetAttribute(attribute.Stat, value)
end

local function PlayerDevelopmentView()
    local attribute = ATTRIBUTES[s_Attribute.index or 1]
    if s_Attribute.index ~= s_LoadedAttribute then
        s_LoadedAttribute = s_Attribute.index
        s_AttributeLevel.value = PlayerDevelopment.GetAttribute(attribute.Stat) or s_AttributeLevel.value
    end

    Buttons.Submenu(L("playerdev.submenus.proficiencies.label"), ProficiencyMenu, tip("playerdev.submenus.proficiencies.tip"))
    Buttons.Submenu(L("playerdev.submenus.resources.label"), ResourceMenu, tip("playerdev.submenus.resources.tip"))

    Buttons.Break(L("playerdev.perkattributes"))
    Buttons.Dropdown(L("playerdev.attributes.label"), s_Attribute, s_AttributeKeys, tip("playerdev.attributes.tip"))
    Buttons.Int(L("playerdev.attributes.setlevel.label"), s_AttributeLevel, tip("playerdev.attributes.setlevel.tip"), SetAttributeLevel)
    Buttons.StringCycler(L("playerdev.perks.filter.label"), s_PerkFilter, PERK_FILTER_OPTIONS, tip("playerdev.perks.filter.tip"))

    Buttons.Break(L("playerdev.perks.header"))
    for _, perk in ipairs(SortedPerks(attribute.Name)) do DrawPerk(perk) end
end

return Submenu.Create("playerdev.title", PlayerDevelopmentView)
