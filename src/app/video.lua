-- src/app/video.lua
-- Gere les changements de mode d'affichage depuis les options.

local video = {}

local WINDOWED_WIDTH = 1280
local WINDOWED_HEIGHT = 720

-- Applique le mode fenetre standard du jeu.
function video.setWindowed(game)
    love.window.setMode(WINDOWED_WIDTH, WINDOWED_HEIGHT, {
        resizable = false,
        vsync = 1,
        fullscreen = false
    })
    game.video_mode = "windowed"
end

-- Applique un plein ecran exclusif.
function video.setFullscreen(game)
    local _, _, flags = love.window.getMode()
    love.window.setMode(0, 0, {
        resizable = false,
        vsync = 1,
        fullscreen = true,
        fullscreentype = "exclusive",
        display = flags and flags.display or 1
    })
    game.video_mode = "fullscreen"
end

-- Applique un plein ecran fenetre sans bordure.
function video.setBorderlessFullscreen(game)
    local _, _, flags = love.window.getMode()
    love.window.setMode(0, 0, {
        resizable = false,
        vsync = 1,
        fullscreen = true,
        fullscreentype = "desktop",
        display = flags and flags.display or 1
    })
    game.video_mode = "borderless"
end

return video
