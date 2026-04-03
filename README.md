# Pixelity

Pixelity est un prototype de city-builder / deckbuilder en pixel art construit avec `LÖVE 11.5` et `Lua`.

Le joueur choisit un maire, construit un deck, passe des manches de score croissant, affronte des boss de plateau, puis améliore sa run via un shop entre les manches.

## Etat Actuel Du Jeu

Le jeu contient deja :
- une intro et un menu principal
- une selection de maire et de difficulte
- une boucle de run jusqu'a 15 manches
- un systeme de deck / main / redraw
- un shop avec batiments, lois et objets
- plusieurs maires avec effets persistants
- plusieurs boss avec effets de manche
- une sauvegarde de run et un profil permanent
- un menu debug pour tester rapidement les scenes et les boss

## Stack Technique

- Runtime : [LÖVE 11.5](https://love2d.org/)
- Langage : `Lua`
- Pixel art / assets : `PNG`, `TTF`
- Pas de backend, pas de base de donnees, pas de librairie externe tierce

## Lancer Le Projet

Il faut lancer le dossier avec `LÖVE`.

Exemples selon l'installation :

```bash
love .
```

ou

```bash
love /home/kali/Pixelity
```

## Build

Des scripts de build sont disponibles pour :
- generer `dist/Pixelity.love`
- preparer un package Linux
- preparer un package Windows

Voir [BUILD.md](/home/kali/Pixelity/BUILD.md).

Raccourci principal :

```bash
./scripts/build.sh love
./scripts/build.sh linux
./scripts/build.sh windows
```

Sous Windows, un script PowerShell est aussi fourni :

```powershell
.\scripts\build.ps1
```

Nettoyage Windows :

```powershell
.\scripts\clean.ps1
```

## Structure Reelle

- `main.lua` : point d'entree LÖVE
- `src/app/` : orchestration racine, input, render, update, sauvegardes, profil
- `src/game/` : logique de partie, score, shop, rendu in-game
- `src/game/systems/` : flow de manche, resolution, boss, effets persistants
- `src/data/` : contenu declaratif du jeu
- `src/ui/` : layout, widgets, polices, cartes, theme
- `src/menus/` : intro, menu, setup, stats, victoire, defaite
- `src/overlays/` : options, deck, classeur, boss intro, fin de manche
- `src/debug/` : outils de debug et scenarios rapides

## Documentation Interne

Pour comprendre l'architecture plus vite :
- [PROJECT_FILES.md](/home/kali/Pixelity/PROJECT_FILES.md)
- [ARCHITECTURE_GUIDE.md](/home/kali/Pixelity/ARCHITECTURE_GUIDE.md)
- [SPRITE_GUIDE.md](/home/kali/Pixelity/SPRITE_GUIDE.md)

## Direction De Gameplay

Le coeur de Pixelity repose sur :
- la pose de cartes batiments sur une grille 5x5
- des bonus de voisinage
- des lois permanentes achetees au shop
- des objets tactiques
- des maires qui changent les regles de la run
- des boss qui perturbent la manche

## Etat De La Doc

Le projet a beaucoup evolue par rapport au README initial. Ce fichier resume maintenant l'etat reel du code, pas seulement l'intention de prototype.
