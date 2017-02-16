        segment .text
        extern  printf, random, malloc, atoi
        global  main, create, fill, min

;       array = create ( size );
create:
        push    rbp
        mov     rbp, rsp
        imul    rdi, 4
        call    malloc
        leave
        ret

;       fill ( array, size );
fill:
.array  equ     local1
.size   equ     local2
.i      equ     local3
        push    rbp
        mov     rbp, rsp
        frame   2, 3, 0
        sub     rsp, frame_size
        mov     [rbp+.array], rdi
        mov     [rbp+.size], rsi
        xor     ecx, ecx
.more   mov     [rbp+.i], rcx
        call    random
        mov     rcx, [rbp+.i]
        mov     rdi, [rbp+.array]
        mov     [rdi+rcx*4], eax
        inc     rcx
        cmp     rcx, [rbp+.size]
        jl      .more
        leave
        ret

;       print ( array, size );
print:
.array  equ     local1
.size   equ     local2
.i      equ     local3
        push    rbp
        mov     rbp, rsp
        frame   2, 3, 2
        sub     rsp, frame_size
        mov     [rbp+.array], rdi
        mov     [rbp+.size], rsi
        xor     ecx, ecx
        mov     [rbp+.i], rcx
        segment .data
.format:
        db      "%10d",0x0a,0
        segment .text
.more   lea     rdi, [.format]
        mov     rdx, [rbp+.array]
        mov     rcx, [rbp+.i]
        mov     esi, [rdx+rcx*4]
        mov     [rbp+.i], rcx
        xor     eax, eax
        call    printf
        mov     rcx, [rsp+.i]
        inc     rcx
        mov     [rbp+.i], rcx
        cmp     rcx, [rbp+.size]
        jl      .more
        leave
        ret

;       x = min ( array, size );
min:
        mov     eax, [rdi]
        mov     rcx, 1
.more   mov     r8d, [rdi+rcx*4]
        cmp     r8d, eax
        cmovl   eax, r8d
        inc     rcx
        cmp     rcx, rsi
        jl      .more
        ret

main:
.array  equ     local1
.size   equ     local2
        push    rbp
        mov     rbp, rsp
        frame   2, 2, 2
        sub     rsp, frame_size

;       set default size
        mov     ecx, 10
        mov     [rbp+.size], rcx

;       check for argv[1] providing a size
        cmp     edi, 2
        jl      .nosize
        mov     rdi, [rsi+8]
        call    atoi
        mov     [rbp+.size], rax
.nosize:

;       create the array
        mov     rdi, [rbp+.size]
        call    create
        mov     [rbp+.array], rax

;       fill the array with random numbers
        mov     rdi, rax
        mov     rsi, [rbp+.size]
        call    fill

;       if size <= 20 print the array
        mov     rsi, [rbp+.size]
        cmp     rsi, 20
        jg      .toobig
        mov     rdi, [rbp+.array]
        call    print
.toobig:

;       print the minimum
        segment .data
.format:
        db      "min: %ld",0xa,0
        segment .text
        mov     rdi, [rbp+.array]
        mov     rsi, [rbp+.size]
        call    min
        lea     rdi, [.format]
        mov     rsi, rax
        xor     eax, eax
        call    printf

        leave
        ret
