        segment .data
msg:    db      "Hello World",10
len:    equ     $-msg

        segment .text
        global  main
main:
        mov     rdx, len   ; equals 13
        mov     rcx, msg   ; array to write
        mov     eax, 4     ; 4 is the 32 bit system call number
        mov     ebx, 1     ; 1 is stdout file descriptor
        int     0x80

        mov     ebx, 0     ; 0 is the return status for success
        mov     eax, 1     ; 1 is the exit system call number
        int     0x80
