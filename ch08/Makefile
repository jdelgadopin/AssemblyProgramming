OS := $(shell uname -s)

ifeq ($(OS),Darwin)
   OBJFMT = -f macho64
else
   OBJFMT = -f elf64 -g dwarf2
endif

PROGS = switch if if2 if3 countbitsc countbits findchar add_arrays \
	findcharright strlen memcmp

all: $(PROGS) 

.SUFFIXES:
.SUFFIXES: .o .asm
.SECONDARY:

.asm.o:
	yasm -P ebe.inc -Worphan-labels $(OBJFMT) -l $*.lst $<

.o:
	gcc -g -o $@ $<

countbitsc: countbits.c
	gcc -O3 -g -o countbitsc countbits.c

clean:
	rm -f $(PROGS) *.o *.lst *~ .*.gdb *.s .ebe.*

