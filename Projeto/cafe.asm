.data
	zero:					.byte		63	#0x63 para imprimir 0 display 7 segmentos
	um:						.byte		6	#0x6  para imprimir 1 display 7 segmentos
	dois:					.byte		91	#0x91 para imprimir 2 display 7 segmentos
	tres:					.byte		79	#0x79 para imprimir 3 display 7 segmentos
	cinco:					.byte		109	#0x73 para imprimir 5 display 7 segmentos
	g_segment:				.byte		64	#0x63 = 0b 0100 0000 p acender segmento g do display
	msg_boas_vindas:		.asciiz		"Bem-vindo a maquina de cafe, escolha seu cafe (1-Puro, 2-Com leite, 3-Mochaccino):"
	msg_tamanho:			.asciiz		"Selecione o tamanho do copo: (1-Pequeno, 2-Grande)"
	msg_grande_escolhido:	.asciiz		"Voce escolheu o tamanho Grande"
	msg_pequeno_escolhido:	.asciiz		"Voce escolheu o tamanho pequeno"
	msg_invalido:			.asciiz 	"Opção inválida. Tente novamente.\n"
	msg_limite:				.asciiz		"Limite de tentativas excedido. Valor extornado\n"
	msg_puro_escolhido:		.asciiz		"Voce escolheu cafe puro"
	leite_escolhido:		.asciiz		"Voce escolheu cafe COM leite"
	mocha_escolhido:		.asciiz		"Voce escolheu mochaccino"	
	msg_acucar:				.asciiz		"Selecione se voce deseja açucar: 1-Sim, 0-Não"
	msg_acucar_sim:			.asciiz		"Voce escolheu COM açucar"
	msg_acucar_nao:			.asciiz		"Voce escolheu SEM açucar"
	faltando_cafe:			.asciiz		"Máquina faltando CAFÉ. Aperte 5 para reabastecer"
	faltando_leite:			.asciiz		"Máquina faltando LEITE. Aperte 5 para reabastecer"
	faltando_chocolate:		.asciiz		"Máquina faltando CHOCOLATE. Aperte 5 para reabastecer"
	faltando_acucar:		.asciiz		"Máquina faltando AÇÚCAR. Aperte 5 para reabastecer"
	reabastecer_po:			.asciiz		"Selecione o pó que voce desejar reabastecer: 0-Café, 1-Leite, 2-Chocolate, 3-Açucar"
	po_reabastecido:		.asciiz		"Pó reabastecido. Reiniciando a máquina..."
	liberando_agua:			.asciiz		"Liberando água..."
	botando_cafe:			.asciiz		"Preparando cafe"
	botando_leite:			.asciiz		"Adicionando leite"
	botando_chocolate:		.asciiz		"Adicionando chocolate"
	botando_acucar:			.asciiz		"Adicionando açucar"
	botando_agua:			.asciiz		"Adicionando agua"
	gera_cupom:				.asciiz		"Gerando Cupom Fiscal"
	cafe_dose:				.word		1		# Doses de café
	leite_dose:				.word		1		# Doses de leite
	acucar_dose:			.word		1		# Doses de açucar
	chocolate_dose:			.word		1		# Doses de chocolate
   # Nomes dos arquivos
	template_f:				.asciiz		"Template_Cupom_Fiscal_0.txt"	# Arquivo de template
	output_f:				.asciiz		"cupom_fiscal.txt"				# Arquivo de saída
   # Buffers
	buffer:					.space		1024			# Buffer para leitura do arquivo
	in_date:				.asciiz		"05/12/2024"	# Argumento de teste para substituir '@'
	in_time:				.asciiz		"22:22:30"		# Argumento de teste para substituir '&'
	print_date:				.asciiz		"@@@@@@@@@@"	# Caractere de substituicao
	print_time:				.asciiz		"&&&&&&&&"		# Caractere de substituicao
	print_prod:				.asciiz		"****************************************************"
	produto_1_1:			.asciiz		"1.1                     Cafe pequeno            1.00"
	produto_2_1:			.asciiz		"2.1                     Cafe grande             1.50"
	produto_1_2:			.asciiz		"1.2                     Cafe c leite P          1.50"
	produto_2_2:			.asciiz		"2.2                     Cafe c leite G          2.00"
	produto_1_3:			.asciiz		"1.3                     Mochaccino P            2.00"
	produto_2_3:			.asciiz		"2.3                     Mochaccino G            2.50"
.text
#---------------------------------- Bloco principal -----------------------------------------------
main:
	# Carrega as quantidades de doses de cada pó
	lw		$s0,	cafe_dose 
	lw		$s1,	leite_dose
	lw		$s2,	chocolate_dose
	lw		$s3,	acucar_dose

inicio:
	add		$s5,	$0,	$0			#iterador de seguranca
	# Printa mensagem de boas vindas e solicita selecao do tipo do café
	la		$a0,	msg_boas_vindas 
	li		$v0,	4				#Printa mensagem para selecionar o café
	syscall
	# Imprime nova linha
	li		$v0,	11				# Syscall para imprimir caractere
	li		$a0,	10				# Caractere de nova linha (ASCII 10)
	syscall	

	jal		escolhe_cafe			# Vai para o procedimento da escolha do tipo do café retorna em $s7

	jal		escolhe_tamanho			# Vai p escolha tamanho do café, definindo qtde. de doses em $s6

	jal		com_ou_sem_acucar		# Vai pra escolha se quer com ou sem açucar e retorna em $s4

	jal		cupom					#chama rotina impressao TXT

	#Apos as escolhas, comparamos o tipo de cafe escolhidos armazenados em $t e vamos ao preparo
	move	$t9,	$s6 						# move valor de $s6 p $t9 pois $t9 decrementador iterações
	beq		$s7,	1,			preparo_puro	# Se o valor selecionado for 1, café puro é escolhido
	beq		$s7,	2,			preparo_leite	# Se o valor selecionado for 1, café com leite é escolhido
	beq		$s7,	3,			preparo_mocha	# Se o valor selecionado for 1, mochaccino é escolhido
   
	j		encerra_pedido			#volta para inicio

