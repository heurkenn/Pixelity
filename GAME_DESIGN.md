# 📘 GAME_DESIGN.md - Pixelity

## 🏗️ 1. Types d'objets
* **Bâtiment :** Pièce à jouer (unité de base).
* **Loi :** Bonus permettant d'amplifier des règles existantes.
* **Event :** Boss de fin de palier.
* **Obstacle :** Éléments générant des malus sur la grille.

---

## 🔁 2. Système de boucle et progression
* **Grille :** 5x5.
* **Objectif :** Atteindre un score cible à chaque manche.
* **Difficulté :** Le score à atteindre augmente à chaque manche.
* **Maires :** Choix d'un maire (spécialisation de base) au début de la partie. Nouveaux maires débloqués via les complétions du joueur.
* **Niveaux :** Plusieurs niveaux de difficultés à terme.

---

## 🌊 3. Événements (Boss)
* **Fréquence :** Toutes les 5 manches.
* **Exemple (TSUNAMI) :** Tous les bâtiments de la 2ème colonne disparaissent s'ils ne sont pas protégés.

---

## 💰 4. Économie et Shop
* **Fin de manche :** Présence d'un Shop systématique.
* **Revenus :** * Quantité fixe par manche.
    * Bonus via bâtiments (ex: Banque).
    * Bonus via lois (ex: Taxe sur habitation).
* **Gestion des obstacles :** Des objets dans le shop permettent de se débarrasser des obstacles (ex: roche, forêt) générés aléatoirement.