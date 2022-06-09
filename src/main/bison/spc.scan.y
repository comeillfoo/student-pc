%locations

%code requires {
  #include "ast.h"
  #include "tac.h"
}


%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <stdbool.h>
  #include <getopt.h>

  extern FILE* yyin;
  extern FILE* yyout;

  int yylex(void);
  void yyerror( char const* s );

  int is_verbose = 0;
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

int main( int argc, char** argv ) {
  int optidx = 0;
  int is_input = 0, is_output = 0, is_ast = 0;
  struct option options[] = {
    { "out",     required_argument, NULL, 'o' },
    { "file",    required_argument, NULL, 'f' },
    { "help",    no_argument,       NULL, 'h' },
    { "verbose", no_argument,       NULL, 'v' },
    { "ast",     no_argument,       NULL, 'a' },
    { 0, 0, 0, 0 }
  };

  char brief_option;
  while ( -1 != (brief_option = getopt_long( argc, argv, "vhf:o:", options, &optidx )) )
    switch ( brief_option ) {
      case 'h':
        fprintf( stderr,
          "SYNOPSYS"
          "\n\tspc [-v] [-f <input file>] [-o <output file>]"
          "\nDESCRIPTION"
          "\n\t-h, --help"
          "\n\t\tshows this help message and exits"
          "\n\t-f, --file"
          "\n\t\tspecifies the input file path, default: stdin"
          "\n\t-o, --out"
          "\n\t\tspecifies the output file path, default: a.out"
          "\n\t-a, --ast"
          "\n\t\tif option presents then ast tree prints in stderr"
          "\n\t-v, --verbose"
          "\n\t\tenables extra output\n"
        );
        return 0;
      case 'f':
        yyin = fopen( optarg, "r" ); is_input = 1; break;
      case 'o':
        yyout = fopen( optarg, "w" ); is_output = 1; break;
      case 'v':
        is_verbose = 1; break;
      case 'a':
        is_ast = 1; break;
      default:
        exit(-1);
    }
  
  bool parse_result = yyparse( );
  if ( is_input )
    fclose( yyin );

  if ( !is_output )
    yyout = fopen( "a.out", "w" );

  // traverse AST for generating TAC
  if ( root == NULL )
    is_verbose && fprintf( stderr, "can't find root\n" );
  else {
    is_ast && print_ast( root );
    print_tac( yyout, root );
    fprintf( yyout, "\n" );
  }
  
  fclose( yyout );

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