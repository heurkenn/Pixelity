-- src/scenes/setup.lua
-- Two-step setup flow: choose a mayor, then choose a difficulty and start.

local fonts = require("src.helpers.fonts")
local cards = require("src.helpers.cards")

local setup = {}

function setup.draw(game, getMayorById)
    fonts.drawOutlinedText("Pixelity", 0, 40, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    local selectedMayor = getMayorById(game.selected_mayor_id)
    if game.setup_step == "mayor" then
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf("Choisis ton maire", 0, 126, love.graphics.getWidth(), "center")
        cards.drawArrowButton(game.start_buttons.prev_mayor, "left")
        cards.drawArrowButton(game.start_buttons.next_mayor, "right")
        cards.drawMayorCard(game.start_buttons.mayor_card, selectedMayor, true, game.mayor_portraits and game.mayor_portraits[selectedMayor.id] or nil)
        cards.drawPrimaryButton(game.start_buttons.next, "Suivant")
        cards.drawSecondaryButton(game.start_buttons.back_to_menu, "Menu")
        return
    end

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf("Choisis la difficulte", 0, 126, love.graphics.getWidth(), "center")
    cards.drawMayorCard(game.start_buttons.mayor_preview, selectedMayor, true, game.mayor_portraits and game.mayor_portraits[selectedMayor.id] or nil)

    for _, button in ipairs(game.start_buttons.difficulties) do
        local selected = game.selected_difficulty_id == button.id
        love.graphics.setColor(selected and 0.24 or 0.18, selected and 0.52 or 0.22, selected and 0.78 or 0.3)
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 12, 12)
        love.graphics.setColor(1, 1, 1)

        if button.id == "easy" then
            love.graphics.printf("Facile\n0 obstacle", button.x, button.y + 18, button.w, "center")
        elseif button.id == "normal" then
            love.graphics.printf("Normal\n2 obstacles", button.x, button.y + 18, button.w, "center")
        else
            love.graphics.printf("Difficile\n4 obstacles", button.x, button.y + 18, button.w, "center")
        end
    end

    cards.drawSecondaryButton(game.start_buttons.back, "Retour")
    cards.drawPrimaryButton(game.start_buttons.start, "Commencer")
end

return setup
