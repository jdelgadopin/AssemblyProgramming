        segment .data
        align   8
infd    dq      0
outfd   dq      0
in_name dq      0
out_name:
        dq      0
in_size dq      0
data    dq      0
        segment .text
        global  main
        extern  open, malloc, lseek, read, write, close, printf
main:
        push    rbp
        mov     rbp, rsp

;       Check the command line parameter count
        cmp     rdi, 3
        jne     .param_error

;       Save the input and output file names
        mov     r8, [rsi+8]
        mov     r9, [rsi+16]
        mov     [in_name], r8
        mov     [out_name], r9

;       Report the files being copied
        segment .data
.files_fmt:
        db      "copying %s to %s",0x0a,0
        segment .text
        lea     rdi, [.files_fmt]
        mov     rsi, [in_name]
        mov     rdx, [out_name]
        xor     eax, eax
        call    printf

;       Try to open the input file
        mov     rdi, [in_name]
        xor     esi, esi
        call    open
        cmp     rax, 0
        jl      .input_open_failed
        mov     [infd], rax

;       Try to open the output file
        mov     rdi, [out_name]
        xor     esi, esi
        call    open
        cmp     rax, 0
        jge     .output_exists

;       Try to create the output file
        mov     rdi, [out_name]
        mov     esi, 0x41
        mov     edx, 700o
        call    open
        cmp     rax, 0
        jl      .output_open_failed
        mov     [outfd], rax

;       Determine the input file size
        mov     rdi, [infd]
        xor     esi, esi
        mov     edx, 2
        call    lseek
        mov     [in_size], rax
        mov     rdi, [infd]
        xor     esi, esi
        mov     edx, 0
        call    lseek

;       Allocate the data array
        mov     rdi, [in_size]
        call    malloc
        cmp     rax, 0
        je      .malloc_failed
        mov     [data], rax

;       Read the input file
        mov     rdi, [infd]
        mov     rsi, [data]
        mov     rdx, [in_size]
        call    read

;       Write the output file
        mov     rdi, [outfd]
        mov     rsi, [data]
        mov     rdx, [in_size]
        call    write

;       Close the input and output files
        mov     rdi, [infd]
        call    close
        mov     rdi, [outfd]
        call    close

        xor     eax, eax
        leave
        ret

        segment .data
.malloc_failed_fmt:
        db      "malloc failed for %ld bytes",0x0a,0
        segment .text
.malloc_failed:
        lea     rdi, [.malloc_failed_fmt]
        mov     rsi, [in_size]
        xor     eax, eax
        call    printf
        mov     eax, 1
        leave
        ret

        segment .data
.output_exist_fmt:
        db      "%s already exists",0x0a,0
        segment .text
.output_exists:
        lea     rdi, [.output_exist_fmt]
        mov     rsi, [out_name]
        xor     eax, eax
        call    printf
        mov     eax, 1
        leave
        ret

        segment .data
.output_open_fmt:
        db      "Could not open output_file %s",0x0a,0
        segment .text
.output_open_failed:
        lea     rdi, [.output_open_fmt]
        mov     rsi, [out_name]
        xor     eax, eax
        call    printf
        mov     eax, 1
        leave
        ret

        segment .data
.input_open_fmt:
        db      "Could not open input_file %s",0x0a,0
        segment .text
.input_open_failed:
        lea     rdi, [.input_open_fmt]
        mov     rsi, [in_name]
        xor     eax, eax
        call    printf
        mov     eax, 1
        leave
        ret

        segment .data
.param_fmt:
        db      "Usage: copy input_file output_file",0x0a,0
        segment .text
.param_error:
        lea     rdi, [.param_fmt]
        xor     eax, eax
        call    printf
        mov     eax, 1
        leave
        ret
