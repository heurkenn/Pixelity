-- src/scenes/debug_menu.lua
-- Debug overlay that jumps directly to representative UI/gameplay states.

local debug_menu = {}

function debug_menu.draw(game)
    if not game.debug_open then
        return
    end

    local panel = game.debug_panel
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 18, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Debug Menu", panel.x, panel.y + 24, panel.w, "center")
    love.graphics.printf(
        "Raccourcis pour tester les ecrans sans jouer une manche complete.",
        panel.x + 28,
        panel.y + 56,
        panel.w - 56,
        "center"
    )

    for _, button in ipairs(game.debug_buttons.scenarios or {}) do
        love.graphics.setColor(0.22, 0.32, 0.42)
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 12, 12)
        love.graphics.setColor(1, 1, 1)

        if button.id == "play" then
            love.graphics.printf("Lancer une partie test", button.x, button.y + 18, button.w, "center")
        elseif button.id == "summary" then
            love.graphics.printf("Apercu resume de manche", button.x, button.y + 18, button.w, "center")
        elseif button.id == "shop" then
            love.graphics.printf("Apercu direct du shop", button.x, button.y + 18, button.w, "center")
        elseif button.id == "options" then
            love.graphics.printf("Popup options", button.x, button.y + 18, button.w, "center")
        elseif button.id == "codex" then
            love.graphics.printf("Popup classeur", button.x, button.y + 18, button.w, "center")
        elseif button.id == "deck" then
            love.graphics.printf("Popup deck", button.x, button.y + 18, button.w, "center")
        end
    end

    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", game.debug_buttons.close.x, game.debug_buttons.close.y, game.debug_buttons.close.w, game.debug_buttons.close.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("X", game.debug_buttons.close.x, game.debug_buttons.close.y + 8, game.debug_buttons.close.w, "center")
end

return debug_menu
