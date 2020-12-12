
%{
#include "aritimetica.tab.h"
%}

%%

[ \t\n\r]	    	{}
"//".*			    { }
"+" 			      { return '+'; }
">" 			      { return '>'; }
"<" 			      { return '<'; }
"-"				      { return '-'; }
"<="					  { return LE_OP; }
">="					  { return GE_OP; }
"++"					  { return INC_OP; }
"*" 			      { return '*'; }
"/"				      { return '/'; }
"(" 			      { return '('; }
")"				      { return ')'; }
"int"			      { return TINT; }
"float"			    { return TFLOAT; }
"return"		    { return RETURN; }
"struct"		    { return STRUCT; }
"if"            { return IF; }
"for"           { return FOR; }
"else"          { return ELSE; }
"||"            { return OR; }
"&&"            { return AND; }
"=="            { return EQUALS; }
"!="            { return DIF; }
"()"            { return PAREN; }

[0-9]+ {
  yylval.valor = atoi(yytext);
  return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {
  yylval.nome = strdup(yytext);
  return IDENT; 
}

.				{ return yytext[0]; }

%%


