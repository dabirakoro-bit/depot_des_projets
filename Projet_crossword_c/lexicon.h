#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#define MAX_WORD_SIZE 30
#define MAX_WORDS 30

/* Loads a lexicon from a file.
 *    filename: the path to the file containing the lexicon
 *    lexicon: contains the lexicon when function terminates
 *    lexicon_size: contains the number of words of the lexicon when function terminates
 */
void read_lexicon(const char* filename, char lexicon[MAX_WORDS][MAX_WORD_SIZE], int* lexicon_size) {
  FILE* lex_file;

  if((lex_file=fopen(filename, "r")) == NULL) {
    fprintf(stderr,"Cannot open file %s\n", filename);
    exit(1);
  }
  *lexicon_size=0;
  while(*lexicon_size<MAX_WORDS && fscanf(lex_file, "%s",lexicon[*lexicon_size])!=EOF)
    (*lexicon_size)++;
}