encerra_pedido:
	jr	$ra

cancela_pedido:
	lw		$s5,	0($sp)				# Pop do s
	lw		$ra,	4($sp)				# Pop do return address
	addi	$sp,	$sp,	8			# Pop na pilha de 3elementos*4=12
	j	inicio
#---------------------------------- Escolha Bebida -------------------------------------------------
escolhe_cafe:
	addi	$sp,	$sp,	-8				# Push na pilha
	sw		$ra,	4($sp)					# Push do return address
    #sw		$s7,	4($sp)					# Push do iterador
	sw		$s5,	0($sp)					# Push do $s
	
    #limite de tentativas para evitar stack overflow
	li		$t8,	3                       # Limite 3 tentativas
	beq		$s5,	$t8,	aborta_selecao	# cancela a compra
	
    #chama teclado
	jal		Dig_Lab_Sim						# Chama funcao Display/teclado
	
    #salva valor retornado e desvia p print da selecao
	move	$s7,	$v1							# le o identificador do cafe escolhido retornado em v1
	beq		$s7,	1,		print_cafe_puro		# Se tipo selecionado for 1, avisa que café puro foi selecionado
	beq		$s7,	2,		print_cafe_leite	# Se tipo selecionado for 2, avisa que café com leite foi selecionado
	beq		$s7,	3,		print_mochaccino	# Se tipo selecionado for 3, avisa que mochaccino foi selecionado
	
    #se nao desvia, incrementa limitador de tentativas
	addi	$s5,	$s5,	1					# Incrementa iterador de limite de erro	

	# Printa msg_invalido caso usuario insista em uma opcao invalida
	la		$a0,	msg_invalido
	li		$v0,	4	
	syscall	
	li		$v0,	11							# Syscall para imprimir caractere
	li		$a0,	10							# Caractere de nova linha (ASCII 10)
	syscall
	j		escolhe_cafe						#volta p inicio da escolha
    
    # Printa mensagem "Você escolheu café puro"
	print_cafe_puro:
	la		$a0,	msg_puro_escolhido
	li		$v0,	4	
	syscall
	j	end_escolhe_cafe				# escape do loop em lugar unico
    # Printa mensagem "Você escolheu café com leite"
	print_cafe_leite:
	la	$a0,	leite_escolhido  
	li	$v0,	4	
	syscall
	j		end_escolhe_cafe				# escape do loop em lugar unico
    # Printa mensagem "Você escolheu mochaccino"
	print_mochaccino:	
	la	$a0,	mocha_escolhido  
	li	$v0,	4	
	syscall
	j		end_escolhe_cafe				# escape do loop em lugar unico
	
    # Caso usuario insista opcao errada, cancela compra
	aborta_selecao:                      #qndo máximo de tentativas é atingido
	la		$a0,	msg_limite
	li		$v0,	4
	syscall
	j		cancela_pedido
	
    # Encerra escolha
	end_escolhe_cafe:
	lw		$s5,	0($sp)				# Pop do s
    #lw		$s7,	4($sp)				# Pop do s
	lw		$ra,	4($sp)				# Pop do return address
	addi	$sp,	$sp,	8			# Pop na pilha de 2elemento*4=8
	j		encerra_pedido				# Retorna p main chamadora e escolhe_tamanho

#---------------------------------- Escolhe o tamanho ----------------------------------------------
escolhe_tamanho:
	addi	$sp,	$sp,	-8				# Push na pilha
	sw		$ra,	4($sp)					# Push do return address
    #sw		$s6,	4($sp)					# Push do $s
    sw		$s5,	0($sp)					# Push do $s
	#limite de tentativas para evitar stack overflow
	li		$t8,	3						# Limite 3 tentativas
	beq		$s5,	$t8,	aborta_tamanho	# cancela a compra

 	# Printa nova linha
	li		$v0,	11					# Syscall para imprimir caractere
	li		$a0,	10					# Caractere de nova linha (ASCII 10)
	syscall	
	# Printa mensagem para escolher o tamanho
	la		$a0,	msg_tamanho 
	li		$v0,	4	
	syscall
	# Printa nova linha
	li		$v0,	11					# Syscall para imprimir caractere
	li		$a0,	10					# Caractere de nova linha (ASCII 10)
	syscall

	#chama teclado
	jal		Dig_Lab_Sim						# Chama funcao Display/teclado

	#salva valor retornado e desvia p print da selecao
	move	$s6,	$v1
	beq		$s6,	2,	print_tamanho_G
	beq		$s6,	1,	print_tamanho_P

    #se nao desvia, incrementa limitador de tentativas
	addi	$s5,	$s5,	1					# Incrementa iterador de limite de erro	

	# Printa msg_invalido e pergunta dnv
	la		$a0,	msg_invalido
	li		$v0,	4	
	syscall
	# Printa nova linha
	li		$v0,	11					# Syscall para imprimir caractere
	li		$a0,	10					# Caractere de nova linha (ASCII 10)
	syscall
	j		escolhe_tamanho
	
	print_tamanho_G:
		# Printa msg tamanho escolhido
		la		$a0,	msg_grande_escolhido
		li		$v0,	4	
		syscall
	j	end_escolhe_tamanho			# Retorna p saida unica

	print_tamanho_P:
		# Printa msg tamanho escolhido
		la		$a0,	msg_pequeno_escolhido
		li		$v0,	4	
		syscall
	j	end_escolhe_tamanho			# Retorna p saida unica

    # Caso usuario insista opcao errada, cancela compra
	aborta_tamanho:							#qndo máximo de tentativas é atingido
		la		$a0,	msg_limite
		li		$v0,	4
		syscall
	j	cancela_pedido
    # Encerra escolha
	end_escolhe_tamanho:
		lw		$s5,	0($sp)				# Pop do s
		#lw		$s6,	4($sp)				# Pop do s
		lw		$ra,	4($sp)				# Pop do return address
		addi	$sp,	$sp,	8			# Pop na pilha de 3elementos*4=12
	j	encerra_pedido						# encerra escolhe_tamanho

