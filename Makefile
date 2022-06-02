YACC=bison
LEX=flex
CC=gcc

SRCDIR=src/main
BUILDIR=build
YACCDIR=bison
LEXDIR=flex
CNAME=spc

all: build $(CNAME)

build:
	mkdir -p $(BUILDIR)

$(CNAME): $(BUILDIR)/$(CNAME).tab.c $(BUILDIR)/$(CNAME).lex.c
	@$(CC) -o $@ $^ -lfl
	@printf "\033[1mCC\033[0m\t$^\n"

$(BUILDIR)/%.lex.c: $(SRCDIR)/$(LEXDIR)/%.lex.l
	@$(LEX) -o $@ $^
	@printf "\033[1mLEX\033[0m\t$^\n"

$(BUILDIR)/%.tab.c: $(SRCDIR)/$(YACCDIR)/%.scan.y
	@$(YACC) -d $^ -o $@
	@printf "\033[1mYACC\033[0m\t$^\n"

clean:
	rm -rf build

.PHONY: clean