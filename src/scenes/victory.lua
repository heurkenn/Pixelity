-- src/scenes/victory.lua
-- Run victory screen shown after the player clears round 15.

local fonts = require("src.helpers.fonts")

local victory = {}

-- Dessine le resume final d'une run gagnee avant le retour au menu.
function victory.draw(game, player)
    local summary = game.victory_summary or {}

    love.graphics.setColor(0, 0, 0, 0.72)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    fonts.drawOutlinedText("Victoire", 0, 72, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    local panel = {
        x = (love.graphics.getWidth() - 520) / 2,
        y = 178,
        w = 520,
        h = 320
    }

    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 18, 18)

    local y = panel.y + 34
    local lineHeight = 34

    local function drawLine(label, value)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(label, panel.x + 28, y, 210, "left")
        love.graphics.printf(tostring(value), panel.x + 238, y, panel.w - 266, "right")
        y = y + lineHeight
    end

    drawLine("Maire", summary.mayor_name or "-")
    drawLine("Difficulte", summary.difficulty_name or "-")
    drawLine("Manches jouees", summary.rounds_played or 0)
    drawLine("Score global", player.total_score or 0)
    drawLine("Pieces restantes", player.money or 0)

    if summary.unlock_message then
        love.graphics.setColor(1, 0.9, 0.55)
        love.graphics.printf(summary.unlock_message, panel.x + 28, panel.y + panel.h - 92, panel.w - 56, "center")
    end

    love.graphics.setColor(0.18, 0.44, 0.3)
    love.graphics.rectangle("fill", panel.x + 150, panel.y + panel.h - 54, 220, 42, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("MENU PRINCIPAL", panel.x + 150, panel.y + panel.h - 41, 220, "center")
end

return victory
