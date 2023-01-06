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



global find_word

extern strcmp

; find_word - rdi: pointer to null-terminated `key` string
;           - rsi: pointer to last entry in dictionary/list
;             returns a pointer to the address of the entry of the key 
;             if found otherwise, a zero is returned
find_word:
    xor rax, rax
.find:
    test rsi, rsi
    jz .end
    push rsi
    push rdi
    add rsi, 16
    call strcmp
    pop rdi
    pop rsi
    cmp rax, 0
    jnz .found
    mov rsi, [rsi]  ; rsi = rsi->next
    jmp .find
.found:
    mov rax, rsi
.end:
    ret
