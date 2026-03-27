-- src/overlays/deck_view.lua
-- Shows hand, draw pile and discard in one deck inspection modal.

local layout = require("src.ui.layout")
local cards = require("src.ui.cards")
local widgets = require("src.ui.widgets")

local deck_view = {}

-- Regroupe les cartes par etat pour rendre le deck plus lisible.
local function collectSections(player)
    local sections = {
        { title = "Main", subtitle = "Entouree en rouge", cards = player.hand, state = "hand", alpha = 1, highlight = true },
        { title = "Deck", subtitle = "Encore a tirer", cards = player.deck, state = "deck", alpha = 1, highlight = false },
        { title = "Defausse", subtitle = "Cartes deja jouees", cards = player.discard, state = "discard", alpha = 0.42, highlight = false }
    }
    return sections
end

-- Dessine la vue detaillee de la main, du deck et de la defausse.
function deck_view.draw(game, player)
    if not game.deck_view_open then
        return
    end

    local deckPopup = game.deck_modal
    widgets.drawOverlay()
    widgets.drawPopupFrame(deckPopup.panel, "Etat du deck")

    local sections = collectSections(player)
    local sectionArea = {
        x = deckPopup.panel.x + 26,
        y = deckPopup.panel.y + 82,
        w = deckPopup.panel.w - 52,
        h = deckPopup.panel.h - 112
    }
    local sectionHeight = 114
    local sectionGap = 18

    for index, section in ipairs(sections) do
        local sectionY = sectionArea.y + ((index - 1) * (sectionHeight + sectionGap))
        local sectionRect = {
            x = sectionArea.x,
            y = sectionY,
            w = sectionArea.w,
            h = sectionHeight
        }
        local cardCount = math.max(#section.cards, 1)
        local cardWidth = math.min(104, math.floor((sectionRect.w - 196 - ((cardCount - 1) * 10)) / cardCount))
        local cardHeight = 92
        local cardsArea = {
            x = sectionRect.x + 180,
            y = sectionRect.y + 12,
            w = sectionRect.w - 194,
            h = sectionRect.h - 24
        }

        love.graphics.setColor(0.18, 0.22, 0.28)
        love.graphics.rectangle("fill", sectionRect.x, sectionRect.y, sectionRect.w, sectionRect.h, 16, 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(section.title, sectionRect.x + 18, sectionRect.y + 18, 150, "left")
        love.graphics.printf(section.subtitle, sectionRect.x + 18, sectionRect.y + 48, 150, "left")
        love.graphics.printf(tostring(#section.cards) .. " carte(s)", sectionRect.x + 18, sectionRect.y + 76, 150, "left")

        local rects = layout.distributeRowInRect(cardsArea, cardCount, cardWidth, cardHeight, 10)
        if #section.cards == 0 then
            love.graphics.setColor(0.55, 0.58, 0.62)
            love.graphics.printf("Aucune carte", cardsArea.x, cardsArea.y + 28, cardsArea.w, "center")
        else
            for cardIndex, card in ipairs(section.cards) do
                cards.drawMiniCard(
                    rects[cardIndex],
                    card.name,
                    nil,
                    section.alpha,
                    section.highlight
                )
            end
        end
    end

    widgets.drawCloseButton(deckPopup.close)
end

return deck_view
