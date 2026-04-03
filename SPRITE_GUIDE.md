# Guide Sprite Isometrique

Ce projet est maintenant prepare pour une grille isometrique en gardant une logique de jeu en grille 5x5 classique.

## Grille

- empreinte d'une case au sol : `96x48`
- constante : [constants.lua](/home/kali/Pixelity/src/constants.lua)
  - `ISO_TILE_WIDTH = 96`
  - `ISO_TILE_HEIGHT = 48`

Chaque case est un losange isometrique.

## Batiments

Format recommande :

- extension : `PNG`
- fond : transparent
- feuille par batiment : `3 frames` sur une seule ligne
- taille recommandee par frame : `96x96`
- feuille recommandee complete : `288x96`

Le loader accepte deja automatiquement une feuille `3 colonnes`.

## Ancrage

Important :
- le batiment est dessine avec une ancre en bas-centre sur la case
- autrement dit, le bas du sprite doit representer le point de contact avec le sol

Concretement :
- le sprite peut depasser au-dessus de la case
- mais son pied doit tomber au centre bas du losange

## Sol / Objets hauts

Recommandation de proportions :

- petits batiments : `96x96`
- batiments plus hauts : `96x128` possible plus tard
- obstacles : idealement dans un cadre visuel proche de `96x64` a `96x96`

Si tu veux des batiments plus hauts plus tard, il suffira surtout d'ajuster `frame_height`.

## Nommage conseille

Pour rester coherent avec les chemins actuels :

- `assets/house_sheets.png`
- `assets/park_sheets.png`
- `assets/factory_sheets.png`
- `assets/bank_sheets.png`
- `assets/building_sheets.png`
- `assets/casino_sheets.png`
- `assets/townhall_sheets.png`

Pour les nouveaux :

- `assets/bourgeois_king_sheets.png`
- `assets/mec_donatien_sheets.png`

## Pipeline conseille

Pour chaque batiment :

1. creer une frame idle principale
2. dupliquer en 3 frames
3. faire de petites variations d'eclairage ou de detail
4. exporter en `PNG`

## Ce Qui Est Deja Pret Dans Le Code

- projection isometrique : [layout.lua](/home/kali/Pixelity/src/ui/layout.lua)
- rendu de la grille : [play.lua](/home/kali/Pixelity/src/game/play.lua)
- rendu des tuiles / sprites : [board.lua](/home/kali/Pixelity/src/ui/board.lua)
- chargement flexible des feuilles : [buildings.lua](/home/kali/Pixelity/src/data/buildings.lua)

## Conseils Pixel Art

- garde un ratio strict et des dimensions entieres
- evite les demi-pixels
- utilise `PNG`
- garde un contour lisible sur les silhouettes
- pense les sprites pour etre lisibles a petite taille avant de chercher trop de details
