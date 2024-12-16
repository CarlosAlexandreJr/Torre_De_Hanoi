section .data
	; Strings que poderão ser usadas no código posteriormente
	pergunta db 'Insira o numero de discos: ', 0
	frase1 db 'Mova o disco ', 0
	frase2 db ' da coluna ', 0
	frase3 db ' até a coluna ', 0
	concluido db 'Concluído!', 0
	coluna_origem db 'A', 0
	coluna_auxiliar db 'B', 0
	coluna_destino db 'C', 0
	um_disco db "1", 0
	endline db 10 ; Valor responsável por pular linhas na tabela ASCII

section .bss
	resposta resb 2  ; Receber a entrada do usuário (um ou dois dígitos + newline(quebra de linha))
	quant_discos resb 1 ; Armazenamento do número de discos
	espaco resb 2 ; Buffer para armazenar a comprimento de uma string

section .text
	global _start
_start:
	inicio: ; O codigo main
	mov ecx, pergunta 
	call print_separado
	mov ecx, resposta ; Ponteiro para o espaco que armazena a resposta do usuario
	mov eax, 3          ; Syscall para ler
	mov ebx, 0          ; Descritor de arquivo (stdin)
	mov edx, 2          ; Tamanho máximo de entrada
	int 0x80
	
	; Transformar de string pra inteiro
	call converter_para_int ; Faz a conversão e armazena em eax
	mov [quant_discos], edx ; Move o valor de eax para a variável que será usada
	call torre_de_hanoi ; Função da torre de hanói
	mov ecx, concluido ; Move o conteúdo de concluido para ecx
	call print_separado ; Printar a string que está em ecx, desde que a string seja terminado com 0

	; Sair do programa
	mov eax, 1          ; Número da chamada de sistema para sair
	int 0x80            ; Chamar a interrupção do sistema

torre_de_hanoi: ; Funcao Recursiva da Torre de Hanói
	cmp byte [quant_discos], 1 ; Verifica se a quant_discos e igual a 1
	je disco_unico ; Caso tenha apenas 1 disco
	jmp mais_discos ; Caso tenha mais de 1 disco

	disco_unico:
		;Printando as frases separadamente
		mov ecx, frase1
		call print_separado
		mov ecx, um_disco
		call print_separado
		mov ecx, frase2
		call print_separado
		mov ecx, coluna_origem
		call print_separado
		mov ecx, frase3
		call print_separado
		mov ecx, coluna_destino
		call print_separado
		mov ecx, endline ;Quebra de Linha
		call printar_na_tela
		jmp fim ; Ir para o final da função

	mais_discos:
		dec byte [quant_discos] ; Decrescimento na quantidade de discos
		;Colocando os valores na pilha, para as recursões futuras não influenciarem nos valores da chamada atual da função
		push word [quant_discos]
		push word [coluna_origem]
		push word [coluna_auxiliar]
		push word [coluna_destino]

		; Trocando o valor da coluna auxiliar com o valor da coluna de destino
		mov dx, [coluna_auxiliar]
		mov cx, [coluna_destino]
		mov [coluna_destino], dx
		mov [coluna_auxiliar], cx

		call torre_de_hanoi ; Recursão
		; Obtém os valores e coloca na pilha, para as recursões passadas não influenciarem nos valores da chamada atual da função
		pop word [coluna_destino]
		pop word [coluna_auxiliar]
		pop word [coluna_origem]
		pop word [quant_discos]

		mov ecx, frase1 
		call print_separado ; Printar o que está em ecx
		inc byte [quant_discos] ; Aumento da quantidade de discos para o decréscimo anterior não influenciar na exibição do valor do disco que será movido
		call mostrar_num_de_discos ; Função que exibe a quantidade de discos atual, que também é o disco que está sendo movido, assumindo que o disco 1 é o menor e o número vai crescendo de acordo com o tamanho do disco
		dec byte [quant_discos] ; Decréscimo para retornar o valor anterior ao acréscimo que foi feito anteriormente
		mov ecx, frase2
		call print_separado
		mov ecx, coluna_origem
		call print_separado
		mov ecx, frase3
		call print_separado
		mov ecx, coluna_destino
		call print_separado 
		mov ecx, endline
		call printar_na_tela 

		; Trocando o valor da coluna auxiliar com o valor da coluna de origem
		mov dx, [coluna_auxiliar]
		mov cx, [coluna_origem]
		mov [coluna_origem], dx
		mov [coluna_auxiliar], cx
		call torre_de_hanoi ; Recursão

	fim: ; Fim da função
		ret

