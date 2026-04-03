-- src/ui/layout.lua

local constants = require("src.constants")

local layout = {}

-- Retourne le rectangle qui couvre toute la fenetre courante.
function layout.getViewportRect()
    return {
        x = 0,
        y = 0,
        w = love.graphics.getWidth(),
        h = love.graphics.getHeight()
    }
end

-- Shared hit-test helper for cards, buttons and modals.
-- Teste si un point ecran se trouve a l'interieur d'un rectangle.
function layout.pointInRect(px, py, rect)
    return px >= rect.x and px <= rect.x + rect.w and py >= rect.y and py <= rect.y + rect.h
end

-- Cree un rectangle interieur avec marges horizontales et verticales.
function layout.insetRect(rect, paddingX, paddingY)
    paddingY = paddingY or paddingX
    return {
        x = rect.x + paddingX,
        y = rect.y + paddingY,
        w = rect.w - (paddingX * 2),
        h = rect.h - (paddingY * 2)
    }
end

-- Centre un rectangle de taille fixe a l'interieur d'un autre.
function layout.centerRectInRect(outerRect, width, height)
    return {
        x = outerRect.x + ((outerRect.w - width) / 2),
        y = outerRect.y + ((outerRect.h - height) / 2),
        w = width,
        h = height
    }
end

-- Retourne un popup centre dans la fenetre avec une taille fixe.
function layout.getCenteredPopup(width, height)
    return layout.centerRectInRect(layout.getViewportRect(), width, height)
end

-- Retourne le bouton de fermeture standard dans l'angle d'un popup.
function layout.getPopupCloseButton(popupRect)
    return {
        x = popupRect.x + popupRect.w - 54,
        y = popupRect.y + 16,
        w = 38,
        h = 38
    }
end

-- Retourne la zone utile d'un popup avec des marges adaptees.
function layout.getPopupContentRect(popupRect, paddingX, paddingY)
    return layout.insetRect(popupRect, paddingX or 28, paddingY or 80)
end

-- Retourne un bouton centre en bas d'un panneau.
function layout.getBottomCenteredButton(panelRect, buttonWidth, buttonHeight, bottomMargin)
    return {
        x = panelRect.x + ((panelRect.w - buttonWidth) / 2),
        y = panelRect.y + panelRect.h - (bottomMargin or 54) - buttonHeight,
        w = buttonWidth,
        h = buttonHeight
    }
end

-- Retourne un rectangle relatif a la taille actuelle de la fenetre.
function layout.getScreenRect(widthRatio, heightRatio, yRatio)
    local width = love.graphics.getWidth() * widthRatio
    local height = love.graphics.getHeight() * heightRatio
    return {
        x = (love.graphics.getWidth() - width) / 2,
        y = love.graphics.getHeight() * (yRatio or ((1 - heightRatio) / 2)),
        w = width,
        h = height
    }
end

-- Repartit des rectangles sur une seule ligne centree dans une zone.
function layout.distributeRowInRect(outerRect, itemCount, itemWidth, itemHeight, gap)
    local rects = {}
    if itemCount <= 0 then
        return rects
    end

    local totalWidth = (itemCount * itemWidth) + ((itemCount - 1) * gap)
    local startX = outerRect.x + ((outerRect.w - totalWidth) / 2)
    local y = outerRect.y + ((outerRect.h - itemHeight) / 2)

    for index = 1, itemCount do
        rects[index] = {
            x = startX + ((index - 1) * (itemWidth + gap)),
            y = y,
            w = itemWidth,
            h = itemHeight
        }
    end

    return rects
end

