all:
	flex aritimetica.l
	bison -r all -d aritimetica.y
	gcc -ggdb aritimetica.tab.c lex.yy.c -o cmp
	head -n 30 teste_for.c | ./cmp
