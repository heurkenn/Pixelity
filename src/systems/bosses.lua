-- src/systems/bosses.lua
-- Boss selection, round start setup and boss effects that trigger on BUILD.

local boss_catalog = require("src.data.boss")

local bosses = {}

local function shuffleIds()
    local ids = {}
    for _, bossData in ipairs(boss_catalog.types) do
        table.insert(ids, bossData.id)
    end

    for index = #ids, 2, -1 do
        local swapIndex = love.math.random(1, index)
        ids[index], ids[swapIndex] = ids[swapIndex], ids[index]
    end

    return ids
end

local function collectDestroyableCells(grid)
    local cells = {}
    for y = 1, grid.getSize() do
        for x = 1, grid.getSize() do
            local value = grid.getCell(x, y)
            if value ~= 0 and value ~= grid.getObstacleId() then
                table.insert(cells, { x = x, y = y })
            end
        end
    end
    return cells
end

function bosses.buildOrder()
    return shuffleIds()
end

function bosses.getBossForRound(game, roundNumber)
    if not game.boss_order then
        return nil
    end

    local bossIndex = math.floor(roundNumber / 3)
    local bossId = game.boss_order[bossIndex]
    return boss_catalog.getData(bossId)
end

function bosses.prepareBossIntro(game, bossData)
    game.current_boss = bossData
    game.state = "boss_intro"
    game.boss_intro = {
        timer = 0,
        continue_ready = false,
        explosions = {},
        spawned = false
    }
end

local function spawnIntroExplosion(game, x, y, scale)
    local introState = game.boss_intro
    table.insert(introState.explosions, {
        x = x,
        y = y,
        scale = scale or 1.4,
        timer = 0
    })
end

function bosses.updateBossIntro(game, dt)
    if game.state ~= "boss_intro" or not game.boss_intro then
        return
    end

    local introState = game.boss_intro
    introState.timer = introState.timer + dt

    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2 - 70

    if not introState.spawned and introState.timer >= 0.08 then
        introState.spawned = true
        spawnIntroExplosion(game, centerX, centerY, 2.2)
    end

    local frames = game.intro and game.intro.explosion_frames or {}
    local maxLifetime = #frames > 0 and (#frames * 0.1) or 0.6

    for index = #introState.explosions, 1, -1 do
        local effect = introState.explosions[index]
        effect.timer = effect.timer + dt
        if effect.timer >= maxLifetime then
            table.remove(introState.explosions, index)
        end
    end

    if introState.timer >= 0.9 then
        introState.continue_ready = true
    end
end

function bosses.applyRoundStartEffects(bossData, grid)
    if not bossData then
        return
    end

    for _, effect in ipairs(bossData.effects or {}) do
        if effect.type == "spawn_obstacles_on_round_start" then
            grid.generateObstacles(effect.count or 0)
        end
    end
end

function bosses.applyBuildEffects(game, player, grid)
    local bossData = game.current_boss
    if not bossData then
        return nil
    end

    local destroyedCount = 0
    local label = nil

    for _, effect in ipairs(bossData.effects or {}) do
        if effect.type == "destroy_random_cells_on_build" then
            local cells = collectDestroyableCells(grid)
            for _ = 1, math.min(effect.count or 0, #cells) do
                local pickIndex = love.math.random(1, #cells)
                local picked = table.remove(cells, pickIndex)
                grid.setCell(picked.x, picked.y, 0)
                grid.setCellLevel(picked.x, picked.y, 0)
                destroyedCount = destroyedCount + 1
            end
            label = bossData.name .. ": -" .. destroyedCount .. " cases"
        elseif effect.type == "destroy_row_and_column_on_build" then
            local row = love.math.random(1, grid.getSize())
            local column = love.math.random(1, grid.getSize())
            for x = 1, grid.getSize() do
                if grid.getCell(x, row) ~= 0 and grid.getCell(x, row) ~= grid.getObstacleId() then
                    destroyedCount = destroyedCount + 1
                end
                grid.setCell(x, row, 0)
                grid.setCellLevel(x, row, 0)
            end
            for y = 1, grid.getSize() do
                if y ~= row then
                    if grid.getCell(column, y) ~= 0 and grid.getCell(column, y) ~= grid.getObstacleId() then
                        destroyedCount = destroyedCount + 1
                    end
                    grid.setCell(column, y, 0)
                    grid.setCellLevel(column, y, 0)
                end
            end
            label = bossData.name .. ": ligne " .. row .. ", colonne " .. column
        end
    end

    if label then
        game.message = label
    end

    return {
        destroyed_cells = destroyedCount,
        label = label
    }
end

return bosses
