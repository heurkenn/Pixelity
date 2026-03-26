-- src/systems/bosses.lua
-- Boss selection, round start setup and boss effects that trigger on BUILD.

local boss_catalog = require("src.data.boss")

local bosses = {}

-- Melange les identifiants de boss pour construire un ordre de run aleatoire.
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

-- Liste les cases de grille contenant encore un batiment destructible.
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

-- Trie une liste de cases par lecture visuelle pour une destruction propre.
local function sortCells(cells)
    table.sort(cells, function(a, b)
        if a.y == b.y then
            return a.x < b.x
        end
        return a.y < b.y
    end)
end

-- Construit l'ordre aleatoire des boss d'une nouvelle run.
function bosses.buildOrder()
    return shuffleIds()
end

-- Retourne le boss attribue a une manche boss donnee.
function bosses.getBossForRound(game, roundNumber)
    if not game.boss_order then
        return nil
    end

    local bossIndex = math.floor(roundNumber / 3)
    local bossId = game.boss_order[bossIndex]
    return boss_catalog.getData(bossId)
end

-- Ouvre l'intro de presentation d'un boss avant sa manche.
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

-- Ajoute une explosion ponctuelle a l'intro de boss.
local function spawnIntroExplosion(game, x, y, scale)
    local introState = game.boss_intro
    table.insert(introState.explosions, {
        x = x,
        y = y,
        scale = scale or 1.4,
        timer = 0
    })
end

-- Met a jour l'intro visuelle d'un boss jusqu'au bouton continuer.
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

-- Applique les effets de boss qui s'executent au debut d'une manche.
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

-- Construit la sequence de destruction visuelle d'un boss sur BUILD.
function bosses.applyBuildEffects(game, player, grid)
    local bossData = game.current_boss
    if not bossData then
        return nil
    end

    local result = {
        steps = {},
        markers = {},
        label = bossData.name
    }

    for _, effect in ipairs(bossData.effects or {}) do
        if effect.type == "destroy_random_cells_on_build" then
            local cells = collectDestroyableCells(grid)
            for _ = 1, math.min(effect.count or 0, #cells) do
                local pickIndex = love.math.random(1, #cells)
                local picked = table.remove(cells, pickIndex)
                table.insert(result.markers, {
                    type = "cell",
                    x = picked.x,
                    y = picked.y,
                    label = bossData.name
                })
                table.insert(result.steps, {
                    x = picked.x,
                    y = picked.y,
                    label = bossData.name
                })
            end
        elseif effect.type == "destroy_row_and_column_on_build" then
            local row = love.math.random(1, grid.getSize())
            local column = love.math.random(1, grid.getSize())
            table.insert(result.markers, {
                type = "row",
                index = row,
                label = bossData.name
            })
            table.insert(result.markers, {
                type = "column",
                index = column,
                label = bossData.name
            })
            local seen = {}
            local cells = {}
            for x = 1, grid.getSize() do
                if grid.getCell(x, row) ~= 0 and grid.getCell(x, row) ~= grid.getObstacleId() then
                    local key = x .. ":" .. row
                    if not seen[key] then
                        seen[key] = true
                        table.insert(cells, { x = x, y = row })
                    end
                end
            end
            for y = 1, grid.getSize() do
                if grid.getCell(column, y) ~= 0 and grid.getCell(column, y) ~= grid.getObstacleId() then
                    local key = column .. ":" .. y
                    if not seen[key] then
                        seen[key] = true
                        table.insert(cells, { x = column, y = y })
                    end
                end
            end
            sortCells(cells)
            for _, cell in ipairs(cells) do
                table.insert(result.steps, {
                    x = cell.x,
                    y = cell.y,
                    label = bossData.name
                })
            end
        end
    end

    if #result.steps == 0 then
        return nil
    end

    return result
end

return bosses
