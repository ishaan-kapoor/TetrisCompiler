%debug
%{
#include <math.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "header.h"
#define STRLEN 2048
void yyerror(char *s) {
  fprintf(stderr,"%s\n",s);
  return;
}
extern int yylex();
extern int yywrap();
lexemeType alloc() {
  lexemeType tmp = malloc(sizeof(lexemeType));
  tmp->literalName = malloc(STRLEN);
  memset(tmp->literalName, 0, STRLEN);
  return tmp;
}
extern char* yytext;
char* indent(char* body) {
  char* ans = malloc(STRLEN);
  memset(ans, 0, STRLEN);
  char* line = strtok(body, "\n");
  while(line != NULL) {
    sprintf(ans, "%s    %s\n", ans, line);
    line = strtok(NULL, "\n");
  }
  free(body);
  return ans;
}
const char set_args[] = "    for c in kwargs: exec(f'{c} = {kwargs.get(c)}')\n";
const char verbatim[] = "def Print(value=None): print(value)\nfrom engine import TetrisEngine\n\nengine = TetrisEngine()\ndef pre_play(*args, **kwargs): pass\ndef post_play(*args, **kwargs): pass\ndef play(*args, **kwargs):\n    pre_play(*args, **kwargs)\n    engine.run(*args, **kwargs)\n    post_play(*args, **kwargs)\n";
%}

%token SECTION1 SECTION2 SECTION3 NEWLINE IF THEN ELSE END WHILE CALL WITH OP_OR OP_AND OP_NOT OP_NEG PLAY NUM ID BRACKET_SQ_OPEN BRACKET_SQ_CLOSE BRACKET_PAREN_OPEN BRACKET_PAREN_CLOSE BRACKET_CURLY_OPEN BRACKET_CURLY_CLOSE OP_MUL OP_ADD OP_SUB ASSIGN DELIMETER RETURN GREATER_THAN LESSER_THAN OP_EQUAL

%%
START: VERBATIM SECTION1 NEWLINE PRIMITIVE SECTION2 NEWLINE FUNCTIONS SECTION3 NEWLINE ENGINE VERBATIM { $$ = alloc(); sprintf($$->literalName, "%s\n%s\n%s\n%s\n\n", verbatim, $4->literalName, $7->literalName, $10->literalName); printf("%s", $$->literalName); }
     // | NEWLINE START { $$ = $2; }
     ;

VERBATIM: VERBATIM NEWLINE { $$ = alloc(); strcpy($$->literalName, $1->literalName); free($1->literalName); }
        | VERBATIM NUM { $$ = alloc(); sprintf($$->literalName, "%s%s", $1->literalName, $2->literalName); free($1->literalName); free($2->literalName); }
        | { $$ = alloc(); }
        ;

PRIMITIVE: ID ASSIGN EXPR NEWLINE PRIMITIVE { $$ = alloc(); sprintf($$->literalName, "engine.%s = %s\n%s", $1->literalName, $3->literalName, $5->literalName); free($1->literalName); free($3->literalName); free($5->literalName);}
         | { $$ = alloc(); }
         ;

ENGINE: BRACKET_SQ_OPEN PLAY BRACKET_SQ_CLOSE { $$ = alloc(); sprintf($$->literalName, "play()\n"); }
      | BRACKET_SQ_OPEN PLAY WITH PARAM PARAMLIST BRACKET_SQ_CLOSE { $$ = alloc(); sprintf($$->literalName, "play(%s%s)\n", $4->literalName, $5->literalName); free($4->literalName); free($5->literalName);}
      ;

FUNCTIONS: FUNCTION NEWLINE FUNCTIONS { $$ = alloc(); sprintf($$->literalName, "%s\n%s", $1->literalName, $3->literalName); free($1->literalName); free($3->literalName); }
         | { $$ = alloc(); }
         ;

FUNCTION: BRACKET_CURLY_OPEN ID BODY BRACKET_CURLY_CLOSE {
        char* body = indent($3->literalName);
        $$ = alloc(); sprintf($$->literalName, "def %s(*args, **kwargs):\n%s%sengine.%s = %s\n", $2->literalName, set_args, body, $2->literalName, $2->literalName);
        free($2->literalName); free(body);
        }
        ;

BODY: STATEMENT BODY { $$ = alloc(); sprintf($$->literalName, "%s\n%s", $1->literalName, $2->literalName); free($1->literalName); free($2->literalName);}
    | STATEMENT { $$ = alloc(); sprintf($$->literalName, "%s", $1->literalName); free($1->literalName); }
    ;