#---------------------------------- Escolhe se quer com ou sem açucar ------------------------------
com_ou_sem_acucar:
	addi	$sp,	$sp,	-8				# Push na pilha
	sw		$ra,	4($sp)					# Push do return address
	sw		$s5,	0($sp)					# Push do $s
	#sw		$s4,	0($sp)					# Push do $s
	#limite de tentativas para evitar stack overflow
	li		$t8,	3						# Limite 3 tentativas
    #beq		$s5,	$t8,	aborta_acucar	# cancela a compra

	# Imprime uma nova linha
	li		$v0,	11			# Syscall para imprimir caractere
	li		$a0,	10			# Caractere de nova linha (ASCII 10)
	syscall
	# Printa a mensagem para escolher com ou sem açucar
	la		$a0,	msg_acucar
	li		$v0,	4
	syscall
	# Printa nova linha
	li      $v0,	11			# Syscall para imprimir caractere
	li      $a0,	10			# Caractere de nova linha (ASCII 10)
	syscall
	
	#chama teclado e le a escolha de açucar
	jal		Dig_Lab_Sim					# Chama funcao Display/teclado
	move	$s4,	$v1
	beq		$s4,	1,	com_acucar		# Se o açucar for = 0 (selecao=NAO), vai para o procedimento com_açucar
	beq		$s4, 	0,	sem_acucar		# Se o açucar for = 1 (selecao=SIM), vai pro procedimento sem_acucar
	
    #se nao desvia, incrementa limitador de tentativas
	addi	$s5,	$s5,	1					# Incrementa iterador de limite de erro	

	# Caso seja selecionado algo diferente de 0 ou 1, printa msg_invalido e pergunta novamente
	la		$a0,	msg_invalido 
	li		$v0,	4	
	syscall
	# Printa nova linha
	li      $v0,	11		# Syscall para imprimir caractere
	li      $a0,	10		# Caractere de nova linha (ASCII 10)
	syscall
	j       com_ou_sem_acucar
	
	sem_acucar:	
		#Printa a mensagem de escolha sem açucar
	    la	$a0,	msg_acucar_nao
	    li	$v0,	4	
	    syscall
	    li	$v0,	11			# Syscall para imprimir caractere
	    li	$a0,	10			# Caractere de nova linha (ASCII 10)
	    syscall
    j end_com_ou_sem_acucar
    
    com_acucar:
    	# Printa a mensagem falando que o cliente escolheu com açucar
    	la      $a0,	msg_acucar_sim
    	li      $v0,	4	
    	syscall
    	li      $v0,	11                   # Syscall para imprimir caractere
    	li      $a0,	10                   # Caractere de nova linha (ASCII 10)
    	syscall
    	
    	blt     $s3,	$s6,	bloqueado	# Se qtde. desejada açucar $s6 for < que quantidade conteiner $s3, vai p bloqueado
    
    # Caso usuario insista opcao errada, cancela compra
	# aborta_acucar:							#qndo máximo de tentativas é atingido
	# 	la		$a0,	msg_limite
	# 	li		$v0,	4
	# 	syscall
    #   j   cancela_pedido
	
    # Encerra escolha
	end_com_ou_sem_acucar:
		#lw		$s4,	0($sp)				# Pop do s
		lw		$s5,	0($sp)				# Pop do s
		lw		$ra,	4($sp)				# Pop do return address
		addi	$sp,	$sp,	8			# Pop na pilha de 3elementos*4=12
	j	encerra_pedido						# encerra escolhe_tamanho

#---------------------------------- Libera a agua --------------------------------------------------
libera_agua:
	#push
    addi    $sp,    $sp,    -4             # Push na pilha de 1elemento*4=4
    sw      $ra,    0($sp)                 # Push do return address 

    # Printa a mensagem "Liberando água..."
	la      $a0,	liberando_agua
    li      $v0,	4	
    syscall
    beq     $s6,    2,  libera_copo_grande	# Caso escolhido grande, vai procedimento agua pra copo grande (10 segundos)
    
    # Caso escolhido pequeno, libera agua por 5 segundos
    li      $a0,    5000            # Argumento para syscall 32 (5000 ms). Congela programa por aproximadamente 5 segundos
    li      $v0,    32              # Syscall para sleep
    syscall
    li      $v0,    11              # Syscall para imprimir caractere
    li      $a0,    10              # Caractere de nova linha (ASCII 10)
    syscall
    j   end_libera_agua  

    libera_copo_grande:
    	li      $a0,    10000       # Argumento para syscall 32 (milissegundos)
    	li      $v0,    32          # syscall para sleep
    	syscall
    	li      $v0,	11          # Syscall para imprimir caractere
    	li      $a0,	10          # Caractere de nova linha (ASCII 10)
    	syscall

    end_libera_agua:
        lw      $ra,    0($sp)      # Pop do return address
        addi    $sp,    $sp,    4   # Pop na pilha de 5elementos*4=20
    jr  $ra                         # Retorna a funcao chamadora
    	
