-- src/scenes/boss_intro.lua
-- Boss announcement overlay with explosion reveal before a boss round starts.

local fonts = require("src.helpers.fonts")

local boss_intro = {}
local FRAME_DURATION = 0.1

function boss_intro.draw(game)
    if game.state ~= "boss_intro" or not game.current_boss or not game.boss_intro then
        return
    end

    local panel = {
        x = (love.graphics.getWidth() - 720) / 2,
        y = (love.graphics.getHeight() - 360) / 2,
        w = 720,
        h = 360
    }
    local centerX = love.graphics.getWidth() / 2
    local titleY = panel.y + 86
    local descriptionY = panel.y + 184
    local buttonRect = {
        x = centerX - 90,
        y = panel.y + panel.h - 74,
        w = 180,
        h = 48
    }

    game.boss_intro.continue_button = buttonRect

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0.12, 0.14, 0.18)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.w, panel.h, 18, 18)

    fonts.drawOutlinedText(game.current_boss.name, 0, titleY, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(game.current_boss.description or "", panel.x + 60, descriptionY, panel.w - 120, "center")

    local frames = game.intro and game.intro.explosion_frames or {}
    for _, effect in ipairs(game.boss_intro.explosions or {}) do
        local frameIndex = math.floor((effect.timer or 0) / FRAME_DURATION) + 1
        local image = frameIndex <= #frames and frames[frameIndex] or nil
        if image then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(
                image,
                effect.x,
                effect.y,
                0,
                effect.scale or 1.4,
                effect.scale or 1.4,
                image:getWidth() / 2,
                image:getHeight() / 2
            )
        end
    end

    love.graphics.setColor(game.boss_intro.continue_ready and 0.18 or 0.12, 0.44, 0.3)
    love.graphics.rectangle("fill", buttonRect.x, buttonRect.y, buttonRect.w, buttonRect.h, 12, 12)
    love.graphics.setColor(1, 1, 1, game.boss_intro.continue_ready and 1 or 0.6)
    love.graphics.printf("CONTINUER", buttonRect.x, buttonRect.y + 16, buttonRect.w, "center")
end

return boss_intro
