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

%token IDENTIFIER REALNUMBER INTEGERNUM SCIENTIFIC LITERALSTR

%union {
  int val;
  char* text;
  double dval;
}


%%
prog	::= PROGRAM id (identifier_list);
		declarations
		subprogram_declarations
		compound_statement
		.

identifier_list    ::= id
		| identifier_list, id

declarations    ::= declarations VAR identifier_list : type;
		| lambda
		
type    ::= standard_type
		| ARRAY [num .. num] OF type
		
standard_type    ::= INTEGER
		| REAL
		| STRING

subprogram_declarations    ::=
		subprogram_declarations subprogram_declaration;
		| lambda
		
subprogram_declaration    ::=
		subprogram_head
		declarations
		subprogram_declarations
		compound_statement
	
subprogram_head    ::= FUNCTION id arguments : standard_type;
		| PROCEDURE id arguments;
		
arguments    ::=(parameter_list)
		| lambda

optional_var    ::= VAR
		| lambda

compound_statement    ::= begin
		optional_statements
		end

optional_statements    ::= standard_list
		| lambda

standard_list    ::= statement
		| standard_list ; statement

statement    ::= variable := expression
		| procedure_statement
		| compound_statement
		| IF expression THEN statement ELSE statement
		| WHILE expression DO statement
		| lambda

variable    ::= id tail

tail    ::= [expression] tail
		| lambda
		
procedure_statement    ::= id
		| id (expression_list)
		
expression_list    ::= expression
		| expression_list , expression
		
expression    ::= boolexpression
		| boolexpression AND boolexpression
		| boolexpression OR boolexpression
		
boolexpression    ::= simple_expression
		| simple_expression relop simple_expression

simple_expression    ::= term
		| simple_expression addop term
		
term    ::= factor
		| term mulop factor
		
factor    ::= id tail
		| id (expression_list)
		| num
		| stringconst
		|(expression)
		| not factor
		| sub factor
		
addop    ::= + | -

mulop    ::= * | /

relop    ::= <
		| >
		| =
		| <=
		| >=
		| !=
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
