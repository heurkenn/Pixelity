-- src/scenes/options.lua
-- Centered options modal for gameplay toggles and scoring speed.

local options = {}

-- Dessine la modal d'options accessible depuis le menu ou la partie.
function options.draw(game)
    if not game.options_open then
        return
    end

    local modal = game.options_modal
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", modal.panel.x, modal.panel.y, modal.panel.w, modal.panel.h, 18, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Options", modal.panel.x, modal.panel.y + 24, modal.panel.w, "center")
    love.graphics.printf("Vitesse du scoring", modal.panel.x, modal.panel.y + 65, modal.panel.w, "center")

    for _, speedButton in ipairs(game.speed_buttons) do
        local selected = game.scoring_speed == speedButton.multiplier
        love.graphics.setColor(selected and 0.82 or 0.24, selected and 0.64 or 0.3, selected and 0.26 or 0.36)
        love.graphics.rectangle("fill", speedButton.x, speedButton.y, speedButton.w, speedButton.h, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("x" .. speedButton.multiplier, speedButton.x, speedButton.y + 8, speedButton.w, "center")
    end

    love.graphics.setColor(game.confirm_empty_build_enabled and 0.24 or 0.14, game.confirm_empty_build_enabled and 0.52 or 0.24, 0.3)
    love.graphics.rectangle("fill", game.confirm_toggle_button.x, game.confirm_toggle_button.y, game.confirm_toggle_button.w, game.confirm_toggle_button.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "Confirm BUILD vide: " .. (game.confirm_empty_build_enabled and "ON" or "OFF"),
        game.confirm_toggle_button.x,
        game.confirm_toggle_button.y + 16,
        game.confirm_toggle_button.w,
        "center"
    )

    love.graphics.setColor(0.52, 0.2, 0.2)
    love.graphics.rectangle(
        "fill",
        game.options_back_to_menu_button.x,
        game.options_back_to_menu_button.y,
        game.options_back_to_menu_button.w,
        game.options_back_to_menu_button.h,
        10,
        10
    )
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "MENU PRINCIPAL",
        game.options_back_to_menu_button.x,
        game.options_back_to_menu_button.y + 14,
        game.options_back_to_menu_button.w,
        "center"
    )

    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", modal.close.x, modal.close.y, modal.close.w, modal.close.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("X", modal.close.x, modal.close.y + 7, modal.close.w, "center")
end

return options
