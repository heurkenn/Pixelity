-- main.lua

local grid = require("src.grid")
local buildings = require("src.buildings")
local score = require("src.score")
local player = require("src.player")
local mayor = require("src.mayor")
local constants = require("src.constants")
local layout = require("src.layout")
local ui = require("src.ui")
local gameplay = require("src.gameplay")
local shop = require("src.shop")
local intro = require("src.scenes.intro")
local game_state = require("src.app.game_state")
local navigation = require("src.app.navigation")
local input = require("src.app.input")

-- main.lua now stays intentionally thin:
-- it creates the root state, loads shared assets and delegates input/update/draw.
local game = game_state.create()
local app_context = nil

local function updateButtons()
    layout.updateButtons(game, mayor.types, constants.DIFFICULTIES, constants.SCORING_SPEED_OPTIONS)
    shop.updateLayout(game, player)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    buildings.loadImages()
    ui.loadAssets()
    ui.applyDefaultFont()
    intro.load(game)

    for _, mayorData in ipairs(mayor.types) do
        if mayorData.portrait and love.filesystem.getInfo(mayorData.portrait) then
            game.mayor_portraits[mayorData.id] = love.graphics.newImage(mayorData.portrait)
            game.mayor_portraits[mayorData.id]:setFilter("nearest", "nearest")
        end
    end

    intro.reset(game)
    app_context = {
        game = game,
        player = player,
        grid = grid,
        layout = layout,
        gameplay = gameplay,
        shop = shop,
        score = score,
        navigation = navigation
    }
    updateButtons()
end

function love.update(dt)
    updateButtons()

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

    if game.state == "round_clear" then
        gameplay.updateRoundClear(game, player, dt)
    end
end

function love.draw()
    love.graphics.clear(0.1, 0.11, 0.14)
    ui.applyDefaultFont()

    if game.state == "splash" then
        ui.drawIntro(game)
        return
    end

    if game.state == "menu" then
        ui.drawMenu(game)
        ui.drawOptionsModal(game)
        return
    end

    if game.state == "setup" then
        ui.drawSetup(game, navigation.getMayorById)
        ui.drawOptionsModal(game)
        return
    end

    if game.state == "gameover" then
        ui.drawGameOver(game, player)
        return
    end

    ui.drawGrid(game, grid, buildings, function(x, y)
        return gameplay.getPendingPlacementAt(game, x, y)
    end)

    if game.state == "round_clear" then
        ui.drawRoundClear(game, player)
        return
    end

    ui.drawHUD(game, player, function()
        return gameplay.getDifficulty(game)
    end)
    ui.drawHand(game, player)
    ui.drawScorePopup(game)
    ui.drawConfirmBuild(game)
    ui.drawOptionsModal(game)
    ui.drawCodexModal(game, player)
    ui.drawDeckModal(game, player)
end

function love.mousepressed(x, y, button)
    input.mousepressed(app_context, x, y, button)
end

function love.mousereleased(x, y, button)
    input.mousereleased(app_context, x, y, button)
end

function love.keypressed(key)
    input.keypressed(app_context, key)
end
