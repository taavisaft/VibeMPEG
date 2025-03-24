; VibeMPEG - MOV to MP4 converter
; Optimized for Apple Silicon (ARM64)

    DEFAULT REL
    BITS 64

    global  _main
    extern  _printf
    extern  _fopen
    extern  _fread
    extern  _fwrite
    extern  _fclose
    extern  _exit

    section .data
usage_msg:      db  "Usage: vibempeg input.mov output.mp4", 10, 0
read_mode:      db  "rb", 0
write_mode:     db  "wb", 0
error_msg:      db  "Error: Could not open input file", 10, 0
error_out_msg:  db  "Error: Could not open output file", 10, 0
read_error_msg: db  "Error: Failed to read from file", 10, 0
write_error_msg:db  "Error: Failed to write to file", 10, 0

    section .bss
input_file:     resq    1    ; Input file handle
output_file:    resq    1    ; Output file handle
buffer:         resb    4096 ; General purpose buffer
bytes_read:     resq    1    ; Number of bytes read

    section .text

_main:
    ; Preserve frame pointer and stack
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32         ; Allocate stack space

    ; Save argc and argv
    mov     [rbp-8], rdi    ; Save argc
    mov     [rbp-16], rsi   ; Save argv

    ; Check argument count
    cmp     rdi, 3
    je      check_args

    ; Print usage if wrong number of args
    lea     rdi, [rel usage_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    call    _exit

check_args:
    ; Open input file
    mov     rsi, [rbp-16]   ; Restore argv
    mov     rdi, [rsi+8]    ; argv[1] - input filename
    lea     rsi, [rel read_mode]
    call    _fopen
    mov     [rel input_file], rax

    ; Check if input file opened successfully
    test    rax, rax
    jnz     open_output

    ; Print error and exit if input file open failed
    lea     rdi, [rel error_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    call    _exit

open_output:
    ; Open output file
    mov     rsi, [rbp-16]   ; Restore argv
    mov     rdi, [rsi+16]   ; argv[2] - output filename
    lea     rsi, [rel write_mode]
    call    _fopen
    mov     [rel output_file], rax

    ; Check if output file opened successfully
    test    rax, rax
    jnz     copy_file

    ; Print error and exit if output file open failed
    lea     rdi, [rel error_out_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    jmp     cleanup

copy_file:
    ; Read from input file
    lea     rdi, [rel buffer]    ; Buffer
    mov     rsi, 1              ; Size of each element
    mov     rdx, 4096           ; Number of elements
    mov     rcx, [rel input_file] ; File pointer
    call    _fread
    mov     [rel bytes_read], rax

    ; Check if read was successful
    test    rax, rax
    jz      cleanup

    ; Write to output file
    lea     rdi, [rel buffer]    ; Buffer
    mov     rsi, 1              ; Size of each element
    mov     rdx, [rel bytes_read] ; Number of elements
    mov     rcx, [rel output_file] ; File pointer
    call    _fwrite

    ; Check if write was successful
    cmp     rax, [rel bytes_read]
    jne     write_error

    ; Continue reading until EOF
    jmp     copy_file

write_error:
    ; Print error message
    lea     rdi, [rel write_error_msg]
    xor     eax, eax
    call    _printf

cleanup:
    ; Close input file
    mov     rdi, [rel input_file]
    call    _fclose

    ; Close output file
    mov     rdi, [rel output_file]
    call    _fclose

    ; Exit with success
    xor     edi, edi
    call    _exit
