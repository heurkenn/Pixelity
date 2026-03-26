-- src/scenes/menu.lua
-- Main menu shown after the splash screen.

local fonts = require("src.helpers.fonts")
local cards = require("src.helpers.cards")
local debug_menu = require("src.scenes.debug_menu")

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

    cards.drawPrimaryButton(game.menu_buttons.play, "Jouer")
    if game.menu_play_open then
        cards.drawSecondaryButtonState(game.menu_buttons.continue, "Continuer", not game.has_save)
        cards.drawSecondaryButton(game.menu_buttons.new_game, "Nouvelle partie")
    end
    cards.drawSecondaryButton(game.menu_buttons.stats, "Stats")
    cards.drawSecondaryButton(game.menu_buttons.options, "Options")
    cards.drawSecondaryButton(game.debug_buttons.open, "Debug")

    debug_menu.draw(game)
end

return menu
