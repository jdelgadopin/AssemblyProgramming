        segment .data
name    db      "Calvin", 0
address db      "12 Mockingbird Lane",0
balance dd      12500

        struc   Customer
c_id      resd    1
c_name    resb    64
c_address resb    65
          align   4
c_balance resd    1
c_j       resb    1
          align   4
        endstruc

m       istruc  Customer
        at c_id, dd 8
        at c_name, db "Calvin"
        at c_address, db "junk"
        at c_balance, dd 12500
        iend

c       dq      0

        segment .text
        global  main
        extern  malloc, strcpy
main:   push    rbp
        mov     rbp, rsp
        mov     rdi, Customer_size
        call    malloc
        mov     [c], rax
        mov     [rax+c_id], dword 7
        lea     rdi, [rax+c_name]
        lea     rsi, [name]
        call    strcpy
        mov     rax, [c]
        lea     rdi, [rax+c_address]
        lea     rsi, [address]
        call    strcpy
        mov     rax, [c]
        mov     edx, [balance]
        mov     [rax+c_balance], edx
        xor     eax, eax
        leave
        ret
