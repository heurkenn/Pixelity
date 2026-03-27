-- src/menus/setup.lua
-- Two-step setup flow: choose a mayor, then choose a difficulty and start.

local fonts = require("src.ui.fonts")
local cards = require("src.ui.cards")
local mayor = require("src.data.mayor")

local setup = {}

-- Retourne un maire fictif masque quand un vrai maire est verrouille.
local function getLockedMayor(index)
    local previousMayor = mayor.types[index - 1]
    local previousName = previousMayor and previousMayor.name or "le maire precedent"
    return {
        id = -1,
        name = "???",
        description = "Finir une partie avec " .. previousName .. " pour debloquer.",
        portrait = nil
    }
end

-- Dessine l'ecran de selection du maire puis de la difficulte.
function setup.draw(game, getMayorById, profile)
    fonts.drawOutlinedText("Pixelity", 0, 40, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    local selectedMayor = getMayorById(game.selected_mayor_id)
    local mayorIndex = 1
    for index, item in ipairs(mayor.types) do
        if item.id == game.selected_mayor_id then
            mayorIndex = index
            break
        end
    end
    local mayorUnlocked = profile.isMayorUnlocked(game.selected_mayor_id)
    local displayedMayor = mayorUnlocked and selectedMayor or getLockedMayor(mayorIndex)

    if game.setup_step == "mayor" then
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf("Choisis ton maire", 0, 126, love.graphics.getWidth(), "center")
        cards.drawArrowButton(game.start_buttons.prev_mayor, "left")
        cards.drawArrowButton(game.start_buttons.next_mayor, "right")
        cards.drawMayorCard(game.start_buttons.mayor_card, displayedMayor, true, mayorUnlocked and game.mayor_portraits and game.mayor_portraits[selectedMayor.id] or nil)
        cards.drawPrimaryButton(game.start_buttons.next, mayorUnlocked and "Suivant" or "Verrouille")
        cards.drawSecondaryButton(game.start_buttons.back_to_menu, "Menu")
        return
    end

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf("Choisis la difficulte", 0, 126, love.graphics.getWidth(), "center")
    cards.drawMayorCard(game.start_buttons.mayor_preview, displayedMayor, true, mayorUnlocked and game.mayor_portraits and game.mayor_portraits[selectedMayor.id] or nil)

    for _, button in ipairs(game.start_buttons.difficulties) do
        local selected = game.selected_difficulty_id == button.id
        local unlocked = profile.isDifficultyUnlocked(button.id)
        if unlocked then
            love.graphics.setColor(selected and 0.24 or 0.18, selected and 0.52 or 0.22, selected and 0.78 or 0.3)
        else
            love.graphics.setColor(0.18, 0.18, 0.2, 0.9)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 12, 12)
        love.graphics.setColor(unlocked and 1 or 0.6, unlocked and 1 or 0.6, unlocked and 1 or 0.6)

        if button.id == "easy" then
            love.graphics.printf("Facile\n0 obstacle", button.x, button.y + 18, button.w, "center")
        elseif button.id == "normal" then
            love.graphics.printf("Normal\n2 obstacles", button.x, button.y + 18, button.w, "center")
        else
            love.graphics.printf("Difficile\n4 obstacles", button.x, button.y + 18, button.w, "center")
        end
    end

    cards.drawSecondaryButton(game.start_buttons.back, "Retour")
    cards.drawPrimaryButton(game.start_buttons.start, profile.isDifficultyUnlocked(game.selected_difficulty_id) and "Commencer" or "Verrouille")
end

return setup
