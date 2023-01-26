%include "../lib.inc"
%include "../dict.inc"
%include "words.inc"

section .data
ERR: db "Key value not found in dictionary", 0

section .text

global _start
_start:
    push rbp
    mov rbp, rsp
    sub rsp, 256

    mov rdi, rsp
    mov rsi, 255
    call read_word

    mov rdi, rsp
    mov rsi, COL_PREV_ENTRY ; from words.inc -> entry.inc
    call find_word
    cmp rax, 0
    jz .bad_end

    mov r8, [rax + 8]   ; load length of key string
    add r8, 16 + 1      ; 16 bytes of data structure's first two fields + 
                        ; accounting for null-terminator in key string
    add rax, r8
    mov rdi, rax        ; value from (key, value) 
    call print_string
    call print_newline

    add rsp, 256
    pop rbp
    xor rdi, rdi
    jmp .ok_end
.bad_end:
    add rsp, 256
    pop rbp
    mov rdi, ERR
    call print_string
    call print_newline
    mov rdi, 1
.ok_end:
    call exit
