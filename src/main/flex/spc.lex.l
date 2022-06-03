%option noyywrap nodefault yylineno
%{
  #include <assert.h>
  #include "spc.tab.h"

  static struct { size_t line; size_t column; } current_position = { 1, 1 };

  static size_t line( )   { return current_position.line; }
  static size_t column( ) { return current_position.column; }

  static void add_line( size_t n )   { current_position.line += n; }
  static void add_column( size_t n ) { current_position.column += n; }
  static void drop_column( ) { current_position.column = 1; }

  #define YY_USER_ACTION { \
    yylloc.first_line   = line( ); \
    yylloc.last_line    = line( ); \
    yylloc.first_column = column( ); \
    yylloc.last_column  = column( ) + yyleng - 1; \
    add_column( yyleng ); }

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
[0-9]+      { yylval.d = atof(yytext); return CONST; }
"="         { return ASSIGN; }
"Begin"     { return BEGINNING;}
"End"       { return END; }
"REPEAT"    { return REPEAT; }
"UNTIL"     { return UNTIL; }
"IF"        { return IF; }
"ELSE"      { return ELSE; }
"Var"       { return VAR; }
[A-z]+      { yylval.s = yytext; return IDENT; }

"//".*  
[ \t]       { /* ignore white space */ }
\n          { drop_column( ); add_line( 1 ); yylloc.first_line++; }
.           { assert( "critical error: mystery character\n" ); return ERROR; }

%%