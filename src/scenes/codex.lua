-- src/scenes/codex.lua
-- Displays mayor info and the player's law collection in a binder-like modal.

local cards = require("src.helpers.cards")

local codex = {}

-- Dessine la modal du classeur avec maire, lois et revente.
function codex.draw(game, player)
    if not game.codex_open then
        return
    end

    local modal = game.codex_modal
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", modal.panel.x, modal.panel.y, modal.panel.w, modal.panel.h, 18, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Classeur", modal.panel.x, modal.panel.y + 22, modal.panel.w, "center")

    if player.mayor then
        love.graphics.printf(player.mayor.name, modal.panel.x + 28, modal.panel.y + 74, modal.panel.w - 56, "left")
        love.graphics.printf(player.mayor.description, modal.panel.x + 28, modal.panel.y + 102, modal.panel.w - 56, "left")
    end

    for index, lawData in ipairs(player.laws) do
        local rect = modal.law_cards[index]
        if rect then
            local title = lawData.name
            cards.drawMiniCard(rect, title, nil, 1, game.selected_codex_law_index == index)
        end
    end

    if game.selected_codex_law_index and player.laws[game.selected_codex_law_index] then
        local lawData = player.laws[game.selected_codex_law_index]
        local rect = modal.focus_card
        love.graphics.setColor(0.2, 0.24, 0.3)
        love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 16, 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(lawData.name, rect.x, rect.y + 18, rect.w, "center")
        love.graphics.printf(lawData.description or "", rect.x + 22, rect.y + 48, rect.w - 44, "center")

        local refund = math.floor((lawData.price or 0) / 2)
        love.graphics.setColor(0.5, 0.24, 0.2)
        love.graphics.rectangle("fill", modal.sell_button.x, modal.sell_button.y, modal.sell_button.w, modal.sell_button.h, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("VENDRE (" .. refund .. "p)", modal.sell_button.x, modal.sell_button.y + 8, modal.sell_button.w, "center")
    end

    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", modal.close.x, modal.close.y, modal.close.w, modal.close.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("X", modal.close.x, modal.close.y + 7, modal.close.w, "center")
end

return codex
