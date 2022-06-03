YACC=bison
LEX=flex
CC=gcc

SRCDIR=src/main
BUILDIR=build
YACCDIR=bison
LEXDIR=flex
CDIR=c
CNAME=spc

all: build copyc $(CNAME)

build:
	mkdir -p $(BUILDIR)

copyc:
	cp -f $(SRCDIR)/$(CDIR)/* $(BUILDIR)

$(CNAME): $(BUILDIR)/$(CNAME).tab.c $(BUILDIR)/$(CNAME).lex.c $(BUILDIR)/ast.c
	@printf "\033[1mCC\033[0m\t$^\n"
	@$(CC) -o $@ $^ -lfl

$(BUILDIR)/%.lex.c: $(SRCDIR)/$(LEXDIR)/%.lex.l
	@printf "\033[1mLEX\033[0m\t$^\n"
	@$(LEX) -o $@ $^

$(BUILDIR)/%.tab.c: $(SRCDIR)/$(YACCDIR)/%.scan.y
	@printf "\033[1mYACC\033[0m\t$^\n"
	@$(YACC) -d $^ -o $@

clean:
	rm -rf build
	rm -f $(CNAME)

.PHONY: clean