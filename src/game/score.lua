-- src/game/score.lua

local score = {}
local grid = require("src.game.grid")
local buildings = require("src.data.buildings")
local building_effects = require("src.game.systems.building_effects")

local HOUSE_ID = 1
local ADJACENCY_KEYS = {
    house = "houses",
    park = "parks",
    factory = "factories",
    bank = "banks",
    casino = "casinos",
    tower = "towers",
    bourgeois_king = "bourgeois_kings",
    mec_donatien = "mec_donatiens"
}

local SCORE_LAW_EFFECT_TYPES = {
    aligned_houses = true,
    adjacent_towers_bonus = true,
    building_count_bonus = true
}

-- Retourne la cle logique d'un batiment place sur la grille.
local function getBuildingKey(buildingId)
    local building = buildings.getData(buildingId)
    return building and building.key or nil
end

-- Retourne le multiplicateur des effets de maire actifs grace aux batiments du plateau.
local function getMayorEffectMultiplier()
    return building_effects.getTriggeredMultiplier(grid, "board_modifier", "mayor_effect_multiplier")
end

-- Ajuste une valeur de loi selon les modificateurs actifs du plateau.
local function getAdjustedLawValue(effect, baseValue)
    local adjustedValue = baseValue

    for _, activeEffect in ipairs(building_effects.collectTriggeredEffects(grid, "board_modifier", "law_effect_multiplier")) do
        if SCORE_LAW_EFFECT_TYPES[effect.type] then
            adjustedValue = adjustedValue * (activeEffect.effect.multiplier or 1)
        else
            adjustedValue = adjustedValue + (activeEffect.effect.fallback_bonus or 0)
        end
    end

    return math.floor(adjustedValue)
end

-- Compte les voisins par type autour d'une case de grille.
local function getAdjacencyCounts(x, y)
    local counts = {
        houses = 0,
        parks = 0,
        factories = 0,
        banks = 0,
        casinos = 0,
        towers = 0,
        bourgeois_kings = 0,
        mec_donatiens = 0
    }

    for _, neighborId in ipairs(grid.getNeighbors(x, y)) do
        local neighborKey = getBuildingKey(neighborId)
        if neighborKey == "house" then
            counts.houses = counts.houses + 1
        elseif neighborKey == "park" then
            counts.parks = counts.parks + 1
        elseif neighborKey == "factory" then
            counts.factories = counts.factories + 1
        elseif neighborKey == "bank" then
            counts.banks = counts.banks + 1
        elseif neighborKey == "casino" then
            counts.casinos = counts.casinos + 1
        elseif neighborKey == "tower" then
            counts.towers = counts.towers + 1
        elseif neighborKey == "bourgeois_king" then
            counts.bourgeois_kings = counts.bourgeois_kings + 1
        elseif neighborKey == "mec_donatien" then
            counts.mec_donatiens = counts.mec_donatiens + 1
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
            if getBuildingKey(grid.getCell(x, y)) == "tower" then
                if x < size and getBuildingKey(grid.getCell(x + 1, y)) == "tower" then
                    total = total + 1
                end
                if y < size and getBuildingKey(grid.getCell(x, y + 1)) == "tower" then
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
                local adjustedBonus = getAdjustedLawValue(effect, effect.bonus)

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
                        points = adjustedBonus
                    })
                end

                total = total + (segmentCount * adjustedBonus)
            elseif effect.type == "adjacent_towers_bonus" then
                local pairCount = countAdjacentTowerPairs()
                local adjustedBonus = getAdjustedLawValue(effect, effect.bonus)

                for _ = 1, pairCount do
                    table.insert(resolution, {
                        step_type = "law",
                        law_name = law.name,
                        points = adjustedBonus
                    })
                end

                total = total + (pairCount * adjustedBonus)
            elseif effect.type == "building_count_bonus" then
                local matchingCount = 0
                local adjustedBonus = getAdjustedLawValue(effect, effect.bonus)

                for y = 1, size do
                    for x = 1, size do
                        if getBuildingKey(grid.getCell(x, y)) == effect.building_key then
                            matchingCount = matchingCount + 1
                        end
                    end
                end

                for _ = 1, matchingCount do
                    table.insert(resolution, {
                        step_type = "law",
                        law_name = law.name,
                        points = adjustedBonus
                    })
                end

                total = total + (matchingCount * adjustedBonus)
            end
        end
    end

    return total
end

-- Applique les bonus globaux de maire qui se lisent sur tout le plateau.
local function applyMayorBoardBonuses(player, resolution)
    local total = 0
    local size = grid.getSize()
    local mayorEffectMultiplier = getMayorEffectMultiplier()

    for _, effect in ipairs(player and player.mayor and player.mayor.effects or {}) do
        if effect.type == "empty_or_park_group_bonus" then
            local count = 0

            for y = 1, size do
                for x = 1, size do
                    local cell = grid.getCell(x, y)
                    if cell == 0 or getBuildingKey(cell) == "park" then
                        count = count + 1
                    end
                end
            end

            local groups = math.floor(count / effect.group_size)
            for _ = 1, groups do
                table.insert(resolution, {
                    step_type = "law",
                    law_name = player.mayor.name,
                    points = math.floor((effect.value or 0) * mayorEffectMultiplier)
                })
            end

            total = total + (groups * math.floor((effect.value or 0) * mayorEffectMultiplier))
        end
    end

    return total
end

-- Cumule les modificateurs de maire lies a une source ou une cible precise.
local function getMayorModifier(mayorEffects, modifierType, source, target)
    local total = 0
    local mayorEffectMultiplier = getMayorEffectMultiplier()
    for _, effect in ipairs(mayorEffects or {}) do
        if effect.type == modifierType and effect.source == source then
            if target == nil or effect.target == target then
                total = total + math.floor((effect.value or 0) * mayorEffectMultiplier)
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

            return value * ((effect.multiplier or 1) * getMayorEffectMultiplier())
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
    local source = building.key

    value = value + getMayorModifier(mayorEffects, "flat_bonus_modifier", source)

    building_effects.forEachBuildingEffect(building, "scoring", function(effect)
        if effect.type == "adjacent_bonus" then
            local countKey = ADJACENCY_KEYS[effect.target]
            local baseValue = adjacencyCounts[countKey] or 0
            local mayorModifier = getMayorModifier(mayorEffects, "adjacent_bonus_modifier", source, effect.target)
            value = value + (baseValue * (effect.value + mayorModifier))
        end
    end)

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
