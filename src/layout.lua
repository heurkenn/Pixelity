-- src/layout.lua

local constants = require("src.constants")

local layout = {}

-- Shared hit-test helper for cards, buttons and modals.
function layout.pointInRect(px, py, rect)
    return px >= rect.x and px <= rect.x + rect.w and py >= rect.y and py <= rect.y + rect.h
end

function layout.insetRect(rect, paddingX, paddingY)
    paddingY = paddingY or paddingX
    return {
        x = rect.x + paddingX,
        y = rect.y + paddingY,
        w = rect.w - (paddingX * 2),
        h = rect.h - (paddingY * 2)
    }
end

function layout.centerRectInRect(outerRect, width, height)
    return {
        x = outerRect.x + ((outerRect.w - width) / 2),
        y = outerRect.y + ((outerRect.h - height) / 2),
        w = width,
        h = height
    }
end

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
function layout.getGridOffset()
    return (love.graphics.getWidth() - (constants.GRID_SIZE * constants.TILE_SIZE)) / 2, 140
end

function layout.getCellScreenPosition(x, y)
    local offsetX, offsetY = layout.getGridOffset()
    return offsetX + (x - 1) * constants.TILE_SIZE, offsetY + (y - 1) * constants.TILE_SIZE
end

function layout.getScoreAnchor()
    return love.graphics.getWidth() / 2, 52
end

function layout.getCellFromScreen(x, y, grid)
    local offsetX, offsetY = layout.getGridOffset()
    local gridX = math.floor((x - offsetX) / constants.TILE_SIZE) + 1
    local gridY = math.floor((y - offsetY) / constants.TILE_SIZE) + 1

    if grid.isInside(gridX, gridY) then
        return gridX, gridY
    end

    return nil, nil
end

-- Hand cards are laid out from the bottom center so resizing stays predictable.
function layout.getCardRect(index, handCount)
    local count = math.max(handCount, 1)
    local totalWidth = (count * constants.HAND_CARD_WIDTH) + ((count - 1) * constants.HAND_GAP)
    local startX = (love.graphics.getWidth() - totalWidth) / 2
    local startY = love.graphics.getHeight() - constants.HAND_CARD_HEIGHT - 28

    return startX + ((index - 1) * (constants.HAND_CARD_WIDTH + constants.HAND_GAP)),
        startY,
        constants.HAND_CARD_WIDTH,
        constants.HAND_CARD_HEIGHT
end

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
function layout.updateButtons(game, mayorTypes, difficulties, scoringSpeedOptions)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

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

    local statsPanel = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 520, 420)
    local statsInner = layout.insetRect(statsPanel, 28, 80)
    game.stats_modal = {
        panel = statsPanel,
        close = {
            x = statsPanel.x + statsPanel.w - 54,
            y = statsPanel.y + 16,
            w = 38,
            h = 38
        },
        lines = {
            x = statsInner.x,
            y = statsInner.y,
            w = statsInner.w,
            h = statsInner.h
        }
    }

    local centeredModal = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 520, 360)
    local optionsInner = layout.insetRect(centeredModal, 28, 78)
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
        close = {
            x = centeredModal.x + centeredModal.w - 54,
            y = centeredModal.y + 16,
            w = 38,
            h = 38
        }
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

    game.confirm_toggle_button = {
        x = optionsInner.x + ((optionsInner.w - 240) / 2),
        y = optionsInner.y + 120,
        w = 240,
        h = 48
    }

    game.options_back_to_menu_button = {
        x = optionsInner.x + ((optionsInner.w - 240) / 2),
        y = centeredModal.y + centeredModal.h - 74,
        w = 240,
        h = 44
    }

    local codexPanel = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 800, 560)
    local codexCardArea = {
        x = codexPanel.x + 28,
        y = codexPanel.y + 164,
        w = codexPanel.w - 56,
        h = 188
    }
    game.codex_modal = {
        panel = codexPanel,
        close = {
            x = codexPanel.x + codexPanel.w - 54,
            y = codexPanel.y + 16,
            w = 38,
            h = 38
        },
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

    local deckPanel = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 820, 520)
    local deckGridArea = {
        x = deckPanel.x + 28,
        y = deckPanel.y + 92,
        w = deckPanel.w - 56,
        h = deckPanel.h - 120
    }
    game.deck_modal = {
        panel = deckPanel,
        close = {
            x = deckPanel.x + deckPanel.w - 54,
            y = deckPanel.y + 16,
            w = 38,
            h = 38
        },
        grid_area = deckGridArea
    }

    local confirmPanel = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 360, 180)
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

    local summaryPanel = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 420, 320)
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
        countdown = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 340, 260),
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

    local mayorCard = layout.centerRectInRect({ x = 0, y = 0, w = width, h = height }, 240, 286)
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

    local debugPanel = layout.getScreenRect(2 / 3, 2 / 3, 1 / 6)
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
