#include "tac.h"
#include "ast.h"
#include <stdio.h>

extern const char* ot_symbol[];

static int last_label_nr = 0;

static inline int next_label( ) { return last_label_nr++; }

static inline int current_label( ) { return last_label_nr; }

static int last_temp_nr = 0;

static inline int next_temp( ) { return last_temp_nr++; }

static inline int current_temp( ) { return last_temp_nr; }

void pre_print_tac( struct ast_node* node ) {
}

void post_print_tac( struct ast_node* node ) {
}