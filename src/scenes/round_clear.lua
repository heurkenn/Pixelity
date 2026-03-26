-- src/scenes/round_clear.lua
-- Handles the inter-round overlays: banner, countdown, summary and shop.

local fonts = require("src.helpers.fonts")
local cards = require("src.helpers.cards")

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

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

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
        local panel = game.round_clear_panels.countdown
        local scoreFont = fonts.getScoreFont() or love.graphics.getFont()
        local scoreText = tostring(clear.score_display)
        local globalScoreText = tostring(clear.global_score_display)
        local scoreWidth = scoreFont:getWidth(scoreText)
        local globalScoreWidth = scoreFont:getWidth(globalScoreText)

        love.graphics.setColor(0.12, 0.14, 0.18)
        love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 16, 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Score de manche", panel.x, panel.y + 18, panel.w, "center")
        fonts.drawOutlinedText(scoreText, math.floor((panel.x + (panel.w / 2)) - (scoreWidth / 2)), panel.y + 82, {
            font = fonts.getScoreFont(),
            outline = 1
        })
        love.graphics.printf("Score global", panel.x, panel.y + 132, panel.w, "center")
        fonts.drawOutlinedText(globalScoreText, math.floor((panel.x + (panel.w / 2)) - (globalScoreWidth / 2)), panel.y + 154, {
            font = fonts.getScoreFont(),
            outline = 1
        })
        return
    end

    if clear.phase == "countdown_done" then
        local panel = game.round_clear_panels.countdown
        local scoreFont = fonts.getScoreFont() or love.graphics.getFont()
        local globalScoreText = tostring(clear.global_score_display)
        local globalScoreWidth = scoreFont:getWidth(globalScoreText)

        love.graphics.setColor(0.12, 0.14, 0.18)
        love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 16, 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Score global", panel.x, panel.y + 34, panel.w, "center")
        fonts.drawOutlinedText(globalScoreText, math.floor((panel.x + (panel.w / 2)) - (globalScoreWidth / 2)), panel.y + 88, {
            font = fonts.getScoreFont(),
            outline = 1
        })
        love.graphics.setColor(0.18, 0.44, 0.3)
        love.graphics.rectangle("fill", game.round_clear_buttons.continue.x, game.round_clear_buttons.continue.y, game.round_clear_buttons.continue.w, game.round_clear_buttons.continue.h, 12, 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SUIVANT", game.round_clear_buttons.continue.x, game.round_clear_buttons.continue.y + 18, game.round_clear_buttons.continue.w, "center")
        return
    end

    if clear.phase == "summary" then
        local panel = game.round_clear_panels.summary
        love.graphics.setColor(0.12, 0.14, 0.18)
        love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 16, 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Resume de manche", panel.x, panel.y + 18, panel.w, "center")

        local lineY = panel.y + 62
        for _, line in ipairs(clear.summary_lines) do
            love.graphics.printf(line, panel.x + 24, lineY, panel.w - 48, "left")
            lineY = lineY + 24
        end

        lineY = lineY + 12
        love.graphics.printf("Manche gagnee: + 3 pieces", panel.x + 24, lineY, panel.w - 48, "left")
        lineY = lineY + 24
        love.graphics.printf("Mains restantes " .. clear.remaining_hands .. ": +1*" .. clear.remaining_hands, panel.x + 24, lineY, panel.w - 48, "left")
        lineY = lineY + 24
        if clear.reward_bank and clear.reward_bank > 0 then
            love.graphics.printf("Pieces encaissees : " .. clear.reward_bank, panel.x + 24, lineY, panel.w - 48, "left")
            lineY = lineY + 24
        end
        love.graphics.printf("Total: +" .. clear.total_reward .. " pieces", panel.x + 24, lineY, panel.w - 48, "left")

        love.graphics.setColor(0.18, 0.44, 0.3)
        love.graphics.rectangle("fill", game.round_clear_buttons.shop.x, game.round_clear_buttons.shop.y, game.round_clear_buttons.shop.w, game.round_clear_buttons.shop.h, 12, 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SHOP", game.round_clear_buttons.shop.x, game.round_clear_buttons.shop.y + 18, game.round_clear_buttons.shop.w, "center")
        return
    end

    if clear.phase == "shop" then
        local shopLayout = game.shop_layout
        local panel = shopLayout.panel

        love.graphics.setColor(0.12, 0.14, 0.18)
        love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 18, 18)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SHOP", panel.x, panel.y + 18, panel.w, "center")
        love.graphics.printf("Pieces: " .. player.money, panel.x + 18, panel.y + 22, 160, "left")

        love.graphics.setColor(0.18, 0.22, 0.28)
        love.graphics.rectangle("fill", shopLayout.laws.x, shopLayout.laws.y, shopLayout.laws.w, shopLayout.laws.h, 14, 14)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("LOI", shopLayout.laws.x, shopLayout.laws.y + 12, shopLayout.laws.w, "center")
        for _, entry in ipairs(game.shop_buttons.laws or {}) do
            local effect = entry.effects and entry.effects[1] or {}
            cards.drawShopEntryCard(
                entry,
                entry.name,
                "+" .. (effect.bonus or 0) .. " / " .. (effect.segment_size or 0) .. " maisons",
                entry.display_price or entry.price,
                getShopCardState(player, entry)
            )
        end

        love.graphics.setColor(0.16, 0.2, 0.26)
        love.graphics.rectangle("fill", shopLayout.buildings.x, shopLayout.buildings.y, shopLayout.buildings.w, shopLayout.buildings.h, 14, 14)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("BATIMENTS", shopLayout.buildings.x, shopLayout.buildings.y + 12, shopLayout.buildings.w, "center")
        for _, entry in ipairs(game.shop_buttons.buildings or {}) do
            cards.drawShopEntryCard(entry, entry.name, "Base " .. entry.base_score, entry.display_price or entry.price, getShopCardState(player, entry))
        end

        love.graphics.setColor(0.16, 0.2, 0.26)
        love.graphics.rectangle("fill", shopLayout.objects.x, shopLayout.objects.y, shopLayout.objects.w, shopLayout.objects.h, 14, 14)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("OBJETS", shopLayout.objects.x, shopLayout.objects.y + 12, shopLayout.objects.w, "center")
        for _, entry in ipairs(game.shop_buttons.items or {}) do
            cards.drawShopEntryCard(entry, entry.name, entry.description or "Objet", entry.display_price or entry.price, getShopCardState(player, entry))
        end

        love.graphics.printf("Lois: " .. #player.laws .. "/" .. player.MAX_LAWS, shopLayout.laws.x + shopLayout.laws.w - 150, shopLayout.laws.y - 26, 150, "right")
        love.graphics.printf("Objets: " .. #player.items .. "/" .. player.MAX_ITEMS, panel.x + panel.w - 174, panel.y + 312, 150, "right")

        love.graphics.setColor(player.money >= 5 and 0.22 or 0.12, 0.34, 0.48)
        love.graphics.rectangle("fill", game.round_clear_buttons.refresh.x, game.round_clear_buttons.refresh.y, game.round_clear_buttons.refresh.w, game.round_clear_buttons.refresh.h, 12, 12)
        love.graphics.setColor(1, 1, 1, player.money >= 5 and 1 or 0.6)
        love.graphics.printf("RAFRAICHIR", game.round_clear_buttons.refresh.x, game.round_clear_buttons.refresh.y + 11, game.round_clear_buttons.refresh.w, "center")
        love.graphics.printf("5 pieces", game.round_clear_buttons.refresh.x, game.round_clear_buttons.refresh.y + 28, game.round_clear_buttons.refresh.w, "center")

        love.graphics.setColor(0.18, 0.44, 0.3)
        love.graphics.rectangle("fill", game.round_clear_buttons.continue.x, game.round_clear_buttons.continue.y, game.round_clear_buttons.continue.w, game.round_clear_buttons.continue.h, 12, 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("CONTINUER", game.round_clear_buttons.continue.x, game.round_clear_buttons.continue.y + 18, game.round_clear_buttons.continue.w, "center")
    end
end

return round_clear
