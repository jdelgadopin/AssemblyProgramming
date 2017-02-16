OS := $(shell uname -s)

ifeq ($(OS),Darwin)
   OBJFMT = -f macho64
else
   OBJFMT = -f elf64 -g dwarf2
endif

PROGS = bits bits2 bits3 bits4 rotate
all: $(PROGS) 

.SUFFIXES:
.SUFFIXES: .o .asm .c
.SECONDARY:

.asm.o:
	yasm -P ebe.inc -Worphan-labels $(OBJFMT) -l $*.lst $<

.o:
	gcc -g -o $@ $<

clean:
	rm -f $(PROGS) *.o *.lst *~ .*.gdb .ebe.*

