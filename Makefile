NASM=nasm
CC=gcc
NASMFLAGS=-f macho64
LDFLAGS=

TARGET=vibempeg
SOURCES=vibempeg.asm
OBJECTS=$(SOURCES:.asm=.o)

all: $(TARGET)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all clean