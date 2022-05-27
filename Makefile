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
	$(CC) -o $@ $^ -lfl

$(BUILDIR)/%.lex.c: $(SRCDIR)/$(LEXDIR)/%.lex.l
	$(LEX) -o $@ $^

$(BUILDIR)/%.tab.c: $(SRCDIR)/$(YACCDIR)/%.scan.y
	$(YACC) -d $^ -o $@

clean:
	rm -rf build

.PHONY: clean