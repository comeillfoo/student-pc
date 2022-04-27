%{
  #include "spc.tab.h"
%}

%%

"not"  { return NOT; }
"-"    { return UNARY_MINUS; }
"+"    { return BIN_PLUS; }
"-"    { return BIN_MINUS; }
"*"    { return BIN_MUL; }
"/"    { return BIN_DIV; }
"**"   { return BIN_POW; }
"<"    { return BIN_LESS; }
">"    { return BIN_GREATER; }
"=="   { return BIN_EQUALS; }
"("    { return OP; }
")"    { return CP; }
[0-9]+ { yylval = atoi( yytext ); return CONST; }
"="    { return ASSIGN; }
"REPEAT" { return REPEAT; }
"UNTIL"  { return UNTIL; }
[A-z]+ { return IDENT; }

"//".*  
[ \t\n]  { /* ignore white space */ }
.      { yyerror( "Mystery character %c\n", *yytext ); }

%%