-- src/systems/round_flow.lua
-- Handles round lifecycle, BUILD validation, next-round reset and summary generation.

local constants = require("src.constants")
local buildings = require("src.buildings")
local mayor_effects = require("src.systems.mayor_effects")

local round_flow = {}

function round_flow.getDifficulty(selectedDifficultyId)
    for _, item in ipairs(constants.DIFFICULTIES) do
        if item.id == selectedDifficultyId then
            return item
        end
    end
    return constants.DIFFICULTIES[1]
end

function round_flow.updateHandStatusMessage(game, player, prefix)
    if player.deck_empty and #player.deck == 0 then
        game.message = (prefix or "") .. " Deck vide."
    elseif prefix then
        game.message = prefix
    end
end

function round_flow.beginRound(game, player)
    player.setScores(0, 0)
    player.startRound()
    game.pending_placements = {}
    game.selected_hand_index = nil
    game.selected_item_index = nil
    game.dealing_timer = 0.75
    game.current_resolution_score = 0
    game.highlight_cell = nil
    game.current_score_popup = nil
    game.shop_hidden_entries = {}
    game.shop_offers = nil
    round_flow.updateHandStatusMessage(game, player, "Nouvelle manche: pioche.")
end

function round_flow.startGame(game, player, grid)
    player.reset()
    player.setMayor(game.selected_mayor_id)
    mayor_effects.applyPersistentEffects(player)
    player.setDifficulty(round_flow.getDifficulty(game.selected_difficulty_id))
    player.initDeck()

    grid.init(constants.GRID_SIZE)
    grid.generateObstacles(round_flow.getDifficulty(game.selected_difficulty_id).obstacle_count)
    game.grid_ref = grid

    game.round = 1
    game.target_score = 100
    game.state = "playing"
    game.resolving = false
    game.resolution_queue = {}
    game.resolution_index = 0
    game.resolution_timer = 0
    game.current_resolution_score = 0
    round_flow.beginRound(game, player)
end

function round_flow.endRoundFailure(game)
    game.state = "gameover"
    game.message = "Objectif rate. Clique pour recommencer."
end

function round_flow.endRoundSuccess(game, player)
    local gainedMoney = 3 + player.available_builds
    local bankReward = 0
    local cells = game.grid_ref and game.grid_ref.getCells() or {}

    for _, row in ipairs(cells) do
        for _, value in ipairs(row) do
            local buildingData = buildings.getData(value)
            if buildingData then
                for _, effect in ipairs(buildingData.effects or {}) do
                    if effect.type == "money_reward" then
                        local multiplier = effect.source == "bank" and player.bank_money_multiplier or 1
                        bankReward = bankReward + (effect.value * multiplier)
                    end
                end
            end
        end
    end

    gainedMoney = gainedMoney + bankReward
    player.addMoney(gainedMoney)
    game.state = "round_clear"
    game.round_clear = {
        phase = "banner",
        banner_timer = 0.9,
        countdown_delay = 3,
        countdown_elapsed = 0,
        score_display = game.current_resolution_score,
        global_score_display = player.total_score,
        previous_total_score = player.total_score,
        reward_pieces = 3,
        reward_bank = bankReward,
        remaining_hands = player.available_builds,
        total_reward = gainedMoney,
        summary_lines = game.last_build_summary or { "Aucun nouveau batiment place." },
        next_round = game.round + 1,
        next_target = game.target_score + 25
    }
end

function round_flow.finishResolution(game, player)
    game.resolving = false
    game.highlight_cell = nil
    game.current_score_popup = nil

    if game.current_resolution_score >= game.target_score then
        round_flow.endRoundSuccess(game, player)
        return
    end

    if player.available_builds <= 0 then
        round_flow.endRoundFailure(game)
        return
    end

    player.refillHandAfterBuild()
    if #player.hand == 0 then
        round_flow.endRoundFailure(game)
        return
    end

    game.dealing_timer = 0.35
    round_flow.updateHandStatusMessage(game, player, "BUILD resolu.")
end

function round_flow.summarizeBoardBuildings(grid)
    local counts = {}
    local lines = {}
    local cells = grid.getCells()

    for _, row in ipairs(cells) do
        for _, value in ipairs(row) do
            if value ~= 0 and value ~= grid.getObstacleId() then
                local buildingData = buildings.getData(value)
                if buildingData then
                    counts[buildingData.name] = (counts[buildingData.name] or 0) + 1
                end
            end
        end
    end

    if next(counts) == nil then
        return { "Aucun batiment sur la grille." }
    end

    for name, count in pairs(counts) do
        table.insert(lines, name .. " x" .. count)
    end

    table.sort(lines)
    return lines
end

function round_flow.finalizeBuild(game, player, grid, scoreModule)
    if not player.consumeBuild() then
        game.message = "Plus de BUILD disponible cette manche."
        return
    end

    local committedCards = {}
    for _, placement in ipairs(game.pending_placements) do
        grid.setCell(placement.x, placement.y, placement.card.id)
        table.insert(committedCards, placement.card)
    end
    player.commitPlacedCards(committedCards)

    local _, resolutionQueue = scoreModule.calculateBoard(player)
    game.resolving = true
    game.resolution_queue = resolutionQueue
    game.resolution_index = 0
    game.resolution_timer = 0
    game.current_resolution_score = player.score
    game.highlight_cell = nil
    game.current_score_popup = nil
    game.pending_placements = {}
    game.selected_hand_index = nil
    game.last_build_summary = round_flow.summarizeBoardBuildings(grid)
    game.message = "Resolution du score en cours."
end

function round_flow.openRoundSummary(game)
    if game.round_clear and game.round_clear.phase == "countdown_done" then
        game.round_clear.phase = "summary"
    end
end

function round_flow.openShop(game)
    if game.round_clear then
        game.round_clear.phase = "shop"
    end
end

function round_flow.startNextRound(game, player, grid)
    if not game.round_clear then
        return
    end

    game.round = game.round_clear.next_round
    game.target_score = game.round_clear.next_target
    game.round_clear = nil
    game.state = "playing"
    grid.init(constants.GRID_SIZE)
    grid.generateObstacles(player.difficulty and player.difficulty.obstacle_count or 0)
    player.initDeck()
    round_flow.beginRound(game, player)
end

return round_flow
