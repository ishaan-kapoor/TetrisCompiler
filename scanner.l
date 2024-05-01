%{
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "header.h"

void yyerror(char*);
int yylex();
%}

%%
^"Section1"$ { fprintf(stderr, "Sec%d", 1); return SECTION1; }
^"Section2"$ { fprintf(stderr, "Sec%d", 2); return SECTION2; }
^"Section3"$ { fprintf(stderr, "Sec%d", 3); return SECTION3; }

"and"        { fprintf(stderr, "%s", yytext); return OP_AND; }
"call"       { fprintf(stderr, "%s", yytext); return CALL; }
"else"       { fprintf(stderr, "%s", yytext); return ELSE; }
"end"        { fprintf(stderr, "%s", yytext); return END; }
"if"         { fprintf(stderr, "%s", yytext); return IF; } 
"neg"        { fprintf(stderr, "%s", yytext); return OP_NEG; }
"not"        { fprintf(stderr, "%s", yytext); return OP_NOT; }
"or"         { fprintf(stderr, "%s", yytext); return OP_OR; }
"play"       { fprintf(stderr, "%s", yytext); return PLAY; }
"return"     { fprintf(stderr, "%s", yytext); return RETURN; }
"then"       { fprintf(stderr, "%s", yytext); return THEN; }
"while"      { fprintf(stderr, "%s", yytext); return WHILE; }
"with"       { fprintf(stderr, "%s", yytext); return WITH; }

"("          { fprintf(stderr, "%s", yytext); return BRACKET_PAREN_OPEN; }
")"          { fprintf(stderr, "%s", yytext); return BRACKET_PAREN_CLOSE; }
"*"          { fprintf(stderr, "%s", yytext); return OP_MUL; }
"+"          { fprintf(stderr, "%s", yytext); return OP_ADD; }
"-"          { fprintf(stderr, "%s", yytext); return OP_SUB; }
"=="         { fprintf(stderr, "%s", yytext); return OP_EQUAL; }
"="          { fprintf(stderr, "%s", yytext); return ASSIGN; }
">"          { fprintf(stderr, "%s", yytext); return GREATER_THAN; }
"<"          { fprintf(stderr, "%s", yytext); return LESSER_THAN; }
"["          { fprintf(stderr, "%s", yytext); return BRACKET_SQ_OPEN; }
"]"          { fprintf(stderr, "%s", yytext); return BRACKET_SQ_CLOSE; }
"{"          { fprintf(stderr, "%s", yytext); return BRACKET_CURLY_OPEN; }
"}"          { fprintf(stderr, "%s", yytext); return BRACKET_CURLY_CLOSE; }

^#.*[\n\r]         { fprintf(stderr, "# Comment: %s", yytext); }
[\n\r]+      { fprintf(stderr, "\n"); return NEWLINE; }
[ \t]+       { fprintf(stderr, " "); } // Delimeter

[\+\-]?[0-9][0-9]*(\.[0-9]+)?                      { fprintf(stderr, "%s", yytext); yylval = NewSymbol(yytext);return NUM; }
[a-zA-Z_][A-Za-z0-9_]*(\.[a-zA-Z_][A-Za-z0-9_]*)?  { fprintf(stderr, "%s", yytext); yylval = NewSymbol(yytext); return ID; }

.            { fprintf(stderr, "(UNKNOWN=%s)", yytext); return *yytext; }
%%

int yywrap() { return 1; }