#---------------------------------- Preparo do café puro -------------------------------------------
preparo_puro:
	# Verifica se quantidade de po Cafe suficiente
	blt     $s0,    $t9,    bloqueado
	jal     libera_agua     # Se tem ingrediente suficiente, começa preparação (proced. libera água)
    loop_preparo_puro:
        # Printa a mensagem "adicionando cafe"
        la      $a0,	botando_cafe
        li      $v0,	4	
        syscall
        li      $a0,    1000        # Argumento para syscall 32 (milissegundos). Congela o program por 1 segundo
        li      $v0,    32          # syscall para sleep
        syscall
        li      $v0,	11          # Syscall para imprimir caractere
        li      $a0,	10          # Caractere de nova linha (ASCII 10)
        syscall

        addi    $s0,	$s0,	-1		# Cafe do container decrementa
        addi    $t9,	$t9,	-1		# Contador decrementa
        
        bgtz    $t9,    loop_preparo_puro    # se $t9 >0 itera, se $t9<= 0 segue
        move	$t9,	$s6	            # Se todas doses cafe foram adicionadas, restaura tamanho dose p $t9
        li      $t0,    1 
        beq     $s4,    $t0,    preparo_acucar  # Se $s4 == 1, vai p "preparo_acucar" 
	j       inicio          # senao, acabou preparo e volta p inicio

#---------------------------------- Preparo do café com leite --------------------------------------
preparo_leite:
	# Verifica se a quantidade de Café e Leite é suficiente
	blt		$s0,	$t9,	bloqueado
	blt		$s1, 	$t9, 	bloqueado
	jal	libera_agua	# Se tem ingrediente o suficiente, começa a preparação (Chama o procedimento que libera água)
	leite_cafe:
		# Printa a mensagem "adicionando cafe"
		la      $a0,	botando_cafe
		li      $v0,	4	
		syscall
		li      $v0,	11				# Syscall para imprimir caractere
		li      $a0,	10				# Caractere de nova linha (ASCII 10)
		syscall
		li      $a0,    1000      # Argumento para syscall 32 (milissegundos)
    	li      $v0,    32        # Syscall para sleep
    	syscall
		addi	$s0,	$s0,	-1		# Cafe do container decrementa
		addi	$t9,	$t9,	-1      # Decrementa iterador
	    bgtz    $t9,    leite_cafe	# Se a quantidade de doses faltantes não for igual a 0, executa novamente o procedimento 
	    move	$t9,	$s6             # Se todas doses foram adicionadas, restaura tamanho dose de volta p $t9
	leite_leite:
		# Printa a mensagem "adicionando leite"
		la      $a0,	botando_leite
		li      $v0,	4	
		syscall
		li      $v0,	11				# Syscall para imprimir caractere
		li      $a0,	10				# Caractere de nova linha (ASCII 10)
		syscall
		li      $a0,    1000      # Argumento para syscall 32 (milissegundos)
    	li      $v0,    32        # syscall para sleep
    	syscall
		addi	$s1,	$s1,	-1		# Leite do container decrementa
		addi	$t9,	$t9,	-1		# Contador decrementa
		bgtz    $t9,    leite_leite # Enquanto as doses de leite faltante nao for igual a 0, executa novamente o procedimento
		move	$t9,	$s6	            # Se todas doses foram adicionadas, restaura tamanho dose de volta p $t9
		li      $t0,    1 
        beq     $s4,    $t0,    preparo_acucar  # Se $s4 == 1, vai p "preparo_acucar" 
	    j       inicio          # senao, acabou preparo e volta p inicio
#---------------------------------- Preparo do Mochaccino ------------------------------------------
preparo_mocha:
	# Verifica se a quantidade de Café, Leite e Chocolate é suficiente
	blt     $s0,	$t9,	bloqueado
	blt     $s1,	$t9, 	bloqueado
	blt     $s2, 	$t9,	bloqueado
	jal     libera_agua	# Se tem ingrediente o suficiente, começa a preparação (Chama o procedimento que libera água)
	mocha_cafe:
		# Printa a mensagem "adicionando cafe"
		la      $a0,	botando_cafe
		li      $v0,	4	
		syscall
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    		li      $v0,    32              # syscall para sleep
    		syscall
		li      $v0,	11              # Syscall para imprimir caractere
		li      $a0,	10              # Caractere de nova linha (ASCII 10)
		syscall
		addi	$s0,	$s0,	-1      # Cafe do container decrementa
		addi	$t9,	$t9,	-1      # Decrementa iterador
	    bgtz    $t9,    mocha_cafe      # Enquanto doses faltantes de cafe nao foram colocadas, executa novamente loop
		move	$t9,	$s6             # Se todas doses foram adicionadas, restaura tamanho dose de volta p $t9
	mocha_leite:
		# Printa a mensagem "adicionando leite"
		la      $a0,	botando_leite
		li      $v0,	4	
		syscall
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    	li      $v0,    32              # Syscall para sleep
    	syscall	
		li      $v0,	11				# Syscall para imprimir caractere
		li      $a0,	10				# Caractere de nova linha (ASCII 10)
		syscall
		addi	$s1,	$s1,	-1      # Leite do container decrementa
		addi	$t9,	$t9,	-1      # Iterador decrementa	
	    bgtz    $t9,    mocha_leite     # Enquanto doses de leite faltante nao for igual a 0, executa loop novamente
		move	$t9,	$s6             # Se todas doses foram adicionadas, restaura tamanho dose de volta p $t9
	mocha_chocolate:
		# Printa a mensagem "adicionando chocolate"
		la      $a0,	botando_chocolate
		li      $v0,	4	
		syscall
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    	li      $v0,    32              # Syscall para sleep
    	syscall
		li      $v0,	11              # Syscall para imprimir caractere
		li      $a0,	10              # Caractere de nova linha (ASCII 10)
		syscall
		addi    $s2,	$s2,	-1			# Chocolate do container decrementa
		addi    $t9,	$t9,	-1			# Contador decrementa
	    bgtz    $t9,    mocha_chocolate		# Enquanto doses de chocolate faltantes nao for  0, executa loop novamente
		move	$t9,	$s6					# Se todas doses foram adicionadas, restaura tamanho dose de volta p $t9
		li      $t0,    1 
        beq     $s4,    $t0,    preparo_acucar  # Se $s4 == 1, vai p "preparo_acucar" 
	    j       inicio          # senao, acabou preparo e volta p inicio

