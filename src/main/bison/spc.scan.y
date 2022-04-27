%{
  #include <stdio.h>
%}

/* declare tokens */
%token IDENT
%token CONST
%token OP CP
%token NOT
%token UNARY_MINUS
%token BIN_MINUS BIN_PLUS BIN_MUL BIN_DIV BIN_POW BIN_LESS BIN_GREATER BIN_EQUALS
%token ASSIGN
%token REPEAT UNTIL

%%

program: 
 | statements_list
 | loop_statement
 ;

statements_list: statement
 | statement statements_list 
 ; 

statement: assignment
 // | TODO: add rest of rules
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

operand: IDENT
 | CONST
 ;

loop_statement: REPEAT statements_list UNTIL expression
 ;

%%

main( ) {
  printf( "> " ); 
  yyparse( );
}

yyerror( char* s ) {
  fprintf(stderr, "error: %s\n", s);
}