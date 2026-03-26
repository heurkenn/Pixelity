-- main.lua

local grid = require("src.grid")
local buildings = require("src.data.buildings")
local score = require("src.score")
local player = require("src.player")
local mayor = require("src.data.mayor")
local constants = require("src.constants")
local layout = require("src.layout")
local ui = require("src.ui")
local gameplay = require("src.gameplay")
local shop = require("src.shop")
local game_state = require("src.app.game_state")
local navigation = require("src.app.navigation")
local input = require("src.app.input")
local update = require("src.app.update")
local render = require("src.app.render")
local profile = require("src.app.profile")
local save = require("src.app.save")

-- main.lua now stays intentionally thin:
-- it creates the root state, loads shared assets and delegates input/update/draw.
local game = game_state.create()
local app_context = nil

-- Recalcule tous les rectangles interactifs et le layout dynamique.
local function updateButtons()
    layout.updateButtons(game, mayor.types, constants.DIFFICULTIES, constants.SCORING_SPEED_OPTIONS)
    if game.state == "round_clear" and game.round_clear and game.round_clear.phase == "shop" then
        shop.updateLayout(game, player)
    end
end

-- Charge les assets partages, l'etat global et le contexte applicatif.
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    buildings.loadImages()
    ui.loadAssets()
    ui.applyDefaultFont()
    require("src.scenes.intro").load(game)
    profile.load()

    for _, mayorData in ipairs(mayor.types) do
        if mayorData.portrait and love.filesystem.getInfo(mayorData.portrait) then
            game.mayor_portraits[mayorData.id] = love.graphics.newImage(mayorData.portrait)
            game.mayor_portraits[mayorData.id]:setFilter("nearest", "nearest")
        end
    end

    require("src.scenes.intro").reset(game)
    save.refreshFlag(game)
    app_context = {
        game = game,
        player = player,
        grid = grid,
        layout = layout,
        gameplay = gameplay,
        shop = shop,
        score = score,
        profile = profile,
        save = save,
        navigation = navigation,
        ui = ui,
        buildings = buildings
    }
    updateButtons()
end

-- Met a jour le layout courant puis delegue la logique d'update.
function love.update(dt)
    updateButtons()
    update.run(app_context, dt)
end

-- Delegue tout le rendu au routeur principal de scenes.
function love.draw()
    render.draw(app_context)
end

-- Transmet les clics souris au routeur d'input applicatif.
function love.mousepressed(x, y, button)
    input.mousepressed(app_context, x, y, button)
end

-- Transmet les relachements souris a la logique de drag and drop.
function love.mousereleased(x, y, button)
    input.mousereleased(app_context, x, y, button)
end

-- Transmet les touches clavier aux etats concernes.
function love.keypressed(key)
    input.keypressed(app_context, key)
end

-- Transmet la molette souris aux ecrans qui utilisent du scroll.
function love.wheelmoved(x, y)
    input.wheelmoved(app_context, x, y)
end
