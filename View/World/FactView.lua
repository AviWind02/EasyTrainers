local Draw = require("UI")
local Buttons = Draw.Buttons
local NotificationManager = Draw.Notifier

local GameFacts = require("Features/World/Quest/GameFacts") -- Single table return
local Facts = require("Features/World/Quest/Facts")

local factCategories = {
    { key = "RomanceFlags", label = "Romance" },
    { key = "StoryOutcomeFlags", label = "Story Outcomes" },
    { key = "SmartWeaponStates", label = "Skippy States" },
    { key = "GameplayToggles", label = "Gameplay Toggles" },
    -- { key = "LifePathFlags", label = "Life Path" },
    { key = "WorldEventFlags", label = "World Events" },
    { key = "CensorshipFlags", label = "Censorship" }
}

local factLabels = {
    "Romance",
    "Story Outcomes",
    "Skippy States",
    "Gameplay Toggles",
    -- "Life Path",
    "World Events",
    "Censorship"
}

local selectedCategory = { index = 1, expanded = false }
local initializedCategories = {}
local factToggles = {}

local function GetOrCreateToggle(entry)
    if not factToggles[entry.id] then
        factToggles[entry.id] = Facts.MakeToggle(entry.id)
    end
    return factToggles[entry.id]
end

local function InitializeCategory(categoryKey)
    if initializedCategories[categoryKey] then return end
    initializedCategories[categoryKey] = true

    for _, entry in ipairs(GameFacts.FactFlags[categoryKey]) do
        local toggle = GetOrCreateToggle(entry)
        toggle.value = Facts.IsTrue(entry.id)
    end
end

local function DrawRelationshipFacts()
    Buttons.Break("Relationship Tracking")
    for _, entry in ipairs(GameFacts.RelationshipTrackingFacts) do
        local rawValue = Facts.Get(entry.id)
        local display = (rawValue ~= nil and rawValue ~= "") and tostring(rawValue) or "N/A"
        Buttons.OptionExtended(entry.name, nil, display)
    end
end

local function GameFactsView()
    Buttons.Dropdown("Category", selectedCategory, factLabels, "Choose a fact category to view")

    local categoryKey = factCategories[selectedCategory.index].key

    local entries = GameFacts.FactFlags[categoryKey]
    InitializeCategory(categoryKey)

    Buttons.Break("", factLabels[selectedCategory.index] .. " Flags")

    for _, entry in ipairs(entries) do
        local toggle = GetOrCreateToggle(entry)
        Buttons.Toggle(entry.name, toggle, entry.desc, function()
            toggle.value = not Facts.IsTrue(entry.id)
            Facts.SetBool(entry.id, toggle.value)
            NotificationManager.Push(entry.name .. ": " .. (toggle.value and "Enabled" or "Disabled"))
        end)
    end
end

return {
    title = "Game Fact Manager",
    view = GameFactsView
}
