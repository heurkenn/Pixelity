-- src/score.lua

local score = {}
local grid = require("src.grid")
local buildings = require("src.data.buildings")

local HOUSE_ID = 1
local ADJACENCY_KEYS = {
    house = "houses",
    park = "parks",
    factory = "factories",
    bank = "banks",
    tower = "towers"
}
local BUILDING_NAMES = {
    [1] = "house",
    [2] = "park",
    [3] = "factory",
    [4] = "bank",
    [5] = "tower"
}

-- Compte les voisins par type autour d'une case de grille.
local function getAdjacencyCounts(x, y)
    local counts = {
        houses = 0,
        parks = 0,
        factories = 0,
        banks = 0,
        towers = 0
    }

    for _, neighborId in ipairs(grid.getNeighbors(x, y)) do
        if neighborId == 1 then
            counts.houses = counts.houses + 1
        elseif neighborId == 2 then
            counts.parks = counts.parks + 1
        elseif neighborId == 3 then
            counts.factories = counts.factories + 1
        elseif neighborId == 4 then
            counts.banks = counts.banks + 1
        elseif neighborId == 5 then
            counts.towers = counts.towers + 1
        end
    end

    return counts
end

-- Calcule combien de segments d'une taille donnee existent dans une suite.
local function countSegmentsInRun(runLength, segmentSize)
    if runLength < segmentSize then
        return 0
    end
    return runLength - segmentSize + 1
end

-- Parcourt une ligne ou colonne et retourne les suites contigues de maisons.
local function collectLineRuns(getCellValue)
    local runs = {}
    local runLength = 0
    local size = grid.getSize()

    for index = 1, size do
        if getCellValue(index) == HOUSE_ID then
            runLength = runLength + 1
        else
            if runLength > 0 then
                table.insert(runs, runLength)
            end
            runLength = 0
        end
    end

    if runLength > 0 then
        table.insert(runs, runLength)
    end

    return runs
end

-- Compte les paires adjacentes d'Immeuble sans compter deux fois la meme liaison.
local function countAdjacentTowerPairs()
    local total = 0
    local size = grid.getSize()

    for y = 1, size do
        for x = 1, size do
            if grid.getCell(x, y) == 5 then
                if x < size and grid.getCell(x + 1, y) == 5 then
                    total = total + 1
                end
                if y < size and grid.getCell(x, y + 1) == 5 then
                    total = total + 1
                end
            end
        end
    end

    return total
end

-- Ajoute les bonus de lois en fin de calcul de grille.
local function applyLawBonuses(resolution, laws)
    local total = 0
    local size = grid.getSize()

    for _, law in ipairs(laws or {}) do
        for _, effect in ipairs(law.effects or {}) do
            if effect.type == "aligned_houses" then
                local segmentCount = 0

                for y = 1, size do
                    local runs = collectLineRuns(function(x)
                        return grid.getCell(x, y)
                    end)
                    for _, runLength in ipairs(runs) do
                        segmentCount = segmentCount + countSegmentsInRun(runLength, effect.segment_size)
                    end
                end

                for x = 1, size do
                    local runs = collectLineRuns(function(y)
                        return grid.getCell(x, y)
                    end)
                    for _, runLength in ipairs(runs) do
                        segmentCount = segmentCount + countSegmentsInRun(runLength, effect.segment_size)
                    end
                end

                for _ = 1, segmentCount do
                    table.insert(resolution, {
                        step_type = "law",
                        law_name = law.name,
                        points = effect.bonus
                    })
                end

                total = total + (segmentCount * effect.bonus)
            elseif effect.type == "adjacent_towers_bonus" then
                local pairCount = countAdjacentTowerPairs()

                for _ = 1, pairCount do
                    table.insert(resolution, {
                        step_type = "law",
                        law_name = law.name,
                        points = effect.bonus
                    })
                end

                total = total + (pairCount * effect.bonus)
            end
        end
    end

    return total
end

