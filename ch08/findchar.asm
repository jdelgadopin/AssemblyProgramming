        segment .data
data    db      "hello world", 0
n       dq      0
needle  db      'w'

        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp

;       Register usage
;
;       rax: c, byte of data array
;       r8b:  x, byte to search for
;       rcx: i, loop counter, 0-63
;       rdx: data, address of data
;
        mov     r8b, [needle]
        lea     rdx, [data]
;       i = 0;
        xor     ecx, ecx
;       c = data[i];
        mov     al, [rdx+rcx]
;       if ( c != 0 ) {
        cmp     al, 0
        jz      end_if
;           do {
do_while:
;               if ( c == x ) break;
                cmp     al, r8b
                je      found
;               i++;
                inc     rcx
;               c = data[i];
                mov     al, [rdx+rcx];
;           } while ( c != 0 );
            cmp     al, 0
            jnz     do_while
;       }
end_if:
;       n = c == 0 ? -1 : i;
        mov     rcx, -1
found:  mov     [n], rcx
;       return 0;
        xor     eax, eax
        leave
        ret
