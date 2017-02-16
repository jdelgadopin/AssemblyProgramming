OS := $(shell uname -s)

ifeq ($(OS),Darwin)
   OBJFMT = -f macho64
else
   OBJFMT = -f elf64 -g dwarf2
endif

PROGS = array copy_array min argsc args
all: $(PROGS) 

.SUFFIXES:
.SUFFIXES: .o .asm .c
.SECONDARY:

.asm.o:
	yasm -P ebe.inc -Worphan-labels $(OBJFMT) -l $*.lst $<

.o:
	gcc -g -o $@ $<

args:   args.o
	gcc -g -o $@ $<

argsc: args.c
	gcc -O1 -g -o argsc args.c

clean:
	rm -f $(PROGS) *.o *.lst *~ .*.gdb .ebe.*

