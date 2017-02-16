        segment .bss
set     resq    10
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        bts     qword [set], 4     ; set bit 4 of set
        bts     qword [set], 7     ; set bit 7 of set
        bts     qword [set], 8     ; set bit 8 of set
        bts     qword [set+8], 12  ; set bit 76 of set
        mov     rax, 76            ; test bits 4, 76, 77
        mov     rbx, rax           ; copy bit number to rbx
        shr     rbx, 6             ; qword number of set to test
        mov     rcx, rax           ; copy bit number to rcx
        and     rcx, 0x3f          ; extract rightmost 6 bits
        xor     edx, edx           ; set rdx to 0
        lea     rsi, [set]         ; OS X: must have address in reg
        bt      [rsi+8*rbx], rcx   ; test bit
;       bt      [set+8*rbx], rcx   ; works on Linux
        setc    dl                 ; edx equals the tested bit
        bts     [rsi+8*rbx], rcx   ; set the bit, insert into set
        btr     [rsi+8*rbx], rcx   ; clear the bit, remove
        xor     rax, rax
        leave
        ret
