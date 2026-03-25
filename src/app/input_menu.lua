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
    local profile = ctx.profile
    local save = ctx.save

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
        return shared.handleOptionsClick(ctx, x, y)
    end

    if game.stats_open then
        if layout.pointInRect(x, y, game.stats_modal.close) or not layout.pointInRect(x, y, game.stats_modal.panel) then
            game.stats_open = false
        end
        return true
    end

    if layout.pointInRect(x, y, game.menu_buttons.play) then
        game.menu_play_open = not game.menu_play_open
        return true
    end

    if game.menu_play_open and layout.pointInRect(x, y, game.menu_buttons.continue) then
        if game.has_save then
            save.loadRun(game, player, grid)
        end
        return true
    end

    if game.menu_play_open and layout.pointInRect(x, y, game.menu_buttons.new_game) then
        save.clear(game)
        game.menu_play_open = false
        game.shop_hidden_entries = {}
        game.shop_offers = nil
        game.current_boss = nil
        game.boss_intro = nil
        game.state = "setup"
        game.setup_step = "mayor"
        return true
    end

    if layout.pointInRect(x, y, game.menu_buttons.options) then
        game.menu_play_open = false
        game.options_open = true
        return true
    end

    if layout.pointInRect(x, y, game.menu_buttons.stats) then
        game.menu_play_open = false
        game.stats_open = true
        return true
    end

    if layout.pointInRect(x, y, game.debug_buttons.open) then
        game.menu_play_open = false
        game.debug_open = true
        return true
    end

    game.menu_play_open = false
    return true
end

function input_menu.handleSetupClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout
    local gameplay = ctx.gameplay
    local player = ctx.player
    local grid = ctx.grid
    local navigation = ctx.navigation
    local profile = ctx.profile

    if game.options_open then
        return shared.handleOptionsClick(ctx, x, y)
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
            if not profile.isMayorUnlocked(game.selected_mayor_id) then
                game.message = "Ce maire est verrouille."
                return true
            end
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
            if profile.isDifficultyUnlocked(difficultyButton.id) then
                game.selected_difficulty_id = difficultyButton.id
            else
                game.message = "Cette difficulte est verrouillee."
            end
            return true
        end
    end

    if layout.pointInRect(x, y, game.start_buttons.back) then
        game.setup_step = "mayor"
        return true
    end

    if layout.pointInRect(x, y, game.start_buttons.start) then
        if not profile.isDifficultyUnlocked(game.selected_difficulty_id) then
            game.message = "Cette difficulte est verrouillee."
            return true
        end
        profile.recordRunStarted()
        gameplay.startGame(game, player, grid)
        return true
    end

    return true
end

return input_menu
