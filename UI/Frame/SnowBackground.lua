local UI = require("UI/Core/Style")
local DrawHelpers = require("UI/Core/DrawHelpers")

local SnowBackground = {
    flakes = {},
    lastMenuPos = {x = 0, y = 0},
    gravity = 30,
    windSway = 0.6,
    color = UI.ColPalette.SoftWhite,
    spawnRate = 0.025,
    spawnTimer = 0,
    pileLayers = 2,
    pileColumns = 80,
    pileHeight = {},
    snowman = {built = false, x = 0, y = 0, fall = 0, landed = false},
}

function SnowBackground.Init()
    SnowBackground.flakes = {}
    SnowBackground.pileHeight = {}
    SnowBackground.lastMenuPos = {x = 0, y = 0}
    SnowBackground.snowman = {built = false, x = 0, y = 0, fall = 0, landed = false}
    for i = 1, SnowBackground.pileColumns do
        SnowBackground.pileHeight[i] = math.random() * 3
    end
end

local function spawnFlake(menuX, menuY, menuW)
    return {
        x = menuX + math.random() * menuW,
        y = menuY + 5,
        vy = math.random() * 10,
        r = math.random() * 2 + 1.2,
    }
end

function SnowBackground.Update(dt, menuX, menuY, menuW, menuH, footerH)
    local flakes = SnowBackground.flakes
    local lp = SnowBackground.lastMenuPos
    local menuDX, menuDY = menuX - lp.x, menuY - lp.y
    SnowBackground.lastMenuPos.x, SnowBackground.lastMenuPos.y = menuX, menuY

    if #SnowBackground.pileHeight == 0 then
        for i = 1, SnowBackground.pileColumns do
            SnowBackground.pileHeight[i] = 0
        end
    end

    SnowBackground.spawnTimer = SnowBackground.spawnTimer + dt
    if SnowBackground.spawnTimer >= SnowBackground.spawnRate then
        SnowBackground.spawnTimer = 0
        table.insert(flakes, spawnFlake(menuX, menuY, menuW))
    end

    local left = menuX + 5
    local right = menuX + menuW - 5
    local bottom = menuY + menuH - (footerH or 30) - 3
    local cw = (right - left) / SnowBackground.pileColumns
    local maxHeight = SnowBackground.pileLayers * 6.0

    for _, f in ipairs(flakes) do
        f.x = f.x - menuDX
        f.y = f.y - menuDY
        f.vy = f.vy + SnowBackground.gravity * dt * 0.25
        f.x = f.x + math.sin((os.clock() + f.x) * SnowBackground.windSway) * 8 * dt
        f.y = f.y + f.vy * dt

        if f.x < left + f.r then f.x = left + f.r end
        if f.x > right - f.r then f.x = right - f.r end

        local col = math.floor(((f.x - left) / (right - left)) * SnowBackground.pileColumns)
        col = math.max(1, math.min(SnowBackground.pileColumns, col))
        local pileY = bottom - SnowBackground.pileHeight[col]

        if f.y >= pileY - f.r then
            if SnowBackground.pileHeight[col] < maxHeight then
                for n = -2, 2 do
                    local ni = col + n
                    if ni >= 1 and ni <= SnowBackground.pileColumns then
                        local falloff = 1.0 - math.abs(n) * 0.25
                        SnowBackground.pileHeight[ni] = math.min(maxHeight, SnowBackground.pileHeight[ni] + f.r * falloff)
                    end
                end
            end
            f.remove = true
        end
    end

    for i = #flakes, 1, -1 do
        if flakes[i].remove then table.remove(flakes, i) end
    end

    -- smooth with slight random bias to create natural uneven snow
    for i = 2, SnowBackground.pileColumns - 1 do
        local avg = (SnowBackground.pileHeight[i - 1] + SnowBackground.pileHeight[i] + SnowBackground.pileHeight[i + 1]) / 3
        local bias = (math.random() - 0.5) * 0.15
        SnowBackground.pileHeight[i] = SnowBackground.pileHeight[i] + (avg - SnowBackground.pileHeight[i]) * 0.05 + bias
        if SnowBackground.pileHeight[i] < 0 then SnowBackground.pileHeight[i] = 0 end
    end

    local avgHeight = 0
    for _, h in ipairs(SnowBackground.pileHeight) do avgHeight = avgHeight + h end
    avgHeight = avgHeight / #SnowBackground.pileHeight

    if not SnowBackground.snowman.built and avgHeight >= maxHeight * 0.8 then
        SnowBackground.snowman.built = true
        SnowBackground.snowman.x = menuX + menuW * (math.random() < 0.5 and 0.25 or 0.75)
        SnowBackground.snowman.y = menuY + menuH - (footerH or 30) - maxHeight - 25
        SnowBackground.snowman.fall = -50
    end

    if SnowBackground.snowman.built and not SnowBackground.snowman.landed then
        SnowBackground.snowman.fall = SnowBackground.snowman.fall + dt * 120
        SnowBackground.snowman.y = SnowBackground.snowman.y + SnowBackground.snowman.fall * dt
        if SnowBackground.snowman.y >= bottom - maxHeight - 12 then
            SnowBackground.snowman.y = bottom - maxHeight - 12
            SnowBackground.snowman.landed = true
        end
    end