-- Repartit des rectangles sur une grille reguliere dans une zone.
function layout.distributeGridInRect(outerRect, itemCount, columns, itemHeight, gapX, gapY)
    local rects = {}
    if itemCount <= 0 then
        return rects
    end

    local rows = math.ceil(itemCount / columns)
    local itemWidth = math.floor((outerRect.w - ((columns - 1) * gapX)) / columns)
    local totalHeight = (rows * itemHeight) + ((rows - 1) * gapY)
    local startY = outerRect.y + ((outerRect.h - totalHeight) / 2)

    for index = 1, itemCount do
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        rects[index] = {
            x = outerRect.x + (column * (itemWidth + gapX)),
            y = startY + (row * (itemHeight + gapY)),
            w = itemWidth,
            h = itemHeight
        }
    end

    return rects
end

-- Grid stays centered horizontally while keeping a fixed top margin for the HUD.
-- Retourne l'origine ecran de la grille de jeu.
function layout.getGridOffset()
    return love.graphics.getWidth() / 2, constants.ISO_GRID_TOP_Y
end

-- Retourne le centre ecran de la case isometrique.
function layout.getCellScreenCenter(x, y)
    local originX, originY = layout.getGridOffset()
    return
        originX + ((x - y) * (constants.ISO_TILE_WIDTH / 2)),
        originY + (((x + y) - 2) * (constants.ISO_TILE_HEIGHT / 2))
end

-- Convertit des coordonnees grille en coordonnees ecran.
function layout.getCellScreenPosition(x, y)
    local centerX, centerY = layout.getCellScreenCenter(x, y)
    return centerX - (constants.ISO_TILE_WIDTH / 2), centerY - (constants.ISO_TILE_HEIGHT / 2)
end

-- Retourne le rectangle ecran de l'empreinte d'une case isometrique.
function layout.getCellScreenRect(x, y)
    local cellX, cellY = layout.getCellScreenPosition(x, y)
    return {
        x = cellX,
        y = cellY,
        w = constants.ISO_TILE_WIDTH,
        h = constants.ISO_TILE_HEIGHT
    }
end

-- Retourne l'ancre ecran utilisee par l'affichage du score courant.
function layout.getScoreAnchor()
    return 80, 88
end

-- Indique si un point se situe a l'interieur d'un losange isometrique.
function layout.pointInDiamond(px, py, rect)
    local centerX = rect.x + (rect.w / 2)
    local centerY = rect.y + (rect.h / 2)
    local normalizedX = math.abs(px - centerX) / (rect.w / 2)
    local normalizedY = math.abs(py - centerY) / (rect.h / 2)
    return (normalizedX + normalizedY) <= 1
end

-- Convertit un clic ecran en coordonnees de grille si la case existe.
function layout.getCellFromScreen(x, y, grid)
    local originX, originY = layout.getGridOffset()
    local dx = x - originX
    local dy = y - originY
    local halfWidth = constants.ISO_TILE_WIDTH / 2
    local halfHeight = constants.ISO_TILE_HEIGHT / 2

    local gridX = math.floor((((dx / halfWidth) + (dy / halfHeight) + 2) / 2) + 0.5)
    local gridY = math.floor((((dy / halfHeight) - (dx / halfWidth) + 2) / 2) + 0.5)

    if grid.isInside(gridX, gridY) and layout.pointInDiamond(x, y, layout.getCellScreenRect(gridX, gridY)) then
        return gridX, gridY
    end

    return nil, nil
end

-- Hand cards are laid out from the bottom center so resizing stays predictable.
-- Retourne les dimensions dynamiques de la main selon la taille de fenetre.
function layout.getHandMetrics(handCount)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local count = math.max(handCount, 1)
    local cardWidth = math.floor(math.max(80, math.min(108, width * 0.07)))
    local cardHeight = math.floor(cardWidth * 1.33)
    local gap = math.floor(math.max(6, math.min(12, width * 0.0065)))
    local totalWidth = (count * cardWidth) + ((count - 1) * gap)

    if totalWidth > width - 320 then
        local availableWidth = math.max(1, width - 320)
        local scale = availableWidth / totalWidth
        cardWidth = math.floor(cardWidth * scale)
        cardHeight = math.floor(cardHeight * scale)
        gap = math.max(4, math.floor(gap * scale))
        totalWidth = (count * cardWidth) + ((count - 1) * gap)
    end

    return {
        width = cardWidth,
        height = cardHeight,
        gap = gap,
        start_x = (width - totalWidth) / 2,
        start_y = height - cardHeight - math.floor(math.max(18, math.min(26, height * 0.03)))
    }
