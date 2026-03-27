-- src/overlays/options.lua
-- Centered options modal for gameplay toggles and scoring speed.

local widgets = require("src.ui.widgets")

local options = {}

-- Dessine la modal d'options accessible depuis le menu ou la partie.
function options.draw(game)
    if not game.options_open then
        return
    end

    local optionsPopup = game.options_modal
    widgets.drawOverlay()
    widgets.drawPopupFrame(optionsPopup.panel, "Options")
    love.graphics.printf("Vitesse du scoring", optionsPopup.panel.x, optionsPopup.panel.y + 65, optionsPopup.panel.w, "center")

    for _, speedButton in ipairs(game.speed_buttons) do
        local selected = game.scoring_speed == speedButton.multiplier
        widgets.drawButton(speedButton, "x" .. speedButton.multiplier, selected and "selected" or "secondary")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Affichage", optionsPopup.panel.x, optionsPopup.panel.y + 172, optionsPopup.panel.w, "center")
    for _, videoButton in ipairs(game.video_mode_buttons or {}) do
        local selected = game.video_mode == videoButton.id
        widgets.drawButton(videoButton, videoButton.label, selected and "selected" or "secondary")
    end

    widgets.drawButton(
        game.confirm_toggle_button,
        "Confirm BUILD vide: " .. (game.confirm_empty_build_enabled and "ON" or "OFF"),
        game.confirm_empty_build_enabled and "secondary" or "disabled"
    )
    widgets.drawButton(game.options_reset_data_button, "SUPPRIMER TOUTES LES DONNEES", "danger")
    if game.options_reset_confirm_open then
        widgets.drawButton(game.options_reset_confirm_button, "CONFIRMER LA SUPPRESSION", "danger")
    end
    widgets.drawButton(game.options_back_to_menu_button, "MENU PRINCIPAL", "danger")
    widgets.drawCloseButton(optionsPopup.close)
end

return options
