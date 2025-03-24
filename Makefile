CC = gcc
ASM = nasm
CFLAGS = -arch x86_64 -Wl,-no_pie
ASMFLAGS = -f macho64 -g -F dwarf

all: vibempeg

vibempeg: vibempeg.o
	$(CC) $(CFLAGS) $^ -o $@

vibempeg.o: vibempeg.asm
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f vibempeg.o vibempeg

.PHONY: all clean