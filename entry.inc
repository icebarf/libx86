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

%define COL_PREV_ENTRY 0

; llentry - create a dictionary word/entry
;       - takes two arguments
;       - arg1: key value, null-terminated string
;       - arg2: assembly label name
%macro llentry 2
%strlen key_len %1

%%COL_PREV_ENTRY: dq COL_PREV_ENTRY
dq key_len
db %1, 0
etr_ %+ %2: 

%define COL_PREV_ENTRY %%COL_PREV_ENTRY
%endmacro

; linked list structure is as follows
;struct entry {
;   uintptr_t COL_PREV_ENTRY; /* expected to be 8 bytes on x86_64 */
;   uint64_t key_len;     /* length of the key string, also 8 bytes */
;   char* key;            /* key array - null terminated string */
;   ...                   /* data stored, access via skipping over the data
;                            structure, i.e skip 8+8+key_len bytes from start.
;}
