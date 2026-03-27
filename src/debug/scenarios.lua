-- src/debug/scenarios.lua
-- Seeds representative game states so UI and game flow can be tested quickly.

local debug_scenarios = {}
local boss = require("src.data.boss")
local law = require("src.data.law")
local object = require("src.data.object")
local rounds = require("src.data.rounds")

-- Place quelques batiments et un obstacle pour obtenir un plateau lisible en debug.
local function seedDebugBoard(grid)
    grid.setCell(1, 1, 1)
    grid.setCell(2, 1, 1)
    grid.setCell(3, 1, 1)
    grid.setCell(4, 1, 1)
    grid.setCell(2, 2, 2)
    grid.setCell(3, 2, 3)
    grid.setCell(5, 3, grid.getObstacleId())
end

-- Donne au joueur un petit inventaire representatif pour tester l'UI.
local function seedPlayerCollections(player)
    player.laws = {
        law.getData("growing_street"),
        law.getData("success_avenue")
    }
    player.items = {
        object.getData("explosive")
    }
end

-- Replace l'etat de run sur une manche precise avec son score cible reel.
local function setDebugRound(game, player, roundNumber, bossId)
    game.round = roundNumber
    game.rounds_played = roundNumber
    game.target_score = rounds.getTarget(roundNumber)
    game.current_resolution_score = 0
    game.current_boss = bossId and boss.getData(bossId) or nil
    player.current_boss = game.current_boss
end

-- Prepare un ecran d'inter-manche realiste apres une victoire de manche.
local function seedRoundClear(game, player, roundNumber, phase)
    game.state = "round_clear"
    game.shop_hidden_entries = {}
    game.shop_offers = nil
    game.shop_seeded = false
    game.current_resolution_score = math.floor(rounds.getTarget(roundNumber) * 0.93)
    game.round = roundNumber
    game.rounds_played = roundNumber
    game.target_score = rounds.getTarget(roundNumber)
    game.current_boss = nil
    player.current_boss = nil
    game.round_clear = {
        phase = phase,
        banner_timer = 0.9,
        countdown_delay = math.max(0.2, 1 / math.max(1, game.scoring_speed or 1)),
        countdown_elapsed = 0,
        score_display = game.current_resolution_score,
        global_score_display = player.total_score,
        previous_total_score = player.total_score,
        reward_pieces = 3,
        reward_bank = 2,
        remaining_hands = 2,
        total_reward = 7,
        summary_lines = {
            "House x2",
            "Park x1",
            "Factory x1"
        },
        next_round = roundNumber + 1,
        next_target = rounds.getTarget(roundNumber + 1)
    }
end

-- Construit un etat de jeu utile pour verifier rapidement une scene ou un boss.
function debug_scenarios.start(game, player, grid, startGame, scenarioId)
    startGame(game, player, grid)
    game.debug_open = false
    game.dealing_timer = 0
    game.options_open = false
    game.codex_open = false
    game.deck_view_open = false
    game.selected_codex_law_index = nil
    game.message = "Mode debug."
    player.money = 12

    -- Ouvre directement l'intro d'un boss sur sa vraie manche de run.
    local function openBossIntro(bossId)
        local bosses = require("src.game.systems.bosses")
        seedDebugBoard(grid)
        if bossId == "earthquake" then
            setDebugRound(game, player, 3, bossId)
        elseif bossId == "tsunami" then
            setDebugRound(game, player, 6, bossId)
        elseif bossId == "lactose_dog" then
            setDebugRound(game, player, 9, bossId)
        elseif bossId == "in_the_dark" then
            setDebugRound(game, player, 12, bossId)
        else
            setDebugRound(game, player, 15, bossId)
        end
        bosses.prepareBossIntro(game, game.current_boss)
    end

    if scenarioId == "play" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        setDebugRound(game, player, 2, nil)
        return
    end

    if scenarioId == "options" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        setDebugRound(game, player, 2, nil)
        game.options_open = true
        return
    end

    if scenarioId == "codex" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        setDebugRound(game, player, 4, nil)
        game.codex_open = true
        game.selected_codex_law_index = 1
        return
    end

    if scenarioId == "deck" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        setDebugRound(game, player, 4, nil)
        game.deck_view_open = true
        return
    end

    if scenarioId == "boss_intro" then
        openBossIntro("earthquake")
        return
    end

    if scenarioId == "boss_earthquake" then
        seedDebugBoard(grid)
        setDebugRound(game, player, 3, "earthquake")
        return
    end

    if scenarioId == "boss_tsunami" then
        seedDebugBoard(grid)
        setDebugRound(game, player, 6, "tsunami")
        return
    end

    if scenarioId == "boss_lactose" then
        seedDebugBoard(grid)
        setDebugRound(game, player, 9, "lactose_dog")
        return
    end

    if scenarioId == "boss_dark" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        setDebugRound(game, player, 12, "in_the_dark")
        return
    end

    if scenarioId == "boss_renovation" then
        setDebugRound(game, player, 15, "renovation")
        grid.init(5)
        grid.generateObstacles(10)
        return
    end

    if scenarioId == "victory" then
        game.state = "victory"
        game.round = rounds.getFinalRound()
        game.rounds_played = rounds.getFinalRound()
        player.total_score = 4820
        player.money = 21
        game.victory_summary = {
            mayor_name = player.mayor and player.mayor.name or "Newbie",
            difficulty_name = player.difficulty and player.difficulty.name or "Facile",
            rounds_played = rounds.getFinalRound(),
            unlock_message = "Nouveau maire debloque"
        }
        return
    end

    seedDebugBoard(grid)
    seedPlayerCollections(player)
    seedRoundClear(game, player, 5, scenarioId == "summary" and "summary" or "shop")
end

return debug_scenarios
