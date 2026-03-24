-- src/helpers/cards.lua
-- Reusable card drawing primitives shared by hand, shop, codex and deck views.

local constants = require("src.constants")
local fonts = require("src.helpers.fonts")

local cards = {}

function cards.drawInventoryCard(rect, title, subtitle, selected)
    love.graphics.setColor(selected and 0.84 or 0.22, selected and 0.62 or 0.26, selected and 0.28 or 0.32)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(title, rect.x + 8, rect.y + 10, rect.w - 16, "center")
    if subtitle then
        love.graphics.printf(subtitle, rect.x + 8, rect.y + 30, rect.w - 16, "center")
    end
end

function cards.drawShopEntryCard(rect, title, description, price, state)
    if state == "owned" then
        love.graphics.setColor(0.24, 0.34, 0.22)
    elseif state == "blocked" then
        love.graphics.setColor(0.22, 0.22, 0.22)
    else
        love.graphics.setColor(0.26, 0.32, 0.4)
    end

    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 12, 12)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(title, rect.x + 8, rect.y + 12, rect.w - 16, "center")
    love.graphics.printf(description, rect.x + 8, rect.y + 42, rect.w - 16, "center")
    love.graphics.printf(price .. "p", rect.x + 8, rect.y + rect.h - 26, rect.w - 16, "center")
end

function cards.drawMiniCard(rect, title, subtitle, alpha, highlight)
    alpha = alpha or 1
    love.graphics.setColor(0.94, 0.9, 0.8, alpha)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 12, 12)
    love.graphics.setColor(0.15, 0.15, 0.15, alpha)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 12, 12)
    love.graphics.setColor(0.12, 0.12, 0.12, alpha)
    love.graphics.printf(title, rect.x + 8, rect.y + 16, rect.w - 16, "center")
    if subtitle then
        love.graphics.printf(subtitle, rect.x + 8, rect.y + 56, rect.w - 16, "center")
    end
    if highlight then
        love.graphics.setColor(0.9, 0.2, 0.2, alpha)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", rect.x - 2, rect.y - 2, rect.w + 4, rect.h + 4, 12, 12)
        love.graphics.setLineWidth(1)
    end
end

function cards.drawHandCard(card, x, y, selected, alpha)
    alpha = alpha or 1
    love.graphics.setColor(0.94, 0.9, 0.8, alpha)
    love.graphics.rectangle("fill", x, y, constants.HAND_CARD_WIDTH, constants.HAND_CARD_HEIGHT, 12, 12)
    love.graphics.setColor(0.15, 0.15, 0.15, alpha)
    love.graphics.rectangle("line", x, y, constants.HAND_CARD_WIDTH, constants.HAND_CARD_HEIGHT, 12, 12)

    love.graphics.setColor(card.color[1], card.color[2], card.color[3], alpha)
    love.graphics.rectangle("fill", x + 16, y + 18, constants.HAND_CARD_WIDTH - 32, 54, 10, 10)

    love.graphics.setColor(0.12, 0.12, 0.12, alpha)
    love.graphics.print(card.name, x + 14, y + 88)
    love.graphics.print("Base: " .. card.base_score, x + 14, y + 110)

    if selected then
        love.graphics.setColor(0.96, 0.72, 0.18, alpha)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 2, y - 2, constants.HAND_CARD_WIDTH + 4, constants.HAND_CARD_HEIGHT + 4, 14, 14)
        love.graphics.setLineWidth(1)
    end
end

function cards.drawMayorCard(rect, mayorData, selected, portraitImage)
    love.graphics.setColor(0.94, 0.9, 0.8, 1)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 12, 12)
    love.graphics.setColor(0.15, 0.15, 0.15, 1)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h, 12, 12)

    local portraitRect = {
        x = rect.x + 16,
        y = rect.y + 16,
        w = rect.w - 32,
        h = 120
    }

    love.graphics.setColor(0.22, 0.3, 0.38, 1)
    love.graphics.rectangle("fill", portraitRect.x, portraitRect.y, portraitRect.w, portraitRect.h, 10, 10)

    if portraitImage then
        local scaleX = portraitRect.w / portraitImage:getWidth()
        local scaleY = portraitRect.h / portraitImage:getHeight()
        local scale = math.min(scaleX, scaleY)
        local drawW = portraitImage:getWidth() * scale
        local drawH = portraitImage:getHeight() * scale
        local drawX = portraitRect.x + ((portraitRect.w - drawW) / 2)
        local drawY = portraitRect.y + ((portraitRect.h - drawH) / 2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(portraitImage, drawX, drawY, 0, scale, scale)
    else
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.printf("PORTRAIT", portraitRect.x, portraitRect.y + 46, portraitRect.w, "center")
    end

    love.graphics.setColor(0.12, 0.12, 0.12, 1)
    love.graphics.printf(mayorData.name, rect.x + 12, rect.y + 148, rect.w - 24, "center")
    love.graphics.printf(mayorData.description or "", rect.x + 12, rect.y + 178, rect.w - 24, "center")

    if selected then
        love.graphics.setColor(0.96, 0.72, 0.18, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", rect.x - 2, rect.y - 2, rect.w + 4, rect.h + 4, 14, 14)
        love.graphics.setLineWidth(1)
    end
end

function cards.drawArrowButton(rect, direction)
    love.graphics.setColor(0.24, 0.28, 0.36, 1)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)

    local centerX = rect.x + (rect.w / 2)
    local centerY = rect.y + (rect.h / 2)
    local size = 12
    if direction == "left" then
        love.graphics.polygon("fill",
            centerX + size / 2, centerY - size,
            centerX - size / 2, centerY,
            centerX + size / 2, centerY + size
        )
    else
        love.graphics.polygon("fill",
            centerX - size / 2, centerY - size,
            centerX + size / 2, centerY,
            centerX - size / 2, centerY + size
        )
    end
end

function cards.drawPrimaryButton(rect, label)
    love.graphics.setColor(0.18, 0.48, 0.32, 1)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 14, 14)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(label, rect.x, rect.y + 20, rect.w, "center")
end

function cards.drawSecondaryButton(rect, label)
    love.graphics.setColor(0.24, 0.26, 0.34, 1)
    love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(label, rect.x, rect.y + 14, rect.w, "center")
end

return cards
