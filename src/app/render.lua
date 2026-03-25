-- src/app/render.lua
-- State-based draw router for the root application loop.

local render = {}

function render.draw(ctx)
    local game = ctx.game
    local player = ctx.player
    local grid = ctx.grid
    local buildings = ctx.buildings
    local ui = ctx.ui
    local gameplay = ctx.gameplay
    local navigation = ctx.navigation
    local profile = ctx.profile

    love.graphics.clear(0.1, 0.11, 0.14)
    ui.applyDefaultFont()

    if game.state == "splash" then
        ui.drawIntro(game)
        return
    end

    if game.state == "menu" then
        ui.drawMenu(game)
        ui.drawStatsModal(game, profile)
        ui.drawOptionsModal(game)
        return
    end

    if game.state == "setup" then
        ui.drawSetup(game, navigation.getMayorById, profile)
        ui.drawOptionsModal(game)
        return
    end

    if game.state == "gameover" then
        ui.drawGameOver(game, player)
        return
    end

    if game.state == "boss_intro" then
        ui.drawGrid(game, grid, buildings, function(x, y)
            return gameplay.getPendingPlacementAt(game, x, y)
        end)
        ui.drawBossIntro(game)
        return
    end

    ui.drawGrid(game, grid, buildings, function(x, y)
        return gameplay.getPendingPlacementAt(game, x, y)
    end)

    if game.state == "round_clear" then
        ui.drawRoundClear(game, player)
        return
    end

    ui.drawHUD(game, player, function()
        return gameplay.getDifficulty(game)
    end)
    ui.drawHand(game, player)
    ui.drawScorePopup(game)
    ui.drawConfirmBuild(game)
    ui.drawOptionsModal(game)
    ui.drawCodexModal(game, player)
    ui.drawDeckModal(game, player)
end

return render