end

function SnowBackground.Render(menuX, menuY, menuW, menuH)
    local drawlist = ImGui.GetWindowDrawList()
    local now = os.clock()
    local left = menuX + 5
    local right = menuX + menuW - 5
    local bottom = menuY + menuH - 30
    local cw = (right - left) / SnowBackground.pileColumns

    local baseColor = (255 * 0x1000000) + (SnowBackground.color % 0x1000000)    
    local groundPoly = {}
    table.insert(groundPoly, {x = left, y = bottom})
    for i = 1, SnowBackground.pileColumns do
        local h = SnowBackground.pileHeight[i]
        local x = left + (i - 0.5) * cw
        local bump = math.sin(i * 0.35 + now * 0.5) * 0.6
        local y = bottom - h - bump
        table.insert(groundPoly, {x = x, y = y})
    end
    table.insert(groundPoly, {x = right, y = bottom})

    for i = 1, #groundPoly - 1 do
        local a, b = groundPoly[i], groundPoly[i + 1]
        ImGui.ImDrawListAddRectFilled(drawlist, a.x, a.y, b.x, bottom, baseColor)
    end

    for i = 1, SnowBackground.pileColumns - 1 do
        local h1, h2 = SnowBackground.pileHeight[i], SnowBackground.pileHeight[i + 1]
        local x1 = left + (i - 0.5) * cw
        local x2 = left + (i + 0.5) * cw
        local y1, y2 = bottom - h1, bottom - h2
        local color = (220 * 0x1000000) + (SnowBackground.color % 0x1000000)
        ImGui.ImDrawListAddLine(drawlist, x1, y1, x2, y2, color, 3)
    end

    for _, f in ipairs(SnowBackground.flakes) do
        local pulse = 0.8 + 0.2 * math.sin(now * 3 + f.x)
        local a = math.floor(200 * pulse)
        local color = a * 0x1000000 + (SnowBackground.color % 0x1000000)
        ImGui.ImDrawListAddCircleFilled(drawlist, f.x, f.y, f.r, color)
    end

    if SnowBackground.snowman.built then
        local s = SnowBackground.snowman
        local colBody = 0xFFF0F0F0
        local colHat = 0xFF000000
        local colNose = UI.ColPalette.SoftRed
        ImGui.ImDrawListAddCircleFilled(drawlist, s.x, s.y, 8, colBody)
        ImGui.ImDrawListAddCircleFilled(drawlist, s.x, s.y - 10, 6, colBody)
        ImGui.ImDrawListAddCircleFilled(drawlist, s.x, s.y - 18, 4, colBody)
        ImGui.ImDrawListAddRectFilled(drawlist, s.x - 5, s.y - 27, s.x + 5, s.y - 23, colHat)
        ImGui.ImDrawListAddRectFilled(drawlist, s.x - 7, s.y - 23, s.x + 7, s.y - 22, colHat)
        ImGui.ImDrawListAddTriangleFilled(drawlist, s.x, s.y - 18, s.x + 5, s.y - 17, s.x, s.y - 16, colNose)
    end
end

return SnowBackground
