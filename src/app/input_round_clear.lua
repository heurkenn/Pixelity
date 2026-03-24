-- src/app/input_round_clear.lua
-- Mouse interactions during inter-round overlays and the shop phase.

local input_round_clear = {}

function input_round_clear.handleClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout
    local gameplay = ctx.gameplay
    local shop = ctx.shop
    local player = ctx.player
    local grid = ctx.grid

    if game.round_clear and game.round_clear.phase == "countdown_done" and layout.pointInRect(x, y, game.round_clear_buttons.continue) then
        gameplay.openRoundSummary(game)
        return true
    end

    if game.round_clear and game.round_clear.phase == "summary" and layout.pointInRect(x, y, game.round_clear_buttons.shop) then
        gameplay.openShop(game)
        return true
    end

    if game.round_clear and game.round_clear.phase == "shop" then
        for _, entry in ipairs(game.shop_buttons.buildings or {}) do
            if layout.pointInRect(x, y, entry) then
                local ok, message = shop.buyBuilding(player, entry.id)
                if ok then
                    shop.hideEntry(game, "building", entry.id)
                end
                game.message = message
                return true
            end
        end

        for _, entry in ipairs(game.shop_buttons.laws or {}) do
            if layout.pointInRect(x, y, entry) then
                local ok, message = shop.buyLaw(player, entry.id)
                if ok and not player.allow_duplicate_laws then
                    shop.hideEntry(game, "law", entry.id)
                end
                game.message = message
                return true
            end
        end

        for _, entry in ipairs(game.shop_buttons.items or {}) do
            if layout.pointInRect(x, y, entry) then
                local ok, message = shop.buyItem(player, entry.id)
                if ok then
                    shop.hideEntry(game, "item", entry.id)
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
