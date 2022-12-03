example: example.o io.o util.o
	ld -melf_x86_64 -o example example.o io.o util.o
example.o: example.asm
	as --64 -g -o example.o example.asm -a=example.lst
io.o: io.asm
	as --64 -g -o io.o io.asm -a=io.lst
util.o: util.asm
	as --64 -g -o util.o util.asm -a=util.lst
