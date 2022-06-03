#include "tac.h"

static int last_label_nr = 0;

static inline int next_label( ) { return last_label_nr++; }

static inline int current_label( ) { return last_label_nr; }

void pre_print_tac( struct ast* node ) {
    switch ( node->type ) {
        case ANT_REPEAT: printf( ".l%d:\t", next_label( ) ); break;
        default: break;
    }
}

void post_print_tac( struct ast* node ) {
    printf( "node printed\n" );
}