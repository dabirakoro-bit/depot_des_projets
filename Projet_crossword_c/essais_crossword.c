#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include "lexicon.h"

#define ROWS 15
#define COLS 15
#define EMPTY_CELL ' '

// --------------------------------------------------
// Amélioration du rendement : tri des mots par longueur décroissante
// --------------------------------------------------
int compare_by_length_desc_2d(const void *a, const void *b) {
    const char *pa = (const char *)a;
    const char *pb = (const char *)b;
    return strlen(pb) - strlen(pa); // retourne la différence de longueur pour qsort
}

// --------------------------------------------------
// Types et structures : pour eviter beaucoup de variable en entrée des fonctions
// --------------------------------------------------
typedef enum {
    NO_DIRECTION,
    VERTICAL,
    HORIZONTAL
} Direction;

// Structure pour gérer l’information d’une correspondance lettre / position
typedef struct {
    int index_mot;   // indice de la lettre dans le mot
    int row;         // position dans la grille
    int col;
} MatchInfo;

// Liste des mots pour le mode joueur
char words[MAX_WORDS][MAX_WORD_SIZE];

// --------------------------------------------------
// Initialisation et affichage de la grille
// --------------------------------------------------
void initialize_grid(char grid[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
            grid[i][j] = EMPTY_CELL; // initialise toutes les cases à vide
}

// Affichage grille pour le joueur (indices visibles)
void print_grid_player(char grid[ROWS][COLS]) {
    printf("    |");
    for (int j = 0; j < COLS; j++) printf("%2d|", j); // affiche indices colonnes
    printf("\n");

    printf("    +");
    for (int j = 0; j < COLS; j++) printf("---");
    printf("+\n");

    for (int i = 0; i < ROWS; i++) {
        printf("%3d |", i); // affiche indices lignes
        for (int j = 0; j < COLS; j++) {
            printf(" %c|", grid[i][j]);
        }
        printf("\n");
    }

    printf("    +");
    for (int j = 0; j < COLS; j++) printf("---");
    printf("+\n");
}

// Affichage grille classique
void print_grid(char grid[ROWS][COLS]) {
    printf("+");
    for (int j = 0; j < COLS; j++) printf("--");
    printf("+\n");

    for (int i = 0; i < ROWS; i++) {
        printf("|");
        for (int j = 0; j < COLS; j++) {
            printf("%c ", grid[i][j]);
        }
        printf("|\n");
    }

    printf("+");
    for (int j = 0; j < COLS; j++) printf("--");
    printf("+\n");
}

// --------------------------------------------------
// Vérification débordement
// --------------------------------------------------
int debordement_horizontal(MatchInfo m, int long_mot) {
    int debut_col = m.col - m.index_mot;                              // calcul colonne départ du mot
    int fin_col = debut_col + long_mot - 1;                          // calcul colonne fin du mot
    return (debut_col < 0 || fin_col >= COLS);                      // retourne true si déborde
}

int debordement_vertical(MatchInfo m, int long_mot) {
    int debut_ligne = m.row - m.index_mot;                            // calcul ligne départ
    int fin_ligne = debut_ligne + long_mot - 1;                      // calcul ligne fin
    return (debut_ligne < 0 || fin_ligne >= ROWS);                  // retourne true si déborde
}

// --------------------------------------------------
// Vérification placement possible
// --------------------------------------------------
Direction placement_possible(char grid[ROWS][COLS], const char* word, MatchInfo m) {
    int L = strlen(word);
    int r_match = m.row;
    int c_match = m.col;
    int k = m.index_mot;

    // --- Vertical ---
    int r_start = r_match - k; // ligne de départ en vertical
    if (r_start >= 0 && r_start + L <= ROWS) {
        bool ok = true;

        // Vérifie que les cases avant et après le mot sont vides
        if (r_start > 0 && grid[r_start - 1][c_match] != EMPTY_CELL) ok = false;
        if (r_start + L < ROWS && grid[r_start + L][c_match] != EMPTY_CELL) ok = false;

        for (int i = 0; i < L && ok; i++) {
            int r = r_start + i;
            int c = c_match;

            if (grid[r][c] != EMPTY_CELL && grid[r][c] != word[i]) ok = false;

            // Vérification des cases adjacentes uniquement pour les lettres autres que celle à l'intersection
            if (i != k) {
                if (c > 0 && grid[r][c - 1] != EMPTY_CELL) ok = false;
                if (c < COLS - 1 && grid[r][c + 1] != EMPTY_CELL) ok = false;
            }
        }
        if (ok) return VERTICAL;
    }

    // --- Horizontal ---
    int c_start = c_match - k; // colonne de départ en horizontal
    if (c_start >= 0 && c_start + L <= COLS) {
        bool ok = true;

        // Vérifie que les cases avant et après le mot sont vides
        if (c_start > 0 && grid[r_match][c_start - 1] != EMPTY_CELL) ok = false;
        if (c_start + L < COLS && grid[r_match][c_start + L] != EMPTY_CELL) ok = false;

        for (int i = 0; i < L && ok; i++) {
            int r = r_match;
            int c = c_start + i;

            if (grid[r][c] != EMPTY_CELL && grid[r][c] != word[i]) ok = false;

            // Vérification des cases adjacentes uniquement pour les lettres autres que celle à l'intersection
            if (i != k) {
                if (r > 0 && grid[r - 1][c] != EMPTY_CELL) ok = false;
                if (r < ROWS - 1 && grid[r + 1][c] != EMPTY_CELL) ok = false;
            }
        }
        if (ok) return HORIZONTAL;
    }

    return NO_DIRECTION; // placement impossible
}

// --------------------------------------------------
// Placement du mot dans la grille
// --------------------------------------------------
bool place_word(char grid[ROWS][COLS], const char* word, MatchInfo m, Direction dir) {
    int L = strlen(word);
    int r_start = m.row;
    int c_start = m.col;
    int k = m.index_mot;

    if (dir == VERTICAL) {
        r_start -= k; // calcule ligne de départ réelle
        for (int i = 0; i < L; i++) grid[r_start + i][c_start] = word[i]; 
        return true;
    } else if (dir == HORIZONTAL) {
        c_start -= k; // calcule colonne de départ réelle
        for (int i = 0; i < L; i++) grid[r_start][c_start + i] = word[i];
        return true;
    } 
    return false;
}


//nous avons péféré faire une fonction à part pour le placement du premier car j'ai décidé de chosisir le premier mot au hasard 
bool place_first_word(char grid[ROWS][COLS], const char* word, int row, int col, Direction dir) {
    int L = strlen(word);
    if (dir == HORIZONTAL) {
        if (col + L > COLS) return false; // vérifie débordement
        for (int i = 0; i < L; i++) grid[row][col + i] = word[i];
    } else {
        if (row + L > ROWS) return false; // vérifie débordement
        for (int i = 0; i < L; i++) grid[row + i][col] = word[i];
    }
    return true;
}



//fonction pour la géneration des dummys crossword 

void dummy_crossword_horizontal(char grid[ROWS][COLS], char lexicon[MAX_WORDS][MAX_WORD_SIZE], int lexicon_size) {
    for (int i = 0; i < lexicon_size && i < ROWS; i++) {
        place_first_word(grid, lexicon[i], i, 0, HORIZONTAL); // place mot sur chaque ligne
    }
}

void dummy_crossword_vertical(char grid[ROWS][COLS], char lexicon[MAX_WORDS][MAX_WORD_SIZE], int lexicon_size) {
    for (int j = 0; j < lexicon_size && j < COLS; j++) {
        place_first_word(grid, lexicon[j], 0, j, VERTICAL); // place mot sur chaque colonne
    }
}


// --------------------------------------------------
// Placement direct pour le mode joueur
// --------------------------------------------------
bool can_place_word_direct(char grid[ROWS][COLS], const char* word, int r, int c, Direction dir) {
    int L = strlen(word);

    if (dir == HORIZONTAL) {
        if (c + L > COLS) return false; // vérifie débordement
        for (int i = 0; i < L; i++) {
            char current = grid[r][c + i];
            if (current != EMPTY_CELL && current != word[i])
                return false; // impossibilité de placer si conflit
        }
    } else { // VERTICAL
        if (r + L > ROWS) return false; // vérifie débordement
        for (int i = 0; i < L; i++) {
            char current = grid[r + i][c];
            if (current != EMPTY_CELL && current != word[i])
                return false; // impossibilité de placer si conflit
        }
    }
    return true;
}

bool place_word_player_direct(char grid[ROWS][COLS], const char* word, int r, int c, Direction dir) {
    if (!can_place_word_direct(grid, word, r, c, dir)) return false;

    int L = strlen(word);
    if (dir == HORIZONTAL) {
        for (int i = 0; i < L; i++) grid[r][c + i] = word[i];
    } else {
        for (int i = 0; i < L; i++) grid[r + i][c] = word[i];
    }
    return true;
}

// --------------------------------------------------
// Génération d’un mot croisé
// --------------------------------------------------
bool gen_crossword(char grid[ROWS][COLS], const char* word) {
    int L = strlen(word);
    for (int i = 0; i < L; i++) {
        char target = word[i]; // lettre cible pour intersection
        for (int r = 0; r < ROWS; r++) {
            for (int c = 0; c < COLS; c++) {
                if (grid[r][c] == target) { // si lettre correspondante sur la grille
                    MatchInfo m = {i, r, c};
                    Direction d = placement_possible(grid, word, m);
                    if (d != NO_DIRECTION) {
                        place_word(grid, word, m, d);
                        return true;
                    }
                }
            }
        }
    }
    return false; // placement impossible
}

// --------------------------------------------------
// Fonction principale
// --------------------------------------------------
int main() {
    srand(time(NULL));

    char grid[ROWS][COLS];
    char lexicon[MAX_WORDS][MAX_WORD_SIZE];
    int lexicon_size;
    int choice;

    int best_score = 0;
    int player_score = 0;
    const char* best_first_word = NULL;

    read_lexicon("lexique", lexicon, &lexicon_size); // fonction pour lire lexique
  
    //fonction de trie des mots à placé (décroissant) 
   qsort(lexicon, lexicon_size, MAX_WORD_SIZE, compare_by_length_desc_2d);


    do {
        printf("\n===== MENU TEST CROSSWORD =====\n");
        printf("1 - Dummy crossword HORIZONTAL\n");
        printf("2 - Dummy crossword VERTICAL\n");
        printf("3 - VRAI crossword\n");
        printf("4 - Meilleur crossword\n");
        printf("5 - Mode player\n");
        printf("0 - Quitter\n");
        printf("Votre choix : ");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                initialize_grid(grid);
                dummy_crossword_horizontal(grid, lexicon, lexicon_size);
                print_grid(grid);
                break;

            case 2:
                initialize_grid(grid);
                dummy_crossword_vertical(grid, lexicon, lexicon_size);
                print_grid(grid);
                break;

            case 3: {
                initialize_grid(grid);
                int rand_index = rand() % lexicon_size;
                const char* first_word = lexicon[rand_index];
                int debut_ligne = ROWS / 2;
                int debut_col = (COLS - strlen(first_word)) / 2; // centre horizontal

                while (!place_first_word(grid, first_word, debut_ligne, debut_col, HORIZONTAL)) {
                    rand_index = rand() % lexicon_size;
                    first_word = lexicon[rand_index];
                }
                printf("Premier mot placé : %s\n", first_word);
                print_grid(grid);

                for (int i = 0; i < lexicon_size; i++) {
                    if (strcmp(lexicon[i], first_word) == 0) continue;
                    if (gen_crossword(grid, lexicon[i]))
                        printf("Mot placé : %s\n", lexicon[i]);
                    else
                        printf("Impossible de placer : %s\n", lexicon[i]);
                }
                print_grid(grid);
                break;
            }

            case 4: {
                best_score = 0;
                for (int f = 0; f < lexicon_size; f++) {
                    char temp_grid[ROWS][COLS];
                    initialize_grid(temp_grid);

                    const char* first_word = lexicon[f];
                    int debut_ligne = ROWS / 2;
                    int debut_col = (COLS - strlen(first_word)) / 2; // centre horizontal

                    if (!place_first_word(temp_grid, first_word, debut_ligne, debut_col, HORIZONTAL))
                        continue;

                    int score = 1;
                    for (int i = 0; i < lexicon_size; i++) {
                        if (i == f) continue;
                        if (gen_crossword(temp_grid, lexicon[i])) score++;
                    }

                    if (score > best_score) {
                        best_score = score;
                        best_first_word = first_word;
                        memcpy(grid, temp_grid, sizeof(grid)); // copie la grille gagnante
                    }
                }

                printf("\n===== MEILLEURE CONFIGURATION =====\n");
                printf("Premier mot : %s\n", best_first_word);
                printf("Nombre de mots placés : %d / %d\n", best_score, lexicon_size);
                print_grid(grid);
                break;
            }

            case 5: {
                printf("\n===== MODE JOUEUR PLACE LES MOTS =====\n");
                initialize_grid(grid);

                int rand_index = rand() % lexicon_size;
                const char* first_word = lexicon[rand_index];
                int debut_ligne = ROWS / 2;
                int debut_col = (COLS - strlen(first_word)) / 2;
                place_first_word(grid, first_word, debut_ligne, debut_col, HORIZONTAL);

                printf("Premier mot placé pour démarrer : %s\n", first_word);
                print_grid_player(grid);

                int word_count = 0;
                for (int i = 0; i < lexicon_size; i++) {
                    if (strcmp(lexicon[i], first_word) == 0) continue;
                    strcpy(words[word_count], lexicon[i]);
                    word_count++;
                }

                player_score = 0;
                for (int i = 0; i < word_count; i++) {
                    printf("\nMot à placer : %s\n", words[i]);
                    int r, c, dir_choice;
                    Direction dir;

                    printf("Entrez la ligne de départ (0-%d, -1 pour quitter) : ", ROWS-1);
                    scanf("%d", &r);
                    if (r == -1) break;
                    if (r < 0 || r >= ROWS) {
                        printf("Ligne hors limite !\n");
                        i--; // répéter le mot
                        continue;
                    }

                    printf("Entrez la colonne de départ (0-%d, -1 pour quitter) : ", COLS-1);
                    scanf("%d", &c);
                    if (c == -1) break;
                    if (c < 0 || c >= COLS) {
                        printf("Colonne hors limite !\n");
                        i--; // répéter le mot
                        continue;
                    }

                    printf("Direction (1 = HORIZONTAL, 2 = VERTICAL, -1 pour quitter) : ");
                    scanf("%d", &dir_choice);
                    if (dir_choice == -1) break;

                    if (dir_choice == 1)
                        dir = HORIZONTAL;
                    else if (dir_choice == 2)
                        dir = VERTICAL;
                    else {
                        printf("Direction invalide\n");
                        i--; // répéter le mot
                        continue;
                    }

                    if (place_word_player_direct(grid, words[i], r, c, dir)) {
                        printf("Placement valide !\n");
                        player_score++;
                        print_grid_player(grid);
                    } else {
                        printf("Placement invalide\n");
                        i--; // répéter le mot
                    }
                }

                printf("\n===== FIN DU MODE JOUEUR =====\n");
                printf("Votre score : %d / %d\n", player_score, word_count);
                break;
            }

            case 0:
                printf("Fin du programme.\n");
                break;

            default:
                printf("Choix invalide.\n");
        }

    } while (choice != 0);

}

