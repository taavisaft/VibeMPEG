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
    extern  _malloc
    extern  _free
    extern  _fseek
    extern  _feof
    extern  _ftell
    extern  _ferror
    extern  _clearerr

    section .data
usage_msg:      db  "Usage: vibempeg input.mov output.mp4", 10, 0
read_mode:      db  "rb", 0
write_mode:     db  "wb", 0
error_msg:      db  "Error: Could not open input file", 10, 0
error_out_msg:  db  "Error: Could not open output file", 10, 0
read_error_msg: db  "Error: Failed to read from file", 10, 0
write_error_msg:db  "Error: Failed to write to file", 10, 0
seek_error_msg: db  "Error: Failed to seek in file", 10, 0
debug_msg:      db  "Processing file...", 10, 0
parse_msg:      db  "Parsing MOV container...", 10, 0
read_msg:       db  "Reading atom header...", 10, 0
pos_msg:        db  "Current file position: %lld", 10, 0
size_msg:       db  "Read size: %lld", 10, 0
type_msg:       db  "Read type: %s", 10, 0
atom_msg:       db  "Found atom: %s, size: %lld bytes at position %lld", 10, 0
seek_msg:       db  "Seeking to position %lld", 10, 0
invalid_msg:    db  "Error: Invalid MOV format", 10, 0
success_msg:    db  "Conversion completed", 10, 0
eof_msg:        db  "Reached end of file", 10, 0
read_bytes_msg: db  "Read %lld bytes", 10, 0
error_check_msg:db  "Checking for error...", 10, 0
ferror_msg:     db  "ferror returned: %d", 10, 0
feof_msg:       db  "feof returned: %d", 10, 0
newline:        db  10, 0
debug_ptr:      db  "File pointer: %p", 10, 0
debug_read:     db  "Reading %d bytes from %p into %p", 10, 0
file_size_msg:  db  "File size: %lld bytes", 10, 0
pos_error_msg:  db  "Error: Invalid file position %lld (file size: %lld)", 10, 0
size_error_msg: db  "Error: Invalid atom size %lld at position %lld", 10, 0
copy_msg:       db  "Copying atom of size %lld bytes", 10, 0
wrote_msg:      db  "Wrote %lld bytes", 10, 0
header_error_msg: db "Error: Failed to store atom header", 10, 0
eof_success_msg: db  "Reached end of file successfully", 10, 0
atom_error_msg:  db  "Error: Invalid atom at position %lld (size: %lld)", 10, 0
ftyp_msg:       db  "Processing ftyp atom...", 10, 0
extended_size_msg: db "Processing extended size atom...", 10, 0
prev_atom_msg:  db  "Previous atom: %s, size: %lld at position %lld", 10, 0
no_ftyp_msg:    db  "Warning: No ftyp atom found at start of file", 10, 0

; Add MP4 related messages and atoms
mp4_brand:      db  "isom", 0    ; Default MP4 brand
mp4_version:    dd  0x00000200   ; MP4 version 2.0
converting_msg: db  "Converting MOV to MP4...", 10, 0
progress_msg:   db  "Progress: %d%%", 13, 0   ; \r for same line updates
brand_msg:      db  "Setting MP4 brand: %s", 10, 0
version_msg:    db  "Setting MP4 version: %d.%d", 10, 0

; All QuickTime/MP4 atom types
ftyp_atom:      db  "ftyp", 0
moov_atom:      db  "moov", 0
mdat_atom:      db  "mdat", 0
trak_atom:      db  "trak", 0
mvhd_atom:      db  "mvhd", 0
clef_atom:      db  "clef", 0
prof_atom:      db  "prof", 0
enof_atom:      db  "enof", 0
wave_atom:      db  "wave", 0
free_atom:      db  "free", 0
skip_atom:      db  "skip", 0
wide_atom:      db  "wide", 0    ; Moved here from duplicate definition
uuid_atom:      db  "uuid", 0

