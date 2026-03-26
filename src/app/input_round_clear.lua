-- src/app/input_round_clear.lua
-- Mouse interactions during inter-round overlays and the shop phase.

local input_round_clear = {}

-- Gere les clics sur les ecrans de fin de manche, shop inclus.
function input_round_clear.handleClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout
    local gameplay = ctx.gameplay
    local shop = ctx.shop
    local player = ctx.player
    local grid = ctx.grid
    local profile = ctx.profile
    local save = ctx.save

    if game.round_clear and game.round_clear.phase == "countdown_done" and layout.pointInRect(x, y, game.round_clear_buttons.continue) then
        gameplay.openRoundSummary(game)
        return true
    end

    if game.round_clear and game.round_clear.phase == "summary" and layout.pointInRect(x, y, game.round_clear_buttons.shop) then
        gameplay.openShop(game, player)
        return true
    end

    if game.round_clear and game.round_clear.phase == "shop" then
        if layout.pointInRect(x, y, game.round_clear_buttons.refresh) then
            local ok, message = shop.refreshOffers(game, player)
            if ok then
                profile.recordMoneySpent(5)
                save.saveRun(game, player, grid)
            end
            game.message = message
            return true
        end

        for _, entry in ipairs(game.shop_buttons.buildings or {}) do
            if layout.pointInRect(x, y, entry) then
                local ok, message = shop.buyBuilding(player, entry.id)
                if ok then
                    profile.recordMoneySpent(entry.display_price or entry.price or 0)
                    shop.hideEntry(game, "building", entry.id)
                    save.saveRun(game, player, grid)
                end
                game.message = message
                return true
            end
        end

        for _, entry in ipairs(game.shop_buttons.laws or {}) do
            if layout.pointInRect(x, y, entry) then
                local ok, message = shop.buyLaw(player, entry.id)
                if ok then
                    profile.recordMoneySpent(entry.display_price or entry.price or 0)
                    shop.hideEntry(game, "law", entry.id)
                    save.saveRun(game, player, grid)
                end
                game.message = message
                return true
            end
        end

        for _, entry in ipairs(game.shop_buttons.items or {}) do
            if layout.pointInRect(x, y, entry) then
                local ok, message = shop.buyItem(player, entry.id)
                if ok then
                    profile.recordMoneySpent(entry.display_price or entry.price or 0)
                    shop.hideEntry(game, "item", entry.id)
                    save.saveRun(game, player, grid)
                end
                game.message = message
                return true
            end
        end
    end

    if game.round_clear and game.round_clear.phase == "shop" and layout.pointInRect(x, y, game.round_clear_buttons.continue) then
        gameplay.startNextRound(game, player, grid)
        return true
    end

    return true
end

return input_round_clear
