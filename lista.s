.global _start
.intel_syntax noprefix

.section .bss
buffer: .skip 128                # Buffer para entrada do usuário
list:   .skip 1024               # Lista para armazenar entradas
list_end: .quad 0                # Ponteiro para o fim da lista

.section .data
msg_prompt: .asciz "Digite um item (ou 'mostrar' para exibir a lista): "
msg_list:   .asciz "Itens na lista:\n"
msg_newline: .asciz "\n"
msg_error: .asciz "Erro: entrada muito longa ou sem espaço na lista.\n"
msg_mostrar: .asciz "mostrar"

.section .text

_start:
    # Inicializar o ponteiro da lista
    LEA rbx, [list]
    MOV [list_end], rbx

read_input:
    # Exibir mensagem de prompt
    MOV rax, 0x01                # syscall: write
    MOV rdi, 0x01                # file descriptor: stdout
    LEA rsi, [msg_prompt]        # endereço da mensagem
    MOV rdx, 51                  # tamanho da mensagem
    SYSCALL

    # Ler entrada do usuário
    MOV rax, 0x00                # syscall: read
    MOV rdi, 0x00                # file descriptor: stdin
    LEA rsi, [buffer]            # endereço do buffer
    MOV rdx, 128                 # tamanho máximo
    SYSCALL

    # Calcular o comprimento real da entrada (desconsiderando o newline)
    DEC rax                      # Desconsiderar o newline
    CMP rax, 0
    JL read_input                # Se nada foi lido, voltar ao início
    MOV BYTE PTR [buffer + rax], 0

    # Verificar se a entrada é "mostrar"
    LEA rsi, [buffer]
    LEA rdi, [msg_mostrar]
    CALL strcmp
    CMP rax, 0
    JE show_list

    # Copiar buffer para a lista
    MOV rdi, [list_end]
    LEA rsi, [buffer]
    MOV rcx, rax
    REP MOVSB

    # Adicionar nova linha na lista
    MOV BYTE PTR [rdi], 0x0A
    INC rdi

    # Atualizar o ponteiro de fim da lista
    MOV [list_end], rdi

    # Continuar leitura
    JMP read_input

show_list:
    # Exibir mensagem "Itens na lista:"
    MOV rax, 0x01                # syscall: write
    MOV rdi, 0x01                # file descriptor: stdout
    LEA rsi, [msg_list]          # endereço da mensagem
    MOV rdx, 16                  # tamanho da mensagem
    SYSCALL

    # Exibir cada item na lista
    LEA rsi, [list]
    MOV rbx, [list_end]
display_loop:
    CMP rsi, rbx
    JE read_input
    MOV rax, 0x01                # syscall: write
    MOV rdi, 0x01                # file descriptor: stdout
    LEA rsi, [rsi]               # endereço do próximo item
    MOV rdx, 1                   # tamanho de cada byte
    SYSCALL
    INC rsi
    JMP display_loop

error_message:
    # Exibir mensagem de erro
    MOV rax, 0x01                # syscall: write
    MOV rdi, 0x01                # file descriptor: stdout
    LEA rsi, [msg_error]         # endereço da mensagem
    MOV rdx, 49                  # tamanho da mensagem
    SYSCALL
    JMP read_input

strcmp:
    PUSH rsi
    PUSH rdi
    XOR rax, rax
strcmp_loop:
    LODSB
    SCASB
    JNE strcmp_diff
    TEST al, al
    JNZ strcmp_loop
    XOR rax, rax
    JMP strcmp_end
strcmp_diff:
    MOV rax, 1
strcmp_end:
    POP rdi
    POP rsi
    RET
