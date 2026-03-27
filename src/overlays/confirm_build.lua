-- src/overlays/confirm_build.lua
-- Blocking confirmation modal for BUILD with no new placements.

local confirm_build = {}
local widgets = require("src.ui.widgets")

-- Dessine la confirmation pour un BUILD sans nouveau placement.
function confirm_build.draw(game)
    if not game.confirm_empty_build_open then
        return
    end

    local confirmPopup = game.confirm_modal
    widgets.drawOverlay(0.45)
    widgets.drawPopupFrame(confirmPopup.panel)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Faire BUILD sans nouvelle carte ?", confirmPopup.panel.x, confirmPopup.panel.y + 28, confirmPopup.panel.w, "center")
    love.graphics.printf("Le score sera recalcule sur la grille actuelle.", confirmPopup.panel.x, confirmPopup.panel.y + 60, confirmPopup.panel.w, "center")

    widgets.drawButton(confirmPopup.yes, "Confirmer", "primary")
    widgets.drawButton(confirmPopup.no, "Annuler", "danger")
end

return confirm_build