#---------------------------------- Coloca o açucar depois de preparar o café -----------------------
preparo_acucar:
	blez     $s3,	inicio         # Se quantidade de açucar a botar for 0, ele pula e segue adiante
	blt     $s3,	$t9,    bloqueado	# Verifica se a quantidade de açucar requisitado é maior que a disponivel no container
	# Imprime a mensagem "adicionando açucar"
	la      $a0,	botando_acucar
	li      $v0,	4	
	syscall
	li      $a0,    1000        # Argumento para syscall 32 (milissegundos)
    li      $v0,    32          # syscall para sleep
    syscall
	li      $v0,	11          # Syscall para imprimir caractere
	li      $a0,	10          # Caractere de nova linha (ASCII 10)
	syscall
	addi	$t9,	$t9,	-1
	addi	$s3, 	$s3, 	-1

    bgtz    $t9,    preparo_acucar    # se $t9 >0 itera, se $t9<= 0 segue
	move	$t9,	$s6	            # Se todas doses foram adicionadas, restaura tamanho dose de volta p $t9    
	j		inicio

#---------------------------------- Estado bloqueado caso falte algum dos pós -----------------------
bloqueado:
	blt     $s1,	$s6,	falta_leite
	blt     $s2,	$s6,	falta_chocolate
	blt     $s3,	$s6,	falta_acucar
	falta_cafe:
		la      $a0,	faltando_cafe
		li      $v0,	4	
		syscall
		li      $v0,	11	# Syscall para imprimir caractere
		li      $a0,	10	# Caractere de nova linha (ASCII 10)
		syscall
		j       bloqueado_aguarda
	falta_leite:
		la      $a0,	faltando_leite
		li      $v0,	4	
		syscall
		li      $v0,	11	# Syscall para imprimir caractere
		li      $a0,	10	# Caractere de nova linha (ASCII 10)
		syscall
		j	bloqueado_aguarda
	falta_chocolate:
		la      $a0,	faltando_chocolate
		li      $v0,	4	
		syscall
		li      $v0,	11						# Syscall para imprimir caractere
		li      $a0,	10						# Caractere de nova linha (ASCII 10)
		syscall
		j       bloqueado_aguarda
	falta_acucar:
		la      $a0,	faltando_acucar
		li      $v0,	4	
		syscall
		li      $v0,	11						# Syscall para imprimir caractere
		li      $a0,	10						# Caractere de nova linha (ASCII 10)
		syscall
	bloqueado_aguarda:
		jal		Dig_Lab_Sim 
		move	$t1, 	$v1		
		beq 	$t1,	5, 	reabastece		# Se o valor 5 for digitado, reabastece
	
		# Printa msg_invalido caso usuario selecione uma opcao invalida
		la      $a0,	msg_invalido
		li      $v0,	4	
		syscall	
		li      $v0,	11                   # Syscall para imprimir caractere
		li      $a0,	10                   # Caractere de nova linha (ASCII 10)
		syscall
		j       bloqueado_aguarda		# Senao volta o loop
