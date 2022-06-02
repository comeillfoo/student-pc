%{
  #include <assert.h>
  #include "spc.tab.h"

%}

%%

"not"       { return NOT; }
"-"         { return MINUS; }
"+"         { return BIN_PLUS; }
"*"         { return BIN_MUL; }
"/"         { return BIN_DIV; }
"**"        { return BIN_POW; }
"<"         { return BIN_LESS; }
">"         { return BIN_GREATER; }
"=="        { return BIN_EQUALS; }
"("         { return OP; }
")"         { return CP; }
","         { return COMMA; }
";"         { return EOEXPR; }
"\."        { return DOT;    }
[0-9]+      { yylval = atoi( yytext ); return CONST; }
"="         { return ASSIGN; }
"Begin"     { return BEGINNING;}
"End"       { return END; }
"REPEAT"    { return REPEAT; }
"UNTIL"     { return UNTIL; }
"IF"        { return IF; }
"ELSE"      { return ELSE; }
"Var"       { return VAR; }
[A-z]+      { return IDENT; }

"//".*  
[ \t\n]     { /* ignore white space */ }
.           { assert( "critical error: mystery character\n" ); return ERROR; }

%%