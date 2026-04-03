# Project Files

Ce document donne un resume rapide du role de chaque fichier principal du projet.

## Racine

- [`main.lua`](/home/kali/Pixelity/main.lua) : point d'entree LÖVE, branche les modules racine et les callbacks.
- [`conf.lua`](/home/kali/Pixelity/conf.lua) : configuration de la fenetre LÖVE.
- [`README.md`](/home/kali/Pixelity/README.md) : presentation generale du projet.
- [`TODO.md`](/home/kali/Pixelity/TODO.md) : roadmap de developpement.
- [`PROJECT_FILES.md`](/home/kali/Pixelity/PROJECT_FILES.md) : resume des fichiers du codebase.
- [`ARCHITECTURE_GUIDE.md`](/home/kali/Pixelity/ARCHITECTURE_GUIDE.md) : guide de lecture de l'architecture, du runtime LÖVE et des fichiers centraux.

## src

- [`src/constants.lua`](/home/kali/Pixelity/src/constants.lua) : constantes globales de gameplay et de layout.

## src/data

- [`src/data/buildings.lua`](/home/kali/Pixelity/src/data/buildings.lua) : catalogue des batiments, prix, effets et sprites.
- [`src/data/law.lua`](/home/kali/Pixelity/src/data/law.lua) : catalogue des lois et de leurs effets.
- [`src/data/mayor.lua`](/home/kali/Pixelity/src/data/mayor.lua) : catalogue des maires, portraits et effets.
- [`src/data/object.lua`](/home/kali/Pixelity/src/data/object.lua) : catalogue des objets utilisables.
- [`src/data/boss.lua`](/home/kali/Pixelity/src/data/boss.lua) : catalogue des boss et de leurs effets.
- [`src/data/rounds.lua`](/home/kali/Pixelity/src/data/rounds.lua) : table des scores cibles et des manches boss.

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
- [`src/app/video.lua`](/home/kali/Pixelity/src/app/video.lua) : gestion des modes fenetre, plein ecran et plein ecran fenetre.

## src/game

- [`src/game/gameplay.lua`](/home/kali/Pixelity/src/game/gameplay.lua) : facade de gameplay qui relie la grille, le score, la pioche et les systemes de manche.
- [`src/game/grid.lua`](/home/kali/Pixelity/src/game/grid.lua) : grille 5x5, cases, obstacles et niveaux d'Immeuble.
- [`src/game/play.lua`](/home/kali/Pixelity/src/game/play.lua) : rendu principal de la partie, HUD, main et effets visuels de gameplay.
- [`src/game/player.lua`](/home/kali/Pixelity/src/game/player.lua) : etat du joueur, deck, main, lois, objets et economie.
- [`src/game/score.lua`](/home/kali/Pixelity/src/game/score.lua) : calcul du score de grille, des lois et des bonus de maire.
- [`src/game/shop.lua`](/home/kali/Pixelity/src/game/shop.lua) : logique du shop, offres, layout des achats et achat/vente.

## src/game/systems

- [`src/game/systems/bosses.lua`](/home/kali/Pixelity/src/game/systems/bosses.lua) : ordre des boss, intros et effets de destruction pendant la manche.
- [`src/game/systems/mayor_effects.lua`](/home/kali/Pixelity/src/game/systems/mayor_effects.lua) : application des effets persistants des maires.
- [`src/game/systems/resolution.lua`](/home/kali/Pixelity/src/game/systems/resolution.lua) : resolution temporelle du score et des effets boss.
- [`src/game/systems/round_flow.lua`](/home/kali/Pixelity/src/game/systems/round_flow.lua) : cycle de manche, succes/echec, reward et transition de run.
- [`src/game/systems/shop_state.lua`](/home/kali/Pixelity/src/game/systems/shop_state.lua) : utilisation gameplay des objets comme l'explosif.

## src/menus

- [`src/menus/game_over.lua`](/home/kali/Pixelity/src/menus/game_over.lua) : ecran de defaite.
- [`src/menus/intro.lua`](/home/kali/Pixelity/src/menus/intro.lua) : intro de lancement avec explosions et fade.
- [`src/menus/menu.lua`](/home/kali/Pixelity/src/menus/menu.lua) : menu principal.
- [`src/menus/setup.lua`](/home/kali/Pixelity/src/menus/setup.lua) : selection du maire puis de la difficulte.
- [`src/menus/stats.lua`](/home/kali/Pixelity/src/menus/stats.lua) : popup des statistiques globales du profil.
- [`src/menus/victory.lua`](/home/kali/Pixelity/src/menus/victory.lua) : ecran de victoire de run.

## src/overlays

- [`src/overlays/boss_intro.lua`](/home/kali/Pixelity/src/overlays/boss_intro.lua) : popup d'introduction d'un boss avant sa manche.
- [`src/overlays/codex.lua`](/home/kali/Pixelity/src/overlays/codex.lua) : popup du classeur avec maire, lois et revente.
- [`src/overlays/confirm_build.lua`](/home/kali/Pixelity/src/overlays/confirm_build.lua) : popup de confirmation du `BUILD` vide.
- [`src/overlays/deck_view.lua`](/home/kali/Pixelity/src/overlays/deck_view.lua) : popup de visualisation de la main, du deck et de la defausse.
- [`src/overlays/options.lua`](/home/kali/Pixelity/src/overlays/options.lua) : popup d'options de partie et d'affichage.
- [`src/overlays/round_clear.lua`](/home/kali/Pixelity/src/overlays/round_clear.lua) : banner, decompte, resume et shop inter-manche.

## src/debug

- [`src/debug/menu.lua`](/home/kali/Pixelity/src/debug/menu.lua) : panneau debug avec raccourcis de test.
- [`src/debug/scenarios.lua`](/home/kali/Pixelity/src/debug/scenarios.lua) : etats de test preconstruits.

## src/ui

- [`src/ui/board.lua`](/home/kali/Pixelity/src/ui/board.lua) : aides de rendu pour la grille et ses cellules.
- [`src/ui/cards.lua`](/home/kali/Pixelity/src/ui/cards.lua) : primitives de dessin pour cartes, fleches et boutons.
- [`src/ui/fonts.lua`](/home/kali/Pixelity/src/ui/fonts.lua) : chargement des polices et texte outline.
- [`src/ui/init.lua`](/home/kali/Pixelity/src/ui/init.lua) : routeur de rendu vers les differentes scenes et overlays.
- [`src/ui/layout.lua`](/home/kali/Pixelity/src/ui/layout.lua) : calcul des rectangles UI, boutons et zones cliquables.
- [`src/ui/theme.lua`](/home/kali/Pixelity/src/ui/theme.lua) : palette de couleurs partagee pour harmoniser l'interface.
- [`src/ui/widgets.lua`](/home/kali/Pixelity/src/ui/widgets.lua) : widgets UI communs comme popups, boutons et cartes d'information.