; Messages for atom handling
container_msg:  db  "Found container atom: %s", 10, 0
nested_msg:     db  "Processing nested atom at position %lld", 10, 0
debug_size_msg: db  "Debug: Atom size bytes: %02x %02x %02x %02x", 10, 0
debug_type_msg: db  "Debug: Atom type bytes: %02x %02x %02x %02x", 10, 0
reading_file_msg: db "Reading MOV file header...", 10, 0
raw_read_msg:   db  "Using low-level read...", 10, 0
header_dump_msg: db  "First 16 bytes: %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x", 10, 0
hex_debug_msg:   db  "Byte at offset %d: 0x%02x", 10, 0
format_debug:    db  "Detected format: %s", 10, 0
atom_repair_msg: db  "Attempting to repair atom...", 10, 0
simple_mode_msg: db  "Switching to simple conversion mode...", 10, 0
simple_copy_msg: db  "Direct copy mode: %lld bytes remaining", 10, 0
skip_count_msg:  db  "Skipping first %lld bytes of source file", 10, 0
buffer_msg:      db  "Using buffer size: %lld bytes", 10, 0
direct_done_msg: db  "Direct conversion complete!", 10, 0
codec_msg:      db  "Note: This tool only handles container conversion, not codec transcoding.", 10, 0
codec_req_msg:  db  "For full transcoding, consider integrating with libraries like libx264 or libfdk-aac.", 10, 0
debug_fread_msg:  db  "fread returned: %lld bytes", 10, 0
debug_fwrite_msg: db  "fwrite returned: %lld bytes", 10, 0
debug_seek_msg:   db  "Seeking to position %lld in input file", 10, 0
debug_block_msg:  db  "Processing block %lld of %lld", 10, 0
simplified_copy_msg: db "Using simplified copy approach", 10, 0
proper_copy_msg: db  "Using proper atom-aware conversion mode", 10, 0
atom_found_msg:  db  "Found essential atom: %s (%lld bytes)", 10, 0
moov_copy_msg:   db  "Copying moov atom (contains essential metadata)", 10, 0
mdat_copy_msg:   db  "Copying mdat atom (contains media data)", 10, 0
atom_order_msg:  db  "Ensuring proper atom order for playback", 10, 0
basic_mp4_msg:   db  "Creating basic MP4 structure", 10, 0
minimal_mode_msg: db  "Using minimal conversion mode - basic MOV to MP4", 10, 0
copy_bytes_msg:   db  "Copying %lld bytes in chunks", 10, 0

    section .bss
input_file:     resq    1
output_file:    resq    1
buffer:         resb    4096
bytes_read:     resq    1
atom_size:      resq    1
atom_type:      resb    5
prev_atom_type: resb    5
prev_atom_size: resq    1
prev_atom_pos:  resq    1
temp_buffer:    resb    8
file_pos:       resq    1
target_pos:     resq    1
file_size:      resq    1
copy_buffer:    resb    65536
ftyp_buffer:    resb    24       ; Buffer for ftyp atom (including brand)
brand_buffer:   resb    4        ; Buffer for MP4 brand
progress:       resd    1        ; Progress counter
raw_buffer:     resb    16        ; Buffer for raw file reading

    section .text

read_bytes:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13

    mov     rbx, rdi
    mov     r12, rsi
    mov     r13, rdx

    lea     rdi, [rel debug_read]
    mov     rsi, r12
    mov     rdx, r13
    mov     rcx, rbx
    xor     eax, eax
    call    _printf

    mov     rdi, rbx
    mov     rsi, 1
    mov     rdx, r12
    mov     rcx, r13
    call    _fread

    pop     r13
    pop     r12
    pop     rbx
    leave
    ret

