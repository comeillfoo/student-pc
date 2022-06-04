#ifndef _AST_H_
#define _AST_H_

#include <stdbool.h>
#include "ot.h"

enum ast_node_type {
  ANT_IDENT,
  ANT_CONST,
  ANT_EXPR,
  ANT_UNEXPR,
  ANT_BRANCH,
  ANT_REPEAT,
  ANT_STMTS_LIST,
  ANT_PROGRAM
};

static const char* ant_names[] = {
  [ ANT_IDENT ]      = "identifier",
  [ ANT_CONST ]      = "constant",
  [ ANT_EXPR ]       = "expression",
  [ ANT_UNEXPR ]     = "unary-expression",
  [ ANT_BRANCH ]     = "if-then-else",
  [ ANT_REPEAT ]     = "repeat-until",
  [ ANT_STMTS_LIST ] = "statements-list",
  [ ANT_PROGRAM ]    = "program"
};

#define MAXIMUM_IDENTIFIER_LENGTH 256

struct ast_ident {
  char name[ MAXIMUM_IDENTIFIER_LENGTH ];
};

struct ast_const {
  int value;
};

struct ast_node;

struct ast_expression {
  enum operation_type oper;
  struct ast_node* left;
  struct ast_node* right;
};

struct ast_unary_expression {
  enum operation_type oper;
  struct ast_node* argument;
};

struct ast_branch {
  struct ast_node* test;
  struct ast_node* consequent;
  struct ast_node* alternate;
};

struct ast_repeat {
  struct ast_node* test;
  struct ast_node* body;
};

struct ast_stmts_list {
  struct ast_node* current;
  struct ast_node* next;
};

struct ast_program {
  struct ast_node* child;
};

struct ast_node {
  enum ast_node_type type;
  bool is_visited;
  union {
    struct ast_ident            as_ident;
    struct ast_const            as_const;
    struct ast_expression       as_expr;
    struct ast_unary_expression as_unexpr;
    struct ast_branch           as_branch;
    struct ast_repeat           as_repeat;
    struct ast_stmts_list       as_stmts_list;
    struct ast_program          as_program;
  };
};

struct ast_node* make_ident( const char* );
struct ast_node* make_const( int );

struct ast_node* make_expr( struct ast_node*, enum operation_type, struct ast_node* );

struct ast_node* make_unexpr( enum operation_type, struct ast_node* );

struct ast_node* make_branch( struct ast_node*, struct ast_node*, struct ast_node* );

struct ast_node* make_repeat( struct ast_node*, struct ast_node* );

struct ast_node* make_stmts_list( struct ast_node*, struct ast_node* );

void stmts_list_insert( struct ast_node**, struct ast_node* );

struct ast_node* make_program( struct ast_node* );

typedef void (process_cb)( struct ast_node* );

void dfs_traverse( struct ast_node*, process_cb, process_cb );

void free_ast( struct ast_node* );

#endif // _AST_H_
