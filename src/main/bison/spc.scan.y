%{
  #include <stdio.h>
  #include <stdlib.h>

  int yylex(void);
  void yyerror( char const* s );
%}

/* declare tokens */
%precedence IDENT LETTER
%precedence CONST NUMBER
%precedence OP CP
%left NOT MINUS
%left BIN_PLUS BIN_MUL BIN_DIV BIN_POW BIN_LESS BIN_GREATER BIN_EQUALS
%right ASSIGN
%precedence VAR
%precedence EOEXPR COMMA
%precedence REPEAT UNTIL IF ELSE
%precedence BEGINNING END DOT
%token ERROR

%%

program: variables_declaration description_of_calculations
 | loop_statement // ?
 ;

description_of_calculations: BEGINNING statements_list END DOT
 ;
 
variables_declaration: VAR variables_list
 ;

variables_list: IDENT EOEXPR
 | IDENT COMMA variables_list
 | IDENT EOEXPR variables_list
 ;

statements_list: statement
 | statement statements_list 
 ; 

statement: assignment
 | branch_statement
 | composed_statement
 ;

composed_statement: BEGINNING statements_list END
 ;

assignment: IDENT ASSIGN expression EOEXPR
 ;

expression: unop subexpression
 | subexpression
 ;

subexpression: OP expression CP
 | operand
 | subexpression binop subexpression
 ;

unop: MINUS
 | NOT
 ;

binop: MINUS
 | BIN_PLUS
 | BIN_MUL
 | BIN_DIV
 | BIN_POW
 | BIN_LESS
 | BIN_GREATER
 | BIN_EQUALS
 ;

operand: ident
 | const
 ;

branch_statement: IF OP expression CP statement
 | IF OP expression CP statement ELSE statement
 | loop_statement
 ;

loop_statement: REPEAT statements_list UNTIL expression
 ;

ident: LETTER ident | LETTER
 ;

const: NUMBER const | NUMBER
 ;

%%

int main( void ) {
  printf( "> " ); 
  yyparse( );
}

void yyerror( char const* s ) {
  fprintf( stderr, "error: %d:%d: %s\n", 0, 0, s );
  exit(1);
}