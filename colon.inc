;    This file is part of libx86.
;    libx86 is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
;    libx86 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
;    You should have received a copy of the GNU Affero General Public License along with libx86. If not, see <https://www.gnu.org/licenses/>. 


%define next_entry 0
; colon - create a dictionary word/entry
;       - takes two arguments
;       - arg1: key value, null-terminated string
;       - arg2: assembly label name
%macro colon 2
%%next_entry: dq next_entry
db %1, 0
etr_ %+ %2: 
%define next_entry %%next_entry
%endmacro