printar_na_tela: ; Imprimir a string que está em ecx
	mov eax, 4               ; Número da chamada de sistema para imprimir
	mov ebx, 1               ; Descritor de arquivo (stdout)
	mov edx, 1               ; Tamanho do caractere a ser impresso
	int 0x80                 ; Chamar a interrupção do sistema
	ret                      ; Retorno
	
print_separado:  ; Printa a string caractere por caractere. OBS: Precisa terminar com 0 (int).
	loop_de_prints:
		mov al, ecx[0]           ; Carregar o caractere atual
		cmp al, 0               ; Verificar se é o final da string
		je fim_dos_prints         ; Se for, sair da função
		call printar_na_tela
		inc ecx                 ; Mover para o próximo caractere
		jmp loop_de_prints        ; Repetir o loop
	fim_dos_prints:               ; Saída do loop
		ret                     ; Retorno
	
converter_para_int: ; Conversão de 2 algarismos em formato de string para um número inteiro
	mov edx, resposta[0] ; Mover o primeiro caractere para o eax
	sub edx, '0' ; Transformar o caractere em algarismo inteiro
	mov eax, resposta[1] ; Mover o segundo caractere para o ebx
	cmp eax, 0x0a ; Comparar o segundo caractere da string, se for newline(0x0a em hexadecimal) então só existe um número, pois newline significa que houve uma quebra de linha, o que seria equivalente ao "ENTER" do usuário
	je um_algarismo ; Se o segundo caractere for newline, pula o tratamento de dezena, pois neste caso não existe dezena
	sub eax, '0' ; Transformar o caractere em algrismo inteiro
	imul edx, 10 ; Multiplicando o valor do primeiro caractere em 10, porque é a dezena
	add edx, eax ; Somando a dezena(eax) com a unidade(ebx) e formando um número de 0 a 99
	um_algarismo:
	ret ; Retorno


mostrar_num_de_discos: ; Função que printa a quantidade de discos atual
	movzx eax, byte [quant_discos] ; Move o valor da variável quant_discos para o registrador EAX
	lea edi, [espaco + 1] ; Carrega o endereço de memória apontado por EDI, usando um offset de 2
	call converter_para_string
	mov eax, 4 ; Número da chamada de sistema para imprimir
	mov ebx, 1 ; Descritor de arquivo (stdout)
	lea ecx, [edi] ; ECX aponta para o endereço de memória apontado por EDI (Carrega o endereço da string convertida em ECX) 
	lea edx, [espaco + 1] ; Carrega o endereço de um buffer no registrador EDX
	sub edx, ecx ; Calcula o comprimento da string subtraindo os endereços
	int 0x80 ;
	ret

	converter_para_string: ; Função que converte inteiros para string
			dec edi ; Decrementa o conteúdo do registrador EDI
			xor edx, edx ; Zera o registrador EDX
			mov ecx, 10 ;  Move o valor 10 para o registrador ECX
			div ecx ; Divide o valor nos registradores EDX:EAX por 10 (EAX = quociente, EDX = resto).
			add dl, '0' ; Colocando na estrutura da tabela ASCII
			mov [edi], dl ; Armazena o valor no endereço dentro de EDI
			test eax, eax ; Testa se o quociente da divisão contido em EAX é zero
			jnz converter_para_string ; Se for diferente de zero, a funcao de repete
			ret ; Retorno
