-- src/overlays/boss_intro.lua
-- Boss announcement overlay with explosion reveal before a boss round starts.

local fonts = require("src.ui.fonts")
local layout = require("src.ui.layout")
local widgets = require("src.ui.widgets")

local boss_intro = {}
local FRAME_DURATION = 0.1

-- Dessine le popup d'annonce d'un boss avant sa manche.
function boss_intro.draw(game)
    if game.state ~= "boss_intro" or not game.current_boss or not game.boss_intro then
        return
    end

    local bossAnnouncementRect = layout.getCenteredPopup(720, 360)
    local centerX = love.graphics.getWidth() / 2
    local titleY = bossAnnouncementRect.y + 86
    local descriptionY = bossAnnouncementRect.y + 184
    local continueButtonRect = layout.getBottomCenteredButton(bossAnnouncementRect, 180, 48, 26)

    game.boss_intro.continue_button = continueButtonRect

    widgets.drawOverlay(0.7)
    widgets.drawPopupFrame(bossAnnouncementRect)

    fonts.drawOutlinedText(game.current_boss.name, 0, titleY, {
        font = fonts.getTitleFont(),
        mode = "printf",
        limit = love.graphics.getWidth(),
        align = "center",
        outline = 1
    })

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(game.current_boss.description or "", bossAnnouncementRect.x + 60, descriptionY, bossAnnouncementRect.w - 120, "center")

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

    widgets.drawButton(continueButtonRect, "CONTINUER", "primary", not game.boss_intro.continue_ready)
end

return boss_intro
