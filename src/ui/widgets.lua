-- src/ui/widgets.lua
-- Regroupe les widgets UI partages: popups, boutons, cartes d'info et listes cle/valeur.

local fonts = require("src.ui.fonts")
local theme = require("src.ui.theme")

local widgets = {}

-- Dessine l'overlay sombre commun des popups.
function widgets.drawOverlay(alpha)
    local overlayAlpha = alpha or theme.overlay[4] or 0.6
    love.graphics.setColor(theme.overlay[1], theme.overlay[2], theme.overlay[3], overlayAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

-- Dessine le fond principal d'un popup centré.
function widgets.drawPopupFrame(popupRect, title)
    love.graphics.setColor(theme.panel[1], theme.panel[2], theme.panel[3])
    love.graphics.rectangle("fill", popupRect.x, popupRect.y, popupRect.w, popupRect.h, 18, 18)
    if title then
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf(title, popupRect.x, popupRect.y + 24, popupRect.w, "center")
    end
end

-- Dessine le bouton de fermeture standard d'un popup.
function widgets.drawCloseButton(closeRect)
    local variant = theme.buttons.danger
    love.graphics.setColor(variant.fill[1], variant.fill[2], variant.fill[3])
    love.graphics.rectangle("fill", closeRect.x, closeRect.y, closeRect.w, closeRect.h, 10, 10)
    love.graphics.setColor(variant.text[1], variant.text[2], variant.text[3])
    love.graphics.printf("X", closeRect.x, closeRect.y + 7, closeRect.w, "center")
end

-- Dessine un bouton reutilisable avec variantes visuelles et etat desactive.
function widgets.drawButton(buttonRect, label, variantName, disabled, subtitle)
    local variant = disabled and theme.buttons.disabled or theme.buttons[variantName or "secondary"] or theme.buttons.secondary
    love.graphics.setColor(variant.fill[1], variant.fill[2], variant.fill[3], variant.fill[4] or 1)
    love.graphics.rectangle("fill", buttonRect.x, buttonRect.y, buttonRect.w, buttonRect.h, 12, 12)
    love.graphics.setColor(variant.text[1], variant.text[2], variant.text[3], variant.text[4] or 1)
    love.graphics.printf(label, buttonRect.x, buttonRect.y + (subtitle and 10 or 14), buttonRect.w, "center")
    if subtitle then
        love.graphics.printf(subtitle, buttonRect.x, buttonRect.y + 27, buttonRect.w, "center")
    end
end

-- Dessine une liste de lignes label/valeur dans une meme colonne.
function widgets.drawKeyValueList(rows, x, y, width, lineHeight)
    local currentY = y
    for _, row in ipairs(rows) do
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf(row.label, x, currentY, width * 0.62, "left")
        love.graphics.printf(tostring(row.value), x + (width * 0.62), currentY, width * 0.38, "right")
        currentY = currentY + (lineHeight or 34)
    end
end

-- Dessine un bloc d'information simple avec un titre et une valeur marquee.
function widgets.drawInfoCard(infoRect, title, value, valueFont)
    love.graphics.setColor(theme.info_fill[1], theme.info_fill[2], theme.info_fill[3], theme.info_fill[4])
    love.graphics.rectangle("fill", infoRect.x, infoRect.y, infoRect.w, infoRect.h, 14, 14)
    love.graphics.setColor(theme.panel_outline[1], theme.panel_outline[2], theme.panel_outline[3], theme.panel_outline[4])
    love.graphics.rectangle("line", infoRect.x, infoRect.y, infoRect.w, infoRect.h, 14, 14)
    love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
    love.graphics.printf(title, infoRect.x, infoRect.y + 12, infoRect.w, "center")
    fonts.drawOutlinedText(tostring(value), infoRect.x, infoRect.y + 34, {
        font = valueFont or fonts.getScoreFont(),
        mode = "printf",
        limit = infoRect.w,
        align = "center",
        outline = 1
    })
end

-- Dessine une carte de progression qui se remplit entierement sans depasser son cadre.
function widgets.drawProgressCard(progressRect, title, value, progress, valueFont)
    local clampedProgress = math.min(1, math.max(0, progress or 0))
    local fillHeight = math.floor((progressRect.h - 4) * clampedProgress)

    love.graphics.setColor(theme.info_fill[1], theme.info_fill[2], theme.info_fill[3], theme.info_fill[4])
    love.graphics.rectangle("fill", progressRect.x, progressRect.y, progressRect.w, progressRect.h, 14, 14)
    love.graphics.setColor(theme.progress_fill[1], theme.progress_fill[2], theme.progress_fill[3], theme.progress_fill[4])
    love.graphics.setScissor(progressRect.x + 2, progressRect.y + 2 + ((progressRect.h - 4) - fillHeight), progressRect.w - 4, fillHeight)
    love.graphics.rectangle("fill", progressRect.x + 2, progressRect.y + 2, progressRect.w - 4, progressRect.h - 4, 12, 12)
    love.graphics.setScissor()
    love.graphics.setColor(theme.panel_outline[1], theme.panel_outline[2], theme.panel_outline[3], theme.panel_outline[4])
    love.graphics.rectangle("line", progressRect.x, progressRect.y, progressRect.w, progressRect.h, 14, 14)
    love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
    love.graphics.printf(title, progressRect.x, progressRect.y + 10, progressRect.w, "center")
    fonts.drawOutlinedText(tostring(value), progressRect.x, progressRect.y + 30, {
        font = valueFont or fonts.getScoreFont(),
        mode = "printf",
        limit = progressRect.w,
        align = "center",
        outline = 1
    })
end

return widgets
