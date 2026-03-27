-- src/game/play.lua
-- Draws the active gameplay scene: board, hand, HUD and transient score feedback.

local constants = require("src.constants")
local layout = require("src.ui.layout")
local fonts = require("src.ui.fonts")
local cards = require("src.ui.cards")
local board = require("src.ui.board")
local theme = require("src.ui.theme")
local widgets = require("src.ui.widgets")

local play = {}

-- Dessine un cadre decoratif avec guirlande animee reutilisable par d'autres ecrans.
function play.drawLightFrame(rect, horizontalCount, verticalCount, spacing, inset, frameColor, borderColor, lightColorA, lightColorB)
    local pulse = 0.55 + (0.45 * ((math.sin(love.timer.getTime() * 4) + 1) / 2))
    local lightSize = 8
    local phase = math.floor(love.timer.getTime() * 10) % 2
    horizontalCount = math.max(1, math.floor(horizontalCount or 5))
    verticalCount = math.max(1, math.floor(verticalCount or 5))
    if horizontalCount % 2 == 0 then
        horizontalCount = horizontalCount + 1
    end
    if verticalCount % 2 == 0 then
        verticalCount = verticalCount + 1
    end
    spacing = spacing or 12
    inset = inset or 8
    local colorA = lightColorA or { 0.98, 0.84, 0.18 }
    local colorB = lightColorB or { 0.76, 0.18, 0.18 }

    local function drawLight(x, y, lit)
        local color = lit and colorA or colorB
        love.graphics.setColor(color[1], color[2], color[3], lit and pulse or 0.9)
        love.graphics.rectangle("fill", math.floor(x), math.floor(y), lightSize, lightSize, 3, 3)
    end

    local function drawCenteredSeries(startCoord, span, fixedCoord, count, isHorizontal, startIndex)
        local availableSpan = math.max(0, span - (inset * 2) - lightSize)
        local localSpacing = spacing
        if count > 1 then
            localSpacing = math.min(spacing, availableSpan / (count - 1))
        end

        local occupiedSpan = localSpacing * math.max(0, count - 1)
        local firstCoord = startCoord + ((span - occupiedSpan - lightSize) / 2)

        for index = 0, count - 1 do
            local lit = ((startIndex + index + phase) % 2 == 0)
            if isHorizontal then
                drawLight(firstCoord + (index * localSpacing), fixedCoord, lit)
            else
                drawLight(fixedCoord, firstCoord + (index * localSpacing), lit)
            end
        end

        return startIndex + count
    end

    local frame = frameColor or { 0.26, 0.18, 0.12 }
    local border = borderColor or { 0.74, 0.16, 0.18 }

    love.graphics.setColor(frame[1], frame[2], frame[3], 0.96)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 14, 14)
    love.graphics.setColor(border[1], border[2], border[3], 0.92)
    love.graphics.rectangle("line", rect.x - 2, rect.y - 2, rect.w + 4, rect.h + 4, 16, 16)

    drawLight(rect.x - (lightSize / 2), rect.y - (lightSize / 2), phase == 0)
    drawLight(rect.x + rect.w - (lightSize / 2), rect.y - (lightSize / 2), phase ~= 0)
    drawLight(rect.x + rect.w - (lightSize / 2), rect.y + rect.h - (lightSize / 2), phase == 0)
    drawLight(rect.x - (lightSize / 2), rect.y + rect.h - (lightSize / 2), phase ~= 0)

    local indexOffset = 0
    indexOffset = drawCenteredSeries(rect.x + inset, rect.w - (inset * 2), rect.y - (lightSize / 2), horizontalCount, true, indexOffset)
    indexOffset = drawCenteredSeries(rect.y + inset, rect.h - (inset * 2), rect.x + rect.w - (lightSize / 2), verticalCount, false, indexOffset)
    indexOffset = drawCenteredSeries(rect.x + inset, rect.w - (inset * 2), rect.y + rect.h - (lightSize / 2), horizontalCount, true, indexOffset)
    drawCenteredSeries(rect.y + inset, rect.h - (inset * 2), rect.x - (lightSize / 2), verticalCount, false, indexOffset)
end

-- Dessine le bloc de score courant comme une jauge pleine qui remplit tout le cadre.
local function drawScoreProgress(rect, currentScore, targetScore)
    local progress = targetScore and targetScore > 0 and (currentScore / targetScore) or 0
    widgets.drawProgressCard(rect, "SCORE", currentScore, progress, fonts.getScoreFont())
end

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
    local metrics = layout.getHandMetrics(#player.hand)

    if game.dealing_timer > 0 then
        local progress = 1 - (game.dealing_timer / 0.75)
        for index, card in ipairs(player.hand) do
            local targetX, targetY, cardW, cardH = layout.getCardRect(index, #player.hand)
            local fromY = love.graphics.getHeight() + 120
            local animatedY = fromY + ((targetY - fromY) * math.min(progress * 1.15, 1))
            if hidden then
                cards.drawHiddenHandCard(targetX, animatedY, game.selected_hand_index == index, 1, cardW, cardH)
            else
                cards.drawHandCard(card, targetX, animatedY, game.selected_hand_index == index, 1, cardW, cardH)
            end
        end
        return
    end

    for index, card in ipairs(player.hand) do
        local cardX, cardY, cardW, cardH = layout.getCardRect(index, #player.hand)
        if not (game.dragging.active and game.dragging.hand_index == index) then
            if hidden then
                cards.drawHiddenHandCard(cardX, cardY, game.selected_hand_index == index, 1, cardW, cardH)
            else
                cards.drawHandCard(card, cardX, cardY, game.selected_hand_index == index, 1, cardW, cardH)
            end
        end
    end

    if game.dragging.active and game.dragging.card then
        if hidden then
            cards.drawHiddenHandCard(
                game.dragging.x - game.dragging.offset_x,
                game.dragging.y - game.dragging.offset_y,
                true,
                0.92,
                metrics.width,
                metrics.height
            )
        else
            cards.drawHandCard(
                game.dragging.card,
                game.dragging.x - game.dragging.offset_x,
                game.dragging.y - game.dragging.offset_y,
                true,
                0.92,
                metrics.width,
                metrics.height
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
    local objectiveRect = { x = 42, y = 18, w = 164, h = 86 }
    local scoreRect = { x = 42, y = 120, w = 164, h = 96 }
    local titleText = game.current_boss and game.current_boss.name or ("Manche " .. tostring(game.round))

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(titleText, 0, 18, love.graphics.getWidth(), "center")
    if game.current_boss then
        love.graphics.printf("Manche " .. tostring(game.round), 0, 42, love.graphics.getWidth(), "center")
    end

    play.drawLightFrame(
        objectiveRect,
        15,
        7,
        20,
        3,
        theme.goal_lights.frame,
        theme.goal_lights.border,
        theme.goal_lights.a,
        theme.goal_lights.b
    )
    widgets.drawInfoCard(objectiveRect, "OBJECTIF", game.target_score, fonts.getScoreFont())

    drawScoreProgress(scoreRect, game.current_resolution_score, game.target_score)

    if game.current_score_popup then
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.print("+" .. game.current_score_popup.points, scoreRect.x + scoreRect.w + 6, scoreRect.y + 34)
    end

    widgets.drawButton(game.options_button, "OPTIONS", "secondary")
    widgets.drawButton(game.build_button, "BUILD", "primary")
    widgets.drawButton(game.redraw_button, "REDRAW MAIN", "warning", not (player.hand_can_redraw and player.available_redraws > 0 and #player.hand > 0))

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
