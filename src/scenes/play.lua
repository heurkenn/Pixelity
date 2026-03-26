-- src/scenes/play.lua
-- Draws the active gameplay scene: board, hand, HUD and transient score feedback.

local constants = require("src.constants")
local layout = require("src.layout")
local fonts = require("src.helpers.fonts")
local cards = require("src.helpers.cards")
local board = require("src.helpers.board")

local play = {}

-- Indique si la main doit etre cachee par le boss courant.
local function shouldHideHand(player)
    for _, effect in ipairs(player.current_boss and player.current_boss.effects or {}) do
        if effect.type == "hide_hand_cards" then
            return true
        end
    end
    return false
end

-- Indique si les tuiles posees doivent aussi etre masquees sur la grille.
local function shouldHideBoard(game)
    return shouldHideHand({ current_boss = game.current_boss })
end

-- Dessine la grille, ses batiments, les placements temporaires et les alertes boss.
function play.drawGrid(game, grid, buildings, getPendingPlacementAt)
    local cells = grid.getCells()
    local offsetX, offsetY = layout.getGridOffset()
    local hidden = shouldHideBoard(game)

    for y = 1, constants.GRID_SIZE do
        for x = 1, constants.GRID_SIZE do
            local posX = offsetX + (x - 1) * constants.TILE_SIZE
            local posY = offsetY + (y - 1) * constants.TILE_SIZE
            local pendingPlacement = getPendingPlacementAt(x, y)

            love.graphics.setColor(0.22, 0.25, 0.29)
            love.graphics.rectangle("fill", posX, posY, constants.TILE_SIZE, constants.TILE_SIZE)
            love.graphics.setColor(0.42, 0.45, 0.5)
            love.graphics.rectangle("line", posX, posY, constants.TILE_SIZE, constants.TILE_SIZE)

            if game.highlight_cell and game.highlight_cell.x == x and game.highlight_cell.y == y then
                love.graphics.setColor(0.95, 0.78, 0.28, 0.35)
                love.graphics.rectangle("fill", posX, posY, constants.TILE_SIZE, constants.TILE_SIZE)
            end

            local buildingID = cells[y][x]
            if buildingID ~= 0 then
                board.drawBuildingTile(buildings, grid, buildingID, posX, posY, 1, x, y, hidden and buildingID ~= grid.getObstacleId())
            end

            if pendingPlacement then
                love.graphics.setColor(1, 1, 1, 0.2)
                love.graphics.rectangle("fill", posX, posY, constants.TILE_SIZE, constants.TILE_SIZE)
                board.drawBuildingTile(buildings, grid, pendingPlacement.card.id, posX, posY, 0.8, x, y, hidden)
            end
        end
    end

    if game.boss_effect and game.boss_effect.markers then
        for _, marker in ipairs(game.boss_effect.markers) do
            if marker.type == "cell" then
                local cellX, cellY = layout.getCellScreenPosition(marker.x, marker.y)
                love.graphics.setColor(0.95, 0.22, 0.16, 0.92)
                love.graphics.rectangle("fill", cellX + 8, cellY + 8, constants.TILE_SIZE - 16, constants.TILE_SIZE - 16, 8, 8)
                fonts.drawOutlinedText("!", cellX, cellY + 6, {
                    font = fonts.getScoreFont(),
                    mode = "printf",
                    limit = constants.TILE_SIZE,
                    align = "center",
                    outline = 1
                })
            elseif marker.type == "row" then
                local _, rowY = layout.getCellScreenPosition(1, marker.index)
                love.graphics.setColor(0.9, 0.3, 0.2, 0.9)
                love.graphics.rectangle("fill", offsetX - 36, rowY + 10, 24, constants.TILE_SIZE - 20, 6, 6)
                fonts.drawOutlinedText("!", offsetX - 34, rowY + 8, {
                    font = fonts.getScoreFont(),
                    outline = 1
                })
            elseif marker.type == "column" then
                local columnX = offsetX + ((marker.index - 1) * constants.TILE_SIZE)
                love.graphics.setColor(0.9, 0.3, 0.2, 0.9)
                love.graphics.rectangle("fill", columnX + 10, offsetY - 34, constants.TILE_SIZE - 20, 24, 6, 6)
                fonts.drawOutlinedText("!", columnX + 18, offsetY - 42, {
                    font = fonts.getScoreFont(),
                    outline = 1
                })
            end
        end
    end
end

