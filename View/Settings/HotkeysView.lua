local Buttons = require("UI/Options/Buttons")
local Submenu = require("UI/Navigation/Submenu")
local Bindings = require("Controls/Bindings")
local BindingsConfig = require("Config/BindingsConfig")
local Registry = require("UI/Registry/OptionRegistry")

local s_Toggles = nil

local function GetToggles()
    if s_Toggles then return s_Toggles end

    s_Toggles = {}
    for _, entry in ipairs(Registry.GetAll()) do
        if entry.Kind == Registry.Kind.Toggle then
            Bindings.EnsureAction(Registry.GetHotkeyAction(entry))
            table.insert(s_Toggles, entry)
        end
    end
    return s_Toggles
end

local function ClearAll()
    for _, entry in ipairs(GetToggles()) do
        Bindings.Actions[Registry.GetHotkeyAction(entry)] = { keys = {}, btns = {} }
    end
    BindingsConfig.Save()
end

local function HotkeysView()
    local toggles = GetToggles()
    Buttons.OptionExtended("Registered Toggles", "", tostring(#toggles), "Every toggle below can use a keyboard or controller binding.")
    Buttons.Option("Clear All Toggle Hotkeys", "Remove every optional toggle binding.", ClearAll)

    local category = nil
    for _, entry in ipairs(toggles) do
        if entry.Category ~= category then
            category = entry.Category
            Buttons.Break((tostring(category):gsub("^%l", string.upper)))
        end
        Buttons.Bind(Registry.GetLabel(entry), Registry.GetHotkeyAction(entry), Registry.GetTip(entry))
    end
end

return Submenu.Create("Toggle Hotkeys", HotkeysView)
