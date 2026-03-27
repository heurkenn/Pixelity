-- src/gameplay.lua
-- Facade over gameplay systems so the rest of the codebase keeps a small public API.

local round_flow = require("src.systems.round_flow")
local resolution = require("src.systems.resolution")
local debug_scenarios = require("src.systems.debug_scenarios")
local shop_state = require("src.systems.shop_state")
local bosses = require("src.systems.bosses")
local buildings = require("src.data.buildings")

local gameplay = {}

-- Retourne les donnees de difficulte selectionnees dans la run courante.
function gameplay.getDifficulty(game)
    return round_flow.getDifficulty(game.selected_difficulty_id)
end

-- Recherche le dernier placement temporaire sur une case pour manipuler le dessus de pile.
function gameplay.getPendingPlacementAt(game, x, y)
    for index = #game.pending_placements, 1, -1 do
        local placement = game.pending_placements[index]
        if placement.x == x and placement.y == y then
            return placement, index
        end
    end
    return nil, nil
end

-- Retourne le type de batiment qui occupera une case apres les placements en attente.
local function getProjectedCellId(game, grid, x, y)
    local pendingPlacement = gameplay.getPendingPlacementAt(game, x, y)
    if pendingPlacement then
        return pendingPlacement.card.id
    end
    return grid.getCell(x, y)
end

-- Verifie si une case est libre pour y poser une carte.
function gameplay.canPlaceAt(game, grid, x, y)
    if not grid.isInside(x, y) or not grid.isFree(x, y) then
        return false
    end
    return gameplay.getPendingPlacementAt(game, x, y) == nil
end

-- Compte un type de batiment deja construit ou en attente de construction.
function gameplay.countPlacedOrCommitted(game, grid, buildingId)
    local count = 0
    local cells = grid.getCells()

    for y = 1, grid.getSize() do
        for x = 1, grid.getSize() do
            if cells[y][x] == buildingId then
                count = count + 1
            end
        end
    end

    for _, placement in ipairs(game.pending_placements) do
        if placement.card.id == buildingId then
            count = count + 1
        end
    end

    return count
end

-- Met a jour le message d'etat lie a la main et au deck.
function gameplay.updateHandStatusMessage(game, player, prefix)
    round_flow.updateHandStatusMessage(game, player, prefix)
end

-- Initialise les donnees d'une nouvelle manche.
function gameplay.beginRound(game, player)
    round_flow.beginRound(game, player)
end

-- Lance une nouvelle partie complete depuis le setup.
function gameplay.startGame(game, player, grid)
    round_flow.startGame(game, player, grid)
end

-- Construit un etat de debug correspondant a un scenario donne.
function gameplay.startDebugScenario(game, player, grid, scenarioId)
    debug_scenarios.start(game, player, grid, round_flow.startGame, scenarioId)
end

-- Termine la run sur un echec de manche.
function gameplay.endRoundFailure(game)
    round_flow.endRoundFailure(game)
end

-- Ouvre la sequence de fin de manche reussie.
function gameplay.endRoundSuccess(game, player)
    round_flow.endRoundSuccess(game, player)
end

-- Termine la resolution d'un BUILD et applique la suite du flow.
function gameplay.finishResolution(game, player)
    round_flow.finishResolution(game, player)
end

-- Valide un BUILD si les preconditions de pose sont remplies.
function gameplay.finalizeBuild(game, player, grid, scoreModule)
    if #game.pending_placements == 0 and not gameplay.hasCommittedBuildings(grid) then
        game.message = "Place au moins une carte avant BUILD."
        return
    end

    round_flow.finalizeBuild(game, player, grid, scoreModule)
end

-- Fait avancer la resolution du score case par case.
function gameplay.updateResolution(game, player, dt)
    resolution.updateResolution(game, player, round_flow.finishResolution, dt)
end

-- Met a jour les ecrans inter-manche.
function gameplay.updateRoundClear(game, player, dt)
    resolution.updateRoundClear(game, player, dt)
end

-- Met a jour l'intro visuelle d'un boss avant la manche.
function gameplay.updateBossIntro(game, dt)
    bosses.updateBossIntro(game, dt)
end

-- Ouvre le resume de manche une fois le decompte termine.
function gameplay.openRoundSummary(game)
    round_flow.openRoundSummary(game)
end

-- Ouvre le shop inter-manche avec ses offres courantes.
function gameplay.openShop(game, player)
    round_flow.openShop(game, player)
end

-- Utilise un explosif sur une case d'obstacle.
function gameplay.useExplosive(game, player, grid, x, y)
    return shop_state.useExplosive(game, player, grid, x, y)
end

-- Applique l'effet de BUILD du boss courant.
function gameplay.applyBossBuildEffects(game, player, grid)
    return bosses.applyBuildEffects(game, player, grid)
end

-- Passe a la manche suivante apres le shop.
function gameplay.startNextRound(game, player, grid)
    round_flow.startNextRound(game, player, grid)
end

-- Demarre effectivement une manche boss apres son intro.
function gameplay.startBossRound(game, player, grid)
    round_flow.startBossRound(game, player, grid)
end

-- Indique si la grille contient deja au moins un batiment construit.
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

-- Tente de poser une carte de main sur une case cible.
function gameplay.placeCardFromHand(game, player, grid, handIndex, x, y)
    local maxPendingPlacements = player.getMaxPendingPlacements and player.getMaxPendingPlacements() or 4
    if #game.pending_placements >= maxPendingPlacements then
        game.message = "Maximum " .. maxPendingPlacements .. " cartes avant BUILD."
        return false
    end

    local card = player.removeCardFromHand(handIndex)
    if not card then
        return false
    end

    -- Immeuble is the only card that can legally target an occupied cell:
    -- stacking it upgrades the existing Immeuble instead of replacing the tile.
    local projectedId = getProjectedCellId(game, grid, x, y)
    local isTowerUpgrade = card.id == 5 and projectedId == 5

    if not isTowerUpgrade and not gameplay.canPlaceAt(game, grid, x, y) then
        player.returnCardToHand(card)
        game.message = "Case indisponible."
        return false
    end

    if card.id == 2 and player.max_park_on_grid then
        local parkCount = gameplay.countPlacedOrCommitted(game, grid, 2)
        if parkCount >= player.max_park_on_grid then
            player.returnCardToHand(card)
            game.message = "Maximum " .. player.max_park_on_grid .. " Park sur la grille."
            return false
        end
    end

    table.insert(game.pending_placements, {
        x = x,
        y = y,
        card = card,
        upgrade = isTowerUpgrade
    })
    game.selected_hand_index = nil
    if isTowerUpgrade then
        game.message = card.name .. " va ameliorer l'Immeuble."
    else
        game.message = card.name .. " prete a etre construite."
    end
    return true
end

-- Tente de poser la carte actuellement selectionnee sur une case.
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

-- Retire un placement temporaire et remet la carte dans la main.
function gameplay.removePendingPlacement(game, player, index)
    local placement = table.remove(game.pending_placements, index)
    if placement then
        player.returnCardToHand(placement.card)
    end
end

return gameplay
