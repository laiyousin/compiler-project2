%{
/*
 * scanner.l
 *
 * lex input file for pascal scanner
 *
 */

#include <stdio.h>
#include <string.h>
#include "parser.h"

int fileno(FILE *);

#define YY_USER_ACTION     chr_no += yyleng; // note this line

#define MAX_LINE_LENG      1000
#define LIST       strcat(buffer, yytext)
#define LIST_FLUSH do{ if(opt_list) printf("%s", buffer); *buffer = 0; }while(0)
#define LOG(TYPE) do{ LIST; if(tokenon == 0){fprintf(stderr, "token(type:%-10s) on line %4d, %3d : %s\n", #TYPE, line_no, chr_no - yyleng + 1, yytext);}} while(0)
#define COMMENT do{ LIST; if(tokenon == 0){fprintf(stderr, "[INFO ] line %4d:%3d comment string\n", line_no, chr_no-(int)yyleng+1); }} while(0)		



int opt_list = 1, opt_token = 0;
int line_no = 1, chr_no = 0;
char buffer[MAX_LINE_LENG];
int flag = 0;
int turnon = 0;
int tokenon = 1;

%}

%option nounput
%option noinput

A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]

%%
											/* v could do something */
{P}{R}{O}{G}{R}{A}{M}       				{LOG(KEYWORD); return(PROGRAM);    }
{V}{A}{R}                   				{LOG(KEYWORD); return(VAR);        }
{A}{R}{R}{A}{Y}             				{LOG(KEYWORD); return(ARRAY);      }
{O}{F}                      				{LOG(KEYWORD); return(OF);         }
{I}{N}{T}{E}{G}{E}{R}       				{LOG(KEYWORD); return(INTEGER);    }
{R}{E}{A}{L}                				{LOG(KEYWORD); return(REAL);       }
{S}{T}{R}{I}{N}{G}          				{LOG(KEYWORD); return(STRING);     }
{F}{U}{N}{C}{T}{I}{O}{N}    				{LOG(KEYWORD); return(FUNCTION);   }
{P}{R}{O}{C}{E}{D}{U}{R}{E} 				{LOG(KEYWORD); return(PROCEDURE);  }
{B}{E}{G}{I}{N}             				{LOG(KEYWORD); return(PBEGIN);     }
{E}{N}{D}                   				{LOG(KEYWORD); return(END);        }
{I}{F}                      				{LOG(KEYWORD); return(IF);         }
{T}{H}{E}{N}            	    			{LOG(KEYWORD); return(THEN);       }
{E}{L}{S}{E}            	    			{LOG(KEYWORD); return(ELSE);       }
{W}{H}{I}{L}{E}         	    			{LOG(KEYWORD); return(WHILE);      }
{D}{O}                  	    			{LOG(KEYWORD); return(DO);         }
{N}{O}{T}                  					{LOG(KEYWORD); return(NOT);        }
{A}{N}{D}           	        			{LOG(KEYWORD); return(AND);        }
{O}{R}                 		    			{LOG(KEYWORD); return(OR);         }

"("	                            			{LOG(KEYWORD); return(LPAREN);     }
")" 	                        			{LOG(KEYWORD); return(RPAREN);     }
";"     	                    			{LOG(KEYWORD); return(SEMICOLON);  }
"."         	                			{LOG(KEYWORD); return(DOT);        }
","             	            			{LOG(KEYWORD); return(COMMA);      }
":"                 	        			{LOG(KEYWORD); return(COLON);      }
"["                     	    			{LOG(KEYWORD); return(LBRACE);     }
"]" 	                        			{LOG(KEYWORD); return(RBRACE);     }
".."    	                    			{LOG(KEYWORD); return(DOTDOT);     }
":="        	                			{LOG(KEYWORD); return(ASSIGNMENT); }
"+"             	            			{LOG(KEYWORD); return(ADDOP);      }
"-"                 	        			{LOG(KEYWORD); return(SUBOP);      }
"*"                     	    			{LOG(KEYWORD); return(MULOP);      }
"/" 	                       				{LOG(KEYWORD); return(DIVOP);      }
">"     	                    			{LOG(KEYWORD); return(GTOP);       }
"<"         	                			{LOG(KEYWORD); return(LTOP);       }
"="             	            			{LOG(KEYWORD); return(EQOP);       }
">="                	        			{LOG(KEYWORD); return(GETOP);      }
"<="                   		    			{LOG(KEYWORD); return(LETOP);      }
"!="	                        			{LOG(KEYWORD); return(NEQOP);      }
[a-z][a-z|A-Z|0-9]*([_]+[a-z|A-Z|0-9]+)*	{LOG(IDENTIFIER);}
[0-9]+("."[0-9]+)*([E|e][+|-]*[0-9]+)*      {LOG(NUMBER);}
[0-9]+"."[0-9]+ 	            			{LOG(REALNUMBER);}
[0-9]+"."[0-9]+[e|E][+|-][0-9]+ 			{LOG(SCIENTIFIC);}
\"([^\\\"]|\\.)*\"	                        {LOG(STRING);}
("//")|("//"[^\n]+)                			{COMMENT;}
"/*"([^(\*/)]+((\*[^/])|(("//")*[^(\*/)]+)|[\)])*)* {do{
												LIST; 
												if(tokenon == 0)
												{
													fprintf(stderr, "[INFO ] line %4d:%3d comment string start\n", line_no, chr_no-(int)yyleng+1); 
												}
												int flag = 0;
												for(int i = 0; i < yyleng; i++)
												{
													if(yytext[i] == '\n')
													{
														line_no++;
														chr_no = 0;
														flag = 1;
													}
													else
													{
														if(flag == 1)
														{
															chr_no++;
														}	
													}
												}
												if(turnon == 0)
													LIST_FLUSH;
											   } while(0);
											}
"*/"                                        {do{ 
													LIST; 
													if(tokenon == 0)
												    {
														fprintf(stderr, "[INFO ] line %4d:%3d comment string end\n", line_no, chr_no-(int)yyleng+1); }
													
												} while(0);
											}
[ \t\f\r]    LIST;

\n {
  LIST;
  if(turnon == 0)
	LIST_FLUSH;
  line_no++, chr_no = 0;
}

.  { LIST; fprintf(stderr, "[ERROR] line %4d:%3d lexical analyzer error %s\n", line_no, chr_no-(int)yyleng+1, yytext); }

["#"][" "]*pragma[" "]*list[" "]*on  { *buffer = 0; turnon = 0; LIST; LIST_FLUSH;}
["#"][" "]*pragma[" "]*list[" "]*off { turnon = 1;}
["#"][" "]*pragma[" "]*token[" "]*on  { *buffer = 0; tokenon = 0; LIST; LIST_FLUSH;}
["#"][" "]*pragma[" "]*token[" "]*off { tokenon = 1;}
