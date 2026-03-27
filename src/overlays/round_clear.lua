-- src/overlays/round_clear.lua
-- Handles the inter-round overlays: banner, countdown, summary and shop.

local fonts = require("src.ui.fonts")
local cards = require("src.ui.cards")
local play = require("src.game.play")
local widgets = require("src.ui.widgets")
local theme = require("src.ui.theme")

local round_clear = {}

-- Retourne l'etat visuel d'une offre de shop pour le joueur courant.
local function getShopCardState(player, entry)
    local price = entry.display_price or entry.price

    if entry.section == "law" then
        local copyCount = player.countLawCopies(entry.id)
        if copyCount > 0 and not player.allow_duplicate_laws then
            return "owned"
        end
        if player.allow_duplicate_laws and copyCount >= 2 then
            return "blocked"
        end
        if #player.laws >= player.MAX_LAWS or player.money < price then
            return "blocked"
        end
        return "enabled"
    end

    if entry.section == "item" then
        if #player.items >= player.MAX_ITEMS or player.money < price then
            return "blocked"
        end
        return "enabled"
    end

    if player.money < price then
        return "blocked"
    end
    return "enabled"
end

-- Dessine les differentes phases de fin de manche et le shop.
function round_clear.draw(game, player)
    local clear = game.round_clear
    if not clear then
        return
    end

    widgets.drawOverlay(0.5)

    if clear.phase == "banner" then
        fonts.drawOutlinedText("Felicitations", 0, 160, {
            font = fonts.getTitleFont(),
            mode = "printf",
            limit = love.graphics.getWidth(),
            align = "center",
            outline = 1
        })
        return
    end

    if clear.phase == "countdown" then
        local countdownPanel = game.round_clear_panels.countdown
        local scoreFont = fonts.getScoreFont() or love.graphics.getFont()
        local scoreText = tostring(clear.score_display)
        local globalScoreText = tostring(clear.global_score_display)
        local scoreWidth = scoreFont:getWidth(scoreText)
        local globalScoreWidth = scoreFont:getWidth(globalScoreText)

        widgets.drawPopupFrame(countdownPanel)
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf("Score de manche", countdownPanel.x, countdownPanel.y + 18, countdownPanel.w, "center")
        fonts.drawOutlinedText(scoreText, math.floor((countdownPanel.x + (countdownPanel.w / 2)) - (scoreWidth / 2)), countdownPanel.y + 82, {
            font = fonts.getScoreFont(),
            outline = 1
        })
        love.graphics.printf("Score global", countdownPanel.x, countdownPanel.y + 132, countdownPanel.w, "center")
        fonts.drawOutlinedText(globalScoreText, math.floor((countdownPanel.x + (countdownPanel.w / 2)) - (globalScoreWidth / 2)), countdownPanel.y + 154, {
            font = fonts.getScoreFont(),
            outline = 1
        })
        return
    end

    if clear.phase == "countdown_done" then
        local countdownPanel = game.round_clear_panels.countdown
        local scoreFont = fonts.getScoreFont() or love.graphics.getFont()
        local globalScoreText = tostring(clear.global_score_display)
        local globalScoreWidth = scoreFont:getWidth(globalScoreText)

        widgets.drawPopupFrame(countdownPanel)
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf("Score global", countdownPanel.x, countdownPanel.y + 34, countdownPanel.w, "center")
        fonts.drawOutlinedText(globalScoreText, math.floor((countdownPanel.x + (countdownPanel.w / 2)) - (globalScoreWidth / 2)), countdownPanel.y + 88, {
            font = fonts.getScoreFont(),
            outline = 1
        })
        widgets.drawButton(game.round_clear_buttons.continue, "SUIVANT", "primary")
        return
    end

    if clear.phase == "summary" then
        local summaryPanel = game.round_clear_panels.summary
        local summaryRows = {}

        for _, line in ipairs(clear.summary_lines) do
            table.insert(summaryRows, { label = line, value = "" })
        end

        table.insert(summaryRows, { label = "Manche gagnee", value = "+ 3 pieces" })
        table.insert(summaryRows, {
            label = "Mains restantes " .. clear.remaining_hands,
            value = "+1*" .. clear.remaining_hands
        })
        if clear.reward_bank and clear.reward_bank > 0 then
            table.insert(summaryRows, { label = "Pieces encaissees", value = clear.reward_bank })
        end
        table.insert(summaryRows, { label = "Total", value = "+" .. clear.total_reward .. " pieces" })

        widgets.drawPopupFrame(summaryPanel, "Resume de manche")
        widgets.drawKeyValueList(summaryRows, summaryPanel.x + 24, summaryPanel.y + 62, summaryPanel.w - 48, 24)
        widgets.drawButton(game.round_clear_buttons.shop, "SHOP", "primary")
        return
    end

    if clear.phase == "shop" then
        local shopLayout = game.shop_layout
        local shopPanel = shopLayout.panel

        play.drawLightFrame(
            shopPanel,
            81,
            61,
            18,
            3,
            { 0.08, 0.12, 0.16 },
            { 0.12, 0.52, 0.62 },
            { 0.16, 0.82, 0.54 },
            { 0.18, 0.48, 0.92 }
        )
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf("SHOP", shopPanel.x, shopPanel.y + 18, shopPanel.w, "center")
        love.graphics.printf("Pieces: " .. player.money, shopPanel.x + 18, shopPanel.y + 22, 160, "left")

        love.graphics.setColor(theme.panel_alt[1], theme.panel_alt[2], theme.panel_alt[3])
        love.graphics.rectangle("fill", shopLayout.laws.x, shopLayout.laws.y, shopLayout.laws.w, shopLayout.laws.h, 14, 14)
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf("LOI", shopLayout.laws.x, shopLayout.laws.y + 12, shopLayout.laws.w, "center")
        for _, entry in ipairs(game.shop_buttons.laws or {}) do
            cards.drawShopEntryCard(
                entry,
                entry.name,
                entry.description or "Loi",
                entry.display_price or entry.price,
                getShopCardState(player, entry)
            )
        end

        love.graphics.setColor(theme.panel_soft[1], theme.panel_soft[2], theme.panel_soft[3])
        love.graphics.rectangle("fill", shopLayout.buildings.x, shopLayout.buildings.y, shopLayout.buildings.w, shopLayout.buildings.h, 14, 14)
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf("BATIMENTS", shopLayout.buildings.x, shopLayout.buildings.y + 12, shopLayout.buildings.w, "center")
        for _, entry in ipairs(game.shop_buttons.buildings or {}) do
            cards.drawShopEntryCard(entry, entry.name, "Base " .. entry.base_score, entry.display_price or entry.price, getShopCardState(player, entry))
        end

        love.graphics.setColor(theme.panel_soft[1], theme.panel_soft[2], theme.panel_soft[3])
        love.graphics.rectangle("fill", shopLayout.objects.x, shopLayout.objects.y, shopLayout.objects.w, shopLayout.objects.h, 14, 14)
        love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3])
        love.graphics.printf("OBJETS", shopLayout.objects.x, shopLayout.objects.y + 12, shopLayout.objects.w, "center")
        for _, entry in ipairs(game.shop_buttons.items or {}) do
            cards.drawShopEntryCard(entry, entry.name, entry.description or "Objet", entry.display_price or entry.price, getShopCardState(player, entry))
        end

        love.graphics.printf("Lois: " .. #player.laws .. "/" .. player.MAX_LAWS, shopLayout.laws.x + shopLayout.laws.w - 150, shopLayout.laws.y - 26, 150, "right")
        love.graphics.printf("Objets: " .. #player.items .. "/" .. player.MAX_ITEMS, shopPanel.x + shopPanel.w - 174, shopPanel.y + 312, 150, "right")

        widgets.drawButton(game.round_clear_buttons.refresh, "RAFRAICHIR", "warning", player.money < 5, "5 pieces")
        widgets.drawButton(game.round_clear_buttons.continue, "CONTINUER", "primary")
    end
end

return round_clear
