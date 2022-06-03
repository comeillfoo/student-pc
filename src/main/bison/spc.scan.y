%locations

%{
  #include <stdio.h>
  #include <stdlib.h>

  int yylex(void);
  void yyerror( char const* s );

  #define PROGRAM_TYPE 1000
  #define NEW_BLOCK_TYPE 1001
  #define ST_LIST 1002
  #define ST 1003
  #define VB_LIST 1004
  #define dot 1005
  #define var 1006
%}

%union {
  struct ast *a;
  double d;
  char *s;
  int op;
}

/* declare tokens */
%precedence <op> VAR
%precedence <s> IDENT
%precedence  <d> CONST
%precedence <op> OP CP
%left <op> NOT MINUS
%left <op> BIN_PLUS BIN_MUL BIN_DIV BIN_POW BIN_LESS BIN_GREATER BIN_EQUALS
%right <op> ASSIGN

%precedence <op> EOEXPR COMMA
%precedence REPEAT UNTIL IF ELSE
%precedence <op> BEGINNING END DOT
%token ERROR

%type <a> statements_list statement assignment branch_statement loop_statement composed_statement
%type <a> expression
%type <a> subexpression
%type <op> unop binop
%type <a> operand
%type <a> variables_declaration description_of_calculations variables_list
%type <a> program


%%

program: variables_declaration description_of_calculations { $$ = new_ast(PROGRAM_TYPE, $1, $2); }
 ;

description_of_calculations: composed_statement DOT { $$ = new_ast(dot, $1, NULL); }
 ;

variables_declaration: VAR variables_list { $$ = new_ast(var, $2, NULL); }
 ;

variables_list: IDENT EOEXPR { printf("ident: %s\n", $1);$$ = new_ast(VB_LIST,$1, NULL); }
 | IDENT COMMA variables_list { $$ = new_ast(COMMA, $3, $2); }
 | IDENT EOEXPR variables_list { $$ = new_ast(EOEXPR, $3,$2); }
 ;

statements_list: statement { $$ = new_ast(ST, $1, NULL); }
 | statement statements_list { $$ = new_ast(ST_LIST, $2, $1); }
 ;

statement: assignment { $$ = $1; }
 | branch_statement { $$ = $1; }
 | composed_statement { $$ = $1; }
 ;

composed_statement: BEGINNING statements_list END { $$ = new_ast(NEW_BLOCK_TYPE, $2, NULL) ;}
 ;

assignment: IDENT ASSIGN expression EOEXPR { $$ = new_ast(1010, $1, $3); }
 ;

expression: unop subexpression { $$ = new_ast(1011, NULL, $2); }
 | subexpression { $$ = $1 ;}
 ;

subexpression: OP expression CP { $$ = $2; }
 | operand { $$ = $1; }
 | subexpression binop subexpression { $$ = new_ast(1012, $1, $3); }
 ;

unop: MINUS { $$ = 'M' ;}
 | NOT { $$ = 'N' ;}
 ;

binop: MINUS { $$ = '-'; }
 | BIN_PLUS { $$ = '+'; }
 | BIN_MUL { $$ = '*'; }
 | BIN_DIV  {$$ = '/'; }
 | BIN_POW { $$ = '^'; }
 | BIN_LESS { $$ = '<'; }
 | BIN_GREATER { $$ = '>'; }
 | BIN_EQUALS { $$ = 'E'; }
 ;

operand: IDENT { $$ = new_ident($1); }
 | CONST { $$ = new_num($1); }
 ;

branch_statement: IF OP expression CP statement
 | IF OP expression CP statement ELSE statement
 | loop_statement
 ;

loop_statement: REPEAT statements_list UNTIL expression
 ;

%%

int main( void ) {
  return yyparse( );
}

//void yyerror( char const* s ) {
//  fprintf( stderr, "error: %d:%d-%d:%d: %s\n",
//    yylloc.first_line,
//    yylloc.first_column,
//    yylloc.last_line,
//    yylloc.last_column, s );
//  exit(1);
//}