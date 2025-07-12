local UI = require("Draw/Style")
local DrawHelpers = require("Draw/DrawHelpers")
local Controls = require("Draw/Controls")
local Submenus = require("Draw/SubmenuManager")

local Decorators = {}

-- Draws the top title bar
function Decorators.DrawTitleBar(menuX, menuY, menuW)
    local header = UI.Header

    local x = menuX
    local y = menuY
    local w = menuW
    local h = header.Height

    -- Background
    DrawHelpers.RectFilled(x, y, w, h, header.Bg)

    header.Text = Submenus.GetBreadcrumbTitle() or header.Text or "EasyTrainer"
    -- Text
    local textX = x + 10
    local textY = y + (h - header.FontSize) * 0.5
    DrawHelpers.Text(textX, textY, header.TextColor, header.Text or "", header.FontSize)
end

-- Draws the bottom footer with left/right aligned info
function Decorators.DrawFooter(menuX, menuY, menuW, menuH, maxVisible)
    local footer = UI.Footer

    local x = menuX
    local y = menuY + menuH - footer.Height
    local w = menuW
    local h = footer.Height

    local current = Controls.currentOption or 1
    local total = Controls.optionIndex or 1
    local visible = maxVisible or 1

    local currentPage = math.floor((current - 1) / visible) + 1
    local totalPages = math.floor((total + visible - 1) / visible)

    local leftText = footer.Text or "v1.0.0"
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
