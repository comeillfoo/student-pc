#include "tac.h"
#include "ast.h"

extern const char* ot_symbol[];

static int last_label_nr = 0;

static inline int next_label( ) { return last_label_nr++; }

static inline int current_label( ) { return last_label_nr; }

static int last_temp_nr = 0;

static inline int next_temp( ) { return last_temp_nr++; }

static inline int current_temp( ) { return last_temp_nr; }


static void print_literal( FILE* out, struct ast_node* node ) {
  if ( node == NULL ) return;
  switch ( node->type ) {
    case ANT_CONST: fprintf( out, "%d\n", node->as_const.value ); break;
    case ANT_IDENT: fprintf( out, "%s\n", node->as_ident.name ); break;
    default: fprintf( out, "t%d\n", current_temp() - 1 ); break;
  }
}

static void print_tac_unexpr( FILE* out, struct ast_node* unexrp ) {
  struct ast_node* argument = unexrp->as_unexpr.argument;
  if ( argument->type != ANT_CONST && argument->type != ANT_IDENT )
    print_tac( out, argument );

  fprintf( out, "\tt%d = %s", next_temp(), ot_symbol[ unexrp->as_unexpr.oper ] );
  print_literal( out, argument );
}

static void print_tac_expr( FILE* out, struct ast_node* expr ) {
  struct ast_node* left    = expr->as_expr.left;
  struct ast_node* right   = expr->as_expr.right;
  enum operation_type oper = expr->as_expr.oper;
  if ( oper == OT_ASSIGN ) {
    if ( right->type != ANT_CONST && right->type != ANT_IDENT )
      print_tac( out, right );

    fprintf( out, "\t%s = ", left->as_ident.name );
    print_literal( out, right );
  } else {
    print_tac( out, left );
    int left_nr = next_temp();
    fprintf( out, "\tt%d = ", left_nr );
    print_literal( out, left );
    print_tac( out, right );
    int right_nr = next_temp();
    fprintf( out, "\tt%d = ", right_nr );
    print_literal( out, right );
    fprintf( out, "\tt%d = t%d %s t%d\n", next_temp(), left_nr, ot_symbol[ expr->as_expr.oper ], right_nr );
  }
}

static void print_tac_branch( FILE* out, struct ast_node* branch ) {
  print_tac( out, branch->as_branch.test );
  int then_label = next_label();
  fprintf( out, "\tif t%d goto _l%d\n", current_temp() - 1, then_label );
  print_tac( out, branch->as_branch.alternate );
  int if_end_label = next_label();
  fprintf( out, "\tgoto _l%d\n_l%d:\t", if_end_label, then_label );
  print_tac( out, branch->as_branch.consequent );
  fprintf( out, "_l%d:\t", if_end_label );
}

static void print_tac_repeat( FILE* out, struct ast_node* repeat ) {
  int repeat_label = next_label();
  fprintf( out, "_l%d:", repeat_label );
  print_tac( out, repeat->as_repeat.body );
  print_tac( out, repeat->as_repeat.test );
  fprintf( out, "\tif t%d goto _l%d\n", current_temp() - 1, repeat_label );
}

void print_tac( FILE* out, struct ast_node* node ) {
  if ( node == NULL ) return;
  switch ( node->type ) {
    case ANT_PROGRAM: print_tac( out, node->as_program.child ); break;
    case ANT_STMTS_LIST: {
      struct ast_node* iter = node;
      while ( iter != NULL ) {
        print_tac( out, iter->as_stmts_list.current );
        iter = iter->as_stmts_list.next;
      }
      break;
    }
    case ANT_UNEXPR:  print_tac_unexpr( out, node ); break;
    case ANT_EXPR:    print_tac_expr( out, node ); break;
    case ANT_BRANCH:  print_tac_branch( out, node ); break;
    case ANT_REPEAT:  print_tac_repeat( out, node ); break;
    default: break;
  }
}