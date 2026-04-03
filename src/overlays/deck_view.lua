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

-- Resume une pile de cartes en quantites par type pour les affichages compacts.
local function summarizeCards(cardsList)
    local countsById = {}
    local orderedRows = {}

    for _, card in ipairs(cardsList or {}) do
        if not countsById[card.id] then
            countsById[card.id] = {
                label = card.name,
                value = 0
            }
            table.insert(orderedRows, countsById[card.id])
        end
        countsById[card.id].value = countsById[card.id].value + 1
    end

    return orderedRows
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

        if section.state == "deck" or section.state == "discard" then
            local summaryRows = summarizeCards(section.cards)
            if #summaryRows == 0 then
                love.graphics.setColor(0.55, 0.58, 0.62)
                love.graphics.printf("Aucune carte", cardsArea.x, cardsArea.y + 28, cardsArea.w, "center")
            else
                widgets.drawKeyValueList(summaryRows, cardsArea.x + 8, cardsArea.y + 8, cardsArea.w - 16, 18)
            end
        else
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
    end

    widgets.drawCloseButton(deckPopup.close)
end

return deck_view
