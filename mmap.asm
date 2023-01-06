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



; open() flags
%define O_RDONLY 00
%define O_WRONLY 01
%define O_RDWR   02
%define O_CREAT  0100:

; mmap() prot flags
%define PROT_READ	0x1		
%define PROT_WRITE	0x2		
%define PROT_EXEC	0x4		
%define PROT_NONE	0x0		
%define PROT_GROWSDOWN	0x01000000	
%define PROT_GROWSUP	0x02000000	
%define MAP_PRIVATE	0x02		

%define LINUX_PAGE_SIZE 4096
