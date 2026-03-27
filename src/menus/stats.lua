-- src/menus/stats.lua
-- Centered profile-stats modal shown from the main menu.

local stats_scene = {}
local widgets = require("src.ui.widgets")

-- Dessine la modal des statistiques globales du profil.
function stats_scene.draw(game, profile)
    if not game.stats_open then
        return
    end

    local statsPopup = game.stats_modal
    local stats = profile.getData().stats

    widgets.drawOverlay()
    widgets.drawPopupFrame(statsPopup.panel, "Stats")
    widgets.drawKeyValueList({
        { label = "Parties lancees", value = stats.games_started },
        { label = "Batiments poses", value = stats.buildings_placed },
        { label = "Pieces depensees", value = stats.money_spent },
        { label = "Obstacles detruits", value = stats.obstacles_destroyed },
        { label = "Parties gagnees", value = stats.games_won },
        { label = "Meilleur score global", value = stats.best_global_score }
    }, statsPopup.lines.x, statsPopup.lines.y, statsPopup.lines.w, 34)
    widgets.drawCloseButton(statsPopup.close)
end

return stats_scene
