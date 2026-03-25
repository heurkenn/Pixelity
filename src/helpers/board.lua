-- src/helpers/board.lua
-- Board-specific drawing helpers used by the active gameplay scene.

local constants = require("src.constants")
local fonts = require("src.helpers.fonts")

local board = {}

function board.drawBuildingTile(buildings, grid, buildingId, posX, posY, alpha, cellX, cellY, hidden)
    alpha = alpha or 1

    if buildingId == grid.getObstacleId() then
        love.graphics.setColor(0.45, 0.35, 0.28, alpha)
        love.graphics.rectangle("fill", posX + 6, posY + 6, constants.TILE_SIZE - 12, constants.TILE_SIZE - 12, 8, 8)
        love.graphics.setColor(0.2, 0.15, 0.12, alpha)
        love.graphics.print("X", posX + constants.TILE_SIZE / 2 - 4, posY + constants.TILE_SIZE / 2 - 7)
        return
    end

    local data = buildings.getData(buildingId)
    if not data then
        return
    end

    if hidden then
        love.graphics.setColor(0.2, 0.22, 0.28, alpha)
        love.graphics.rectangle("fill", posX + 4, posY + 4, constants.TILE_SIZE - 8, constants.TILE_SIZE - 8, 10, 10)
        fonts.drawOutlinedText("?", posX, posY + 8, {
            font = fonts.getScoreFont(),
            mode = "printf",
            limit = constants.TILE_SIZE,
            align = "center",
            outline = 1
        })
    elseif data.image and data.quads then
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(data.image, data.quads[1], posX, posY, 0, 2, 2)
    else
        love.graphics.setColor(data.color[1], data.color[2], data.color[3], alpha)
        love.graphics.rectangle("fill", posX + 4, posY + 4, constants.TILE_SIZE - 8, constants.TILE_SIZE - 8, 10, 10)
        love.graphics.setColor(0.1, 0.1, 0.1, alpha)
        love.graphics.print(data.name, posX + 8, posY + constants.TILE_SIZE / 2 - 7)
    end

    local level = (grid.getCellLevel and cellX and cellY) and grid.getCellLevel(cellX, cellY) or 1
    if buildingId == 5 and level and level > 1 then
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("x" .. level, posX + constants.TILE_SIZE - 22, posY + 4)
    end
end

return board
