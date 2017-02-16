        segment .data
msg:    db      "Hello World",0x0a      ; String to print
len:    equ     $-msg                   ; Length of the string

        segment .text
        global  _start                  ; Announce _start to the linker
_start:
        mov     edx, len                ; Argument 3 of a function or
                                        ; system call is placed in rdx
        mov     rsi, msg                ; Argument 2 for the write call
        mov     edi, 1                  ; Argument 1 for the write
        mov     eax, 1                  ; Syscall 1 is write
        syscall

        xor     edi, edi                ; 0 return status = success
        mov     eax, 60                 ; 60 is the exit syscall
        syscall
