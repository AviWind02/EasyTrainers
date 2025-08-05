
local SubmenuManager = {}

SubmenuManager.menuStack = {}
SubmenuManager.optionStack = {}
SubmenuManager.currentMenuIndex = -1
SubmenuManager.currentOption = 1
SubmenuManager.optionIndex = 0

function SubmenuManager.OpenSubmenu(submenu)
    table.insert(SubmenuManager.menuStack, submenu)
    table.insert(SubmenuManager.optionStack, SubmenuManager.currentOption)

    if #SubmenuManager.optionStack > 10 then
        table.remove(SubmenuManager.optionStack, 1)
    end

    SubmenuManager.currentMenuIndex = SubmenuManager.currentMenuIndex + 1
    SubmenuManager.currentOption = 1
end

function SubmenuManager.CloseSubmenu()
    if #SubmenuManager.menuStack > 1 then
        table.remove(SubmenuManager.menuStack)
        SubmenuManager.currentMenuIndex = SubmenuManager.currentMenuIndex - 1
        SubmenuManager.currentOption = table.remove(SubmenuManager.optionStack) or 1
    end
end

function SubmenuManager.GetBreadcrumbTitle()
    local stack = SubmenuManager.menuStack
    if #stack == 0 then return "" end
    return stack[#stack].title or ""
end

function SubmenuManager.IsAtRootMenu()
    return #SubmenuManager.menuStack <= 1
end
--[[
function SubmenuManager.GetBreadcrumbTitle()
    local sep = " > "
    local full = ""

    for _, menu in ipairs(SubmenuManager.menuStack) do
        full = full .. menu.title .. sep
    end

    if full:sub(-#sep) == sep then
        full = full:sub(1, -#sep - 1)
    end

    local maxPixels = OptionManager.menuW or 300
    local textW = ImGui.CalcTextSize(full)
    local padding = 10
    local maxChars = math.floor((maxPixels - padding) / 8.0)

    if #full > maxChars then
        local start = #full - maxChars + 3
        full = "..." .. full:sub(start + 1)
    end

    return full
end
]]

function SubmenuManager.GetCurrentView()
    local top = SubmenuManager.menuStack[#SubmenuManager.menuStack]
    return top and top.view
end

return SubmenuManager
