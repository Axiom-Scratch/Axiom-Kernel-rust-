section .multiboot
align 8

header:
    dd 0xe85250d6
    dd 0
    dd header_end - header
    dd -(0xe85250d6 + 0 + (header_end - header))

    dw 0
    dw 0
    dd 8

header_end:

; STACK (16 KB)
section .bss
align 16
stack_bottom:
    resb 16384
stack_top:

; ENTRY POINT
section .text
global _start

extern rust_main

_start:
    ; set stack pointer
    mov rsp, stack_top

    ; call Rust entry
    call rust_main

.hang:
    hlt
    jmp .hang
