INPUT_FILE = testinput.tetris
x2021A7PS2091G: utils.c header.h lex.yy.c grammar.tab.c Makefile
	gcc -o x2021A7PS2091G utils.c lex.yy.c grammar.tab.c
grammar.tab.c: grammar.y
	bison -d grammar.y
lex.yy.c: scanner.l
	flex scanner.l
clean:
	rm -f grammar.tab.h lex.yy.c grammar.tab.c
	rm -rf __pycache__
run: x2021A7PS2091G
	./x2021A7PS2091G < $(INPUT_FILE) > output.py
	echo
	make clean
test: x2021A7PS2091G
	./x2021A7PS2091G < $(INPUT_FILE) > output.py
	echo
	make clean
header.h:
utils.c:
