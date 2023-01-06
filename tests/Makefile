AS:=nasm
LD:=ld
AFLAGS:=-felf64 -Fdwarf -g
BIN := list

all: $(BIN)

$(BIN):
	$(AS) $(AFLAGS) main.asm
	$(AS) $(AFLAGS) ../lib.asm -o lib.o
	$(AS) $(AFLAGS) ../dict.asm -o dict.o
	$(LD) -o $@ lib.o dict.o main.o

clean:
	rm *.o $(BIN)
