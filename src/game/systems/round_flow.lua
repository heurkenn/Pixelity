-- src/game/systems/round_flow.lua
-- Handles round lifecycle, BUILD validation, next-round reset and summary generation.

local constants = require("src.constants")
local buildings = require("src.data.buildings")
local rounds = require("src.data.rounds")
local bosses = require("src.game.systems.bosses")
local mayor_effects = require("src.game.systems.mayor_effects")
local building_effects = require("src.game.systems.building_effects")
local shop = require("src.game.shop")

local round_flow = {}

-- Retourne la difficulte complete a partir de son identifiant.
function round_flow.getDifficulty(selectedDifficultyId)
    for _, item in ipairs(constants.DIFFICULTIES) do
        if item.id == selectedDifficultyId then
            return item
        end
    end
    return constants.DIFFICULTIES[1]
end

-- Met a jour le message de pioche ou de deck vide pour la manche.
function round_flow.updateHandStatusMessage(game, player, prefix)
    if player.deck_empty and #player.deck == 0 then
        game.message = (prefix or "") .. " Deck vide."
    elseif prefix then
        game.message = prefix
    end
end

-- Reinitialise les etats temporaires necessaires au debut d'une manche.
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
    game.boss_effect = nil
    game.shop_hidden_entries = {}
    game.shop_offers = nil
    game.shop_seeded = false
    round_flow.updateHandStatusMessage(game, player, "Nouvelle manche: pioche.")
end

-- Passe proprement dans l'etat jouable d'une manche deja preparee.
local function enterPreparedRound(game, player, grid)
    game.state = "playing"
    game.grid_ref = grid
    round_flow.beginRound(game, player)
end

-- Prepare la grille, le score cible et l'eventuel boss d'une manche.
local function prepareRoundState(game, player, grid, roundNumber)
    grid.init(constants.GRID_SIZE)
    game.grid_ref = grid
    game.round = roundNumber
    game.target_score = rounds.getTarget(roundNumber)

    local bossData = nil
    if rounds.isBossRound(roundNumber) then
        bossData = bosses.getBossForRound(game, roundNumber)
    end

    game.current_boss = bossData
    player.current_boss = bossData
    if bossData then
        bosses.applyRoundStartEffects(bossData, grid)
        bosses.prepareBossIntro(game, bossData)
        return
    end

    grid.generateObstacles(player.difficulty and player.difficulty.obstacle_count or 0)
    enterPreparedRound(game, player, grid)
end

-- Lance une run complete depuis un etat vierge.
function round_flow.startGame(game, player, grid)
    player.reset()
    player.setMayor(game.selected_mayor_id)
    mayor_effects.applyPersistentEffects(player)
    player.setDifficulty(round_flow.getDifficulty(game.selected_difficulty_id))
    player.initDeck()
    game.boss_order = bosses.buildOrder()
    game.round = 1
    game.rounds_played = 1
    game.run_recorded = false
    game.resolving = false
    game.resolution_queue = {}
    game.resolution_index = 0
    game.resolution_timer = 0
    game.current_resolution_score = 0
    prepareRoundState(game, player, grid, 1)
end

-- Bascule la partie vers l'ecran de defaite.
function round_flow.endRoundFailure(game)
    game.state = "gameover"
    game.message = "Objectif rate. Clique pour recommencer."
end

-- Ouvre la sequence de victoire de manche avec ses recompenses.
function round_flow.endRoundSuccess(game, player)
    local gainedMoney = 3 + player.available_builds
    local bankReward = 0
    local countdownDelay = math.max(0.2, 3 / math.max(1, game.scoring_speed or 1))
    bankReward = building_effects.collectRoundRewards(player, game.grid_ref)

    gainedMoney = gainedMoney + bankReward
    player.addMoney(gainedMoney)
    game.state = "round_clear"
    game.round_clear = {
        phase = "banner",
        banner_timer = 0.9,
        countdown_delay = countdownDelay,
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
        next_target = rounds.getTarget(game.round + 1)
    }
end

-- Termine une resolution et decide de la suite de la manche.
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

