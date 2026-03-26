-- conf.lua

-- Configure l'identite LÖVE et les parametres de fenetre du jeu.
function love.conf(t)
    t.identity = "pixelity"
    t.version = "11.5"

    t.window.title = "Pixelity"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = false
    t.window.vsync = 1

    t.modules.physics = false
    t.modules.joystick = false
end
