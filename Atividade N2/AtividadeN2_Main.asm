section .data
    msg1 db "Insira o primeiro numero: "
    msg1_len equ $ - msg1
    msg2 db "Insira o segundo numero: "
    msg2_len equ $ - msg2
    msg_resultado db "Soma: "
    msg_resultado_len equ $ - msg_resultado
    pular_linha_str db 10,10
    pular_linha_len equ $ - pular_linha_str
    buffer1 db 10 ; String do primeiro número
    buffer2 db 10 ; String do segundo número
    buffer_soma db 10 ; String da soma
    buffer_len equ 10 ; Tamanho máximo do buffer

section .bss
    verificar_erro resb 1 ; Byte que verifica se tem algum erro
    
section .text
    global _start
    extern print_msg, read_msg, atoi, itoa, pularlinha
    global buffer_len, pular_linha_str, pular_linha_len, verificar_erro
_start:
    ; SYSCALL WRITE 1: "Insira o primeiro numero:"
    leitura1:
        mov byte [verificar_erro], 0 ; Zera o verificador de erro
        
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
        mov rcx, buffer1            ; aponta para o buffer do primeiro número
        call read_msg               ; chamada da função de leitura da entrada
        
        ; Converte string para número inteiro
        mov rsi, buffer1            ; apontando para o início da string do primeiro número
        xor rax, rax                ; zera o valor acumulador(neste caso rax é o acumulador)
        xor rcx, rcx                ; contador de dígitos lidos
        call atoi                   ; chamada da função atoi (ascii para inteiro)
        cmp byte [verificar_erro], 1 ; verifica se tem algum erro
        je leitura1                  ; se tiver erro, volta para leitura1
        push rax             ; armazena o resultado em num1
    
    ; SYSCALL WRITE 2: "Insira o segundo numero:"
    leitura2:
        mov byte [verificar_erro], 0 ; Zera o verificador de erro
        
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
        cmp byte [verificar_erro], 1 ; verifica se tem algum erro
        je leitura2                  ; se tiver erro, volta para leitura2
    
    ; Soma dos dois números
    pop rbx                     ; pegar o valor de num1 da pilha
    add rax, rbx                ; soma os dois valores
    
    ; Converte o resultado da soma(que agora está em rax) de volta para string
    mov rbx, rax                ; copia o valor da soma para rbx
    mov rdi, buffer_soma        ; guarda o inicio da string buffer_soma
    add rdi, buffer_len         ; faz o ponteiro rdi apontar para o final da string buffer_soma
    call itoa                   ; chamada da função itoa (inteiro para ascii)
    
    ; Exibe "Soma: "
    push 4                  ; syscall number for sys_write
    push 1                  ; file descriptor 1 (stdout)
    push msg_resultado      ; endereço da mensagem de resultado
    push msg_resultado_len  ; tamanho da mensagem de resultado
    call print_msg                    ; chamada de sistema para escrever "Soma: "
    
    ; limpando a pilha
    pop rax
    pop rax
    pop rax
    pop rax
    
    ; Exibe o número convertido para string
    push 4                  ; syscall number for sys_write
    push 1                  ; file descriptor 1 (stdout)
    push rdi                ; aponta para o início do número no buffer
    push buffer_len         ; tamanho máximo (exibe até o '\0')
    call print_msg                    ; chamada de sistema para escrever o número
    
    ; limpando a pilha
    pop rax
    pop rax
    pop rax
    pop rax

    ; Exibe uma quebra de linha
    call pularlinha
    
Fim:
    mov rax, 1                  ; Syscall number para sys_exit
    xor rbx, rbx                ; código de saída 0
    int 0x80                    ; chamada de sistema para sair