end

-- Retourne le rectangle d'une carte de main selon son index.
function layout.getCardRect(index, handCount)
    local metrics = layout.getHandMetrics(handCount)

    return metrics.start_x + ((index - 1) * (metrics.width + metrics.gap)),
        metrics.start_y,
        metrics.width,
        metrics.height
end

-- Detecte quelle carte de main se trouve sous le pointeur.
function layout.getCardIndexAt(x, y, handCount)
    for index = handCount, 1, -1 do
        local cardX, cardY, cardW, cardH = layout.getCardRect(index, handCount)
        if layout.pointInRect(x, y, { x = cardX, y = cardY, w = cardW, h = cardH }) then
            return index
        end
    end

    return nil
end

-- All interactive rectangles are recalculated every frame from the current window size.
-- Recalcule tous les rectangles interactifs et modales de l'interface.
function layout.updateButtons(game, mayorTypes, difficulties, scoringSpeedOptions)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local viewport = layout.getViewportRect()

    game.build_button = {
        x = width - 190,
        y = height - 188,
        w = 150,
        h = 56
    }

    game.redraw_button = {
        x = width - 190,
        y = height - 104,
        w = 150,
        h = 52
    }

    game.options_button = {
        x = width - 190,
        y = 22,
        w = 150,
        h = 44
    }

    game.bottom_left_buttons = {
        codex = {
            x = 24,
            y = height - 188,
            w = 92,
            h = 72
        },
        deck = {
            x = 24,
            y = height - 104,
            w = 92,
            h = 72
        }
    }

    game.menu_buttons = {
        play = layout.centerRectInRect({ x = 0, y = 286, w = width, h = 64 }, 260, 64),
        continue = layout.centerRectInRect({ x = 0, y = 366, w = width, h = 54 }, 240, 54),
        new_game = layout.centerRectInRect({ x = 0, y = 430, w = width, h = 54 }, 240, 54),
        stats = layout.centerRectInRect({ x = 0, y = 508, w = width, h = 54 }, 220, 54),
        options = layout.centerRectInRect({ x = 0, y = 574, w = width, h = 56 }, 220, 56)
    }

    local statsPanel = layout.getCenteredPopup(520, 420)
    local statsInner = layout.getPopupContentRect(statsPanel, 28, 80)
    game.stats_modal = {
        panel = statsPanel,
        close = layout.getPopupCloseButton(statsPanel),
        lines = {
            x = statsInner.x,
            y = statsInner.y,
            w = statsInner.w,
            h = statsInner.h
        }
    }

    local centeredModal = layout.getCenteredPopup(560, 520)
    local optionsInner = layout.getPopupContentRect(centeredModal, 28, 78)
    local speedRects = layout.distributeRowInRect(
        {
            x = optionsInner.x,
            y = optionsInner.y + 10,
            w = optionsInner.w,
            h = 44
        },
        #scoringSpeedOptions,
        88,
        36,
        12
    )
    game.options_modal = {
        panel = centeredModal,
        close = layout.getPopupCloseButton(centeredModal)
    }

    game.speed_buttons = {}
    for index, multiplier in ipairs(scoringSpeedOptions) do
        game.speed_buttons[index] = {
            multiplier = multiplier,
            x = speedRects[index].x,
            y = speedRects[index].y,
            w = speedRects[index].w,
            h = speedRects[index].h
        }
    end

    local videoRects = layout.distributeRowInRect(
        {
            x = optionsInner.x,
            y = optionsInner.y + 118,
            w = optionsInner.w,
            h = 44
        },
        3,
        160,
        40,
        10
    )
    game.video_mode_buttons = {
        {
            id = "windowed",
            label = "Fenetre",
            x = videoRects[1].x,
            y = videoRects[1].y,
            w = videoRects[1].w,
            h = videoRects[1].h
        },
        {
            id = "fullscreen",
            label = "Plein ecran",
            x = videoRects[2].x,
            y = videoRects[2].y,
            w = videoRects[2].w,
            h = videoRects[2].h
        },
        {
            id = "borderless",
            label = "Plein ecran fenetre",
            x = videoRects[3].x,
            y = videoRects[3].y,
            w = videoRects[3].w,
            h = videoRects[3].h
        }
    }

    game.confirm_toggle_button = {
        x = optionsInner.x + ((optionsInner.w - 240) / 2),
        y = optionsInner.y + 196,
        w = 240,
        h = 48
    }

    game.options_back_to_menu_button = {
        x = optionsInner.x + ((optionsInner.w - 240) / 2),
        y = centeredModal.y + centeredModal.h - 78,
        w = 240,
        h = 46
    }
    game.options_reset_data_button = {
        x = optionsInner.x + ((optionsInner.w - 320) / 2),
        y = game.options_back_to_menu_button.y - 58,
        w = 320,
        h = 42
    }
    game.options_reset_confirm_button = {
        x = optionsInner.x + ((optionsInner.w - 280) / 2),
        y = game.options_reset_data_button.y - 50,
        w = 280,
        h = 38
    }

    local codexPanel = layout.getCenteredPopup(800, 560)
    local codexCardArea = {
        x = codexPanel.x + 28,
        y = codexPanel.y + 164,
        w = codexPanel.w - 56,
        h = 188
    }
    game.codex_modal = {
        panel = codexPanel,
        close = layout.getPopupCloseButton(codexPanel),
        law_cards = {}
    }
    local codexLawRects = layout.distributeGridInRect(codexCardArea, 7, 4, 82, 12, 12)
    for index = 1, 7 do
        game.codex_modal.law_cards[index] = codexLawRects[index]
    end
    game.codex_modal.focus_card = {
        x = codexPanel.x + 144,
        y = codexPanel.y + 384,
        w = codexPanel.w - 288,
        h = 144
    }
    game.codex_modal.sell_button = {
        x = game.codex_modal.focus_card.x + game.codex_modal.focus_card.w / 2 - 90,
        y = game.codex_modal.focus_card.y + game.codex_modal.focus_card.h - 46,
        w = 180,
        h = 36
    }

    local deckPanel = layout.getCenteredPopup(820, 520)
    local deckGridArea = {
        x = deckPanel.x + 28,
        y = deckPanel.y + 92,
        w = deckPanel.w - 56,
        h = deckPanel.h - 120
    }
    game.deck_modal = {
        panel = deckPanel,
        close = layout.getPopupCloseButton(deckPanel),
        grid_area = deckGridArea
    }

    local confirmPanel = layout.getCenteredPopup(360, 180)
    local confirmButtonArea = {
        x = confirmPanel.x + 30,
        y = confirmPanel.y + 112,
        w = confirmPanel.w - 60,
        h = 44
    }
    local confirmButtons = layout.distributeRowInRect(confirmButtonArea, 2, 130, 44, 40)
    game.confirm_modal = {
        panel = confirmPanel,
        yes = confirmButtons[1],
        no = confirmButtons[2]
    }

    local summaryPanel = layout.getCenteredPopup(420, 320)
    local summaryFooter = {
        x = summaryPanel.x,
        y = summaryPanel.y + summaryPanel.h - 76,
        w = summaryPanel.w,
        h = 54
    }
    game.round_clear_buttons = {
        shop = layout.centerRectInRect(summaryFooter, 180, 54),
        continue = {
            x = width / 2 - 90,
            y = height - 110,
            w = 180,
            h = 54
        }
    }
    game.round_clear_panels = {
        countdown = layout.getCenteredPopup(340, 260),
        summary = summaryPanel
    }

    game.item_slots = {}
    for index = 1, 2 do
        game.item_slots[index] = {
            x = width - 158,
            y = 150 + ((index - 1) * 66),
            w = 140,
            h = 56
        }
    end

    local mayorCard = layout.getCenteredPopup(240, 286)
    mayorCard.y = 184
    game.start_buttons.mayor_card = mayorCard
    game.start_buttons.prev_mayor = {
        x = mayorCard.x - 86,
        y = mayorCard.y + 94,
        w = 58,
        h = 98
    }
    game.start_buttons.next_mayor = {
        x = mayorCard.x + mayorCard.w + 28,
        y = mayorCard.y + 94,
        w = 58,
        h = 98
    }
    game.start_buttons.next = layout.centerRectInRect({ x = 0, y = mayorCard.y + mayorCard.h + 24, w = width, h = 64 }, 220, 64)
    game.start_buttons.back_to_menu = layout.centerRectInRect({ x = 0, y = mayorCard.y + mayorCard.h + 98, w = width, h = 52 }, 180, 52)

    game.start_buttons.mayor_preview = {
        x = 72,
        y = 170,
        w = 220,
        h = 260
    }

    local difficultiesArea = {
        x = 344,
        y = 198,
        w = width - 416,
        h = 220
    }
    local difficultyRects = layout.distributeRowInRect(difficultiesArea, #difficulties, 220, 90, 30)
    game.start_buttons.difficulties = {}
    for index, item in ipairs(difficulties) do
        game.start_buttons.difficulties[index] = {
            id = item.id,
            x = difficultyRects[index].x,
            y = difficultyRects[index].y,
            w = difficultyRects[index].w,
            h = difficultyRects[index].h
        }
    end

    game.start_buttons.back = {
        x = 410,
        y = 478,
        w = 180,
        h = 56
    }
    game.start_buttons.start = {
        x = 662,
        y = 478,
        w = 220,
        h = 64
    }

    local debugPanel = layout.centerRectInRect(viewport, math.floor(width * (2 / 3)), math.floor(height * (2 / 3)))
    game.debug_panel = debugPanel
    game.debug_buttons = {
        open = {
            x = width - 176,
            y = 442,
            w = 140,
            h = 46
        },
        close = {
            x = debugPanel.x + debugPanel.w - 116,
            y = debugPanel.y + 18,
            w = 92,
            h = 36
        },
        scenarios = {
            { id = "play" },
            { id = "summary" },
            { id = "shop" },
            { id = "victory" },
            { id = "options" },
            { id = "codex" },
            { id = "deck" },
            { id = "boss_intro" },
            { id = "boss_earthquake" },
            { id = "boss_tsunami" },
            { id = "boss_lactose" },
            { id = "boss_dark" },
            { id = "boss_renovation" }
        }
    }

    local debugContentArea = layout.insetRect(debugPanel, 28, 96)
    local columns = 2
    local gapX = 20
    local gapY = 18
    local itemHeight = 64
    local itemWidth = math.floor((debugContentArea.w - ((columns - 1) * gapX)) / columns)
    local rows = math.ceil(#game.debug_buttons.scenarios / columns)
    local contentHeight = (rows * itemHeight) + ((rows - 1) * gapY)
    game.debug_scroll_max = math.max(0, contentHeight - debugContentArea.h)
    game.debug_scroll = math.max(0, math.min(game.debug_scroll or 0, game.debug_scroll_max))
    game.debug_content_area = debugContentArea

    for index, button in ipairs(game.debug_buttons.scenarios) do
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        button.x = debugContentArea.x + (column * (itemWidth + gapX))
        button.base_y = debugContentArea.y + (row * (itemHeight + gapY))
        button.y = button.base_y - (game.debug_scroll or 0)
        button.w = itemWidth
        button.h = itemHeight
    end
end

return layout