#---------------------------------- Reabastece um dos pós faltantes ---------------------------------
reabastece:
	la      $a0,	reabastecer_po
	li      $v0,	4	
	syscall	
	
	li      $v0,	11                   # Syscall para imprimir caractere
	li      $a0,	10                   # Caractere de nova linha (ASCII 10)
	syscall
	
	#addi    $sp,    $sp,    -4             # Push na pilha de 1elemento*4=4
    #sw      $ra,    0($sp)                 # Push do return address

	jal		Dig_Lab_Sim
	move	$t1,	$v1
	
	beq     $t1, 	0,  reabastece_cafe
	beq     $t1,	1,  reabastece_leite
	beq     $t1,	2,  reabastece_chocolate
	beq     $t1,	3,  reabastece_acucar
	# Printa msg_invalido caso usuario selecione uma opcao invalida
	la      $a0,	msg_invalido
	li      $v0,	4	
	syscall	
	li      $v0,	11                   # Syscall para imprimir caractere
	li      $a0,	10                   # Caractere de nova linha (ASCII 10)
	syscall
	j       reabastece 
	
	reabastece_cafe: 
		la      $a0,	po_reabastecido
		li      $v0,	4	
		syscall	
		li      $v0,	11                   # Syscall para imprimir caractere
		li      $a0,	10                   # Caractere de nova linha (ASCII 10)
		syscall
		li      $t1,	20000000
		sw      $t1,	cafe_dose
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    		li      $v0,    32              # syscall para sleep
    		syscall
		
		# Esvaziar a pilha antes de voltar ao main
    		lw      $ra,    16($sp)            # Restaura o return address de $ra
    		addi    $sp,    $sp,    20         # Ajusta o ponteiro da pilha para limpar o espaço
		j       main    # TEM QUE ESVAZIAR A PILHA ANTES
	reabastece_leite:
		la      $a0,	po_reabastecido
		li      $v0,	4	
		syscall	
		li      $v0,	11                   # Syscall para imprimir caractere
		li      $a0,	10                   # Caractere de nova linha (ASCII 10)
		syscall
		li      $t1,	20000000
		sw      $t1,	leite_dose
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    		li      $v0,    32              # syscall para sleep
    		syscall
		# # Esvaziar a pilha antes de voltar ao main
    	 	lw      $ra,    16($sp)            # Restaura o return address de $ra
    	 	addi    $sp,    $sp,    20         # Ajusta o ponteiro da pilha para limpar o espaço
		j	main    # TEM QUE ESVAZIAR A PILHA ANTES
	reabastece_chocolate:
		la      $a0,	po_reabastecido
		li      $v0,	4	
		syscall	
		li      $v0,	11                   # Syscall para imprimir caractere
		li      $a0,	10                   # Caractere de nova linha (ASCII 10)
		syscall
		li      $t1,	20000000
		sw      $t1,	chocolate_dose
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    		li      $v0,    32              # syscall para sleep
    		syscall
		# # Esvaziar a pilha antes de voltar ao main
    	 	lw      $ra,    16($sp)            # Restaura o return address de $ra
    	 	addi    $sp,    $sp,    20         # Ajusta o ponteiro da pilha para limpar o espaço
		j       main    # TEM QUE ESVAZIAR A PILHA ANTES
	reabastece_acucar:
		la      $a0,	po_reabastecido
		li      $v0,	4	
		syscall	
		
		li      $v0,	11                   # Syscall para imprimir caractere
		li      $a0,	10                   # Caractere de nova linha (ASCII 10)
		syscall
		
		li      $t1,	20000000
		sw      $t1,	acucar_dose
		li      $a0,    1000            # Argumento para syscall 32 (milissegundos)
    		li      $v0,    32              # syscall para sleep
    		syscall
		
		# Esvaziar a pilha antes de voltar ao main
    		lw      $ra,    16($sp)            # Restaura o return address de $ra
    		addi    $sp,    $sp,    20         # Ajusta o ponteiro da pilha para limpar o espaço
		j       main    # TEM QUE ESVAZIAR A PILHA ANTES

#---------------------------------- Funcao p teclado/display 7-seg ----------------------------------
Dig_Lab_Sim:
    addi    $sp,    $sp,    -20             # Push na pilha de 5elementos*4=20
    sw      $ra,    16($sp)                 # Push do return address
    sw      $a1,    12($sp)                 # Push $a1 pra qndo implementar tag de controle
    sw      $s2,    8($sp)                  # Push de $s em uso
    sw      $s1,    4($sp)                  # Push de $s em uso
    sw      $s0,    0($sp)                  # Push de $s em uso

    li		$s0,	0xFFFF0010				# Endereço do display de 7 segmentos direita
    li		$s2,	0xFFFF0012				# Endereço teclado
    li		$s1,	0xFFFF0014				# Endereço do codigo da tecla pressionada
    li		$t3,	-1        				# Inicializa $t3 com valor inválido
    li		$t4,	0         				# Contador de tentativas
    lb		$t7,	g_segment 				# Exibe inicialmente apenas segmento G
    sb		$t7,	0($s0)

    loop:
    	bge		$t4,	3,		limite_tentativas	# P dar limite selecoes invalidas e cancelar compra
    	li		$t0,	0x01	# Seleciona linha 1
    	sb		$t0,	0($s2)	# Escreve em $s2 para selecionar a linha
    	lbu		$t1,	0($s1)	# Carrega tecla pressionada da linha 1
    	bne		$t1,	$zero,	processa_tecla
    	li		$t0,	0x02	# Seleciona linha 2
    	sb		$t0,	0($s2)
    	lbu		$t1,	0($s1)
    	bne		$t1,	$zero,	processa_tecla
    	li		$t0,	0x04	# Seleciona linha 3
    	sb		$t0,	0($s2)
    	lbu		$t1,	0($s1)
    	bne		$t1,	$zero,	processa_tecla
    	li		$t0,	0x08	# Seleciona linha 4
    	sb		$t0,	0($s2)
    	lbu		$t1,	0($s1)
    	bne		$t1,	$zero,	processa_tecla
    	j		loop			# Repete o loop

    processa_tecla:
        beq		$t1,	$t3,	loop
        move	$t3,	$t1		# Tecla atual eh a ultima pressionada
        # Verifica teclas validas (0, 1, 2, 3)
        beq		$t1,	0x11,	load_zero	# Tecla 0
        beq		$t1,	0x21,	load_um		# Tecla 1
        beq		$t1,	0x41,	load_dois	# Tecla 2
        beq		$t1,	0x81,	load_tres	# Tecla 3
		beq 	$t1,	0x22,	load_cinco	# Tecla 5
        # Se chegar aqui, é tecla invalida
        addi	$t4,	$t4,	1	#Incrementa tentativas
        # Imprime mensagem de opcao invalida
        li		$v0,	4
        la		$a0,	msg_invalido
        syscall
        # Restaura display com segmento G
        lb		$t7,	g_segment
        sb		$t7,	0($s0)
        j		loop

    load_zero:
    	li		$v1,	0			# Armazena 0 em $t0 (correto)
    	lb		$t7,	zero
    	j		atualiza_display

    load_um:
    	li		$v1,	1           # Armazena 1 em $t0
    	lb		$t7,	um
    	j		atualiza_display

    load_dois:
    	li		$v1,	2           # Armazena 2 em $t0
    	lb		$t7,	dois
    	j		atualiza_display

    load_tres:
    	li		$v1,	3			# Armazena 3 em $t0
    	lb		$t7,	tres
    	j		atualiza_display

    load_cinco:
	li		$v1,	5
	lb		$t7,	cinco
	j 		atualiza_display  	# Armazena 5 em $t0

    atualiza_display:
    	sb		$t7,	0($s0)		# Atualiza display de 7 segmentos
    	j		fim_Dig_Lab_Sim			# Termina apos exibir numero valido

    limite_tentativas:
    	# Imprime mensagem de limite de tentativas
    	li		$v0,	4
    	la		$a0,	msg_limite
    	syscall
    fim_Dig_Lab_Sim:
        # Pausa de 1 segundo
        li      $a0,    1000      # 1000ms argumento p syscall 32 
        li      $v0,    32        # syscall para sleep
        syscall
        lw      $s0,    0($sp)                  # Pop de $s em uso
        lw      $s1,    4($sp)                  # Pop de $s em uso
        lw      $s2,    8($sp)                  # Pop de $s em uso
        lw      $a1,    12($sp)                 # Pop $a1 pra qndo implementar tag de controle
        lw      $ra,    16($sp)               	# Pop do return address
        addi    $sp,    $sp,    20             	# Pop na pilha de 5elementos*4=20
    jr      $ra
