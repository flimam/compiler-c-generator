trabalho: trab.l trab.y	
	bison -d trab.y
	flex trab.l
	gcc -o run lex.yy.c trab.tab.c
	rm lex.yy.c trab.tab.c trab.tab.h
	./run test.po
	cat output.c
