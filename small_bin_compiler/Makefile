parser: lex.yy.c binary.tab.h main.c
	gcc -oparser binary.tab.c lex.yy.c main.c
binary.tab.h: binary.y
	bison -d binary.y
lex.yy.c: binary.flex binary.tab.h
	flex binary.flex
clean: 
	rm -f binary.tab.h binary.tab.c lex.yy.c parser
