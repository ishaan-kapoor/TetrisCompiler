#include "header.h"
#include <stdlib.h>
#include <string.h>

lexemeType NewSymbol(char *lexeme) {
  lexemeType newSymbol = (lexemeType)malloc(sizeof(_lexemeType));
  newSymbol->literalName = strdup(lexeme);
  return newSymbol;
}
