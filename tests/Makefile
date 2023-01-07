AS:=nasm
LD:=ld
ASFLAGS:=-felf64 -Fdwarf -g

BIN := list

OBJ :=  main.o      \
        ../dict.o   \
        ../lib.o

INC :=  words.inc    \
        ../colon.inc \

$(BIN): $(OBJ)
	ld -o $(BIN) $^

%.o: %.asm $(INC)
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f *.o ../*.o $(BIN)
