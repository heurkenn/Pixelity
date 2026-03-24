-- src/ui.lua
-- Thin orchestrator that delegates drawing to scene and helper modules.

local fonts = require("src.helpers.fonts")
local intro_scene = require("src.scenes.intro")
local menu_scene = require("src.scenes.menu")
local play_scene = require("src.scenes.play")
local options_scene = require("src.scenes.options")
local codex_scene = require("src.scenes.codex")
local deck_view_scene = require("src.scenes.deck_view")
local confirm_build_scene = require("src.scenes.confirm_build")
local setup_scene = require("src.scenes.setup")
local game_over_scene = require("src.scenes.game_over")
local round_clear_scene = require("src.scenes.round_clear")

local ui = {}

function ui.loadAssets()
    fonts.load()
end

function ui.applyDefaultFont()
    fonts.applyDefault()
end

function ui.drawIntro(game)
    intro_scene.draw(game)
end

function ui.drawMenu(game)
    menu_scene.draw(game)
end

function ui.drawGrid(game, grid, buildings, getPendingPlacementAt)
    play_scene.drawGrid(game, grid, buildings, getPendingPlacementAt)
end

function ui.drawHand(game, player)
    play_scene.drawHand(game, player)
end

function ui.drawScorePopup(game)
    play_scene.drawScorePopup(game)
end

function ui.drawHUD(game, player)
    play_scene.drawHUD(game, player)
end

function ui.drawOptionsModal(game)
    options_scene.draw(game)
end

function ui.drawCodexModal(game, player)
    codex_scene.draw(game, player)
end

function ui.drawDeckModal(game, player)
    deck_view_scene.draw(game, player)
end

function ui.drawConfirmBuild(game)
    confirm_build_scene.draw(game)
end

function ui.drawSetup(game, getMayorById)
    setup_scene.draw(game, getMayorById)
end

function ui.drawGameOver(game, player)
    game_over_scene.draw(game, player)
end

function ui.drawRoundClear(game, player)
    round_clear_scene.draw(game, player)
end

return ui
