-- src/menus/menu.lua
-- Main menu shown after the splash screen.

local fonts = require("src.ui.fonts")
local widgets = require("src.ui.widgets")
local debug_menu = require("src.debug.menu")

local menu = {}

-- Dessine le menu principal et ses actions disponibles.
function menu.draw(game)
    fonts.drawOutlinedText("Pixelity", 0, 112, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf("@Heurk3nnn", 0, 188, love.graphics.getWidth(), "center")

    widgets.drawButton(game.menu_buttons.play, "Jouer", "primary")
    if game.menu_play_open then
        widgets.drawButton(game.menu_buttons.continue, "Continuer", "secondary", not game.has_save)
        widgets.drawButton(game.menu_buttons.new_game, "Nouvelle partie", "secondary")
    end
    widgets.drawButton(game.menu_buttons.stats, "Stats", "secondary")
    widgets.drawButton(game.menu_buttons.options, "Options", "secondary")
    widgets.drawButton(game.debug_buttons.open, "Debug", "secondary")

    debug_menu.draw(game)
end

return menu
