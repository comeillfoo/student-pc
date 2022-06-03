#ifndef MAIN_HW_VAR5_AST_H
#define MAIN_HW_VAR5_AST_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>

extern int yylineno; /* from lexer */

void yyerror(char *s, ...) {
    va_list ap;
    va_start(ap, s);
    fprintf(stderr, "%d: error: ", yylineno);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}



struct ast {
    int nodetype;
    struct ast *l;
    struct ast *r;
};

struct num_val {
    int nodetype; /* type K for constant */
    double number;
};

struct ident {
    int node_type; // type C for ident
    char *name;
};

/* build an AST */
struct ast *new_ast(int nodetype, struct ast *l, struct ast *r) {
    printf("start ast %d \n", nodetype);
    struct ast *new_ast = malloc(sizeof(struct ast));

    if (!new_ast) {
        yyerror("out of space");
        exit(-1);
    }

    new_ast->l = l;
    new_ast->r = r;
    new_ast->nodetype = nodetype;
    printf("end ast \n");
    return new_ast;
}

struct ast *new_ident(const char *ident) {

    struct ident *id = malloc(sizeof(struct ident));

    if (!id) {
        yyerror("out of space");
        exit(-1);
    }

    id->node_type = 'C';
    if(!ident) {
        printf("Yes\n");
    }
    strcpy(id->name, ident);
    printf("new_id: %s\n", ident);
    return (struct ast *) id;
}

struct ast *new_num(double d) {
    struct num_val *num = malloc(sizeof(struct num_val));

    if (!num) {
        yyerror("out of space");
        exit(-1);
    }
    num->nodetype = 'K';
    num->number = d;
    printf("new_num: %f\n", num->number);
    return (struct ast *) num;
}


#endif //MAIN_HW_VAR5_AST_H
