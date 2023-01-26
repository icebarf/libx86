AS:=nasm
LD:=ld
ASFLAGS:=-felf64 -Fdwarf -g

BIN := list

OBJ :=  main.o      \

INC :=  words.inc    \
        ../colon.inc \

all: $(BIN)

$(OBJ): %.o : %.asm
	$(AS) $(ASFLAGS) $< -o $@

$(BIN): $(OBJ)
	ld -o $(BIN) $^

clean:
	rm -f *.o ../*.o $(BIN)
