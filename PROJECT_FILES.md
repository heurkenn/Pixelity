# Project Files

Ce document donne un resume rapide du role de chaque fichier principal du projet.

## Racine

- [`main.lua`](/home/kali/Pixelity/main.lua) : point d'entree LÖVE, branche les modules racine et les callbacks.
- [`conf.lua`](/home/kali/Pixelity/conf.lua) : configuration de la fenetre LÖVE.
- [`README.md`](/home/kali/Pixelity/README.md) : presentation generale du projet.
- [`TODO.md`](/home/kali/Pixelity/TODO.md) : roadmap de developpement.
- [`PROJECT_FILES.md`](/home/kali/Pixelity/PROJECT_FILES.md) : resume des fichiers du codebase.

## src

- [`src/constants.lua`](/home/kali/Pixelity/src/constants.lua) : constantes globales de gameplay et de layout.
- [`src/gameplay.lua`](/home/kali/Pixelity/src/gameplay.lua) : facade de logique gameplay qui delegue aux systemes.
- [`src/grid.lua`](/home/kali/Pixelity/src/grid.lua) : grille 5x5, acces aux cases et gestion des obstacles.
- [`src/layout.lua`](/home/kali/Pixelity/src/layout.lua) : calcul des rectangles UI, boutons et zones cliquables.
- [`src/player.lua`](/home/kali/Pixelity/src/player.lua) : etat du joueur, deck, main, lois, objets et economie.
- [`src/score.lua`](/home/kali/Pixelity/src/score.lua) : calcul du score de grille, des lois et des bonus de maire.
- [`src/shop.lua`](/home/kali/Pixelity/src/shop.lua) : offres du shop, layout des achats et logique d'achat/vente.
- [`src/ui.lua`](/home/kali/Pixelity/src/ui.lua) : routeur de rendu vers les differentes scenes UI.

## src/data

- [`src/data/buildings.lua`](/home/kali/Pixelity/src/data/buildings.lua) : catalogue des batiments, prix, effets et sprites.
- [`src/data/law.lua`](/home/kali/Pixelity/src/data/law.lua) : catalogue des lois et de leurs effets.
- [`src/data/mayor.lua`](/home/kali/Pixelity/src/data/mayor.lua) : catalogue des maires, portraits et effets.
- [`src/data/object.lua`](/home/kali/Pixelity/src/data/object.lua) : catalogue des objets utilisables.

## src/app

- [`src/app/game_state.lua`](/home/kali/Pixelity/src/app/game_state.lua) : construit la table `game` racine.
- [`src/app/input.lua`](/home/kali/Pixelity/src/app/input.lua) : routeur principal des inputs par etat.
- [`src/app/input_menu.lua`](/home/kali/Pixelity/src/app/input_menu.lua) : inputs du splash/menu/setup.
- [`src/app/input_play.lua`](/home/kali/Pixelity/src/app/input_play.lua) : inputs pendant la partie.
- [`src/app/input_round_clear.lua`](/home/kali/Pixelity/src/app/input_round_clear.lua) : inputs des ecrans de fin de manche et shop.
- [`src/app/input_shared.lua`](/home/kali/Pixelity/src/app/input_shared.lua) : helpers d'input partages, surtout pour les options.
- [`src/app/navigation.lua`](/home/kali/Pixelity/src/app/navigation.lua) : changements d'etat simples et selection de maire.
- [`src/app/profile.lua`](/home/kali/Pixelity/src/app/profile.lua) : progression permanente, debloquages et statistiques globales.
- [`src/app/render.lua`](/home/kali/Pixelity/src/app/render.lua) : routeur du rendu principal selon l'etat.
- [`src/app/save.lua`](/home/kali/Pixelity/src/app/save.lua) : sauvegarde et chargement de l'etat persistant d'une run.
- [`src/app/update.lua`](/home/kali/Pixelity/src/app/update.lua) : routeur de mise a jour principal selon l'etat.

## src/helpers

- [`src/helpers/board.lua`](/home/kali/Pixelity/src/helpers/board.lua) : aides de rendu pour la grille et ses cellules.
- [`src/helpers/cards.lua`](/home/kali/Pixelity/src/helpers/cards.lua) : primitives de dessin pour cartes, fleches et boutons.
- [`src/helpers/fonts.lua`](/home/kali/Pixelity/src/helpers/fonts.lua) : chargement des polices et texte outline.

## src/scenes

- [`src/scenes/codex.lua`](/home/kali/Pixelity/src/scenes/codex.lua) : popup du classeur avec maire, lois et revente.
- [`src/scenes/confirm_build.lua`](/home/kali/Pixelity/src/scenes/confirm_build.lua) : popup de confirmation du `BUILD` vide.
- [`src/scenes/debug_menu.lua`](/home/kali/Pixelity/src/scenes/debug_menu.lua) : menu debug avec raccourcis de test.
- [`src/scenes/deck_view.lua`](/home/kali/Pixelity/src/scenes/deck_view.lua) : popup de visualisation deck/main/defausse.
- [`src/scenes/game_over.lua`](/home/kali/Pixelity/src/scenes/game_over.lua) : ecran de fin de partie.
- [`src/scenes/intro.lua`](/home/kali/Pixelity/src/scenes/intro.lua) : intro complete avec titre, fade et explosions.
- [`src/scenes/menu.lua`](/home/kali/Pixelity/src/scenes/menu.lua) : menu principal.
- [`src/scenes/options.lua`](/home/kali/Pixelity/src/scenes/options.lua) : popup d'options.
- [`src/scenes/play.lua`](/home/kali/Pixelity/src/scenes/play.lua) : rendu principal de la partie, HUD, main et grille.
- [`src/scenes/round_clear.lua`](/home/kali/Pixelity/src/scenes/round_clear.lua) : banner, decompte, resume et shop inter-manche.
- [`src/scenes/setup.lua`](/home/kali/Pixelity/src/scenes/setup.lua) : selection du maire puis de la difficulte.
- [`src/scenes/stats.lua`](/home/kali/Pixelity/src/scenes/stats.lua) : popup des statistiques globales du profil.

## src/systems

- [`src/systems/debug_scenarios.lua`](/home/kali/Pixelity/src/systems/debug_scenarios.lua) : etats de test preconstruits.
- [`src/systems/mayor_effects.lua`](/home/kali/Pixelity/src/systems/mayor_effects.lua) : application des effets persistants des maires.
- [`src/systems/resolution.lua`](/home/kali/Pixelity/src/systems/resolution.lua) : resolution temporelle du score case par case.
- [`src/systems/round_flow.lua`](/home/kali/Pixelity/src/systems/round_flow.lua) : cycle de manche, succes/echec et transitions.
- [`src/systems/shop_state.lua`](/home/kali/Pixelity/src/systems/shop_state.lua) : usage des objets et etat gameplay lie au shop.
