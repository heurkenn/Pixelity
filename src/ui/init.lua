-- src/ui/init.lua
-- Thin orchestrator that delegates drawing to scene and helper modules.

local fonts = require("src.ui.fonts")
local intro_scene = require("src.menus.intro")
local menu_scene = require("src.menus.menu")
local stats_scene = require("src.menus.stats")
local boss_intro_scene = require("src.overlays.boss_intro")
local play_scene = require("src.game.play")
local options_scene = require("src.overlays.options")
local codex_scene = require("src.overlays.codex")
local deck_view_scene = require("src.overlays.deck_view")
local confirm_build_scene = require("src.overlays.confirm_build")
local setup_scene = require("src.menus.setup")
local game_over_scene = require("src.menus.game_over")
local round_clear_scene = require("src.overlays.round_clear")
local victory_scene = require("src.menus.victory")

local ui = {}

-- Charge les ressources graphiques transverses de l'UI.
function ui.loadAssets()
    fonts.load()
end

-- Applique la police standard de l'interface.
function ui.applyDefaultFont()
    fonts.applyDefault()
end

-- Dessine l'intro de lancement du jeu.
function ui.drawIntro(game)
    intro_scene.draw(game)
end

-- Dessine le menu principal.
function ui.drawMenu(game)
    menu_scene.draw(game)
end

-- Dessine l'intro specifique d'une manche boss.
function ui.drawBossIntro(game)
    boss_intro_scene.draw(game)
end

-- Dessine la fenetre de statistiques du profil.
function ui.drawStatsModal(game, profile)
    stats_scene.draw(game, profile)
end

-- Dessine la grille principale et ses placements temporaires.
function ui.drawGrid(game, grid, buildings, getPendingPlacementAt)
    play_scene.drawGrid(game, grid, buildings, getPendingPlacementAt)
end

-- Dessine la main du joueur.
function ui.drawHand(game, player)
    play_scene.drawHand(game, player)
end

-- Dessine l'animation de popup de score en cours.
function ui.drawScorePopup(game)
    play_scene.drawScorePopup(game)
end

-- Dessine le HUD principal pendant la partie.
function ui.drawHUD(game, player)
    play_scene.drawHUD(game, player)
end

-- Dessine la modal d'options.
function ui.drawOptionsModal(game)
    options_scene.draw(game)
end

-- Dessine la modal du classeur.
function ui.drawCodexModal(game, player)
    codex_scene.draw(game, player)
end

-- Dessine la modal de visualisation du deck.
function ui.drawDeckModal(game, player)
    deck_view_scene.draw(game, player)
end

-- Dessine la confirmation de BUILD vide.
function ui.drawConfirmBuild(game)
    confirm_build_scene.draw(game)
end

-- Dessine l'ecran de selection maire puis difficulte.
function ui.drawSetup(game, getMayorById, profile)
    setup_scene.draw(game, getMayorById, profile)
end

-- Dessine l'ecran de defaite de run.
function ui.drawGameOver(game, player)
    game_over_scene.draw(game, player)
end

-- Dessine l'ecran de victoire de run.
function ui.drawVictory(game, player)
    victory_scene.draw(game, player)
end

-- Dessine les differents overlays de fin de manche.
function ui.drawRoundClear(game, player)
    round_clear_scene.draw(game, player)
end

return ui
