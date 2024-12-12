section .data
    prompt_msg db "Digite um numero: ", 0
    prompt_msg_len equ $ - prompt_msg
    result_msg db "Resultado: ", 0
    result_msg_len equ $ - result_msg
    buffer db 10               ; Buffer para armazenar a string lida (tamanho máximo de 10 caracteres)
    buffer_len equ 10

section .bss
    num resd 1                 ; Variável para armazenar o número lido como inteiro

section .text
    global _start

_start:
    ; Exibe "Digite um numero: "
    mov eax, 4                  ; syscall number for sys_write
    mov ebx, 1                  ; file descriptor 1 (stdout)
    mov ecx, prompt_msg         ; endereço da mensagem de prompt
    mov edx, prompt_msg_len     ; tamanho da mensagem de prompt
    int 0x80                    ; chamada de sistema para escrever "Digite um numero: "

    ; Lê a entrada do usuário
    mov eax, 3                  ; syscall number for sys_read
    mov ebx, 0                  ; file descriptor 0 (stdin)
    mov ecx, buffer             ; endereço do buffer
    mov edx, buffer_len         ; tamanho do buffer
    int 0x80                    ; chamada de sistema para ler a string

    ; Converte string para número inteiro
    mov esi, buffer             ; apontando para o início do buffer
    xor eax, eax                ; zera o valor acumulador (para guardar o número)
    xor ecx, ecx                ; contador de dígitos lidos

convert_to_int:
    movzx ebx, byte [esi]       ; carrega o próximo caractere
    cmp ebx, 10                 ; verifica se é '\n' (final da entrada)
    je finish_conversion
    sub ebx, '0'                ; converte caractere ASCII para número
    imul eax, eax, 10           ; multiplica o valor atual por 10
    add eax, ebx                ; adiciona o dígito convertido
    inc esi                     ; próximo caractere
    inc ecx                     ; incrementa contador de dígitos
    jmp convert_to_int

finish_conversion:
    mov [num], eax              ; armazena o valor inteiro em num

    ; Soma um número qualquer
    add eax, 15                  ; soma 15 ao valor

    ; Converte o número de volta para string
    mov ebx, eax                ; copia o valor para ebx (para manipulação)
    mov edi, buffer             ; apontando o buffer para o início
    add edi, buffer_len         ; ajusta para o final do buffer

convert_to_string:
    dec edi                     ; avança para o próximo caractere (de trás para frente)
    mov eax, ebx
    mov edx, 0
    mov ecx, 10
    div ecx                     ; divide eax por 10
    add dl, '0'                 ; converte o dígito para ASCII
    mov [edi], dl               ; armazena no buffer
    mov ebx, eax                ; armazena o quociente para a próxima iteração
    test ebx, ebx               ; verifica se o valor é 0
    jnz convert_to_string

    ; Exibe "Resultado: "
    mov eax, 4                  ; syscall number for sys_write
    mov ebx, 1                  ; file descriptor 1 (stdout)
    mov ecx, result_msg         ; endereço da mensagem de resultado
    mov edx, result_msg_len     ; tamanho da mensagem de resultado
    int 0x80                    ; chamada de sistema para escrever "Resultado: "

    ; Exibe o número convertido para string
    mov eax, 4                  ; syscall number for sys_write
    mov ebx, 1                  ; file descriptor 1 (stdout)
    mov ecx, edi                ; aponta para o início do número no buffer
    mov edx, buffer_len         ; tamanho máximo (exibe até o '\0')
    int 0x80                    ; chamada de sistema para escrever o número

    ; Exit
    mov eax, 1                  ; syscall number for sys_exit
    xor ebx, ebx                ; código de saída 0
    int 0x80                    ; chamada de sistema para sair