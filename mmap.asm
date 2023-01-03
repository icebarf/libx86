; open() flags
%define O_RDONLY 00
%define O_WRONLY 01
%define O_RDWR   02
%define O_CREAT  0100

; mmap() prot flags
%define PROT_READ	0x1		
%define PROT_WRITE	0x2		
%define PROT_EXEC	0x4		
%define PROT_NONE	0x0		
%define PROT_GROWSDOWN	0x01000000	
%define PROT_GROWSUP	0x02000000	
%define MAP_PRIVATE	0x02		

%define LINUX_PAGE_SIZE 4096
