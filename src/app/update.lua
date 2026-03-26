-- src/app/update.lua
-- State-based update router for the root application loop.

local intro = require("src.scenes.intro")

local update = {}

-- Route la mise a jour frame par frame vers l'etat actif du jeu.
function update.run(ctx, dt)
    local game = ctx.game
    local navigation = ctx.navigation
    local gameplay = ctx.gameplay
    local player = ctx.player
    local profile = ctx.profile

    if game.state == "splash" then
        intro.update(game, dt)
        if intro.isFinished(game) then
            navigation.openMenu(game)
        end
        return
    end

    if game.state == "playing" then
        if game.dealing_timer > 0 then
            game.dealing_timer = math.max(0, game.dealing_timer - dt)
        end

        if game.dragging.active then
            local mouseX, mouseY = love.mouse.getPosition()
            game.dragging.x = mouseX
            game.dragging.y = mouseY
        end

        gameplay.updateResolution(game, player, dt)
        return
    end

    if game.state == "boss_intro" then
        gameplay.updateBossIntro(game, dt)
        return
    end

    if game.state == "round_clear" then
        gameplay.updateRoundClear(game, player, dt)
        profile.updateBestScore(player.total_score or 0)
    end
end

return update
