;This file is part of libx86.
;libx86 is free software: you can redistribute it and/or modify it under the 
;terms of the GNU Affero General Public License as published by the Free 
;Software Foundation, either version 3 of the License, or (at your option) 
;any later version.
;libx86 is distributed in the hope that it will be useful, but 
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
;or FITNESS FOR A PARTICULAR PURPOSE. 
;See the GNU Affero General Public License for more details.
;You should have received a copy of the 
;GNU Affero General Public License along with libx86. 
;If not, see <https://www.gnu.org/licenses/>. 

global exit
global print_string
global print_nstring
global print_char
global print_newline
global print_uint64
global print_int64
global parse_uint64
global parse_int64
global read_char
global read_word
global strlen
global strcmp
global strcpy


; calls the exit() syscall as specified by POSIX
exit:
    mov rax, 60
    syscall
    ret


; returns the length of string
strlen:
    mov rax, -1
.loop:
    inc rax
    cmp byte[rdi+rax], 0
    jne .loop
    ret


; pass two pointers to strings. 1 on equality, otherwise 0
strcmp:
    mov r9b, byte [rsi]
    cmp byte[rdi], r9b
    jne .end
    inc rdi
    inc rsi
    test r9b, r9b
    jnz strcmp
    mov rax, 1
    ret
.end:
    xor eax, eax
    ret


; arg1: src_string  arg2: dest_buffer  arg3: buffer_size
; return - on_success: buffer address (arg2)  on_failure: zero
strcpy:
    push rdi
    push rsi
    push rdx
    call strlen
    pop rdx
    pop rsi
    pop rdi
    cmp rax, rdx
    jge .end
    push rsi
.copying:
    mov r9b, byte[rdi]
    mov byte[rsi], r9b
    inc rdi
    inc rsi
    test r9b, r9b
    jnz .copying
    mov byte[rsi], 0
    pop rax
    ret
.end:
    xor eax, eax
    ret


; prints a null-terminated string, without any newline at end
print_string:
    call strlen
    mov rdx, rax ; third argument 
    mov rax, 1  ; write()
    mov rsi, rdi    ; string buffer to print, is second argument
    mov rdi, 1  ; file descriptor for stdout, is first argument
    syscall
    ret

; prints a null-terminated string of size `n`
;   - rdi: null terminated string
;   - rsi: size of string `n`
print_nstring:
    mov rdx, rsi    ; arg 3 - buffer len
    mov rax, 1  ; write()
    mov rsi, rdi    ; string buffer to print, is second argument
    mov rdi, 1  ; file descriptor for stdout, is first argument
    syscall
    ret


; print a char, accepts a immediate passed via anything but not a pointer
print_char:
    push rdi
    mov rdi, rsp
    call print_string
    pop rdi
    ret

; prints a newline character, example use of print_char
print_newline:
    mov rdi, 0xa
    jmp print_char


; prints a 64-bit unsigned number, expects copy of number and not a pointer
print_uint64:
    push r12
    mov rax, rdi ; dividend
    mov r12, 10  ; divisor
    mov rdi, rsp
    push 0
    sub rsp, 20 + 1 ; 2^64 ~20 bytes, 1 byte null terminator
.loop:
    xor rdx, rdx
    div r12
    or rdx, 0x30 ; ascii value of remainder: add rdx, 0x30
    dec rdi
    mov byte [rdi], dl   ; save on the stack
    test rax, rax
    jnz .loop
    call print_string
    add rsp, 20 + 1
    pop r12
    pop r12
    ret


; prints a 64-bit signed number, expects copy of number and not a pointer
; performed via tail call optimization, thanks wikipedia!
print_int64:
    test rdi, rdi
    jns print_uint64
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint64


; parses an unsigned integer
; return: rax: number, rdx: count of characters
parse_uint64:
    xor rax, rax
    xor rcx, rcx
    mov r10, 10
.loop:
    mov r8b, byte [rdi+rcx]
    cmp r8b, '0'
    jb .end
    cmp r8b, '9'
    jg .end
    xor rdx, rdx    ; clear rdx just like div
    mul r10
    and r8, 0x0f    ; normal value, numbers are in range 0x30-0x39
                    ; so getting rid of upper half should result in
                    ; normal integer value
                    ; similar to `sub r8, 0x30`
    add rax, r8
    inc rcx
    jmp .loop
.end:
    mov rdx, rcx
    ret


; same as parse_uint64 but for signed numbers
parse_int64:
    mov r8b, byte[rdi+rcx]
    cmp r8b, '-'
    je .neg_num
    jmp parse_uint64
.neg_num:
    inc rdi
    call parse_uint64
    neg rax
    test rdx, rdx
    jz .end
    inc rdx
    ret
.end:
    xor rax, rax
    ret


; read one characted from stdin and return it
read_char:
    push 1  ; originally: add rsp, 8
    xor eax, eax  ; read()
    xor edi, edi  ; stdin
    mov rsi, rsp  ; buffer
    mov rdx, 1    ; count
    syscall
    pop rax ; originally: mov rax, [rsp] ; sub rsp, 8
    ret


; read a word into a buffer, pass pointer to buffer, size of buffer
read_word:
    push r13
    push r14
    push r15
    xor r13, r13 ; counter
    mov r14, rdi ; buffer
    mov r15, rsi ; size
    dec r15
.check_whitespaces_start:
    call read_char
    cmp al, 0x20
    je .check_whitespaces_start
    cmp al, 0xa
    je .check_whitespaces_start
    cmp al, 0x9
    je .check_whitespaces_start
    cmp al, 0xd
    je .check_whitespaces_start
    cmp al, 0x4
    je .end
    test al, al
    je .end
    mov byte [r14+r13], al
    inc r13
.read_more:
    call read_char
    cmp al, 0x20
    je .end
    cmp al, 0xa
    je .end
    cmp al, 0x9
    je .end
    cmp al, 0xd
    je .end
    cmp al, 0x4
    je .end
    test al, al
    je .end
    cmp r13, r15
    jge .end
    mov byte [r14+r13], al
    inc r13
    jmp .read_more
.end_basic:
    xor eax, eax
    pop r13
    ret
.end:
    mov byte [r14+r13], 0
    mov rax, r14
    mov rdx, r13
    pop r15
    pop r14
    pop r13
    ret
