-- src/scenes/game_over.lua
-- Simple game over screen displayed when the target score is missed.

local game_over = {}

function game_over.draw(game, player)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Over", 0, 180, love.graphics.getWidth(), "center")
    love.graphics.printf("Score final: " .. player.round_score, 0, 228, love.graphics.getWidth(), "center")
    love.graphics.printf("Pieces: " .. player.money, 0, 260, love.graphics.getWidth(), "center")
    love.graphics.printf(game.message, 0, 300, love.graphics.getWidth(), "center")
end

return game_over
