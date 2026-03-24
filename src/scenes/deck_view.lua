-- src/scenes/deck_view.lua
-- Shows hand, draw pile and discard in one deck inspection modal.

local layout = require("src.layout")
local cards = require("src.helpers.cards")

local deck_view = {}

function deck_view.draw(game, player)
    if not game.deck_view_open then
        return
    end

    local modal = game.deck_modal
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", modal.panel.x, modal.panel.y, modal.panel.w, modal.panel.h, 18, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Deck", modal.panel.x, modal.panel.y + 22, modal.panel.w, "center")

    local allCards = {}
    for _, card in ipairs(player.hand) do
        table.insert(allCards, { card = card, state = "hand" })
    end
    for _, card in ipairs(player.deck) do
        table.insert(allCards, { card = card, state = "deck" })
    end
    for _, card in ipairs(player.discard) do
        table.insert(allCards, { card = card, state = "discard" })
    end

    local rects = layout.distributeGridInRect(modal.grid_area, #allCards, 5, 116, 12, 12)
    for index, entry in ipairs(allCards) do
        cards.drawMiniCard(
            rects[index],
            entry.card.name,
            entry.state == "deck" and "A tirer" or (entry.state == "hand" and "Main" or "Defausse"),
            entry.state == "discard" and 0.45 or 1,
            entry.state == "hand"
        )
    end

    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.rectangle("fill", modal.close.x, modal.close.y, modal.close.w, modal.close.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("X", modal.close.x, modal.close.y + 7, modal.close.w, "center")
end

return deck_view