STATEMENT: ID ASSIGN EXPR {
           $$ = alloc();
           sprintf($$->literalName, "%s = %s", $1->literalName, $3->literalName);
           free($1->literalName);
           free($3->literalName);
         }
         | RETURN EXPR {
           $$ = alloc();
           sprintf($$->literalName, "return %s", $2->literalName);
           free($2->literalName);
         }
         | EXPR { $$ = alloc(); strcpy($$->literalName, $1->literalName); free($1->literalName); } // Added to allow fucntion calls without assigning them to temp variables
         | WHILELOOP { $$ = alloc(); sprintf($$->literalName, "%s", $1->literalName); free($1->literalName); }
         | IFSTATEMENT { $$ = alloc(); sprintf($$->literalName, "%s", $1->literalName); free($1->literalName); }
         ;

IFSTATEMENT: IF BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE THEN STATEMENT END {
           char* statement = indent($6->literalName);
           $$ = alloc(); sprintf($$->literalName, "if %s:\n%s", $3->literalName, statement);
           free($3->literalName); free(statement);
           }
           | IF BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE THEN STATEMENT ELSE STATEMENT END {
           char* if_statement = indent($6->literalName);
           char* else_statement = indent($8->literalName);
           $$ = alloc(); sprintf($$->literalName, "if %s:\n%s\nelse:\n%s", $3->literalName, if_statement, else_statement);
           free($3->literalName); free(if_statement); free(else_statement);
           }
           ;

WHILELOOP: WHILE BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE STATEMENT END {
         char* statement = indent($5->literalName);
         $$ = alloc(); sprintf($$->literalName, "while %s:\n%s", $3->literalName, statement);
         free($3->literalName); free(statement);
         }
         ;

EXPR: ARITHLOGIC { $$ = alloc(); sprintf($$->literalName, "%s", $1->literalName); free($1->literalName); }
    | BRACKET_SQ_OPEN CALL ID BRACKET_SQ_CLOSE {
    $$ = alloc();
    if (strcmp($3->literalName, "Print") == 0) {
      sprintf($$->literalName, "%s()", $3->literalName); free($3->literalName);
    } else {
      sprintf($$->literalName, "engine.%s()", $3->literalName); free($3->literalName);
    }
    }
    | BRACKET_SQ_OPEN CALL ID WITH PARAM PARAMLIST BRACKET_SQ_CLOSE {
    $$ = alloc();
    if (strcmp($3->literalName, "Print") == 0) {
      sprintf($$->literalName, "Print(%s%s)", $5->literalName, $6->literalName);
    } else {
      sprintf($$->literalName, "engine.%s(%s%s)", $3->literalName, $5->literalName, $6->literalName);
    }
    free($3->literalName); free($5->literalName); free($6->literalName);
    }
    ;

ARITHLOGIC: TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, "%s%s", $1->literalName, $2->literalName); free($1->literalName); free($2->literalName); }
          ;

TERM: FACTOR TERM1 { $$ = alloc(); sprintf($$->literalName, "%s%s", $1->literalName, $2->literalName); free($1->literalName); free($2->literalName); }
    ;

ARITH1: OP_ADD TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, " + %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
      | OP_SUB TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, " - %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
      | OP_OR TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, " or %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
      | GREATER_THAN TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, " > %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
      | LESSER_THAN TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, " < %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
      | OP_EQUAL TERM ARITH1 { $$ = alloc(); sprintf($$->literalName, " == %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
      | { $$ = alloc(); }
      ;

FACTOR: ID { $$ = alloc(); sprintf($$->literalName, "%s", $1->literalName); free($1->literalName); }
      | NUM { $$ = alloc(); sprintf($$->literalName, "%s", $1->literalName); free($1->literalName); }
      | BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE { $$ = alloc(); sprintf($$->literalName, "(%s)", $2->literalName); free($2->literalName); }
      | BRACKET_PAREN_OPEN OP_NEG EXPR BRACKET_PAREN_CLOSE { $$ = alloc(); sprintf($$->literalName, "(not %s)", $3->literalName); free($3->literalName); }
      | BRACKET_PAREN_OPEN OP_NOT EXPR BRACKET_PAREN_CLOSE { $$ = alloc(); sprintf($$->literalName, "(~ %s)", $3->literalName); free($3->literalName); }
      ;

TERM1: OP_MUL FACTOR TERM1 { $$ = alloc(); sprintf($$->literalName, " * %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
     | OP_AND FACTOR TERM1 { $$ = alloc(); sprintf($$->literalName, " and %s%s", $2->literalName, $3->literalName); free($2->literalName); free($3->literalName); }
     | { $$ = alloc(); }
     ;

PARAM: ID ASSIGN EXPR { $$ = alloc(); sprintf($$->literalName, "%s = %s", $1->literalName, $3->literalName); free($1->literalName); free($3->literalName); }
     ;

PARAMLIST: PARAM PARAMLIST { $$ = alloc(); sprintf($$->literalName, ",%s%s", $1->literalName, $2->literalName); free($1->literalName); free($2->literalName); }
         | { $$ = alloc(); }
         ;
%%

int main(int argc, char *argv[]) {
  yyparse();
  return 0;
}
