-- src/game/systems/building_effects.lua
-- Centralise les triggers d'effets de batiments pour eviter de disperser leur logique dans plusieurs systemes.

local buildings = require("src.data.buildings")
local grid = require("src.game.grid")

local building_effects = {}

-- Associe les anciens types d'effet a un trigger par defaut quand le trigger n'est pas explicite dans la data.
local LEGACY_TRIGGER_BY_TYPE = {
    adjacent_bonus = "scoring",
    stack_multiplier = "scoring",
    money_reward = "round_reward",
    adjacent_money_reward = "round_reward",
    gamble = "on_build",
    weighted_money = "on_build"
}

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

-- Retourne la cle logique d'un batiment a partir de son identifiant sur la grille.
local function getBuildingKey(buildingId)
    local building = buildings.getData(buildingId)
    return building and building.key or nil
end

-- Compte les voisins orthogonaux d'une case par cle de batiment.
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
        local countKey = neighborKey and ADJACENCY_KEYS[neighborKey] or nil
        if countKey then
            counts[countKey] = counts[countKey] + 1
        end
    end

    return counts
end

-- Retourne le trigger reel d'un effet de batiment, explicite ou derive de son type legacy.
local function resolveTrigger(effect)
    return effect and (effect.trigger or LEGACY_TRIGGER_BY_TYPE[effect.type]) or nil
end

-- Parcourt tous les effets d'un batiment qui correspondent au trigger demande.
function building_effects.forEachBuildingEffect(buildingData, trigger, callback)
    if not buildingData or not callback then
        return
    end

    for _, effect in ipairs(buildingData.effects or {}) do
        if resolveTrigger(effect) == trigger then
            callback(effect, buildingData)
        end
    end
end

-- Parcourt tous les batiments poses sur la grille et leurs effets d'un trigger donne.
function building_effects.forEachGridEffect(grid, trigger, callback)
    if not grid or not callback then
        return
    end

    local cells = grid.getCells()
    local obstacleId = grid.getObstacleId()

    for y, row in ipairs(cells) do
        for x, buildingId in ipairs(row) do
            if buildingId ~= 0 and buildingId ~= obstacleId then
                local buildingData = buildings.getData(buildingId)
                building_effects.forEachBuildingEffect(buildingData, trigger, function(effect)
                    callback(effect, buildingData, x, y)
                end)
            end
        end
    end
end

-- Retourne tous les effets actifs sur la grille pour un trigger donne, avec filtre de type optionnel.
function building_effects.collectTriggeredEffects(grid, trigger, effectType)
    local effects = {}

    building_effects.forEachGridEffect(grid, trigger, function(effect, buildingData, x, y)
        if not effectType or effect.type == effectType then
            table.insert(effects, {
                effect = effect,
                building = buildingData,
                x = x,
                y = y
            })
        end
    end)

    return effects
end

-- Retourne le produit de tous les multiplicateurs actifs d'un type d'effet sur la grille.
function building_effects.getTriggeredMultiplier(grid, trigger, effectType, fieldName)
    local multiplier = 1

    for _, activeEffect in ipairs(building_effects.collectTriggeredEffects(grid, trigger, effectType)) do
        multiplier = multiplier * (activeEffect.effect[fieldName or "multiplier"] or 1)
    end

    return multiplier
end

-- Tire une issue aleatoire ponderee dans une liste d'issues pour un effet de batiment.
local function rollWeightedOutcome(outcomes)
    local roll = love.math.random()
    local cumulativeChance = 0
    local fallbackOutcome = outcomes and outcomes[#outcomes] or nil

    for _, outcome in ipairs(outcomes or {}) do
        cumulativeChance = cumulativeChance + (outcome.chance or 0)
        if roll <= cumulativeChance then
            return outcome
        end
    end

    return fallbackOutcome
end

-- Applique tous les effets de batiments qui se declenchent au moment d'un BUILD valide.
function building_effects.applyOnBuildEffects(game, player, grid)
    local result = {
        money_delta = 0,
        details = {}
    }

    building_effects.forEachGridEffect(grid, "on_build", function(effect, buildingData, x, y)
        if effect.type == "weighted_money" or effect.type == "gamble" then
            local outcome = rollWeightedOutcome(effect.outcomes)
            if outcome and outcome.value then
                player.addMoney(outcome.value)
                result.money_delta = result.money_delta + outcome.value
                table.insert(result.details, {
                    building_name = buildingData.name,
                    x = x,
                    y = y,
                    value = outcome.value
                })
            end
        end
    end)

    if result.money_delta ~= 0 then
        local sign = result.money_delta > 0 and "+" or ""
        game.message = "Effets de BUILD: " .. sign .. result.money_delta .. "$"
    end

    return result
end

-- Cumule les recompenses differees gagnees en fin de manche grace aux batiments poses.
function building_effects.collectRoundRewards(player, grid)
    local reward = 0
    local mayorMoneyMultiplier = building_effects.getTriggeredMultiplier(grid, "board_modifier", "mayor_effect_multiplier")

    building_effects.forEachGridEffect(grid, "round_reward", function(effect, buildingData, x, y)
        if effect.type == "money_reward" then
            local multiplier = effect.source == "bank" and (player.bank_money_multiplier * mayorMoneyMultiplier) or 1
            reward = reward + ((effect.value or 0) * multiplier)
        elseif effect.type == "adjacent_money_reward" then
            local countKey = ADJACENCY_KEYS[effect.target]
            local adjacencyCounts = getAdjacencyCounts(x, y)
            reward = reward + ((adjacencyCounts[countKey] or 0) * (effect.value or 0))
        end
    end)

    return reward
end

return building_effects