-- Applique les bonus globaux de maire qui se lisent sur tout le plateau.
local function applyMayorBoardBonuses(player, resolution)
    local total = 0
    local size = grid.getSize()

    for _, effect in ipairs(player and player.mayor and player.mayor.effects or {}) do
        if effect.type == "empty_or_park_group_bonus" then
            local count = 0

            for y = 1, size do
                for x = 1, size do
                    local cell = grid.getCell(x, y)
                    if cell == 0 or cell == 2 then
                        count = count + 1
                    end
                end
            end

            local groups = math.floor(count / effect.group_size)
            for _ = 1, groups do
                table.insert(resolution, {
                    step_type = "law",
                    law_name = player.mayor.name,
                    points = effect.value
                })
            end

            total = total + (groups * effect.value)
        end
    end

    return total
end

-- Cumule les modificateurs de maire lies a une source ou une cible precise.
local function getMayorModifier(mayorEffects, modifierType, source, target)
    local total = 0
    for _, effect in ipairs(mayorEffects or {}) do
        if effect.type == modifierType and effect.source == source then
            if target == nil or effect.target == target then
                total = total + effect.value
            end
        end
    end
    return total
end

-- Multiplie la valeur d'un Immeuble selon son niveau de pile.
local function applyBuildingLevel(source, x, y, value)
    if source ~= "tower" then
        return value
    end

    -- Each extra Immeuble level doubles the final value of that tile.
    local level = grid.getCellLevel(x, y)
    if level <= 1 then
        return value
    end

    return value * (2 ^ (level - 1))
end

-- Applique la regle speciale de Leaf Enjoyer sur les parks.
local function applyLeafEnjoyerRule(mayorEffects, source, adjacencyCounts, value)
    if source ~= "park" then
        return value
    end

    for _, effect in ipairs(mayorEffects or {}) do
        if effect.type == "park_isolation_rule" then
            -- Parks only keep their value if they stay next to other parks or empty cells.
            local differentBuildingCount =
                (adjacencyCounts.houses or 0) +
                (adjacencyCounts.factories or 0) +
                (adjacencyCounts.banks or 0) +
                (adjacencyCounts.towers or 0)

            if differentBuildingCount > 0 then
                return 0
            end

            return value * effect.multiplier
        end
    end

    return value
end

-- Force une valeur fixe a certains batiments quand un boss l'impose.
local function applyBossOverrides(currentBoss, source, value)
    if not currentBoss then
        return value
    end

    for _, effect in ipairs(currentBoss.effects or {}) do
        if effect.type == "fixed_building_value" and effect.source == source then
            return effect.value
        end
    end

    return value
end

-- Retourne la valeur finale d'un batiment place sur une case.
function score.getBuildingValue(buildingId, x, y, adjacencyCounts, mayorEffects, currentBoss)
    local building = buildings.getData(buildingId)
    if not building then
        return 0
    end

    local value = building.base_score
    local source = BUILDING_NAMES[buildingId]

    value = value + getMayorModifier(mayorEffects, "flat_bonus_modifier", source)

    for _, effect in ipairs(building.effects or {}) do
        if effect.type == "adjacent_bonus" then
            local countKey = ADJACENCY_KEYS[effect.target]
            local baseValue = adjacencyCounts[countKey] or 0
            local mayorModifier = getMayorModifier(mayorEffects, "adjacent_bonus_modifier", source, effect.target)
            value = value + (baseValue * (effect.value + mayorModifier))
        end
    end

    value = applyLeafEnjoyerRule(mayorEffects, source, adjacencyCounts, value)
    value = applyBossOverrides(currentBoss, source, value)
    value = applyBuildingLevel(source, x, y, value)

    return value
end

-- Calcule le score total de la grille et la file de resolution visuelle.
function score.calculateBoard(player)
    local mayorEffects = player and player.mayor and player.mayor.effects or {}
    local resolution = {}
    local total = 0
    local size = grid.getSize()

    for y = 1, size do
        for x = 1, size do
            local buildingId = grid.getCell(x, y)

            if buildingId and buildingId > 0 and buildingId ~= grid.getObstacleId() then
                local points = score.getBuildingValue(buildingId, x, y, getAdjacencyCounts(x, y), mayorEffects, player and player.current_boss or nil)
                total = total + points

                table.insert(resolution, {
                    step_type = "cell",
                    x = x,
                    y = y,
                    points = points,
                    building_id = buildingId
                })
            end
        end
    end

    total = total + applyLawBonuses(resolution, player and player.laws or {})
    total = total + applyMayorBoardBonuses(player, resolution)

    return total, resolution
end

return score
