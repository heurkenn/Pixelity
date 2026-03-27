-- src/overlays/codex.lua
-- Displays mayor info and the player's law collection in a binder-like modal.

local cards = require("src.ui.cards")
local widgets = require("src.ui.widgets")

local codex = {}

-- Dessine la modal du classeur avec maire, lois et revente.
function codex.draw(game, player)
    if not game.codex_open then
        return
    end

    local codexPopup = game.codex_modal
    widgets.drawOverlay()
    widgets.drawPopupFrame(codexPopup.panel, "Classeur")

    if player.mayor then
        love.graphics.printf(player.mayor.name, codexPopup.panel.x + 28, codexPopup.panel.y + 74, codexPopup.panel.w - 56, "left")
        love.graphics.printf(player.mayor.description, codexPopup.panel.x + 28, codexPopup.panel.y + 102, codexPopup.panel.w - 56, "left")
    end

    for index, lawData in ipairs(player.laws) do
        local lawCardRect = codexPopup.law_cards[index]
        if lawCardRect then
            local title = lawData.name
            cards.drawMiniCard(lawCardRect, title, nil, 1, game.selected_codex_law_index == index)
        end
    end

    if game.selected_codex_law_index and player.laws[game.selected_codex_law_index] then
        local lawData = player.laws[game.selected_codex_law_index]
        local focusedLawCard = codexPopup.focus_card
        love.graphics.setColor(0.2, 0.24, 0.3)
        love.graphics.rectangle("fill", focusedLawCard.x, focusedLawCard.y, focusedLawCard.w, focusedLawCard.h, 16, 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(lawData.name, focusedLawCard.x, focusedLawCard.y + 18, focusedLawCard.w, "center")
        love.graphics.printf(lawData.description or "", focusedLawCard.x + 22, focusedLawCard.y + 48, focusedLawCard.w - 44, "center")

        local refund = math.floor((lawData.price or 0) / 2)
        widgets.drawButton(codexPopup.sell_button, "VENDRE (" .. refund .. "p)", "danger")
    end

    widgets.drawCloseButton(codexPopup.close)
end

return codex
