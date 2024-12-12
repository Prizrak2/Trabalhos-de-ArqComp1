global print_msg, read_msg, atoi, itoa, pularlinha
extern buffer_len, pular_linha_str, pular_linha_len, verificar_erro

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
    cmp rbx, 10                 ; verifica se é '\0' (final da string)
    je finish_conversion
    ; verifica se o caractere é um dígito válido
    cmp rbx, '0'
    jb erro                     ; verifica se é menor que '0'
    cmp rbx, '9'
    ja erro                     ; verifica se é maior que '9'
    sub rbx, '0'                ; converte caractere ASCII para número
    
    imul rax, rax, 10           ; multiplica o valor atual por 10
    add rax, rbx                ; adiciona o dígito convertido
    inc rsi                     ; incrementa para ir para o próximo caractere
    jmp atoi
    ; O número convertido está em rax
    finish_conversion:
        ret
    erro:
        mov byte [verificar_erro], 1
        ret
    
itoa:
    dec rdi                     ; avança para o próximo caractere (de trás para frente)
    mov rax, rbx                ; armazena o valor do quociente(rbx) atual em rax
    mov rdx, 0                  ; zera o registrador rdx, será usado para o resto da divisão
    mov rcx, 10                 ; seta o divisor, ou seja, qual base(10 nesste caso)
    div rcx                     ; divide rax por 10
    add dl, '0'                 ; converte o resto para ASCII
    mov [rdi], dl               ; armazena na string
    mov rbx, rax                ; armazena o quociente para a próxima iteração
    test rbx, rbx               ; verifica se o valor é 0
    jnz itoa
    ret

pularlinha:
    push 4                      ; syscall number para sys_write
    push 1                      ; file descriptor 1 (stdout)
    push pular_linha_str         ; endereço da mensagem de prompt por pilha
    push pular_linha_len         ; tamanho da mensagem de prompt por pilha
    call print_msg              ; chamada da função de impressão de mensagem
    pop rax
    pop rax
    pop rax
    pop rax
    ret