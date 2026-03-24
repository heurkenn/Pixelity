-- src/systems/shop_state.lua
-- Tracks gameplay-side shop interactions like pending offers and explosive usage.

local shop_state = {}

function shop_state.useExplosive(game, player, grid, x, y)
    if not grid.isObstacle(x, y) then
        return false, "Aucun obstacle ici."
    end

    local explosiveIndex = nil
    for index, item in ipairs(player.items) do
        if item.id == "explosive" then
            explosiveIndex = index
            break
        end
    end

    if not explosiveIndex then
        return false, "Aucun EXPLOSIF disponible."
    end

    local item = player.items[explosiveIndex]
    local effect = item and item.effects and item.effects[1] or nil
    if not effect or effect.type ~= "remove_obstacle" then
        return false, "Objet invalide."
    end

    local preserved = love.math.random() < player.explosive_preserve_chance
    if not preserved then
        player.consumeItem(explosiveIndex)
    end

    grid.setCell(x, y, 0)

    local reward = love.math.random(effect.reward_min, effect.reward_max)
    player.addMoney(reward)
    game.selected_item_index = nil
    return true, "Obstacle detruit: +" .. reward .. " pieces."
end

return shop_state
