#ifndef _TAC_H_
#define _TAC_H_

#include "ast.h"

typedef void ( pre_func )( struct ast* node );
typedef void ( post_func )( struct ast* node );

void pre_print_tac( struct ast* node );
void post_print_tac( struct ast* node );

void dfs_traverse( struct ast* node, pre_func pre, post_func post );

#endif /* _TAC_H_ */