-- src/app/input_play.lua
-- Mouse and keyboard interactions while the player is in a run.

local shared = require("src.app.input_shared")

local input_play = {}

function input_play.handleClick(ctx, x, y)
    local game = ctx.game
    local layout = ctx.layout
    local gameplay = ctx.gameplay
    local player = ctx.player
    local grid = ctx.grid
    local score = ctx.score
    local shop = ctx.shop
    local profile = ctx.profile
    local save = ctx.save

    if game.confirm_empty_build_open then
        if layout.pointInRect(x, y, game.confirm_modal.yes) then
            local placedCount = #game.pending_placements
            game.confirm_empty_build_open = false
            gameplay.finalizeBuild(game, player, grid, score)
            profile.recordBuildingsPlaced(placedCount)
            save.saveRun(game, player, grid)
            return true
        end

        if layout.pointInRect(x, y, game.confirm_modal.no) or not layout.pointInRect(x, y, game.confirm_modal.panel) then
            game.confirm_empty_build_open = false
            return true
        end
    end

    if game.resolving or game.dealing_timer > 0 then
        return true
    end

    if game.codex_open then
        if layout.pointInRect(x, y, game.codex_modal.close) or not layout.pointInRect(x, y, game.codex_modal.panel) then
            game.codex_open = false
            return true
        end
        if game.selected_codex_law_index and layout.pointInRect(x, y, game.codex_modal.sell_button) then
            local ok, message = shop.sellLaw(player, game.selected_codex_law_index)
            if ok and game.selected_codex_law_index > #player.laws then
                game.selected_codex_law_index = #player.laws > 0 and #player.laws or nil
            end
            game.message = message
            return true
        end
        for index, rect in ipairs(game.codex_modal.law_cards or {}) do
            if player.laws[index] and layout.pointInRect(x, y, rect) then
                game.selected_codex_law_index = index
                return true
            end
        end
        return true
    end

    if game.deck_view_open then
        if layout.pointInRect(x, y, game.deck_modal.close) or not layout.pointInRect(x, y, game.deck_modal.panel) then
            game.deck_view_open = false
        end
        return true
    end

    if layout.pointInRect(x, y, game.options_button) then
        game.options_open = not game.options_open
        return true
    end

    if game.options_open then
        return shared.handleOptionsClick(ctx, x, y)
    end

    if layout.pointInRect(x, y, game.build_button) then
        if #game.pending_placements == 0 and gameplay.hasCommittedBuildings(grid) and game.confirm_empty_build_enabled then
            game.confirm_empty_build_open = true
            return true
        end
        local placedCount = #game.pending_placements
        gameplay.finalizeBuild(game, player, grid, score)
        profile.recordBuildingsPlaced(placedCount)
        save.saveRun(game, player, grid)
        return true
    end

    if layout.pointInRect(x, y, game.redraw_button) then
        if player.redrawHand() then
            gameplay.updateHandStatusMessage(game, player, "Main redessinee.")
        else
            game.message = "Redraw impossible pour cette main."
        end
        return true
    end

    if layout.pointInRect(x, y, game.bottom_left_buttons.codex) then
        game.codex_open = true
        game.selected_codex_law_index = game.selected_codex_law_index or 1
        return true
    end

    if layout.pointInRect(x, y, game.bottom_left_buttons.deck) then
        game.deck_view_open = true
        return true
    end

    local gridX, gridY = layout.getCellFromScreen(x, y, grid)
    if gridX and gridY then
        if game.selected_item_index and player.items[game.selected_item_index] and player.items[game.selected_item_index].id == "explosive" then
            local used, message = gameplay.useExplosive(game, player, grid, gridX, gridY)
            if used then
                profile.recordObstacleDestroyed(1)
                save.saveRun(game, player, grid)
            end
            game.message = message
            return true
        end

        local pendingPlacement, pendingIndex = gameplay.getPendingPlacementAt(game, gridX, gridY)
        if pendingPlacement then
            gameplay.removePendingPlacement(game, player, pendingIndex)
            game.message = "Carte retournee dans la main."
            return true
        end

        if gameplay.tryPlaceSelectedCard(game, player, grid, gridX, gridY) then
            return true
        end
    end

    local handIndex = layout.getCardIndexAt(x, y, #player.hand)
    if handIndex then
        local cardX, cardY = layout.getCardRect(handIndex, #player.hand)
        game.dragging.active = true
        game.dragging.hand_index = handIndex
        game.dragging.card = player.hand[handIndex]
        game.dragging.offset_x = x - cardX
        game.dragging.offset_y = y - cardY
        game.dragging.x = x
        game.dragging.y = y
        game.selected_hand_index = handIndex
        return true
    end

    for index, rect in ipairs(game.item_slots or {}) do
        if player.items[index] and layout.pointInRect(x, y, rect) then
            if game.selected_item_index == index then
                game.selected_item_index = nil
            else
                game.selected_item_index = index
            end
            return true
        end
    end

    game.selected_hand_index = nil
    return true
end

function input_play.handleRelease(ctx, x, y, button)
    local game = ctx.game
    local grid = ctx.grid
    local gameplay = ctx.gameplay
    local player = ctx.player
    local layout = ctx.layout

    if button ~= 1 or game.state ~= "playing" or not game.dragging.active then
        return
    end

    local handIndex = game.dragging.hand_index
    local gridX, gridY = layout.getCellFromScreen(x, y, grid)

    if gridX and gridY then
        gameplay.placeCardFromHand(game, player, grid, handIndex, gridX, gridY)
    else
        game.selected_hand_index = handIndex
    end

    game.dragging.active = false
    game.dragging.hand_index = nil
    game.dragging.card = nil
end

function input_play.handleKey(ctx, key)
    if key == "return" and ctx.game.state == "playing" then
        local placedCount = #ctx.game.pending_placements
        ctx.gameplay.finalizeBuild(ctx.game, ctx.player, ctx.grid, ctx.score)
        ctx.profile.recordBuildingsPlaced(placedCount)
        ctx.save.saveRun(ctx.game, ctx.player, ctx.grid)
    end
end

return input_play
