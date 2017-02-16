        segment .data
; long data;
data    dq      0xfedcba9876543210
; long sum;
sum     dq      0

        segment .text
        global  main
; int main()
; {
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16
;       int i;  // in register rcx

;       Register usage
;
;       rax: bits being examined
;       rbx: carry bit after bt, setc
;       rcx: loop counter, 0-63
;       rdx: sum of 1 bits
;
        mov     rax, [data]
        xor     ebx, ebx
;       i = 0;
        xor     ecx, ecx
;       sum = 0;
        xor     edx, edx
;       while ( i < 64 ) {
while:
        cmp     rcx, 64
        jnl     end_while
;           sum += data & 1;
            bt      rax, 0
            setc    bl
            add     edx, ebx
;           data >>= 1;
            shr     rax, 1
;           i++;
            inc     rcx
;       }
        jmp     while
end_while:
        mov     [sum], rdx
        xor     eax, eax
        leave
        ret
