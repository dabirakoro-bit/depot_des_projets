# Crossword Generator in C

## Description

Ce projet consiste à générer automatiquement une grille de mots croisés en langage C.  
Le programme place un premier mot, puis tente de placer les autres mots du lexique en utilisant une méthode **brute force avec vérification des contraintes**.  
Il inclut également un mode interactif où un joueur peut placer lui-même les mots dans la grille.

## Fonctionnalités

- Lecture d’un lexique depuis un fichier (`lexique`)  
- Tri des mots à placer par longueur décroissante (pour faciliter le placement des mots longs)  
- Placement automatique du premier mot aléatoirement au centre de la grille  
- Recherche de **correspondances entre les lettres des mots** déjà placés et le mot à placer  
- Vérification des **débords horizontaux et verticaux**  
- Vérification des **cases voisines** pour éviter les collisions  
- Placement horizontal et vertical 
- Agorithme de géneration de la meuilleur configuration possible basé sur la methode brute force 
- Mode joueur interactif avec vérification du placement  

## Organisation du projet

.
├── crossword.c # Code principal du générateur
├── lexicon.h # Déclaration des constantes, types et fonctions liées au lexique
├── lexique # Fichier texte contenant la liste des mots
└── README.md 

## Compilation

```bash
gcc main.c crossword.c -o crossword


## Execution 

```bash
 ./crossword

 utiliser cette commande de préférence pour redirigé le resultat dans un fichier text pour la lisibilité
 ./crossword > crossword.txt 

## Principe de l’algorithme (méthode brute force)

1. Placement du premier mot au centre de la grille (choisi aléatoirement).  
2. Pour chaque mot restant du lexique :  
   - Recherche d’une lettre commune avec un mot déjà placé.  
   - Calcul de la position de départ à partir de la lettre commune.  
   - Test du débordement (ne pas dépasser les limites de la grille).  
   - Vérification des cases adjacentes pour éviter les collisions avec d’autres mots.  
   - Placement du mot si toutes les conditions sont respectées.  
3. Répétition jusqu’à ce que tous les mots soient placés ou que le placement soit impossible.  

## Algorithme du meilleur crossword

Le mode meilleur crossword vise à déterminer la configuration de grille permettant de placer le plus grand nombre de mots du lexique.

### Principe général

1. Chaque mot du lexique est testé successivement comme mot de départ.
2. Pour chaque mot testé :
   - Une grille vide est initialisée.
   - Le mot est placé au centre de la grille, horizontalement.
3. Les autres mots du lexique sont ensuite placés automatiquement en utilisant l’algorithme de placement par intersections.
4. Un score est calculé correspondant au nombre total de mots effectivement placés dans la grille.
5. La configuration obtenant le meilleur score est conservée.
6. À la fin du processus, la grille associée au score maximal est affichée.

### Objectif

Maximiser le nombre de mots placés dans la grille, sans chercher à optimiser la compacité ou la densité des croisements.


## Algorithme du mode joueur (mode interactif)

Le mode joueur permet à l’utilisateur de placer manuellement les mots dans la grille, en interaction directe avec le programme.  
Contrairement au mode automatique, l’objectif est de simplifier les règles de placement afin de rendre le jeu plus fluide et plus accessible.

### Principe général

1. Une grille vide est initialisée.
2. Un **premier mot est placé automatiquement** au centre de la grille, horizontalement, afin de fournir une base de départ.
3. Les mots restants du lexique sont proposés **un par un** au joueur.
4. Pour chaque mot, le joueur doit fournir :
   - La **ligne de départ**
   - La **colonne de départ**
   - La **direction** (horizontal ou vertical)
5. Le programme vérifie si le placement est valide selon des règles simplifiées.
6. Si le placement est valide :
   - Le mot est inscrit dans la grille
   - Le score du joueur est incrémenté
7. En cas d’erreur, le joueur est invité à recommencer le placement du même mot.
8. Le mode se termine lorsque :
   - Tous les mots ont été proposés
   - Ou que le joueur choisit de quitter

---

### Vérifications effectuées en mode joueur

Les vérifications suivantes sont systématiquement appliquées :

- Vérification des bornes de la grille (pas de débordement horizontal ou vertical)
- Vérification des conflits de lettres :
  - Une lettre peut être placée si la case est vide
  - Ou si la lettre correspond exactement à celle déjà présente
- Vérification du sens de placement (horizontal ou vertical valide)

Ces contrôles sont assurés par les fonctions :
- `can_place_word_direct`
- `place_word_player_direct`

---

### Contraintes volontairement non vérifiées en mode joueur

Afin d’alléger la charge algorithmique et de rendre le jeu plus agréable, certaines contraintes présentes dans le mode automatique ne sont pas vérifiées en mode joueur.

Ces choix sont volontaires et assumés.

#### Contraintes non vérifiées :

- **Absence d’obligation de croisement**
  - Le mot peut être placé sans partager de lettre avec un mot existant
- **Non-vérification des cases adjacentes**
  - Les lettres autour du mot (haut, bas, gauche, droite) ne sont pas contrôlées
- **Pas de vérification des cases avant et après le mot**
  - Un mot peut commencer ou se terminer juste à côté d’un autre mot
- **Pas de contrôle de densité ou de compacité de la grille**
- **Pas de pénalité pour les placements isolés**

---

### Justification de ces choix

Ces simplifications ont été introduites pour :

- Réduire la complexité du code en mode interactif
- Éviter des règles trop strictes qui pourraient frustrer le joueur
- Favoriser une expérience ludique plutôt qu’un placement strictement optimal
- Distinguer clairement :
  - le mode automatique (algorithmiquement rigoureux)
  - le mode joueur (orienté jeu et interaction)


## Améliorations possibles

- **Optimisation de l’algorithme de placement automatique**  
  Réduction du temps de brute force en limitant le nombre de positions testées, par exemple en priorisant les lettres rares ou en mémorisant les échecs de placement.

- **Gestion de plusieurs intersections par mot**  
  Actuellement, un mot est placé dès qu’une intersection valide est trouvée.  
  Une amélioration consisterait à tester plusieurs croisements possibles afin de choisir le placement maximisant la densité de la grille.

- **Génération de grilles plus compactes**  
  Ajout d’un critère d’évaluation basé sur l’aire occupée par les mots afin de favoriser des grilles plus regroupées et mieux structurées.

- **Amélioration du mode “meilleur crossword”**  
  Intégration de métriques plus avancées que le simple nombre de mots placés (nombre de croisements, compacité, équilibre horizontal / vertical).

- **Mode joueur enrichi**  
  Ajout progressif de contraintes optionnelles (croisement obligatoire, vérification des cases adjacentes) activables par niveau de difficulté.

- **Système de score plus élaboré**  
  Attribution de points en fonction :
  - du nombre de mots placés,
  - du nombre de croisements réalisés,
  - de la qualité du placement (densité, absence d’isolement).

- **Interface graphique (GUI)**  
  Développement d’une interface graphique pour le mode joueur afin d’améliorer l’ergonomie et l’expérience utilisateur.

- **Sauvegarde et chargement de grilles**  
  Possibilité d’enregistrer une grille générée ou partiellement remplie, puis de la recharger ultérieurement.

- **Support de grilles et lexiques paramétrables**  
  Permettre à l’utilisateur de définir la taille de la grille et de charger différents lexiques selon la langue ou le niveau de difficulté.
 

## Auteur

Dabira Koro
Ngowet Yacynthe

Étudiants à Polytech Lille
