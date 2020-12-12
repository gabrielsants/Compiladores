%{
  #include<stdio.h>
  int yylex();            /* Supress C99 warning on OSX */
  extern char *yytext;    /* Correct for Flex */
  unsigned int total = 0;
%}
%token BIT
%%
number : BIT               {                     total += yytext[0]-'0'; } 
       | number BIT        { total = total << 1; total += yytext[0]-'0'; }
       ;

