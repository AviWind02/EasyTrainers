-- Buttons.lua
local Buttons = {}

local OptionManager = require("UI/Elements/OptionManager")
local Submenus = require("UI/Core/SubmenuManager")

-- Basic Option: left text + tip
function Buttons.Option(label, tip, action)
    if OptionManager.Option(label, "", "", tip) then
        if action then action() end
        return true
    end
    return false
end

-- Option with center/right text and tip
function Buttons.OptionExtended(left, center, right, tip, action)
    if OptionManager.Option(left, center, right, tip) then
        if action then action() end
        return true
    end
    return false
end

-- Break entry (not clickable, used for categories or separation)
function Buttons.Break(left, center, right)
    return OptionManager.Break(left, center, right)
end

-- Submenu entry — should be handled here, not in OptionManager
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

-- Toggle button (bool reference)
function Buttons.Toggle(label, ref, tip, action)
    if OptionManager.Toggle(label, ref, tip) then
        if action then action() end
        return true
    end
    return false
end
-- Integer setting with optional toggle inside the ref
function Buttons.Int(label, ref, tip, action)
    if OptionManager.IntToggle(label, ref, tip) and action then
        action()
        return true
    end
    return false
end

-- Float setting with optional toggle inside the ref
function Buttons.Float(label, ref, tip, action)
    if OptionManager.FloatToggle(label, ref, tip) and action then
        action()
        return true
    end
    return false
end

-- Dropdown wrapper (label, ref table with expanded/index/etc., options list)
function Buttons.Dropdown(label, ref, options, tip)
    OptionManager.Dropdown(label, ref, options, tip)
end

return Buttons
