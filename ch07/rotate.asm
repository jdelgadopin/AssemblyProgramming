        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, 0x12345678; Initial value for rax
        ror     rax, 8         ; Preserve bits 7-0
        shr     rax, 4         ; Shift out original 11-8
        shl     rax, 4         ; Bits 3-0 are 0's
        or      rax, 1010b     ; Set the field to 1010b
        rol     rax, 8         ; Bring back bits 7-0
        xor     rax, rax
        leave
        ret
