-- src/app/input.lua
-- Thin router that dispatches input to smaller handlers by app state.

local input = {}
local input_menu = require("src.app.input_menu")
local input_round_clear = require("src.app.input_round_clear")
local input_play = require("src.app.input_play")

-- Route les clics souris vers l'etat de jeu approprie.
function input.mousepressed(ctx, x, y, button)
    local game = ctx.game
    local navigation = ctx.navigation

    if button ~= 1 then
        return
    end

    if game.state == "splash" then
        navigation.openMenu(game)
        return
    end

    if game.state == "menu" then
        input_menu.handleMenuClick(ctx, x, y)
        return
    end

    if game.state == "setup" then
        input_menu.handleSetupClick(ctx, x, y)
        return
    end

    if game.state == "gameover" then
        ctx.profile.finishRun(game, ctx.player, false)
        ctx.save.clear(game)
        navigation.openMenu(game)
        return
    end

    if game.state == "victory" then
        ctx.profile.finishRun(game, ctx.player, true)
        ctx.save.clear(game)
        navigation.openMenu(game)
        return
    end

    if game.state == "boss_intro" then
        if game.boss_intro and game.boss_intro.continue_ready and game.boss_intro.continue_button and ctx.layout.pointInRect(x, y, game.boss_intro.continue_button) then
            ctx.gameplay.startBossRound(game, ctx.player, ctx.grid)
        end
        return
    end

    if game.state == "round_clear" then
        input_round_clear.handleClick(ctx, x, y)
        return
    end

    input_play.handleClick(ctx, x, y)
end

-- Route les relachements de souris, surtout pour le drag and drop des cartes.
function input.mousereleased(ctx, x, y, button)
    input_play.handleRelease(ctx, x, y, button)
end

-- Route les touches clavier vers l'etat courant et gere les raccourcis globaux.
function input.keypressed(ctx, key)
    local game = ctx.game
    local navigation = ctx.navigation

    if key == "escape" then
        if game.state == "setup" and game.setup_step == "difficulty" then
            game.setup_step = "mayor"
        elseif game.state == "setup" then
            navigation.openMenu(game)
        else
            love.event.quit()
        end
    elseif game.state == "playing" then
        input_play.handleKey(ctx, key)
    elseif game.state == "boss_intro" and key == "return" and game.boss_intro and game.boss_intro.continue_ready then
        ctx.gameplay.startBossRound(game, ctx.player, ctx.grid)
    end
end

-- Gere le scroll souris pour les interfaces qui le supportent.
function input.wheelmoved(ctx, _, y)
    local game = ctx.game
    if game.state ~= "menu" or not game.debug_open then
        return
    end

    game.debug_scroll = math.max(0, math.min(game.debug_scroll_max or 0, (game.debug_scroll or 0) - (y * 28)))
end

return input
