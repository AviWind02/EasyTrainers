local Decorators = {}
local UI = require("UI/Core/Style")
local DrawHelpers = require("UI/Core/DrawHelpers")
local Submenus = require("UI/Core/SubmenuManager")


-- Draws the top title bar
function Decorators.DrawTitleBar(menuX, menuY, menuW)
    local header = UI.Header

    local x = menuX
    local y = menuY
    local w = menuW
    local h = header.Height

    -- Background
    DrawHelpers.RectFilled(x, y, w, h, header.Bg)

    -- Main title (top-left, shifted up)
    local staticText = header.Text
    local titleX = x + 10
    local titleY = y + 8 
    DrawHelpers.Text(titleX, titleY, header.TextColor, staticText, header.FontSize)

    -- Breadcrumb (bottom-right, shifted down)
    local breadcrumb = L(Submenus.GetBreadcrumbTitle()) or ""
    local breadcrumbWidth = ImGui.CalcTextSize(breadcrumb)
    local breadcrumbX = x + w - breadcrumbWidth - 10
    local breadcrumbY = y + h - header.FontSizeSub - 5 -- move slightly down
    DrawHelpers.Text(breadcrumbX, breadcrumbY, header.TextColor, breadcrumb, header.FontSizeSub)

    -- Bottom divider line
    DrawHelpers.Line(x, y + h - 1, x + w, y + h - 1, UI.Colors.Border, 1.0)
end



-- Draws the bottom footer with left/right aligned info
function Decorators.DrawFooter(menuX, menuY, menuW, menuH, maxVisible)
    local footer = UI.Footer

    local x = menuX
    local y = menuY + menuH - footer.Height
    local w = menuW
    local h = footer.Height

    local current = Submenus.currentOption or 1
    local total = Submenus.optionIndex or 1
    local visible = maxVisible or 1

    local currentPage = math.floor((current - 1) / visible) + 1
    local totalPages = math.floor((total + visible - 1) / visible)

    local leftText = footer.Text
    local rightText = string.format("Opt: %d | Pg: %d/%d", current, currentPage, totalPages)

    -- Divider line
    DrawHelpers.Line(x, y, x + w, y, UI.Colors.Border, 1.0)

    -- Text positions
    local leftX = x + 10
    local rightX = x + w - ImGui.CalcTextSize(rightText) + 5
    local textY = y + (h - footer.FontSize) * 0.5

    -- Text rendering
    DrawHelpers.Text(leftX, textY, footer.TextColor, leftText, footer.FontSize)
    DrawHelpers.Text(rightX, textY, footer.TextColor, rightText, footer.FontSize)
end

return Decorators