-- Construit le resume textuel des batiments presents sur la grille.
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

-- Fige les placements d'un BUILD puis lance boss ou scoring.
function round_flow.finalizeBuild(game, player, grid, scoreModule)
    if not player.consumeBuild() then
        game.message = "Plus de BUILD disponible cette manche."
        return
    end

    local committedCards = {}
    for _, placement in ipairs(game.pending_placements) do
        if placement.upgrade then
            grid.setCellLevel(placement.x, placement.y, grid.getCellLevel(placement.x, placement.y) + 1)
        else
            grid.setCell(placement.x, placement.y, placement.card.id)
            grid.setCellLevel(placement.x, placement.y, 1)
        end
        table.insert(committedCards, placement.card)
    end
    player.commitPlacedCards(committedCards)
    building_effects.applyOnBuildEffects(game, player, grid)

    game.pending_placements = {}
    game.selected_hand_index = nil
    game.current_score_popup = nil

    local function startScoreResolution()
        local _, resolutionQueue = scoreModule.calculateBoard(player)
        game.resolving = true
        game.resolution_queue = resolutionQueue
        game.resolution_index = 0
        game.resolution_timer = 0
        game.current_resolution_score = player.score
        game.highlight_cell = nil
        game.last_build_summary = round_flow.summarizeBoardBuildings(grid)
        game.message = "Resolution du score en cours."
    end

    local bossOutcome = bosses.applyBuildEffects(game, player, grid)
    if bossOutcome and bossOutcome.steps and #bossOutcome.steps > 0 then
        game.resolving = false
        game.resolution_queue = {}
        game.resolution_index = 0
        game.resolution_timer = 0
        game.current_resolution_score = player.score
        game.boss_effect = {
            active = true,
            label = bossOutcome.label,
            markers = bossOutcome.markers or {},
            steps = bossOutcome.steps,
            index = 0,
            timer = 0,
            pre_delay = math.max(0.18, 0.42 / math.max(1, game.scoring_speed or 1)),
            step_delay = math.max(0.06, 0.28 / math.max(1, game.scoring_speed or 1)),
            on_complete = startScoreResolution
        }
        game.highlight_cell = nil
        game.message = bossOutcome.label
        return
    end

    startScoreResolution()
end

-- Ouvre le panneau resume une fois le decompte termine.
function round_flow.openRoundSummary(game)
    if game.round_clear and game.round_clear.phase == "countdown_done" then
        game.round_clear.phase = "summary"
    end
end

-- Ouvre le shop et genere ses offres si besoin.
function round_flow.openShop(game, player)
    if game.round_clear then
        if not game.shop_seeded then
            shop.rollOffers(game, player)
            game.shop_seeded = true
        end
        game.round_clear.phase = "shop"
    end
end

-- Avance a la manche suivante ou ouvre la victoire finale de run.
function round_flow.startNextRound(game, player, grid)
    if not game.round_clear then
        return
    end

    if game.round >= rounds.getFinalRound() then
        local difficultyName = player.difficulty and player.difficulty.name or game.selected_difficulty_id
        local unlockMessage = require("src.app.profile").finishRun(game, player, true)
        game.state = "victory"
        game.round_clear = nil
        game.victory_summary = {
            mayor_name = player.mayor and player.mayor.name or "-",
            difficulty_name = difficultyName or "-",
            rounds_played = game.rounds_played or game.round,
            unlock_message = unlockMessage
        }
        game.message = "Run reussie."
        return
    end

    game.round = game.round_clear.next_round
    game.rounds_played = (game.rounds_played or game.round) + 1
    game.target_score = game.round_clear.next_target
    game.round_clear = nil
    player.initDeck()
    prepareRoundState(game, player, grid, game.round)
end

-- Finalise l'intro boss et demarre la vraie manche.
function round_flow.startBossRound(game, player, grid)
    if game.state ~= "boss_intro" then
        return
    end

    grid.generateObstacles(player.difficulty and player.difficulty.obstacle_count or 0)
    enterPreparedRound(game, player, grid)
end

return round_flow
