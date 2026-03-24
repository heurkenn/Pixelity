-- src/scenes/menu.lua
-- Main menu shown after the splash screen.

local fonts = require("src.helpers.fonts")
local cards = require("src.helpers.cards")
local debug_menu = require("src.scenes.debug_menu")

local menu = {}

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
    cards.drawSecondaryButton(game.menu_buttons.options, "Options")
    cards.drawSecondaryButton(game.debug_buttons.open, "Debug")

    debug_menu.draw(game)
end

return menu
