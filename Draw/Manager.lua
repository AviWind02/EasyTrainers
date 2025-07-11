local DrawHelpers = require("Draw/DrawHelpers")

local M = {}

-- Option renderer
local currentOption = 1
local optionIndex = 0
local smoothY = 0

-- Layout constants
local optionHeight = 36
local optionPaddingX = 12
local optionPaddingY = 10
local spacingY = 10
local frameRounding = 5
local textOffsetX = 10
local smoothSpeed = 0.17

-- Layout state (set in DrawMenu)
local menuX, menuY, menuW, menuH = 0, 0, 0, 0

-- Scroll state
local maxVisible = 0
local startOpt = 1
local endOpt = 1

-- Key input functions
local function Down()
    return ImGui.IsKeyPressed(ImGuiKey.DownArrow) -- Arrow Down
end

local function Up()
    return ImGui.IsKeyPressed(ImGuiKey.UpArrow) -- Arrow Up
    
end

local function SelectPressed()
    return ImGui.IsKeyPressed(ImGuiKey.Enter) -- Enter key
end

-- Main option renderer
function M.Option(left, right, tip)
    optionIndex = optionIndex + 1
    local isActive = (currentOption == optionIndex)

    -- Calculate max visible on first option
    if optionIndex == 1 then
        local availableHeight = menuH - optionPaddingY * 2
        maxVisible = math.max(1, math.floor(availableHeight / (optionHeight + spacingY)))
        startOpt = math.floor((currentOption - 1) / maxVisible) * maxVisible + 1
        endOpt = startOpt + maxVisible - 1
    end

    -- Skip drawing if not visible
    if optionIndex < startOpt or optionIndex > endOpt then
        return false
    end

    -- Position
    local relIndex = optionIndex - startOpt
    local optX = menuX + optionPaddingX
    local optY = menuY + optionPaddingY + relIndex * (optionHeight + spacingY)
    local optionW = menuW - optionPaddingX * 2
    local fontY = optY + (optionHeight - 18) * 0.5

    -- Highlight animation
    if isActive then
        smoothY = smoothY + (optY - smoothY) * smoothSpeed
    end

    -- Background
    if isActive then
        DrawHelpers.RectFilled(optX, smoothY, optionW, optionHeight, 0xFF3A6EA5, frameRounding)
    else
        DrawHelpers.RectFilled(optX, optY, optionW, optionHeight, 0xFF202020, frameRounding)
    end

    -- Text
    local textColor = 0xFFFFFFFF
    if left and left ~= "" then
        DrawHelpers.Text(optX + textOffsetX, fontY, textColor, left)
    end
    if right and right ~= "" then
        local textWidth = ImGui.CalcTextSize(right)
        local rightX = optX + optionW - textOffsetX - textWidth
        DrawHelpers.Text(rightX, fontY, textColor, right)
    end

    -- Selection
    if isActive and SelectPressed() then
        print("Selected: " .. left)
        return true
    end

    return false
end


-- Menu renderer
function M.DrawMenu(x, y, w, h)
    menuX, menuY, menuW, menuH = x, y, w, h
    optionIndex = 0

    -- Input
    if Down() and currentOption < (M.maxOptions or 1) then currentOption = currentOption + 1 end
    if Up() and currentOption > 1 then currentOption = currentOption - 1 end

    -- Background
    DrawHelpers.RectFilled(x, y, w, h, 0xFF1A1A1A, 6.0)

    -- Menu options
    if M.Option("Start Game", "F5", "Start a new adventure") then end
    if M.Option("Continue", "F6", "Resume your journey") then end
    if M.Option("Settings", "", "Change your preferences") then end
    if M.Option("Credits", "", "See who made this") then end
    if M.Option("Exit", "Esc", "Close the menu") then end

    -- Save total option count for control use
    M.maxOptions = optionIndex
end


return M
