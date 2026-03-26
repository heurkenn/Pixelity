-- src/scenes/stats.lua
-- Centered profile-stats modal shown from the main menu.

local stats_scene = {}

-- Dessine une ligne cle/valeur dans la fenetre de statistiques.
local function drawLine(label, value, x, y, w)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(label, x, y, w * 0.62, "left")
    love.graphics.printf(tostring(value), x + (w * 0.62), y, w * 0.38, "right")
end

-- Dessine la modal des statistiques globales du profil.
function stats_scene.draw(game, profile)
    if not game.stats_open then
        return
    end

    local modal = game.stats_modal
    local stats = profile.getData().stats

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", modal.panel.x, modal.panel.y, modal.panel.w, modal.panel.h, 18, 18)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Stats", modal.panel.x, modal.panel.y + 24, modal.panel.w, "center")

    local y = modal.lines.y
    drawLine("Parties lancees", stats.games_started, modal.lines.x, y, modal.lines.w)
    y = y + 34
    drawLine("Batiments poses", stats.buildings_placed, modal.lines.x, y, modal.lines.w)
    y = y + 34
    drawLine("Pieces depensees", stats.money_spent, modal.lines.x, y, modal.lines.w)
    y = y + 34
    drawLine("Obstacles detruits", stats.obstacles_destroyed, modal.lines.x, y, modal.lines.w)
    y = y + 34
    drawLine("Parties gagnees", stats.games_won, modal.lines.x, y, modal.lines.w)
    y = y + 34
    drawLine("Meilleur score global", stats.best_global_score, modal.lines.x, y, modal.lines.w)

    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", modal.close.x, modal.close.y, modal.close.w, modal.close.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("X", modal.close.x, modal.close.y + 7, modal.close.w, "center")
end

return stats_scene
