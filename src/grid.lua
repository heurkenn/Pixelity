-- src/grid.lua

local grid = {}
local cells = {}
local size = 0
local OBSTACLE_ID = 99

function grid.init(gridSize)
    size = gridSize
    cells = {}

    for y = 1, size do
        cells[y] = {}
        for x = 1, size do
            cells[y][x] = 0
        end
    end
end

function grid.generateObstacles(count)
    local placed = 0

    while placed < count do
        local rx = love.math.random(1, size)
        local ry = love.math.random(1, size)
        if cells[ry][rx] == 0 then
            cells[ry][rx] = OBSTACLE_ID
            placed = placed + 1
        end
    end
end

function grid.isInside(x, y)
    return x >= 1 and x <= size and y >= 1 and y <= size
end

function grid.isFree(x, y)
    if grid.isInside(x, y) then
        return cells[y][x] == 0
    end
    return false
end

function grid.isObstacle(x, y)
    if grid.isInside(x, y) then
        return cells[y][x] == OBSTACLE_ID
    end
    return false
end

function grid.getNeighbors(x, y)
    local neighbors = {}
    local directions = {
        { x = 0, y = -1 },
        { x = 0, y = 1 },
        { x = -1, y = 0 },
        { x = 1, y = 0 }
    }

    for _, dir in ipairs(directions) do
        local nx, ny = x + dir.x, y + dir.y
        if grid.isInside(nx, ny) then
            table.insert(neighbors, cells[ny][nx])
        end
    end

    return neighbors
end

function grid.setCell(x, y, value)
    if grid.isInside(x, y) then
        cells[y][x] = value
    end
end

function grid.getCell(x, y)
    if grid.isInside(x, y) then
        return cells[y][x]
    end
    return nil
end

function grid.getSize()
    return size
end

function grid.getObstacleId()
    return OBSTACLE_ID
end

function grid.getCells()
    return cells
end

return grid
