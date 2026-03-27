# 🏗️ Pixelity

Un city-builder minimaliste en Pixel Art axé sur les **synergies de placement**. 
Optimisez votre score en plaçant intelligemment vos bâtiments sur une grille limitée.

## 🕹️ Concept
Le joueur reçoit des bâtiments aléatoires (tuiles) qu'il doit placer sur une grille. 
Chaque bâtiment génère des points de **Prospérité** en fonction de ses voisins. 

L'objectif est d'atteindre des paliers de score pour débloquer de nouvelles zones ou des bâtiments spéciaux (Monuments) avant que la grille ne soit saturée.

## 🛠️ Stack Technique
- **Moteur :** [LÖVE 11.5](https://love2d.org/) (Lua)
- **Graphismes :** Pixel Art (Aseprite / LibreSprite)
- **Vue :** Top-down (vue de dessus) sur une grille de 8x8 ou 10x10.

## 🏢 Systèmes de Synergies (Exemples)
- **Zone Résidentielle :** +10 pts. Bonus si adjacente à un Parc.
- **Zone Commerciale :** Multiplie les points des zones Résidentielles voisines.
- **Zone Industrielle :** Gros points de base, mais malus de proximité pour le Résidentiel.
- **Parc :** Bonus fixe, augmente la valeur de tout ce qui l'entoure.

## 📂 Structure du Projet
- `main.lua` : Gestion de la boucle de jeu et des états.
- `src/game/grid.lua` : Logique de la grille (placement, détection de voisins).
- `src/buildings.lua` : Bibliothèque des types de bâtiments et leurs règles.
- `src/ui/init.lua` : Affichage du score, de la main et des menus.
