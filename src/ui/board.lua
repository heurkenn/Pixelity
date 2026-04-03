-- src/ui/board.lua
-- Board-specific drawing helpers used by the active gameplay scene.

local constants = require("src.constants")
local fonts = require("src.ui.fonts")

local board = {}

-- Dessine l'empreinte losange d'une case isometrique.
local function drawIsoDiamond(rectX, rectY, width, height, fillColor, lineColor, alpha)
    local halfWidth = width / 2
    local halfHeight = height / 2
    local points = {
        rectX + halfWidth, rectY,
        rectX + width, rectY + halfHeight,
        rectX + halfWidth, rectY + height,
        rectX, rectY + halfHeight
    }

    if fillColor then
        love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3], alpha or 1)
        love.graphics.polygon("fill", points)
    end

    if lineColor then
        love.graphics.setColor(lineColor[1], lineColor[2], lineColor[3], alpha or 1)
        love.graphics.polygon("line", points)
    end
end

-- Dessine une case de grille pour un batiment, un obstacle ou une tuile cachee.
function board.drawBuildingTile(buildings, grid, buildingId, posX, posY, alpha, cellX, cellY, hidden)
    alpha = alpha or 1
    local tileWidth = constants.ISO_TILE_WIDTH
    local tileHeight = constants.ISO_TILE_HEIGHT
    local centerX = posX + (tileWidth / 2)
    local centerY = posY + (tileHeight / 2)

    if buildingId == grid.getObstacleId() then
        drawIsoDiamond(posX, posY, tileWidth, tileHeight, { 0.45, 0.35, 0.28 }, { 0.2, 0.15, 0.12 }, alpha)
        love.graphics.setColor(0.2, 0.15, 0.12, alpha)
        love.graphics.print("X", centerX - 4, centerY - 9)
        return
    end

    local data = buildings.getData(buildingId)
    if not data then
        return
    end

    if hidden then
        love.graphics.setColor(0.2, 0.22, 0.28, alpha)
        love.graphics.ellipse("fill", centerX, centerY + 6, tileWidth * 0.2, tileHeight * 0.16)
        fonts.drawOutlinedText("?", posX, posY - 8, {
            font = fonts.getScoreFont(),
            mode = "printf",
            limit = tileWidth,
            align = "center",
            outline = 1
        })
    elseif data.image and data.quads then
        love.graphics.setColor(1, 1, 1, alpha)
        local frameWidth = data.frame_width or constants.ISO_BUILDING_FRAME_WIDTH
        local frameHeight = data.frame_height or constants.ISO_BUILDING_FRAME_HEIGHT
        local drawX = centerX - (frameWidth / 2)
        local drawY = centerY - frameHeight + (tileHeight / 2)
        love.graphics.draw(data.image, data.quads[1], drawX, drawY)
    else
        love.graphics.setColor(data.color[1], data.color[2], data.color[3], alpha)
        love.graphics.polygon("fill",
            centerX, posY + 6,
            posX + tileWidth - 10, centerY,
            centerX, posY + tileHeight - 8,
            posX + 10, centerY
        )
        love.graphics.setColor(0.1, 0.1, 0.1, alpha)
        love.graphics.print(data.name, posX + 8, centerY - 7)
    end

    local level = (grid.getCellLevel and cellX and cellY) and grid.getCellLevel(cellX, cellY) or 1
    if data.key == "tower" and level and level > 1 then
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("x" .. level, posX + tileWidth - 26, posY + 8)
    end
end

-- Dessine le fond d'une case vide isometrique.
function board.drawGroundTile(posX, posY, highlighted, overlayAlpha)
    drawIsoDiamond(posX, posY, constants.ISO_TILE_WIDTH, constants.ISO_TILE_HEIGHT, { 0.22, 0.25, 0.29 }, { 0.42, 0.45, 0.5 }, 1)

    if highlighted then
        drawIsoDiamond(posX, posY, constants.ISO_TILE_WIDTH, constants.ISO_TILE_HEIGHT, { 0.95, 0.78, 0.28 }, nil, overlayAlpha or 0.35)
    end
end

return board
