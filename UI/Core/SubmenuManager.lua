
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
    local sep = " > "
    local title = ""

    for _, menu in ipairs(SubmenuManager.menuStack) do
        title = title .. menu.title .. sep
    end

    if title:sub(-#sep) == sep then
        title = title:sub(1, -#sep - 1)
    end

    return title
end

function SubmenuManager.GetCurrentView()
    local top = SubmenuManager.menuStack[#SubmenuManager.menuStack]
    return top and top.view
end

return SubmenuManager
