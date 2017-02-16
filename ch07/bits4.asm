        segment .data
sample  dq      0x0a0a0a0a0a0a0a0a
field   dq      0x12abcdef
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, [sample]      ; move quad-word into rax
        ror     rax, 23            ; shift to align bit 23 at 0
        shr     rax, 29            ; wipe out 29 bits
        shl     rax, 29            ; move bits back into alignment
        or      rax, [field]       ; or in the new bits
        rol     rax, 23            ; realign the bit fields
        mov     [sample], rax      ; save the field
        xor     rax, rax
        leave
        ret
