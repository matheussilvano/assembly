.global _start
.intel_syntax noprefix

_start:
    CALL print_hello_world
    JMP exit

exit:
    MOV rax, 0x3c
    MOV rdi, 0
    SYSCALL

print_hello_world:
    MOV rax, 0x01
    MOV rdi, 0x01
    LEA rsi, [hello_str]
    MOV rdx, 13
    SYSCALL
    RET

.section .data
    hello_str: .asciz "Hello world!\n"
