-- src/gameplay.lua
-- Facade over gameplay systems so the rest of the codebase keeps a small public API.

local round_flow = require("src.systems.round_flow")
local resolution = require("src.systems.resolution")
local debug_scenarios = require("src.systems.debug_scenarios")
local shop_state = require("src.systems.shop_state")

local gameplay = {}

function gameplay.getDifficulty(game)
    return round_flow.getDifficulty(game.selected_difficulty_id)
end

function gameplay.getPendingPlacementAt(game, x, y)
    for index, placement in ipairs(game.pending_placements) do
        if placement.x == x and placement.y == y then
            return placement, index
        end
    end
    return nil, nil
end

function gameplay.canPlaceAt(game, grid, x, y)
    if not grid.isInside(x, y) or not grid.isFree(x, y) then
        return false
    end
    return gameplay.getPendingPlacementAt(game, x, y) == nil
end

function gameplay.updateHandStatusMessage(game, player, prefix)
    round_flow.updateHandStatusMessage(game, player, prefix)
end

function gameplay.beginRound(game, player)
    round_flow.beginRound(game, player)
end

function gameplay.startGame(game, player, grid)
    round_flow.startGame(game, player, grid)
end

function gameplay.startDebugScenario(game, player, grid, scenarioId)
    debug_scenarios.start(game, player, grid, round_flow.startGame, scenarioId)
end

function gameplay.endRoundFailure(game)
    round_flow.endRoundFailure(game)
end

function gameplay.endRoundSuccess(game, player)
    round_flow.endRoundSuccess(game, player)
end

function gameplay.finishResolution(game, player)
    round_flow.finishResolution(game, player)
end

function gameplay.finalizeBuild(game, player, grid, scoreModule)
    if #game.pending_placements == 0 and not gameplay.hasCommittedBuildings(grid) then
        game.message = "Place au moins une carte avant BUILD."
        return
    end

    round_flow.finalizeBuild(game, player, grid, scoreModule)
end

function gameplay.updateResolution(game, player, dt)
    resolution.updateResolution(game, player, round_flow.finishResolution, dt)
end

function gameplay.updateRoundClear(game, player, dt)
    resolution.updateRoundClear(game, player, dt)
end

function gameplay.openRoundSummary(game)
    round_flow.openRoundSummary(game)
end

function gameplay.openShop(game)
    round_flow.openShop(game)
end

function gameplay.useExplosive(game, player, grid, x, y)
    return shop_state.useExplosive(game, player, grid, x, y)
end

function gameplay.startNextRound(game, player, grid)
    round_flow.startNextRound(game, player, grid)
end

function gameplay.hasCommittedBuildings(grid)
    local cells = grid.getCells()

    for _, row in ipairs(cells) do
        for _, value in ipairs(row) do
            if value ~= 0 and value ~= grid.getObstacleId() then
                return true
            end
        end
    end

    return false
end

function gameplay.placeCardFromHand(game, player, grid, handIndex, x, y)
    if #game.pending_placements >= 4 then
        game.message = "Maximum 4 cartes avant BUILD."
        return false
    end
    if not gameplay.canPlaceAt(game, grid, x, y) then
        game.message = "Case indisponible."
        return false
    end

    local card = player.removeCardFromHand(handIndex)
    if not card then
        return false
    end

    table.insert(game.pending_placements, { x = x, y = y, card = card })
    game.selected_hand_index = nil
    game.message = card.name .. " prete a etre construite."
    return true
end

function gameplay.tryPlaceSelectedCard(game, player, grid, x, y)
    if not game.selected_hand_index then
        return false
    end

    local placed = gameplay.placeCardFromHand(game, player, grid, game.selected_hand_index, x, y)
    if placed then
        game.selected_hand_index = nil
    end
    return placed
end

function gameplay.removePendingPlacement(game, player, index)
    local placement = table.remove(game.pending_placements, index)
    if placement then
        player.returnCardToHand(placement.card)
    end
end

return gameplay
