# Guide D'Architecture

Ce document sert a comprendre rapidement l'infra du projet, les briques utilisees par LÖVE, et dans quel ordre lire les fichiers.

## 1. Stack Reelle

- Langage : `Lua`
- Runtime / moteur : `LÖVE 11.5`
- Architecture : projet local sans backend, sans base de donnees, sans librairie externe tierce

En pratique, Pixelity repose surtout sur :
- les API natives de `LÖVE`
- la librairie standard de `Lua`
- les modules internes du dossier `src/`

## 2. Quelles "librairies" sont utilisees

### LÖVE

C'est la seule vraie dependance runtime du jeu.

Modules LÖVE utilises dans le projet :
- `love.graphics`
- `love.window`
- `love.filesystem`
- `love.timer`
- `love.math`
- `love.mouse`
- `love.event`

### Librairie standard Lua

Fonctions natives Lua tres presentes :
- `ipairs`, `pairs`
- `type`, `tostring`
- `pcall`
- `math.floor`, `math.max`, `math.min`, `math.ceil`, `math.sin`
- `table.insert`, `table.remove`, `table.sort`, `table.concat`
- `string.format`, `string.match`

Il n'y a pas de framework externe de type `loveframes`, `hump`, `knife`, `middleclass`, etc.

## 3. Fonctions LÖVE natives importantes a connaitre

### Boucle principale

Dans [main.lua](/home/kali/Pixelity/main.lua) :
- `love.load()`
- `love.update(dt)`
- `love.draw()`
- `love.mousepressed(x, y, button)`
- `love.mousereleased(x, y, button)`
- `love.keypressed(key)`
- `love.wheelmoved(x, y)`

Ce sont les points d'entree du moteur.

### Rendu

Fonctions LÖVE utilisees tres souvent :
- `love.graphics.clear(...)`
- `love.graphics.setColor(...)`
- `love.graphics.rectangle(...)`
- `love.graphics.printf(...)`
- `love.graphics.print(...)`
- `love.graphics.draw(...)`
- `love.graphics.newImage(...)`
- `love.graphics.newFont(...)`
- `love.graphics.setFont(...)`
- `love.graphics.getWidth()`
- `love.graphics.getHeight()`
- `love.graphics.setScissor(...)`
- `love.graphics.setDefaultFilter(...)`

### Fenetre / affichage

Dans [video.lua](/home/kali/Pixelity/src/app/video.lua) :
- `love.window.setMode(...)`
- `love.window.getMode()`

### Sauvegarde

Dans [save.lua](/home/kali/Pixelity/src/app/save.lua) et [profile.lua](/home/kali/Pixelity/src/app/profile.lua) :
- `love.filesystem.getInfo(...)`
- `love.filesystem.load(...)`
- `love.filesystem.write(...)`
- `love.filesystem.remove(...)`

### Temps / hasard / input

- `love.timer.getTime()`
- `love.math.random()`
- `love.mouse.getPosition()`
- `love.event.quit()`

## 4. Comment le jeu est organise

Le code est decoupe par domaine.

### `src/app`

Le "cerveau" racine de l'application :
- creation de l'etat global
- routing input / update / render
- sauvegardes
- profil permanent
- navigation entre scenes
- modes video

Fichiers a lire en premier :
- [game_state.lua](/home/kali/Pixelity/src/app/game_state.lua)
- [render.lua](/home/kali/Pixelity/src/app/render.lua)
- [update.lua](/home/kali/Pixelity/src/app/update.lua)
- [input.lua](/home/kali/Pixelity/src/app/input.lua)

### `src/game`

Le coeur du gameplay :
- grille
- joueur
- score
- shop
- rendu de la partie
- facade gameplay

Fichiers centraux :
- [gameplay.lua](/home/kali/Pixelity/src/game/gameplay.lua)
- [grid.lua](/home/kali/Pixelity/src/game/grid.lua)
- [player.lua](/home/kali/Pixelity/src/game/player.lua)
- [score.lua](/home/kali/Pixelity/src/game/score.lua)
- [shop.lua](/home/kali/Pixelity/src/game/shop.lua)
- [play.lua](/home/kali/Pixelity/src/game/play.lua)

### `src/game/systems`

Les sous-systemes metier du gameplay :
- flow de manche
- resolution du score
- boss
- effets persistants de maire
- objets utilises en partie

Ordre conseille :
- [round_flow.lua](/home/kali/Pixelity/src/game/systems/round_flow.lua)
- [resolution.lua](/home/kali/Pixelity/src/game/systems/resolution.lua)
- [bosses.lua](/home/kali/Pixelity/src/game/systems/bosses.lua)
- [shop_state.lua](/home/kali/Pixelity/src/game/systems/shop_state.lua)
- [mayor_effects.lua](/home/kali/Pixelity/src/game/systems/mayor_effects.lua)

### `src/data`

Tout le contenu declaratif :
- batiments
- lois
- objets
- maires
- boss
- progression des manches

Ces fichiers sont les meilleurs points d'entree si tu veux equilibrer le jeu sans toucher a l'infra.

### `src/ui`

Les briques partagees de l'interface :
- polices
- theme de couleurs
- widgets generiques
- layout
- rendu de cartes
- rendu de grille
- routeur UI

Ordre conseille :
- [layout.lua](/home/kali/Pixelity/src/ui/layout.lua)
- [widgets.lua](/home/kali/Pixelity/src/ui/widgets.lua)
- [cards.lua](/home/kali/Pixelity/src/ui/cards.lua)
- [board.lua](/home/kali/Pixelity/src/ui/board.lua)
- [init.lua](/home/kali/Pixelity/src/ui/init.lua)

