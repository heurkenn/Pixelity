-- src/scenes/debug_menu.lua
-- Debug overlay that jumps directly to representative UI/gameplay states.

local debug_menu = {}

local function getLabel(buttonId)
    if buttonId == "play" then
        return "Lancer une partie test"
    elseif buttonId == "summary" then
        return "Apercu resume de manche"
    elseif buttonId == "shop" then
        return "Apercu direct du shop"
    elseif buttonId == "options" then
        return "Popup options"
    elseif buttonId == "codex" then
        return "Popup classeur"
    elseif buttonId == "deck" then
        return "Popup deck"
    elseif buttonId == "boss_intro" then
        return "Intro boss"
    elseif buttonId == "boss_earthquake" then
        return "Boss Earthquake"
    elseif buttonId == "boss_tsunami" then
        return "Boss Tsunami"
    elseif buttonId == "boss_lactose" then
        return "Boss Lactose dog"
    elseif buttonId == "boss_dark" then
        return "Boss In the dark"
    elseif buttonId == "boss_renovation" then
        return "Boss Renovation"
    end
    return buttonId
end

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

    if game.debug_scroll_max and game.debug_scroll_max > 0 then
        love.graphics.printf("Molette souris pour defiler", panel.x + 28, panel.y + panel.h - 42, panel.w - 56, "center")
    end

    love.graphics.setScissor(game.debug_content_area.x, game.debug_content_area.y, game.debug_content_area.w, game.debug_content_area.h)
    for _, button in ipairs(game.debug_buttons.scenarios or {}) do
        if button.y + button.h >= game.debug_content_area.y and button.y <= game.debug_content_area.y + game.debug_content_area.h then
            love.graphics.setColor(0.22, 0.32, 0.42)
            love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 12, 12)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(getLabel(button.id), button.x, button.y + 18, button.w, "center")
        end
    end
    love.graphics.setScissor()

    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", game.debug_buttons.close.x, game.debug_buttons.close.y, game.debug_buttons.close.w, game.debug_buttons.close.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("X", game.debug_buttons.close.x, game.debug_buttons.close.y + 8, game.debug_buttons.close.w, "center")
end

return debug_menu
