%{
  #include <stdio.h>
%}

/* declare tokens */
%token IDENT LETTER
%token VAR
%token EOEXPR COMMA
%token CONST NUMBER
%token OP CP
%token NOT
%token UNARY_MINUS
%token BIN_MINUS BIN_PLUS BIN_MUL BIN_DIV BIN_POW BIN_LESS BIN_GREATER BIN_EQUALS
%token BEGIN END
%token ASSIGN
%token REPEAT UNTIL IF ELSE

%%

program: variables_declaration description_of_calculations
 | loop_statement // ?
 ;

description_of_calculations: BEGIN statements_list END
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
 // | TODO: add rest of rules
 | branch_statement
 | composed_statement
 ;

composed_statement: BEGIN statements_list END
 ;

assignment: IDENT ASSIGN expression
 ;

expression: unop subexpression
 | subexpression
 ;

subexpression: OP expression CP
 | operand
 | subexpression binop subexpression
 ;

unop: UNARY_MINUS
 | NOT
 ;

binop: BIN_MINUS
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

main( ) {
  printf( "> " ); 
  yyparse( );
}

yyerror( char* s ) {
  fprintf(stderr, "error: %s\n", s);
}