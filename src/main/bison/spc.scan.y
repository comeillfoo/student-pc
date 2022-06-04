%locations

%code requires {
  #include "ast.h"
  #include "tac.h"
}


%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <stdbool.h>

  int yylex(void);
  void yyerror( char const* s );

  static struct ast_node* root = NULL; // pointer to the root of AST
%}

%union {
  struct ast_node* node;
  int         value;
  char*       name;
  enum operation_type oper;
}

/* declare tokens */
%precedence <name>  IDENT
%precedence <value> CONST
%precedence         OP CP
%left       <oper>  NOT MINUS
%left       <oper>  BIN_PLUS BIN_MUL BIN_DIV BIN_POW BIN_LESS BIN_GREATER BIN_EQUALS
%right              ASSIGN

%precedence         REPEAT UNTIL IF ELSE
%precedence         EOEXPR COMMA
%precedence         VAR BEGINNING END DOT
%token              ERROR // used in lexer to return error

%type <oper> unop binop
%type <node> statements_list statement assignment branch_statement loop_statement
%type <node> expression
%type <node> subexpression
%type <node> operand
%type <node> composed_statement
%type <node> description_of_calculations
%type <node> program

%start program

%%

program: variables_declaration description_of_calculations { $$ = root = make_program( $2 ); }
 ;

description_of_calculations: composed_statement DOT { $$ = $1; }
 ;

variables_declaration: VAR variables_list { /* there should be work with symbols table */ }
 ;

variables_list: IDENT EOEXPR   { /* there should be work with symbols table */ }
 | IDENT COMMA variables_list  { /* there should be work with symbols table */ }
 | IDENT EOEXPR variables_list { /* there should be work with symbols table */ }
 ;

statements_list: statement   { $$ = make_stmts_list( $1, NULL ); }
 | statement statements_list { stmts_list_insert( &$2, $1 ); $$ = $2; }
 ;

statement: assignment { $$ = $1; }
 | branch_statement   { $$ = $1; }
 | composed_statement { $$ = $1; }
 ;

composed_statement: BEGINNING statements_list END { $$ = $2; }
 ;

assignment: IDENT ASSIGN expression EOEXPR { $$ = make_expr( make_ident( $1 ), OT_ASSIGN, $3 ); }
 ;

expression: unop subexpression { $$ = make_unexpr( $1, $2 ); }
 | subexpression               { $$ = $1; }
 ;

subexpression: OP expression CP      { $$ = $2; }
 | operand                           { $$ = $1; }
 | subexpression binop subexpression { $$ = make_expr( $1, $2, $3 ); }
 ;

unop: MINUS { $$ = OT_MINUS;  }
 | NOT      { $$ = OT_UN_NOT; }
 ;

binop: MINUS   { $$ = OT_MINUS;       }
 | BIN_PLUS    { $$ = OT_BIN_PLUS;    }
 | BIN_MUL     { $$ = OT_BIN_MUL;     }
 | BIN_DIV     { $$ = OT_BIN_DIV;     }
 | BIN_POW     { $$ = OT_BIN_POW;     }
 | BIN_LESS    { $$ = OT_BIN_LESS;    }
 | BIN_GREATER { $$ = OT_BIN_GREATER; }
 | BIN_EQUALS  { $$ = OT_BIN_EQUALS;  }
 ;

operand: IDENT { $$ = make_ident( $1 ); }
 | CONST       { $$ = make_const( $1 ); }
 ;

branch_statement: IF OP expression CP statement { $$ = make_branch( $3, $5, NULL ); }
 | IF OP expression CP statement ELSE statement { $$ = make_branch( $3, $5, $7   ); }
 | loop_statement                               { $$ = $1; }
 ;

loop_statement: REPEAT statements_list UNTIL expression { $$ = make_repeat( $4, $2 ); }
 ;

%%

int main( void ) {
  bool parse_result = yyparse( );

  // traverse AST for generating TAC
  if ( root == NULL )
    fprintf( stderr, "can't find root\n" );
  else dfs_traverse( root, pre_print_tac, post_print_tac );

  // free the ast
  free_ast( root );
  return parse_result;
}

void yyerror( char const* s ) {
  fprintf( stderr, "error: %d:%d-%d:%d: %s\n",
    yylloc.first_line,
    yylloc.first_column,
    yylloc.last_line,
    yylloc.last_column, s );
  exit(1);
}