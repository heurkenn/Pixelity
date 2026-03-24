-- src/systems/debug_scenarios.lua
-- Seeds representative game states so UI and game flow can be tested quickly.

local debug_scenarios = {}
local law = require("src.law")
local object = require("src.object")

local function seedDebugBoard(grid)
    grid.setCell(1, 1, 1)
    grid.setCell(2, 1, 1)
    grid.setCell(3, 1, 1)
    grid.setCell(4, 1, 1)
    grid.setCell(2, 2, 2)
    grid.setCell(3, 2, 3)
    grid.setCell(5, 3, grid.getObstacleId())
end

local function seedPlayerCollections(player)
    player.laws = {
        law.getData("growing_street"),
        law.getData("success_avenue")
    }
    player.items = {
        object.getData("explosive")
    }
end

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

    if scenarioId == "play" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        return
    end

    if scenarioId == "options" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        game.options_open = true
        return
    end

    if scenarioId == "codex" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        game.codex_open = true
        game.selected_codex_law_index = 1
        return
    end

    if scenarioId == "deck" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        game.deck_view_open = true
        return
    end

    seedDebugBoard(grid)
    game.state = "round_clear"
    game.current_resolution_score = 186
    game.shop_hidden_entries = {}
    game.shop_offers = nil
    game.round_clear = {
        phase = scenarioId == "summary" and "summary" or "shop",
        banner_timer = 0.9,
        countdown_delay = 1,
        countdown_elapsed = 0,
        score_display = 186,
        global_score_display = player.total_score,
        previous_total_score = player.total_score,
        reward_pieces = 3,
        remaining_hands = 2,
        total_reward = 5,
        summary_lines = {
            "House x2",
            "Park x1",
            "Factory x1"
        },
        next_round = 2,
        next_target = 125
    }

    seedPlayerCollections(player)
end

return debug_scenarios