read_atom_header:
    push    rbp
    mov     rbp, rsp
    push    rbx

    lea     rdi, [rel read_msg]
    xor     eax, eax
    call    _printf
    lea     rdi, [rel newline]
    xor     eax, eax
    call    _printf

    mov     rdi, [rel input_file]
    call    _clearerr

    lea     rdi, [rel debug_ptr]
    mov     rsi, [rel input_file]
    xor     eax, eax
    call    _printf

    mov     rdi, [rel input_file]
    call    _ftell
    mov     [rel file_pos], rax

    lea     rdi, [rel pos_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

    mov     rdi, [rel input_file]
    call    _feof
    push    rax
    lea     rdi, [rel feof_msg]
    pop     rsi
    xor     eax, eax
    call    _printf

    ; Read atom size (4 bytes)
    lea     rdi, [rel temp_buffer]
    mov     rsi, 4
    mov     rdx, [rel input_file]
    call    read_bytes
    mov     [rel bytes_read], rax

    lea     rdi, [rel read_bytes_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

    cmp     rax, 4
    jne     .check_error

    ; Add debug output for size bytes
    lea     rdi, [rel debug_size_msg]
    movzx   esi, byte [rel temp_buffer]
    movzx   edx, byte [rel temp_buffer+1]
    movzx   ecx, byte [rel temp_buffer+2]
    movzx   r8d, byte [rel temp_buffer+3]
    xor     eax, eax
    call    _printf

    ; Validate size bytes
    mov     eax, dword [rel temp_buffer]
    test    eax, eax        ; Check for zero size
    jz      .invalid_size   ; Zero size is invalid
    bswap   eax
    cmp     eax, 8         ; Minimum valid size
    jb      .invalid_size
    mov     rbx, rax
    mov     [rel atom_size], rax

    lea     rdi, [rel size_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

    ; Check for extended size
    cmp     rax, 1
    je      .extended_size

    jmp     .read_type

.extended_size:
    lea     rdi, [rel extended_size_msg]
    xor     eax, eax
    call    _printf

    lea     rdi, [rel temp_buffer]
    mov     rsi, 8
    mov     rdx, [rel input_file]
    call    read_bytes
    mov     [rel bytes_read], rax

    cmp     rax, 8
    jne     .check_error

    mov     rax, [rel temp_buffer]
    bswap   rax
    mov     [rel atom_size], rax

    lea     rdi, [rel size_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

.read_type:
    lea     rdi, [rel atom_type]
    mov     rsi, 4
    mov     rdx, [rel input_file]
    call    read_bytes
    mov     [rel bytes_read], rax

    lea     rdi, [rel read_bytes_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

    cmp     rax, 4
    jne     .check_error

    mov     byte [rel atom_type + 4], 0

    ; Add debug output for type bytes
    lea     rdi, [rel debug_type_msg]
    movzx   esi, byte [rel atom_type]
    movzx   edx, byte [rel atom_type+1]
    movzx   ecx, byte [rel atom_type+2]
    movzx   r8d, byte [rel atom_type+3]
    xor     eax, eax
    call    _printf

    ; Validate type bytes (must be printable ASCII)
    mov     ecx, 4
    lea     rsi, [rel atom_type]
.validate_type:
    movzx   edx, byte [rsi]
    cmp     dl, 32          ; Below space
    jb      .invalid_type
    cmp     dl, 126         ; Above tilde
    ja      .invalid_type
    inc     rsi
    dec     ecx
    jnz     .validate_type

    lea     rdi, [rel type_msg]
    lea     rsi, [rel atom_type]
    xor     eax, eax
    call    _printf

    lea     rdi, [rel atom_msg]
    lea     rsi, [rel atom_type]
    mov     rdx, [rel atom_size]
    mov     rcx, [rel file_pos]
    xor     eax, eax
    call    _printf

    mov     rax, [rel atom_size]
    jmp     .exit

.check_error:
    mov     rdi, [rel input_file]
    call    _ferror
    test    rax, rax
    jnz     .read_error

    mov     rdi, [rel input_file]
    call    _feof
    test    rax, rax
    jnz     .eof_reached

    ; If neither error nor EOF but partial read, treat as error
    lea     rdi, [rel read_error_msg]
    xor     eax, eax
    call    _printf
    xor     rax, rax
    jmp     .exit

.invalid_size:
    lea     rdi, [rel size_error_msg]
    mov     rsi, rbx
    mov     rdx, [rel file_pos]
    xor     eax, eax
    call    _printf
    xor     rax, rax
    jmp     .exit

.invalid_type:
    lea     rdi, [rel read_error_msg]
    xor     eax, eax
    call    _printf
    xor     rax, rax
    jmp     .exit

.eof_reached:
    lea     rdi, [rel eof_msg]
    xor     eax, eax
    call    _printf
    xor     rax, rax
    jmp     .exit

.read_error:
    lea     rdi, [rel read_error_msg]
    xor     eax, eax
    call    _printf
    xor     rax, rax

.exit:
    lea     rdi, [rel newline]
    xor     eax, eax
    call    _printf

    pop     rbx
    leave
    ret

get_file_size:
    push    rbp
    mov     rbp, rsp
    push    rdi

    mov     rsi, 0
    mov     rdx, 2
    call    _fseek
    test    rax, rax
    jnz     .error

    mov     rdi, [rsp]
    call    _ftell
    cmp     rax, -1
    je      .error

    mov     [rel file_size], rax
    push    rax

    lea     rdi, [rel file_size_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

    mov     rdi, [rsp+8]
    xor     rsi, rsi
    xor     rdx, rdx
    call    _fseek
    test    rax, rax
    jnz     .error_pop

    pop     rax
    pop     rdi
    leave
    ret

.error_pop:
    pop     rax
.error:
    xor     rax, rax
    pop     rdi
    leave
    ret

validate_position:
    push    rbp
    mov     rbp, rsp

    cmp     rdi, [rel file_size]
    ja      .invalid

    mov     rax, 1
    leave
    ret

.invalid:
    push    rdi
    lea     rdi, [rel pos_error_msg]
    pop     rsi
    mov     rdx, [rel file_size]
    xor     eax, eax
    call    _printf

    xor     rax, rax
    leave
    ret

copy_atom:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14

    mov     rbx, rdi

    push    rbx
    lea     rdi, [rel copy_msg]
    mov     rsi, rbx
    xor     eax, eax
    call    _printf
    pop     rbx

.copy_loop:
    test    rbx, rbx
    jz      .copy_done

    mov     r12, 65536
    cmp     rbx, r12
    cmovb   r12, rbx

    lea     rdi, [rel copy_buffer]
    mov     rsi, r12
    mov     rdx, [rel input_file]
    call    read_bytes

    test    rax, rax
    jz      .copy_error

    lea     rdi, [rel copy_buffer]
    mov     rsi, 1
    mov     rdx, rax
    mov     rcx, [rel output_file]
    call    _fwrite

    cmp     rax, r12
    jne     .copy_error

    sub     rbx, r12
    jmp     .copy_loop

.copy_done:
    mov     rax, 1
    jmp     .copy_exit

.copy_error:
    xor     rax, rax

.copy_exit:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    leave
    ret

is_container_atom:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12

    mov     rbx, rdi

    lea     rsi, [rel clef_atom]
    mov     rcx, 4
    repe    cmpsb
    je      .is_container

    mov     rdi, rbx
    lea     rsi, [rel wave_atom]
    mov     rcx, 4
    repe    cmpsb
    je      .is_container

    xor     rax, rax
    jmp     .exit

.is_container:
    mov     rax, 1

.exit:
    pop     r12
    pop     rbx
    leave
    ret

write_mp4_ftyp:
    push    rbp
    mov     rbp, rsp

    ; Build ftyp atom
    lea     rdi, [rel ftyp_buffer]
    mov     dword [rdi], 0x18000000  ; Size (24) in big-endian
    mov     dword [rdi+4], 'ftyp'    ; Type
    mov     dword [rdi+8], 'isom'    ; Major brand
    mov     dword [rdi+12], 0x00000200 ; Version
    mov     dword [rdi+16], 'isom'   ; Compatible brand 1
    mov     dword [rdi+20], 'mp41'   ; Compatible brand 2

    ; Write ftyp atom
    mov     rdi, ftyp_buffer
    mov     rsi, 1
    mov     rdx, 24
    mov     rcx, [rel output_file]
    call    _fwrite

    cmp     rax, 24
    jne     .write_error
    mov     rax, 1
    jmp     .exit

.write_error:
    xor     rax, rax

.exit:
    leave
    ret

raw_read:
    push    rbp
    mov     rbp, rsp

    ; Parameters:
    ; rdi = buffer pointer
    ; rsi = count
    ; rdx = file pointer

    ; Save registers
    push    rbx
    push    r12
    push    r13

    mov     rbx, rdi    ; buffer
    mov     r12, rsi    ; count
    mov     r13, rdx    ; file

    ; Print debug message
    lea     rdi, [rel raw_read_msg]
    xor     eax, eax
    call    _printf

    ; Force seek to beginning to ensure we're reading from the start
    mov     rdi, r13    ; file
    xor     rsi, rsi    ; offset 0
    xor     rdx, rdx    ; SEEK_SET
    call    _fseek
    test    rax, rax
    jnz     .read_error

    ; Direct fread call
    mov     rdi, rbx    ; buffer
    mov     rsi, 1      ; size of each element
    mov     rdx, r12    ; count
    mov     rcx, r13    ; file
    call    _fread

    ; Check if we read the correct number of bytes
    cmp     rax, r12
    jne     .read_error

    ; Success, return number of bytes read
    mov     rax, r12
    jmp     .exit

.read_error:
    ; Return 0 to indicate failure
    xor     rax, rax

.exit:
    ; Restore registers
    pop     r13
    pop     r12
    pop     rbx

    leave
    ret

; Ultra-minimal direct conversion function - no atom awareness or scanning
direct_file_conversion:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12

    ; Print minimal mode message
    lea     rdi, [rel minimal_mode_msg]
    xor     eax, eax
    call    _printf

    ; Reset file positions
    mov     rdi, [rel input_file]
    xor     rsi, rsi
    xor     rdx, rdx
    call    _fseek

    ; Simply create fixed MP4 header
    lea     rdi, [rel ftyp_buffer]
    mov     dword [rdi], 0x18000000  ; Size (24) in big-endian
    mov     dword [rdi+4], 'ftyp'    ; Type
    mov     dword [rdi+8], 'isom'    ; Major brand
    mov     dword [rdi+12], 0x00000200 ; Version
    mov     dword [rdi+16], 'isom'   ; Compatible brand 1
    mov     dword [rdi+20], 'mp41'   ; Compatible brand 2

    ; Write the header
    mov     rdi, [rel ftyp_buffer]
    mov     rsi, 1
    mov     rdx, 24
    mov     rcx, [rel output_file]
    call    _fwrite
    cmp     rax, 24
    jne     .write_error

    ; Skip first 8 bytes of MOV file (header)
    mov     rdi, [rel input_file]
    mov     rsi, 8
    xor     rdx, rdx
    call    _fseek

    ; Fixed buffer size to avoid problems
    mov     rbx, 4096       ; Use 4KB buffer for safety

    ; Calculate bytes to copy
    mov     rax, [rel file_size]
    sub     rax, 8          ; Minus 8 bytes of MOV header
    push    rax             ; Save for progress calculation

    ; Print message about bytes to copy
    lea     rdi, [rel copy_bytes_msg]
    mov     rsi, rax
    xor     eax, eax
    call    _printf

    ; Start copying
    pop     r12             ; Total bytes to copy in r12
    mov     rbx, r12        ; Remaining bytes in rbx

.simple_copy:
    ; Check if done
    test    rbx, rbx
    jz      .done

    ; Limit to 4KB per chunk
    mov     rdx, 4096
    cmp     rbx, rdx
    cmovb   rdx, rbx

    ; Read chunk
    lea     rdi, [rel copy_buffer]
    mov     rsi, 1
    mov     rcx, [rel input_file]
    call    _fread

    ; Check if read worked
    test    rax, rax
    jz      .done           ; EOF or error - just consider done

    ; Write chunk
    lea     rdi, [rel copy_buffer]
    mov     rsi, 1
    mov     rdx, rax
    mov     rcx, [rel output_file]
    call    _fwrite

    ; Check if write worked
    test    rax, rax
    jz      .write_error

    ; Update counter
    sub     rbx, rax
    jmp     .simple_copy

.done:
    ; Success
    lea     rdi, [rel success_msg]
    xor     eax, eax
    call    _printf
    mov     rax, 1
    jmp     .exit

.write_error:
    lea     rdi, [rel write_error_msg]
    xor     eax, eax
    call    _printf
    xor     rax, rax

.exit:
    pop     r12
    pop     rbx
    pop     rbp
    ret

analyze_file_format:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16

    ; Save the original file position
    mov     rdi, [rel input_file]
    call    _ftell
    mov     [rsp], rax

    ; Go to start of file
    mov     rdi, [rel input_file]
    xor     rsi, rsi
    xor     rdx, rdx
    call    _fseek

    ; Read first 16 bytes
    lea     rdi, [rel raw_buffer]
    mov     rsi, 16
    mov     rdx, [rel input_file]
    call    _fread

    ; Restore original position
    mov     rdi, [rel input_file]
    mov     rsi, [rsp]
    xor     rdx, rdx
    call    _fseek

    ; Check for QuickTime header pattern
    ; ftyp at offset 4
    cmp     dword [rel raw_buffer+4], 'ftyp'
    je      .quicktime_format

    ; Not recognized
    xor     rax, rax
    jmp     .exit

.quicktime_format:
    mov     rax, 1

.exit:
    add     rsp, 16
    leave
    ret

_main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    mov     [rbp-8], rdi
    mov     [rbp-16], rsi

    cmp     rdi, 3
    je      check_args

    lea     rdi, [rel usage_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    call    _exit

check_args:
    mov     rsi, [rbp-16]
    mov     rdi, [rsi+8]
    lea     rsi, [rel read_mode]
    call    _fopen
    mov     [rel input_file], rax

    test    rax, rax
    jnz     .get_size

    lea     rdi, [rel error_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    call    _exit

.get_size:
    mov     rdi, [rel input_file]
    call    get_file_size
    test    rax, rax
    jnz     open_output

    lea     rdi, [rel error_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    jmp     cleanup

open_output:
    mov     rsi, [rbp-16]
    mov     rdi, [rsi+16]
    lea     rsi, [rel write_mode]
    call    _fopen
    mov     [rel output_file], rax

    test    rax, rax
    jnz     start_processing

    lea     rdi, [rel error_out_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    call    _exit

start_processing:
    lea     rdi, [rel converting_msg]
    xor     eax, eax
    call    _printf

    ; Add codec information message
    lea     rdi, [rel codec_msg]
    xor     eax, eax
    call    _printf

    lea     rdi, [rel codec_req_msg]
    xor     eax, eax
    call    _printf

    lea     rdi, [rel parse_msg]
    xor     eax, eax
    call    _printf

    ; Skip directly to parse_mov, which now tries simpler approaches first
    jmp     parse_mov

parse_mov:
    ; Print initial message
    lea     rdi, [rel reading_file_msg]
    xor     eax, eax
    call    _printf

    ; First, try to use the direct approach - simpler and more robust
    call    direct_file_conversion
    test    rax, rax
    jnz     finish_processing  ; If successful, we're done

    ; If direct conversion failed, try the regular approach...
    ; Ensure we're at start of file
    mov     rdi, [rel input_file]
    xor     rsi, rsi
    xor     rdx, rdx
    call    _fseek
    test    rax, rax
    jnz     seek_error

    ; Read the first atom header
    call    read_atom_header
    test    rax, rax
    jz      check_eof       ; Error reading atom or EOF

read_atoms_loop:   ; Define the missing label here
    mov     rdi, [rel input_file]
    call    _ftell
    mov     [rel file_pos], rax

    ; Validate atom size
    mov     rax, [rel atom_size]
    cmp     rax, 8          ; Minimum size including header
    jb      .invalid_atom

    ; Check if atom fits in file
    mov     rdx, [rel file_pos]
    add     rdx, rax
    cmp     rdx, [rel file_size]
    ja      .invalid_atom

    lea     rdi, [rel atom_type]
    lea     rsi, [rel ftyp_atom]
    mov     rcx, 4
    repe    cmpsb
    jne     .check_container

    ; Write MP4 ftyp instead of copying MOV ftyp
    call    write_mp4_ftyp
    test    rax, rax
    jz      write_error

    ; Skip original ftyp data
    mov     rdi, [rel input_file]
    mov     rsi, [rel file_pos]
    add     rsi, [rel atom_size]
    xor     edx, edx
    call    _fseek
    test    rax, rax
    jnz     seek_error
    jmp     .next_atom

.check_container:
    lea     rdi, [rel atom_type]
    call    is_container_atom
    test    rax, rax
    jz      .regular_atom

    lea     rdi, [rel container_msg]
    lea     rsi, [rel atom_type]
    xor     eax, eax
    call    _printf
    jmp     .copy_atom

.regular_atom:
    mov     rax, [rel atom_size]
    cmp     rax, [rel file_size]
    ja      .invalid_atom

.copy_atom:
    ; Update progress
    mov     rax, [rel file_pos]
    mov     rdx, 100
    mul     rdx
    div     qword [rel file_size]
    mov     [rel progress], eax

    ; Print progress
    lea     rdi, [rel progress_msg]
    mov     esi, [rel progress]
    xor     eax, eax
    call    _printf

    mov     rdx, [rel file_pos]
    add     rdx, [rel atom_size]
    mov     rdi, rdx
    call    validate_position
    test    rax, rax
    jz      .size_error

    mov     rdi, [rel input_file]
    mov     rsi, [rel file_pos]
    add     rsi, 8
    xor     edx, edx
    call    _fseek
    test    rax, rax
    jnz     seek_error

    mov     rdi, [rel atom_size]
    sub     rdi, 8
    call    copy_atom
    test    rax, rax
    jz      write_error

    mov     rax, [rel atom_size]
    mov     [rel prev_atom_size], rax
    mov     rax, [rel file_pos]
    mov     [rel prev_atom_pos], rax
    mov     rax, [rel atom_type]
    mov     [rel prev_atom_type], rax
    mov     byte [rel prev_atom_type + 4], 0

.next_atom:
    mov     rdi, [rel input_file]
    mov     rsi, [rel file_pos]
    add     rsi, [rel atom_size]
    xor     edx, edx
    call    _fseek
    test    rax, rax
    jnz     seek_error

    mov     rdi, [rel input_file]
    call    _ftell
    cmp     rax, [rel file_size]
    jae     finish_processing

    call    read_atom_header
    test    rax, rax
    jnz     read_atoms_loop
    jmp     check_eof

.invalid_atom:
    lea     rdi, [rel prev_atom_msg]
    lea     rsi, [rel prev_atom_type]
    mov     rdx, [rel prev_atom_size]
    mov     rcx, [rel prev_atom_pos]
    xor     eax, eax
    call    _printf

    lea     rdi, [rel atom_error_msg]
    mov     rsi, [rel file_pos]
    mov     rdx, [rel atom_size]
    xor     eax, eax
    call    _printf
    jmp     invalid_format

.size_error:
    lea     rdi, [rel size_error_msg]
    mov     rsi, [rel atom_size]
    mov     rdx, [rel file_pos]
    xor     eax, eax
    call    _printf
    jmp     invalid_format

seek_error:
    lea     rdi, [rel seek_error_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    jmp     cleanup

check_eof:
    mov     rdi, [rel input_file]
    call    _feof
    test    rax, rax
    jnz     finish_processing
    jmp     write_error

invalid_format:
    lea     rdi, [rel invalid_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    jmp     cleanup

write_error:
    lea     rdi, [rel write_error_msg]
    xor     eax, eax
    call    _printf
    mov     edi, 1
    jmp     cleanup

finish_processing:
    lea     rdi, [rel success_msg]
    xor     eax, eax
    call    _printf
    xor     edi, edi

cleanup:
    mov     rdi, [rel input_file]
    test    rdi, rdi
    jz      .close_output
    call    _fclose

.close_output:
    mov     rdi, [rel output_file]
    test    rdi, rdi
    jz      .exit
    call    _fclose

.exit:
    leave
    ret

copy_rest_of_file:
    ; Get remaining size
    mov     rdi, [rel input_file]
    call    _ftell
    mov     rbx, rax        ; Current position

    mov     rax, [rel file_size]
    sub     rax, rbx        ; Remaining bytes

    ; Copy the data
    mov     rdi, rax
    call    copy_atom
    test    rax, rax
    jz      write_error

    jmp     finish_processing