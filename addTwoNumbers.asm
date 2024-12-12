section .data
    msg1 db "Insira o primeiro numero: "
    msg1_len equ $ - msg1
    msg2 db "Insira o segundo numero: "
    msg2_len equ $ - msg2
    msg_resultado db "Soma: "
    msg_resultado_len equ $ - msg_resultado
    buffer1 db 10
    buffer2 db 10
    buffer_len equ 10

section .text
    global _start

_start:
    ; SYSCALL WRITE 1: "Insira o primeiro numero:"
    push 4                      ; syscall number para sys_write por pilha
    push 1                      ; file descriptor 1 (stdout) por pilha
    push msg1                   ; endereço da mensagem de prompt por pilha
    push msg1_len               ; tamanho da mensagem de prompt por pilha
    call print_msg              ; chamada da função de impressão de mensagem
        ; "Insira o primeiro numero:"

    ; limpando a pilha
    pop rax
    pop rax
    pop rax
    pop rax

    ; SYSCALL READ 1
    mov rcx, buffer1            ; aponta para o buffer da entrada
    call read_msg               ; chamada da função de leitura da entrada
    
    ; Converte string para número inteiro
    mov rsi, buffer1            ; apontando para o início do buffer
    xor rax, rax                ; zera o valor acumulador
    xor rcx, rcx                ; contador de dígitos lidos
    call atoi                   ; chamada da função atoi (ascii para inteiro)
    push rax             ; armazena o resultado em num1
    
    ; SYSCALL WRITE 2: "Insira o segundo numero:"
    push 4                      ; syscall number para sys_write por pilha
    push 1                      ; file descriptor 1 (stdout) por pilha
    push msg2                   ; endereço da mensagem de prompt por pilha
    push msg2_len               ; tamanho da mensagem de prompt por pilha
    call print_msg              ; chamada da função de impressão de mensagem
        ; "Insira o segundo numero:"

    ; limpando a pilha
    pop rax
    pop rax
    pop rax
    pop rax

    ; SYSCALL READ 2
    mov rcx, buffer2            ; aponta para o buffer da entrada
    call read_msg               ; chamada da função de leitura da entrada
    
    ; Converte string para número inteiro
    mov rsi, buffer2            ; apontando para o início do buffer
    xor rax, rax                ; zera o valor acumulador
    xor rcx, rcx                ; contador de dígitos lidos
    call atoi                   ; chamada da função atoi (ascii para inteiro)
    pop rbx
    add rax, rbx             ; soma o resultado com o valor previamente armazenado
    
    ; Converte o número de volta para string
    mov rbx, rax                ; copia o valor para rbx
    mov rdi, buffer1            ; apontando o buffer para o início
    add rdi, buffer_len         ; ajusta para o final do buffer
    call itoa                   ; chamada da função itoa (inteiro para ascii)
    
    ; Exibe "Soma: "
    push 4                  ; syscall number for sys_write
    push 1                  ; file descriptor 1 (stdout)
    push msg_resultado      ; endereço da mensagem de resultado
    push msg_resultado_len  ; tamanho da mensagem de resultado
    call print_msg                    ; chamada de sistema para escrever "Soma: "
    
    ; Exibe o número convertido para string
    push 4                  ; syscall number for sys_write
    push 1                  ; file descriptor 1 (stdout)
    push rdi                ; aponta para o início do número no buffer
    push buffer_len         ; tamanho máximo (exibe até o '\0')
    call print_msg                    ; chamada de sistema para escrever o número
    
Fim:
    mov rax, 1                  ; syscall number para sys_exit
    xor rbx, rbx                ; código de saída 0
    int 0x80                    ; chamada de sistema para sair

print_msg:
    push rbp                    ; coloca rbp no topo da pilha
    mov rbp, rsp                ; rbp e rsp representam o topo da pilha
    mov rdx, [rbp + 16]          ; acessa 8 bytes abaixo da pilha para acessar o valor pressuposto para rdx
    mov rcx, [rbp + 24]         ; valor pressuposto para rcx
    mov rbx, [rbp + 32]         ; valor pressuposto para rbx
    mov rax, [rbp + 40]         ; valor pressuposto para rax
    int 0x80                    ; chamada de sistema para imprimir
    pop rbp                     ; retira rbp da pilha e rsp volta a ser o unico topo da pilha
    ret

read_msg:
    mov rax, 3                  ; syscall number para sys_read
    mov rbx, 0                  ; file descriptor 0 (stdin)
    mov rdx, buffer_len         ; tamanho do buffer
    int 0x80                    ; chamada de sistema para ler a string
    ret
    
atoi:
    movzx rbx, byte [rsi]       ; carrega o próximo caractere
    cmp rbx, 10                 ; verifica se é '\n' (final da entrada)
    je finish_conversion
    sub rbx, '0'                ; converte caractere ASCII para número
    imul rax, rax, 10           ; multiplica o valor atual por 10
    add rax, rbx                ; adiciona o dígito convertido
    inc rsi                     ; próximo caractere
    inc rcx                     ; incrementa contador de dígitos
    jmp atoi

finish_conversion:
    ret
    
itoa:
    dec rdi                     ; avança para o próximo caractere (de trás para frente)
    mov rax, rbx
    mov rdx, 0
    mov rcx, 10
    div rcx                     ; divide rax por 10
    add dl, '0'                 ; converte o dígito para ASCII
    mov [rdi], dl               ; armazena no buffer
    mov rbx, rax                ; armazena o quociente para a próxima iteração
    test rbx, rbx               ; verifica se o valor é 0
    jnz itoa
    ret