-- Dessine la main visible ou cachee selon le boss courant.
function play.drawHand(game, player)
    local hidden = shouldHideHand(player)

    if game.dealing_timer > 0 then
        local progress = 1 - (game.dealing_timer / 0.75)
        for index, card in ipairs(player.hand) do
            local targetX, targetY = layout.getCardRect(index, #player.hand)
            local fromY = love.graphics.getHeight() + 120
            local animatedY = fromY + ((targetY - fromY) * math.min(progress * 1.15, 1))
            if hidden then
                cards.drawHiddenHandCard(targetX, animatedY, game.selected_hand_index == index)
            else
                cards.drawHandCard(card, targetX, animatedY, game.selected_hand_index == index)
            end
        end
        return
    end

    for index, card in ipairs(player.hand) do
        local cardX, cardY = layout.getCardRect(index, #player.hand)
        if not (game.dragging.active and game.dragging.hand_index == index) then
            if hidden then
                cards.drawHiddenHandCard(cardX, cardY, game.selected_hand_index == index)
            else
                cards.drawHandCard(card, cardX, cardY, game.selected_hand_index == index)
            end
        end
    end

    if game.dragging.active and game.dragging.card then
        if hidden then
            cards.drawHiddenHandCard(
                game.dragging.x - game.dragging.offset_x,
                game.dragging.y - game.dragging.offset_y,
                true,
                0.92
            )
        else
            cards.drawHandCard(
                game.dragging.card,
                game.dragging.x - game.dragging.offset_x,
                game.dragging.y - game.dragging.offset_y,
                true,
                0.92
            )
        end
    end
end

-- Dessine l'animation de popup qui transporte les points vers le score.
function play.drawScorePopup(game)
    if not game.current_score_popup then
        return
    end

    local popup = game.current_score_popup
    local eased = 1 - ((1 - popup.t) * (1 - popup.t))
    local currentX = popup.start_x + ((popup.end_x - popup.start_x) * eased)
    local currentY = popup.start_y + ((popup.end_y - popup.start_y) * eased)
    local alpha = 1 - (popup.t * 0.15)

    love.graphics.setColor(1, 0.95, 0.6, alpha)
    love.graphics.print("+" .. popup.points, popup.start_x, popup.start_y)

    love.graphics.setColor(1, 0.9, 0.4, alpha)
    love.graphics.print("+" .. popup.points, currentX, currentY)
end

-- Dessine le HUD principal pendant la manche.
function play.drawHUD(game, player)
    local scoreX, scoreY = 18, 94
    local scoreText = tostring(game.current_resolution_score)
    local titleText = game.current_boss and game.current_boss.name or ("Manche " .. tostring(game.round))

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(titleText, 0, 18, love.graphics.getWidth(), "center")
    if game.current_boss then
        love.graphics.printf("Manche " .. tostring(game.round), 0, 42, love.graphics.getWidth(), "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Objectif", 20, 18)
    fonts.drawOutlinedText(tostring(game.target_score), 18, 28, {
        font = fonts.getScoreFont(),
        mode = "printf",
        limit = 124,
        align = "left",
        outline = 1
    })

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score", 20, 84)
    fonts.drawOutlinedText(scoreText, math.floor(scoreX - 2), math.floor(scoreY), {
        font = fonts.getScoreFont(),
        mode = "printf",
        limit = 124,
        align = "left",
        outline = 1
    })

    if game.current_score_popup then
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.print("+" .. game.current_score_popup.points, scoreX + 78, scoreY + 10)
    end

    love.graphics.setColor(0.24, 0.26, 0.34)
    love.graphics.rectangle("fill", game.options_button.x, game.options_button.y, game.options_button.w, game.options_button.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("OPTIONS", game.options_button.x, game.options_button.y + 12, game.options_button.w, "center")

    love.graphics.setColor(0.18, 0.44, 0.3)
    love.graphics.rectangle("fill", game.build_button.x, game.build_button.y, game.build_button.w, game.build_button.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("BUILD", game.build_button.x, game.build_button.y + 18, game.build_button.w, "center")

    love.graphics.setColor(player.hand_can_redraw and player.available_redraws > 0 and #player.hand > 0 and 0.22 or 0.14, 0.3, 0.42)
    love.graphics.rectangle("fill", game.redraw_button.x, game.redraw_button.y, game.redraw_button.w, game.redraw_button.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("REDRAW MAIN", game.redraw_button.x, game.redraw_button.y + 16, game.redraw_button.w, "center")

    if game.highlight_cell and game.highlight_cell.x and game.highlight_cell.y and game.highlight_cell.points then
        local cellX, cellY = layout.getCellScreenPosition(game.highlight_cell.x, game.highlight_cell.y)
        love.graphics.setColor(1, 0.95, 0.6)
        love.graphics.print("+" .. game.highlight_cell.points, cellX + constants.TILE_SIZE + 6, cellY + 12)
    end

    if player.deck_empty and #player.deck == 0 then
        love.graphics.setColor(1, 0.82, 0.48)
        love.graphics.printf("Deck vide", 0, love.graphics.getHeight() - 220, love.graphics.getWidth(), "center")
    end

    if game.highlight_cell and game.highlight_cell.label then
        love.graphics.setColor(1, 0.95, 0.6)
        love.graphics.printf(game.highlight_cell.label, 0, 104, love.graphics.getWidth(), "center")
    end

    for index, item in ipairs(player.items) do
        cards.drawInventoryCard(game.item_slots[index], item.name, "Obstacle", game.selected_item_index == index)
    end

    love.graphics.setColor(0.22, 0.26, 0.3)
    love.graphics.rectangle("fill", game.bottom_left_buttons.codex.x, game.bottom_left_buttons.codex.y, game.bottom_left_buttons.codex.w, game.bottom_left_buttons.codex.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("CLASSEUR", game.bottom_left_buttons.codex.x + 6, game.bottom_left_buttons.codex.y + 24, game.bottom_left_buttons.codex.w - 12, "center")

    love.graphics.setColor(0.22, 0.26, 0.3)
    love.graphics.rectangle("fill", game.bottom_left_buttons.deck.x, game.bottom_left_buttons.deck.y, game.bottom_left_buttons.deck.w, game.bottom_left_buttons.deck.h, 12, 12)
    fonts.drawOutlinedText(tostring(#player.deck), game.bottom_left_buttons.deck.x, game.bottom_left_buttons.deck.y + 8, {
        font = fonts.getScoreFont(),
        mode = "printf",
        limit = game.bottom_left_buttons.deck.w,
        align = "center",
        outline = 1
    })

    love.graphics.setColor(0.22, 0.26, 0.3)
    love.graphics.rectangle("fill", game.bottom_left_buttons.deck.x + 106, game.bottom_left_buttons.deck.y, 120, game.bottom_left_buttons.deck.h, 12, 12)
    fonts.drawOutlinedText(tostring(player.money), game.bottom_left_buttons.deck.x + 106, game.bottom_left_buttons.deck.y + 8, {
        font = fonts.getScoreFont(),
        mode = "printf",
        limit = 120,
        align = "center",
        outline = 1
    })
end

return play
