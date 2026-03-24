-- src/scenes/confirm_build.lua
-- Blocking confirmation modal for BUILD with no new placements.

local confirm_build = {}

function confirm_build.draw(game)
    if not game.confirm_empty_build_open then
        return
    end

    local modal = game.confirm_modal
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", modal.panel.x, modal.panel.y, modal.panel.w, modal.panel.h, 16, 16)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Faire BUILD sans nouvelle carte ?", modal.panel.x, modal.panel.y + 28, modal.panel.w, "center")
    love.graphics.printf("Le score sera recalcule sur la grille actuelle.", modal.panel.x, modal.panel.y + 60, modal.panel.w, "center")

    love.graphics.setColor(0.18, 0.5, 0.3)
    love.graphics.rectangle("fill", modal.yes.x, modal.yes.y, modal.yes.w, modal.yes.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Confirmer", modal.yes.x, modal.yes.y + 14, modal.yes.w, "center")

    love.graphics.setColor(0.32, 0.2, 0.2)
    love.graphics.rectangle("fill", modal.no.x, modal.no.y, modal.no.w, modal.no.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Annuler", modal.no.x, modal.no.y + 14, modal.no.w, "center")
end

return confirm_build
