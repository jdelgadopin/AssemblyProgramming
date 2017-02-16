        segment .data

msg:    db      "Hello World!",0x0a      ; String to print
len:    equ     $-msg                   ; Length of the string

        segment .text
        global  main                    ; Announce main to the linker
        extern  write, exit
main:
        push    rbp
        mov     rbp, rsp
        mov     edx, len                ; Argument 3 is the length to write
        lea     rsi, [msg]              ; Argument 2 for the write call
        mov     edi, 1                  ; Argument 1 for the write
        call    write

        xor     edi, edi                ; 0 return status = success
        call    exit
