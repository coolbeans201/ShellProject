all: y

y.tab.c y.tab.h:	shell.y
	bison -dy shell.y

lex.yy.c: shell.lex y.tab.h
	flex shell.lex

y: lex.yy.c y.tab.c y.tab.h
	gcc lex.yy.c y.tab.c -o shell

clean:
	rm shell y.tab.c lex.yy.c y.tab.h
