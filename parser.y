%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "error.h"

#define MAX_LINE_LENG      256
extern int line_no, chr_no, opt_list;
extern char buffer[MAX_LINE_LENG];
extern FILE *yyin;        /* declared by lex */
extern char *yytext;      /* declared by lex */
extern int yyleng;

extern int yylex(void);
static void yyerror(const char *msg);
%}

%token PROGRAM VAR ARRAY OF INTEGER REAL STRING FUNCTION PROCEDURE PBEGIN END IF THEN ELSE WHILE DO NOT AND OR

%token LPAREN RPAREN SEMICOLON DOT COMMA COLON LBRACE RBRACE DOTDOT ASSIGNMENT ADDOP SUBOP MULOP DIVOP LTOP GTOP EQOP GETOP LETOP NEQOP

%token IDENTIFIER REALNUMBER INTEGERNUM SCIENTIFIC LITERALSTR NUMBER

%union {
  int val;
  char* text;
  double dval;
}


%%
prog	: PROGRAM id '('identifier_list')' ';'
		declarations
		subprogram_declarations
		compound_statement
		DOT
		;
identifier_list    : IDENTIFIER
		| identifier_list, IDENTIFIER
		;
declarations    : declaration
		| 
		;
declaration    :VAR identifier_list : type ';' declaration
		|
		;
type    : standard_type
		| ARRAY [num..num] OF type
		
standard_type    : INTEGER
		| REAL
		| STRING
		;
subprogram_declarations    :
		subprogram_declarations subprogram_declaration ';'
		|
		;
subprogram_declaration    :
		subprogram_head
		declarations
		subprogram_declarations
		compound_statement
		;
subprogram_head    : FUNCTION IDENTIFIER arguments : standard_type ';'
		| PROCEDURE id arguments ';'
		;
arguments    : '(' parameter_list ')'
		|
		;
optional_var    : VAR
		|
		;
compound_statement    : PBEGIN
		optional_statements
		END

optional_statements    : standard_list
		| 
		;

standard_list    : statement
		| standard_list ';' statement

statement    : variable : expression
		| procedure_statement
		| compound_statement
		| IF expression THEN statement ELSE statement
		| WHILE expression DO statement
		|
		;
variable    : IDENTIFIER tail
		;
tail    : [expression] tail
		|
		;
procedure_statement    : IDENTIFIER
		| IDENTIFIER '('expression_list ')'
		;
expression_list    : expression
		| expression_list , expression
		
expression    : boolexpression
		| boolexpression AND boolexpression
		| boolexpression OR boolexpression
		;
boolexpression    : simple_expression
		| simple_expression relop simple_expression
		;
simple_expression    : term
		| simple_expression addop term
		;
term    : factor
		| term mulop factor
		;
factor    : IDENTIFIER tail
		| IDENTIFIER '(' expression_list ')'
		| NUMBER
		| LITERALSTR
		|'('expression')'
		| NOT factor
		| SUBOP factor
		;
addop    : ADDOP | SUBOP
		;
mulop    : MULOP | DIVOP
		;
relop    : LTOP
		| GTOP
		| EQOP
		| LETOP
		| GETOP
		| NEQOP
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr,
            "[ERROR] line %4d:%3d %s, Unmatched token: %s\n",
            line_no, chr_no-(int)yyleng+1, buffer, yytext);
}

int main(int argc, const char *argv[]) {

    if(argc > 2)
        fprintf( stderr, "Usage: ./parser [filename]\n" ), exit(0);

    FILE *fp = argc == 1 ? stdin : fopen(argv[1], "r");

    if(fp == NULL)
        fprintf( stderr, "Open file error\n" ), exit(-1);

    yyin = fp;
    yyparse();
    return 0;
}
