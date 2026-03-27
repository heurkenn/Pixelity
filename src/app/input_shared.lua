-- src/app/input_shared.lua
-- Shared input helpers reused by multiple app states.

local shared = {}

-- Gere les clics communs de la popup options, y compris l'affichage video.
function shared.handleOptionsClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout

    if layout.pointInRect(x, y, game.options_modal.close) or not layout.pointInRect(x, y, game.options_modal.panel) then
        game.options_open = false
        return true
    end

    for _, speedButton in ipairs(game.speed_buttons) do
        if layout.pointInRect(x, y, speedButton) then
            game.scoring_speed = speedButton.multiplier
            game.message = "Vitesse du scoring: x" .. speedButton.multiplier
            return true
        end
    end

    for _, videoButton in ipairs(game.video_mode_buttons or {}) do
        if layout.pointInRect(x, y, videoButton) then
            if videoButton.id == "windowed" then
                ctx.video.setWindowed(game)
                game.message = "Affichage: fenetre"
            elseif videoButton.id == "fullscreen" then
                ctx.video.setFullscreen(game)
                game.message = "Affichage: plein ecran"
            elseif videoButton.id == "borderless" then
                ctx.video.setBorderlessFullscreen(game)
                game.message = "Affichage: plein ecran fenetre"
            end
            return true
        end
    end

    if layout.pointInRect(x, y, game.confirm_toggle_button) then
        game.confirm_empty_build_enabled = not game.confirm_empty_build_enabled
        return true
    end

    if layout.pointInRect(x, y, game.options_back_to_menu_button) then
        game.options_open = false
        if game.state == "playing" then
            ctx.save.saveRun(game, ctx.player, ctx.grid)
        end
        ctx.navigation.openMenu(game)
        return true
    end

    return true
end

return shared
