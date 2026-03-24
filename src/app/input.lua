-- src/app/input.lua
-- Thin router that dispatches input to smaller handlers by app state.

local input = {}
local input_menu = require("src.app.input_menu")
local input_round_clear = require("src.app.input_round_clear")
local input_play = require("src.app.input_play")

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
        navigation.openMenu(game)
        return
    end

    if game.state == "round_clear" then
        input_round_clear.handleClick(ctx, x, y)
        return
    end

    input_play.handleClick(ctx, x, y)
end

function input.mousereleased(ctx, x, y, button)
    input_play.handleRelease(ctx, x, y, button)
end

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
    end
end

return input
