#ifndef EXTETRICKSTYPE_H
#define EXTETRICKSTYPE_H

typedef struct {
  char *literalName;
} _lexemeType;

typedef _lexemeType *lexemeType;
#define YYSTYPE lexemeType 

/* define linked list node for the hash table slots */
/* also define hashtable for the symbol table */

#include "grammar.tab.h"

extern lexemeType NewSymbol(char *lexeme);

#endif /* ndef EXTETRICKSTYPE_H */
