#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include "lexicon_include.h"


#define ROWS 15            // nombre de lignes de la grille
#define COLS 15            // nombre de colonnes de la grille
#define EMPTY_CELL '.'     // caractère représentant une case vide



typedef enum { HORIZONTAL, VERTICAL } Direction;

//initialisation de la grille
void initialize_grid(char grid[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            grid[i][j] = EMPTY_CELL;
        }
    }
}

// Fonction pour afficher la grille
void display_grid(char grid[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            printf("%c ", grid[i][j]);
        }
        printf("\n");
    }
}



bool place_first_word(char grid[ROWS][COLS], const char* word, int row, int col, Direction dir) {
    int word_len = strlen(word);

    // Vérifier si le mot rentre dans la grille
    if (dir == HORIZONTAL) {
        if (col + word_len > COLS) return false;  // débordement
        for (int j = 0; j < word_len; j++)
            grid[row][col + j] = word[j];        // placer les lettres
    } else { // VERTICAL
        if (row + word_len > ROWS) return false;  // débordement
        for (int i = 0; i < word_len; i++)
            grid[row + i][col] = word[i];        // placer les lettres
    }

    return true;
}



int main() {
  srand(time(NULL)) ; 
    char grid[ROWS][COLS];
    char lexicon[MAX_WORDS][MAX_WORD_SIZE];
    int lexicon_size; 
    
    read_lexicon("lexique",lexicon,&lexicon_size);
    initialize_grid(grid);
    
    int  rand_index = rand() % lexicon_size;    
    const char* first_word = lexicon[rand_index];

    // Premier mot à placer
    // Placer horizontalement au centre de la grille
    int start_row = ROWS / 2;
    int start_col = (COLS - strlen(first_word)) / 2;
     
     while(!place_first_word(grid, first_word, start_row, start_col, HORIZONTAL)){
           rand_index = rand() % lexicon_size;    
           first_word = lexicon[rand_index];

    } 
     printf("Premier mot placé : %s\n", first_word);
    display_grid(grid);

    return 0;
}




