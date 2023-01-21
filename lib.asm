;;  This file is part of libx86
;;  libx86 is free software: you can redistribute it and/or modify it 
;;  under the terms of the GNU General Public License as published by the 
;;  Free Software Foundation, either version 3 of the License, 
;;  or (at your option) any later version.
;;  This program is distributed in the hope that it will be useful, 
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of 
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
;;  See the GNU General Public License for more details.
;;  You should have received a copy of the GNU General Public License 
;;  along with this program. If not, see <https://www.gnu.org/licenses/>. 

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
;   rdi: exit code
exit:
    mov rax, 60
    syscall
    ret


;   returns the length of string
;   rdi: pointer to null-terminated string
;   returns: rax - length of string
strlen:
    mov rax, -1
.loop:
    inc rax
    cmp byte[rdi+rax], 0
    jne .loop
    ret


;   compare two strings for equality.
;   rdi: pointer to null-terminated string (1)
;   rsi: pointer to null-terminated string (2)
;   returns: rax - if equal: 1 else 0
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


; rdi: src_string  rsi: dest_buffer  rdx: buffer_size
; returns : rax - on_success: buffer address (arg2)  on_failure: zero
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
;   rdi: pointer to null-terminated string
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
;   rdi: immediate value of character
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
;   rdi: immediate value to print
print_uint64:
    push r12
    mov rax, rdi ; dividend
    mov r12, 10  ; divisor
    mov rdi, rsp
    push byte 0
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
    pop r12b
    pop r12
    ret


; prints a 64-bit signed number, expects copy of number and not a pointer
; performed via tail call optimization, thanks wikipedia!
;   rdi: immediate value to print
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
;   rdi: null terminated string containing number in ascii
;   return: rax: number, rdx: count of characters
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
    xor rdx, rdx    
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
;   rdi: null terminated string containing number in ascii
;   return: rax: number, rdx: count of characters
parse_int64:
    xor rcx, rcx
    xor rax, rax
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


; read one character from stdin and return it
;   rax: character read from stdin
read_char:
    push rbp
    mov rbp, rsp
    sub rsp, 1
    xor eax, eax  ; read()
    xor edi, edi  ; stdin
    mov rsi, rsp  ; buffer
    mov rdx, 1    ; count
    syscall
    mov al, [rsp]
    add rsp, 1
    pop rbp
    ret


; read a word into a buffer, pass pointer to buffer, size of buffer
;   rdi: pointer to buffer to read into
;   rsi: size of buffer/number of bytes to be read
;   return - rax: pointer to buffer word was read into
;            rdx: number of characters read
read_word:
    push r13
    push r14
    push r15

    test rsi, rsi   ; buffer size shouldn't be zero
    jz .end_basic

    xor r13, r13 ; counter
    mov r14, rdi ; buffer
    mov r15, rsi ; size
    dec r15
.check_whitespaces_start:
    call read_char

    cmp al, 0x20                ; whitespace checks
    je .check_whitespaces_start
    cmp al, 0xa
    je .check_whitespaces_start
    cmp al, 0x9
    je .check_whitespaces_start
    cmp al, 0xd
    je .check_whitespaces_start

    cmp al, 0x4                 ; stream end and zero checks
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

    cmp r13, r15    ; if we're still parsing a word but our buffer has run out.
    jge .end_basic

    mov byte [r14+r13], al
    inc r13
    jmp .read_more
.end_basic:
    xor eax, eax
    xor rdx, rdx
    pop r15
    pop r14
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
