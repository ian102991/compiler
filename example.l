%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "example.tab.h"
%}
number [0-9]+
add [\+]
sub [\-]
eql [\=]
connect [\:]
connect1 [\/]
variable [a-zA-Z][a-zA-Z0-9]*
%%
{number}  			{yylval.a=atoi(yytext);return NUMBER;}
{add}     	                {return ADD;}
{sub}     	                {return SUB;}
"*"				{return MUL;}
"add"     	                {return ADD1;}
"sub"     	                {return SUB1;}
{connect}                       {return CONNECT;}
{connect1}                      {return CONNECT1;}
{variable}			{strcpy(yylval.c, yytext);return VARIABLE;}
{eql}				{return EQL;}
\n				{return EOL;}
"("				{return LEFTQUA;}
")"				{return RIGHTQUA;}
.    				{}
%%