-- src/menus/victory.lua
-- Run victory screen shown after the player clears round 15.

local fonts = require("src.ui.fonts")
local layout = require("src.ui.layout")
local widgets = require("src.ui.widgets")

local victory = {}

-- Dessine le resume final d'une run gagnee avant le retour au menu.
function victory.draw(game, player)
    local summary = game.victory_summary or {}
    local victorySummaryPanel = layout.getCenteredPopup(520, 320)
    victorySummaryPanel.y = 178

    widgets.drawOverlay(0.72)

    fonts.drawOutlinedText("Victoire", 0, 72, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    widgets.drawPopupFrame(victorySummaryPanel)
    widgets.drawKeyValueList({
        { label = "Maire", value = summary.mayor_name or "-" },
        { label = "Difficulte", value = summary.difficulty_name or "-" },
        { label = "Manches jouees", value = summary.rounds_played or 0 },
        { label = "Score global", value = player.total_score or 0 },
        { label = "Pieces restantes", value = player.money or 0 }
    }, victorySummaryPanel.x + 28, victorySummaryPanel.y + 34, victorySummaryPanel.w - 56, 34)

    if summary.unlock_message then
        love.graphics.setColor(1, 0.9, 0.55)
        love.graphics.printf(summary.unlock_message, victorySummaryPanel.x + 28, victorySummaryPanel.y + victorySummaryPanel.h - 92, victorySummaryPanel.w - 56, "center")
    end

    widgets.drawButton(layout.getBottomCenteredButton(victorySummaryPanel, 220, 42, 12), "MENU PRINCIPAL", "primary")
end

return victory
