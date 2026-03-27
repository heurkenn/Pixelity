-- src/debug/menu.lua
-- Debug overlay that jumps directly to representative UI/gameplay states.

local widgets = require("src.ui.widgets")

local debug_menu = {}

-- Retourne le texte a afficher pour chaque bouton du menu debug.
local function getLabel(buttonId)
    if buttonId == "play" then
        return "Lancer une partie test"
    elseif buttonId == "summary" then
        return "Apercu resume de manche"
    elseif buttonId == "shop" then
        return "Apercu direct du shop"
    elseif buttonId == "victory" then
        return "Ecran de victoire"
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

-- Dessine le panneau debug et sa liste scrollable de scenarios de test.
function debug_menu.draw(game)
    if not game.debug_open then
        return
    end

    local debugMenuPanel = game.debug_panel
    widgets.drawOverlay(0.6)
    widgets.drawPopupFrame(debugMenuPanel, "Debug Menu")
    love.graphics.printf(
        "Raccourcis pour tester les ecrans sans jouer une manche complete.",
        debugMenuPanel.x + 28,
        debugMenuPanel.y + 56,
        debugMenuPanel.w - 56,
        "center"
    )

    if game.debug_scroll_max and game.debug_scroll_max > 0 then
        love.graphics.printf("Molette souris pour defiler", debugMenuPanel.x + 28, debugMenuPanel.y + debugMenuPanel.h - 42, debugMenuPanel.w - 56, "center")
    end

    love.graphics.setScissor(game.debug_content_area.x, game.debug_content_area.y, game.debug_content_area.w, game.debug_content_area.h)
    for _, button in ipairs(game.debug_buttons.scenarios or {}) do
        if button.y + button.h >= game.debug_content_area.y and button.y <= game.debug_content_area.y + game.debug_content_area.h then
            widgets.drawButton(button, getLabel(button.id), "warning")
        end
    end
    love.graphics.setScissor()

    widgets.drawCloseButton(game.debug_buttons.close)
end

return debug_menu