### `src/menus`

Les scenes de haut niveau :
- intro
- menu principal
- setup
- stats
- victoire
- defaite

### `src/overlays`

Les popups / ecrans secondaires affiches au-dessus du jeu :
- options
- classeur
- etat du deck
- confirmation
- intro boss
- fin de manche / shop

### `src/debug`

Le menu debug et les scenarios de test rapides.

## 5. Dans quel ordre lire les fichiers

Si tu veux comprendre l'infra du projet rapidement, lis dans cet ordre :

1. [main.lua](/home/kali/Pixelity/main.lua)
2. [game_state.lua](/home/kali/Pixelity/src/app/game_state.lua)
3. [render.lua](/home/kali/Pixelity/src/app/render.lua)
4. [update.lua](/home/kali/Pixelity/src/app/update.lua)
5. [input.lua](/home/kali/Pixelity/src/app/input.lua)
6. [gameplay.lua](/home/kali/Pixelity/src/game/gameplay.lua)
7. [round_flow.lua](/home/kali/Pixelity/src/game/systems/round_flow.lua)
8. [resolution.lua](/home/kali/Pixelity/src/game/systems/resolution.lua)
9. [score.lua](/home/kali/Pixelity/src/game/score.lua)
10. [player.lua](/home/kali/Pixelity/src/game/player.lua)
11. [grid.lua](/home/kali/Pixelity/src/game/grid.lua)
12. [shop.lua](/home/kali/Pixelity/src/game/shop.lua)
13. [layout.lua](/home/kali/Pixelity/src/ui/layout.lua)
14. [widgets.lua](/home/kali/Pixelity/src/ui/widgets.lua)
15. [play.lua](/home/kali/Pixelity/src/game/play.lua)
16. [data/*.lua](/home/kali/Pixelity/src/data/buildings.lua)

Si tu veux d'abord comprendre "ce que fait le jeu" plutot que "comment le runtime est cable", commence par :
- [src/data/buildings.lua](/home/kali/Pixelity/src/data/buildings.lua)
- [src/data/law.lua](/home/kali/Pixelity/src/data/law.lua)
- [src/data/mayor.lua](/home/kali/Pixelity/src/data/mayor.lua)
- [src/data/object.lua](/home/kali/Pixelity/src/data/object.lua)
- [src/data/boss.lua](/home/kali/Pixelity/src/data/boss.lua)
- [src/data/rounds.lua](/home/kali/Pixelity/src/data/rounds.lua)

## 6. Comment circule une frame

Le flux principal est :

1. `main.lua` recoit les callbacks LÖVE
2. [update.lua](/home/kali/Pixelity/src/app/update.lua) met a jour l'etat selon `game.state`
3. [render.lua](/home/kali/Pixelity/src/app/render.lua) choisit quoi dessiner
4. [ui/init.lua](/home/kali/Pixelity/src/ui/init.lua) delegue vers la bonne scene
5. les handlers d'input dans `src/app/input*.lua` modifient l'etat global

La plupart des transitions passent par `game.state` :
- `splash`
- `menu`
- `setup`
- `playing`
- `boss_intro`
- `round_clear`
- `gameover`
- `victory`

## 7. Sauvegardes

Il y a deux types de persistence :

- sauvegarde de run en cours :
  [save.lua](/home/kali/Pixelity/src/app/save.lua)

- profil permanent :
  [profile.lua](/home/kali/Pixelity/src/app/profile.lua)

Le profil stocke :
- debloquages
- stats globales
- preferences

La sauvegarde de run stocke :
- etat de la partie courante
- grille
- deck / main / defausse
- shop courant
- manche et boss courant

## 8. Ou modifier quoi

Pour modifier :

- une regle de score :
  [score.lua](/home/kali/Pixelity/src/game/score.lua)

- un flow de manche :
  [round_flow.lua](/home/kali/Pixelity/src/game/systems/round_flow.lua)

- un boss :
  [boss.lua](/home/kali/Pixelity/src/data/boss.lua) puis [bosses.lua](/home/kali/Pixelity/src/game/systems/bosses.lua)

- un maire :
  [mayor.lua](/home/kali/Pixelity/src/data/mayor.lua) puis [mayor_effects.lua](/home/kali/Pixelity/src/game/systems/mayor_effects.lua)

- le shop :
  [shop.lua](/home/kali/Pixelity/src/game/shop.lua)

- le HUD / les popups :
  [play.lua](/home/kali/Pixelity/src/game/play.lua), [widgets.lua](/home/kali/Pixelity/src/ui/widgets.lua), [layout.lua](/home/kali/Pixelity/src/ui/layout.lua)

- le contenu achetable :
  `src/data/*.lua`

## 9. Ce qu'il faut retenir

- Il n'y a pas de framework complexe cache.
- Le coeur du runtime tient dans `main.lua` + `src/app`.
- Le vrai gameplay vit dans `src/game` et `src/game/systems`.
- Les donnees de contenu sont deja bien separees dans `src/data`.
- L'UI partagee passe par `src/ui/layout.lua`, `src/ui/widgets.lua`, `src/ui/cards.lua`.

Si tu dois retenir 5 fichiers avant les autres :
- [main.lua](/home/kali/Pixelity/main.lua)
- [src/app/render.lua](/home/kali/Pixelity/src/app/render.lua)
- [src/app/input.lua](/home/kali/Pixelity/src/app/input.lua)
- [src/game/gameplay.lua](/home/kali/Pixelity/src/game/gameplay.lua)
- [src/game/systems/round_flow.lua](/home/kali/Pixelity/src/game/systems/round_flow.lua)
