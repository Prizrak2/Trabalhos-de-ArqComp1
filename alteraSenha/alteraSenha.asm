section .data
    msg_input db "Digite a senha: ", 0
    msg_confirm db "Confirme a senha: ", 0
    msg_error db "Senhas nao conferem.", 0
    msg_success db "Senha armazenada: ", 0
    senha_armazenada db 16 ; Buffer para armazenar a senha processada


section .bss
    senha1 resb 16 ; Armazena a primeira senha
    senha2 resb 16 ; Armazena a segunda senha (confirmação)

section .text
    global _start
_start:
    ; Solicitar a primeira senha
    mov edx, 16 ; Tamanho da mensagem
    mov ecx, msg_input ; Mensagem a ser exibida
    call print_msg
    mov ecx, senha1 ; Buffer para a senha
    call read_input
    call remove_newline ; Remove o caractere de nova linha

    ; Solicitar a confirmação da senha
    mov edx, 17 ; Tamanho da mensagem
    mov ecx, msg_confirm ; Mensagem a ser exibida
    call print_msg
    mov ecx, senha2 ; Buffer para a segunda senha
    call read_input
    call remove_newline ; Remove o caractere de nova linha

    ; Comparar as senhas
    call compare_senhas
    cmp eax, 0 ; Verifica se são diferentes
    je erro_senhas

    ; Alterar a senha
    mov esi, senha1
    mov edi, senha_armazenada
    mov ecx, 16
altera_senha:
    lodsb
    add al, 5
    stosb
    loop altera_senha

    ; Exibir a senha armazenada após a transformação
    mov edx, 19 ; Tamanho da mensagem
    mov ecx, msg_success
    call print_msg
    mov edx, 16 ; Tamanho da senha processada
    mov ecx, senha_armazenada ; Exibe a senha processada
    call print_msg

    ; Finalizar o programa
    call exit

erro_senhas:
; Exibir mensagem de erro
mov edx, 20 ; Tamanho da mensagem
mov ecx, msg_error
call print_msg
call exit

; Função para imprimir mensagens
print_msg:
mov eax, 4 ; syscall write
mov ebx, 1 ; stdout
int 0x80
ret

; Função para ler dados do teclado
read_input:
mov eax, 3 ; syscall read
mov ebx, 0 ; stdin
mov edx, 16 ; Número máximo de bytes a ler
int 0x80
ret

; Função para remover o caractere de nova linha
remove_newline:
    mov esi, ecx ; Apontar para o buffer da senha
    mov ecx, 16 ; Verificar até 16 caracteres
remove_loop:
    cmp byte [esi], 10 ; Verifica se é '\n' (valor ASCII 10)
    je found_newline
    cmp byte [esi], 0 ; Verifica se é o fim da string
    je end_remove_newline
    inc esi
    loop remove_loop
end_remove_newline:
    ret
found_newline:
    mov byte [esi], 0 ; Substitui '\n' por NULL
    ret

; Função para comparar duas senhas
compare_senhas:
    mov esi, senha1
    mov edi, senha2
    mov ecx, 16
compara_loop:
    lodsb
    scasb
    jne senhas_diferentes
    loop compara_loop
    mov eax, 1 ; Senhas são iguais
    ret
senhas_diferentes:
    mov eax, 0 ; Senhas diferentes
    ret

; Função para encerrar o programa
exit:
    mov eax, 1 ; syscall exit
    xor ebx, ebx
    int 0x80