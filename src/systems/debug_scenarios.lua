-- src/systems/debug_scenarios.lua
-- Seeds representative game states so UI and game flow can be tested quickly.

local debug_scenarios = {}
local boss = require("src.data.boss")
local law = require("src.data.law")
local object = require("src.data.object")

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

    local function openBossIntro(bossId)
        local bosses = require("src.systems.bosses")
        seedDebugBoard(grid)
        local bossData = boss.getData(bossId)
        game.current_boss = bossData
        player.current_boss = bossData
        bosses.prepareBossIntro(game, bossData)
    end

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

    if scenarioId == "boss_intro" then
        openBossIntro("earthquake")
        return
    end

    if scenarioId == "boss_earthquake" then
        seedDebugBoard(grid)
        local bossData = boss.getData("earthquake")
        game.current_boss = bossData
        player.current_boss = bossData
        return
    end

    if scenarioId == "boss_tsunami" then
        seedDebugBoard(grid)
        local bossData = boss.getData("tsunami")
        game.current_boss = bossData
        player.current_boss = bossData
        return
    end

    if scenarioId == "boss_lactose" then
        seedDebugBoard(grid)
        local bossData = boss.getData("lactose_dog")
        game.current_boss = bossData
        player.current_boss = bossData
        return
    end

    if scenarioId == "boss_dark" then
        seedDebugBoard(grid)
        seedPlayerCollections(player)
        local bossData = boss.getData("in_the_dark")
        game.current_boss = bossData
        player.current_boss = bossData
        return
    end

    if scenarioId == "boss_renovation" then
        local bossData = boss.getData("renovation")
        game.current_boss = bossData
        player.current_boss = bossData
        grid.init(5)
        grid.generateObstacles(15)
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
        countdown_delay = math.max(0.2, 1 / math.max(1, game.scoring_speed or 1)),
        countdown_elapsed = 0,
        score_display = 186,
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
        next_round = 2,
        next_target = 125
    }

    seedPlayerCollections(player)
end

return debug_scenarios
