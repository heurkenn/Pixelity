# 🚀 Pixelity - Roadmap de Développement

## 🛠️ PHASE 1 : Architecture & Fondations (TERMINÉ)
- [x] Configurer `conf.lua` (1280x720).
- [x] Créer le module `src/game/grid.lua` (Matrice 5x5).
- [x] Créer le module `src/buildings.lua` (Data types & Sprites).
- [x] Gérer l'affichage et les animations (Fumée).
- [x] Fragmenter l'architecture UI/gameplay en helpers, scènes et systèmes.

## 🏗️ PHASE 2 : Game Flow & Deckbuilding
- [x] **Menu Initial :** Créer l'écran de Start et la sélection du **Maire** (Spécificités).
- [x] **Gestion du Deck :** Initialiser le deck de départ (5 Maisons, 3 Parcs, 1 Usine).
- [x] **Mécanique de Main :** Piocher 4 cartes aléatoirement, gérer l'affichage et la défausse.
- [x] **Bouton BUILD :** Créer l'interface pour valider la pose et lancer le tour.
- [x] **Calcul Séquentiel :** Coder l'algorithme de calcul case par case (balayage gauche -> droite).
- [x] **Feedback Visuel :** Illumination de la case en cours de calcul.

## 📈 PHASE 3 : Progression & Équilibrage
- [x] **Score Cible :** Fixer l'objectif à 100 pour la Manche 1.
- [x] **Difficulté :** Augmenter le score requis à chaque manche réussie.
- [x] **Obstacles :** Génération aléatoire de rochers/forêts sur la grille.
- [x] **Maires :** Ajouter des effets persistants de run (caps, multiplicateurs, conservation d'objet).
- [ ] **Déblocages :** Système de nouveaux Maires via les succès.

## 📉 PHASE 4 : Économie & Shop
- [x] **Le Shop :** Transition vers la boutique après une manche réussie.
- [x] **Lois :** Ajouter des bonus passifs permanents (Reliques).
- [x] **Monnaie ($) :** Gérer l'achat de nouvelles cartes pour améliorer le deck.
- [x] **Outils :** Objets pour supprimer les obstacles.
- [x] **Classeur :** Consulter les lois du joueur et les revendre à mi-prix.

## 🌊 PHASE 5 : Événements & Finitions
- [ ] **Boss (Event) :** Cycle de 5 manches (ex: Tsunami sur colonne 2).
- [x] **Game Over :** Écran de fin si le score cible n'est pas atteint.
- [x] **UI Finale :** Score flottant au-dessus des cases lors du calcul.
