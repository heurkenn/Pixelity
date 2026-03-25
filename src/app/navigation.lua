-- src/app/navigation.lua
-- Small state-navigation helpers for entry flow and mayor selection.

local mayor = require("src.data.mayor")

local navigation = {}

function navigation.getMayorById(id)
    return mayor.getData(id)
end

function navigation.selectRelativeMayor(game, direction)
    local currentIndex = 1
    for index, item in ipairs(mayor.types) do
        if item.id == game.selected_mayor_id then
            currentIndex = index
            break
        end
    end

    local nextIndex = currentIndex + direction
    if nextIndex < 1 then
        nextIndex = #mayor.types
    elseif nextIndex > #mayor.types then
        nextIndex = 1
    end

    game.selected_mayor_id = mayor.types[nextIndex].id
end

function navigation.openMenu(game)
    game.state = "menu"
    game.debug_open = false
    game.options_open = false
    game.stats_open = false
    game.menu_play_open = false
end

return navigation
