-- Buttons.lua
local Buttons = {}

local OptionManager = require("UI/Elements/OptionManager")
local Submenus = require("UI/Core/SubmenuManager")
local ConfigManager = require("Core/ConfigManager")

local function makeKey(prefix, label)
    return (prefix or "ui") .. "." .. tostring(label):gsub("%s+", "_"):lower()
end

function Buttons.Option(label, tip, action)
    if OptionManager.Option(label, "", "", tip) then
        if action then action() end
        return true
    end
    return false
end

function Buttons.OptionExtended(left, center, right, tip, action)
    if OptionManager.Option(left, center, right, tip) then
        if action then action() end
        return true
    end
    return false
end

function Buttons.Break(left, center, right)
    return OptionManager.Break(left, center, right)
end

function Buttons.Submenu(label, submenuId, tip, action)
    if OptionManager.Option(label, "", IconGlyphs.ArrowRight, tip) then
        if submenuId then
            Submenus.OpenSubmenu(submenuId)
        end
        if action then action() end
        return true
    end
    return false
end

function Buttons.Toggle(label, ref, tip, action)
    -- ConfigManager.Register(makeKey("toggle", label), ref, ref.value)
    if OptionManager.Toggle(label, ref, tip) then
        if action then action() end
        ConfigManager.Save()
        return true
    end
    return false
end

function Buttons.GhostToggle(label, ref, tip, action)
    if OptionManager.Toggle(label, ref, tip) then
        if action then action() end
        return true
    end
    return false
end

function Buttons.Int(label, ref, tip, action)
    -- ConfigManager.Register(makeKey("int", label), ref, ref.value)
    if OptionManager.IntToggle(label, ref, tip) then
        if action then action() end
        ConfigManager.Save()
        return true
    end
    return false
end

function Buttons.Float(label, ref, tip, action)
    -- ConfigManager.Register(makeKey("float", label), ref, ref.value)
    if OptionManager.FloatToggle(label, ref, tip) then
        if action then action() end
        ConfigManager.Save()
        return true
    end
    return false
end

function Buttons.Dropdown(label, ref, options, tip)
    OptionManager.Dropdown(label, ref, options, tip)
end

function Buttons.Radio(label, ref, options, tip, action)
    if OptionManager.Radio(label, ref, options, tip) then
        if action then action() end
        return true
    end 
    return false
end

function Buttons.StringCycler(label, ref, options, tip)
    return OptionManager.StringCycler(label, ref, options, tip)
end

function Buttons.Color(label, ref, tip)
    return OptionManager.Color(label, ref, tip)
end

return Buttons