#---------------------------------- Funcao p impressao cupom ----------------------------------------
cupom:
        addi $sp, $sp, -20           # Reservar espaço na pilha
        sw   $ra, 16($sp)            # Salvar $ra
        sw   $s7, 12($sp)            # Salvar $s
        sw   $s6, 8($sp)           # Salvar $s
        sw   $s1, 4($sp)           # Salvar $s
        sw   $s0, 0($sp)           # Salvar $s
        

        # Validação de entrada segura
        li   $t4, 1               # Validar range de $s6 (1-2)
        li   $t5, 2
        blt  $s6, $t4, erro
        bgt  $s6, $t5, erro

        li   $t4, 1               # Validar range de $s7 (1-3)
        li   $t5, 3
        blt  $s7, $t4, erro
        bgt  $s7, $t5, erro

        # Selecionar produto com base em $s6 e $s7
        move $t0, $s6               # Copiar $s6 para $t0
        move $t1, $s7               # Copiar $s7 para $t1
        la   $a0, produto_1_1       # Padrão para produto
        li   $t2, 1                 # Verificar $s6 == 1
        li   $t3, 1                 # Verificar $s7 == 1
        beq  $t0, $t2, check_1
        li   $t2, 2                 # $s6 == 2
        beq  $t0, $t2, check_2
        j    end_check              # Pular se não for válido

    check_1:
        li   $t2, 1
        beq  $t1, $t2, use_prod_1_1
        li   $t2, 2
        beq  $t1, $t2, use_prod_1_2
        li   $t2, 3
        beq  $t1, $t2, use_prod_1_3
        j    end_check

    check_2:
        li   $t2, 1
        beq  $t1, $t2, use_prod_2_1
        li   $t2, 2
        beq  $t1, $t2, use_prod_2_2
        li   $t2, 3
        beq  $t1, $t2, use_prod_2_3
        j    end_check

    use_prod_1_1:
        la   $a0, produto_1_1
        j    end_check
    use_prod_1_2:
        la   $a0, produto_1_2
        j    end_check
    use_prod_1_3:
        la   $a0, produto_1_3
        j    end_check
    use_prod_2_1:
        la   $a0, produto_2_1
        j    end_check
    use_prod_2_2:
        la   $a0, produto_2_2
        j    end_check
    use_prod_2_3:
        la   $a0, produto_2_3
        j    end_check

    end_check:
        # Substituir print_prod pelo produto selecionado
        la   $t0, print_prod
        move $t1, $a0               # $t1 aponta para a string do produto
        li   $t3, 0                 # Contador de caracteres copiados

    replace_prod:
        lb   $t2, 0($t1)            # Ler caractere da string do produto
        beq  $t2, $zero, done_replace # Fim da string

        # Verificação de segurança para evitar estouro de buffer
        li   $t4, 53                # Tamanho máximo de print_prod
        beq  $t3, $t4, done_replace

        sb   $t2, 0($t0)            # Substituir caractere em print_prod
        addi $t0, $t0, 1            # Avançar no destino
        addi $t1, $t1, 1            # Avançar na origem
        addi $t3, $t3, 1            # Incrementar contador
        j    replace_prod

    done_replace:
        ###############################################################
        # Abrir arquivo template para leitura
        li   $v0, 13       # Chamada para abrir arquivo
        la   $a0, template_f # Nome do arquivo template
        li   $a1, 0        # Modo de leitura (flags: 0 = leitura)
        li   $a2, 0        # Mode ignorado
        syscall
        bltz $v0, erro  # Verificar erro na abertura
        move $s0, $v0      # Salvar descritor de arquivo do template
    
        ###############################################################
        # Criar arquivo de saída para escrita
        li   $v0, 13       # Chamada para abrir arquivo
        la   $a0, output_f   # Nome do arquivo de saída
        li   $a1, 1        # Modo de escrita (flags: 1 = escrita)
        li   $a2, 0        # Mode ignorado
        syscall
        bltz $v0, erro  # Verificar erro na abertura
        move $s1, $v0      # Salvar descritor de arquivo de saída

        ###############################################################
        # Ler e processar o conteúdo do template
    read_loop:
        li   $v0, 14       # Chamada para ler do arquivo
        move $a0, $s0      # Descritor do arquivo template
        la   $a1, buffer   # Endereço do buffer para leitura
        li   $a2, 1024     # Número máximo de bytes para ler
        syscall
        move $t0, $v0      # Salvar número de bytes lidos
        beq  $t0, $zero, end_read # Fim do arquivo (0 bytes lidos)
        bltz $t0, erro   # Verificar erro na leitura

        # Preparar para substituição
        la   $t1, buffer   # Ponteiro para o início do buffer
        add  $t2, $t1, $t0 # Calcula o fim do buffer

    replace_loop:
        lb   $t3, 0($t1)        # Carrega um byte do buffer
        beq  $t3, $zero, write_buffer  # Fim do buffer

        # Verifica se é '@' (data)
        li   $t4, 64            # ASCII de '@'
        beq  $t3, $t4, replace_date_section

        # Verifica se é '&' (hora)
        li   $t4, 38            # ASCII de '&'
        beq  $t3, $t4, replace_time_section

        # Verifica se é '*' (produto)
        li   $t4, 42            # ASCII de '*'
        beq  $t3, $t4, replace_prod_section

        # Próximo caractere
        addi $t1, $t1, 1
        sub  $t4, $t2, $t1      # Verifica se chegou ao fim do buffer
        bgtz $t4, replace_loop
        j    write_buffer

    replace_date_section:
        la   $t5, in_date       # Endereço da data
        j    perform_date_replace

    replace_time_section:
        la   $t5, in_time       # Endereço da hora
        j    perform_time_replace

    replace_prod_section:
        la   $t5, print_prod    # Endereço do produto
        j    perform_prod_replace

    perform_date_replace:
        # Substituição de data com verificação de limite
        lb   $t6, 0($t5)        # Carrega byte da data
        beq  $t6, $zero, next_char_date # Fim da string de data
        
        # Verificar limites do buffer
        sub  $t4, $t2, $t1
        blez $t4, next_char_date

        sb   $t6, 0($t1)        # Substitui no buffer
        addi $t5, $t5, 1        # Próximo byte da data
        addi $t1, $t1, 1        # Próximo byte do buffer
        j    perform_date_replace

    next_char_date:
        j    next_char

    perform_time_replace:
        # Substituição de hora com verificação de limite
        lb   $t6, 0($t5)        # Carrega byte da hora
        beq  $t6, $zero, next_char_time # Fim da string de hora

        # Verificar limites do buffer
        sub  $t4, $t2, $t1
        blez $t4, next_char_time

        sb   $t6, 0($t1)        # Substitui no buffer
        addi $t5, $t5, 1        # Próximo byte da hora
        addi $t1, $t1, 1        # Próximo byte do buffer
        j    perform_time_replace

    next_char_time:
        j    next_char

    perform_prod_replace:
        # Substituição de produto com verificação de limite
        lb   $t6, 0($t5)        # Carrega byte do produto
        beq  $t6, $zero, next_char_prod # Fim da string de produto

        # Verificar limites do buffer
        sub  $t4, $t2, $t1
        blez $t4, next_char_prod

        sb   $t6, 0($t1)        # Substitui no buffer
        addi $t5, $t5, 1        # Próximo byte do produto
        addi $t1, $t1, 1        # Próximo byte do buffer
        j    perform_prod_replace

    next_char_prod:
        j    next_char

    next_char:
        # Continua processamento do buffer
        sub  $t4, $t2, $t1
        bgtz $t4, replace_loop

    write_buffer:
        ###############################################################
        # Escrever conteúdo processado no arquivo de saída
        li   $v0, 15       # Chamada para escrever no arquivo
        move $a0, $s1      # Descritor do arquivo de saída
        la   $a1, buffer   # Endereço do buffer para escrita
        move $a2, $t0      # Número de bytes para escrever
        syscall
        j    read_loop

    end_read:
        ###############################################################
        # Fechar os arquivos
        li   $v0, 16       # Chamada para fechar arquivo
        move $a0, $s0      # Fechar o arquivo template
        syscall
        li   $v0, 16       # Chamada para fechar arquivo
        move $a0, $s1      # Fechar o arquivo de saída
        syscall

        ###############################################################
        # Encerra rotina com Pop
        lw   $s0, 0($sp)           # Restaurar $s
        lw   $s1, 4($sp)           # Restaurar $s
        lw   $s6, 8($sp)           # Restaurar $s
        lw   $s7, 12($sp)            # Restaurar $s
        lw   $ra, 16($sp)            # Restaurar $ra
        addi $sp, $sp, 20            # Restaurar pilha
        jr   $ra                    # Retornar para chamador
    erro:
        # Tratamento para erro de abertura, leitura de arquivo ou input invalido
        li   $v0, 10       # Código para encerrar programa
        syscall

