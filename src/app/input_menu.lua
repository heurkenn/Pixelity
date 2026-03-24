-- src/app/input_menu.lua
-- Mouse interactions for splash, menu and setup screens.

local shared = require("src.app.input_shared")

local input_menu = {}

function input_menu.handleMenuClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout
    local gameplay = ctx.gameplay
    local player = ctx.player
    local grid = ctx.grid

    if game.debug_open then
        for _, buttonRect in ipairs(game.debug_buttons.scenarios or {}) do
            if layout.pointInRect(x, y, buttonRect) then
                gameplay.startDebugScenario(game, player, grid, buttonRect.id)
                return true
            end
        end

        if layout.pointInRect(x, y, game.debug_buttons.close) then
            game.debug_open = false
            return true
        end

        return true
    end

    if game.options_open then
        return shared.handleOptionsClick(game, layout, x, y)
    end

    if layout.pointInRect(x, y, game.menu_buttons.play) then
        game.state = "setup"
        game.setup_step = "mayor"
        return true
    end

    if layout.pointInRect(x, y, game.menu_buttons.options) then
        game.options_open = true
        return true
    end

    if layout.pointInRect(x, y, game.debug_buttons.open) then
        game.debug_open = true
        return true
    end

    return true
end

function input_menu.handleSetupClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout
    local gameplay = ctx.gameplay
    local player = ctx.player
    local grid = ctx.grid
    local navigation = ctx.navigation

    if game.options_open then
        return shared.handleOptionsClick(game, layout, x, y)
    end

    if game.setup_step == "mayor" then
        if layout.pointInRect(x, y, game.start_buttons.prev_mayor) then
            navigation.selectRelativeMayor(game, -1)
            return true
        end

        if layout.pointInRect(x, y, game.start_buttons.next_mayor) then
            navigation.selectRelativeMayor(game, 1)
            return true
        end

        if layout.pointInRect(x, y, game.start_buttons.next) then
            game.setup_step = "difficulty"
            return true
        end

        if layout.pointInRect(x, y, game.start_buttons.back_to_menu) then
            navigation.openMenu(game)
            return true
        end

        return true
    end

    for _, difficultyButton in ipairs(game.start_buttons.difficulties) do
        if layout.pointInRect(x, y, difficultyButton) then
            game.selected_difficulty_id = difficultyButton.id
            return true
        end
    end

    if layout.pointInRect(x, y, game.start_buttons.back) then
        game.setup_step = "mayor"
        return true
    end

    if layout.pointInRect(x, y, game.start_buttons.start) then
        gameplay.startGame(game, player, grid)
        return true
    end

    return true
end

return input_menu
