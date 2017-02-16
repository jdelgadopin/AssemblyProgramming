        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, 0x12345678
        shr     rax, 8          ; I want bits 8-15
        and     rax, 0xff       ; rax now holds 0x56
        mov     rax, 0x12345678 ; I want to replace bits 8-15
        mov     rdx, 0xaa       ; rdx holds replacement field
        mov     rbx, 0xff       ; I need an 8 bit mask
        shl     rbx, 8          ; Shift mask to align @ bit 8
        not     rbx             ; rbx is the inverted mask
        and     rax, rbx        ; Now bits 8-15 are all 0
        shl     rdx, 8          ; Shift the new bits to align
        or      rax, rdx        ; rax now has 0x1234aa78
        xor     rax, rax
        leave
        ret
