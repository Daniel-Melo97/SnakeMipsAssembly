.data
out_string: .asciiz "\nFim de jogo, sua pontuação foi: "

.text
	
	la $t1, 0x10010000 #posição do primeiro pixel do display
	li $t2, 16776960 #cor amarela
	li $s2, 16711680 #cor vermelha para fruta
	
	
	li $t3, 32#tamanho da borda superior
	
#Desenhando borda superior
topborder:
	sw $t2, 0($t1) #colocando cor no pixel
	addi $t1, $t1, 4 #avança para o próximo pixel
	addi $t3, $t3, -1 #diminui o contador de pixels da borda superior
	bgtz $t3, topborder#enquanto não chegar no fim da borda superior, repetir

	li $t4, 30 #quantidade de linhas no meio


#Desenhando bordas latereis
sideborders:			
		sw $t2, 0($t1) #escrevendo pixel lateral após a borda superior
		addi $t1, $t1, 4 #avançando próximo pixel
		li $t3, 30 #30 pixels para o meio
	row:
		addi $t1, $t1, 4 #avança para o próximo pixel
		addi $t3, $t3, -1 #diminui o contador de pixels do meio
		bgtz $t3, row#enquanto não chegar no penultimo pixel, repetir
	
		sw $t2, 0($t1) #escrevendo último pixel da linha
		addi $t1, $t1, 4 #avançando próximo pixel
	
	addi $t4, $t4, -1
	bgtz $t4, sideborders
	
	li $t3, 32#tamanho da borda inferior

#Desenhando borda inferior

bottomborder:
	sw $t2, 0($t1) #colocando cor no pixel
	addi $t1, $t1, 4 #avança para o próximo pixel
	addi $t3, $t3, -1 #diminui o contador de pixels da borda inferior
	bgtz $t3, bottomborder#enquanto não chegar no fim da borda inferior, repetir
	
#inicializando dados do jogo------------------------------------------------------------------------------------
	
	li $t6, 268502800 #posição inicial da cobra
	sw $t2, 0($t6)#desenhando tamanho inicial da cobra
	sw $t2, -4($t6)#desenhando tamanho inicial da cobra
	sw $t2, -8($t6) #desenhando tamanho inicial da cobra
	addi $t7, $t6, -8 #ponta da cauda
	sw $s2, 32($t6) #desenhando primeira maçã 
	
	
	li $t5, 1 #contador de tempo para atualizar pontuação
	li $s0, 0 #pontuação do jogador
	li $t4, 2 #movimento atual:
	#$t4 = 0, significa que atualmente está subindo
	#$t4 = 1, significa que atualmente está descendo
	#$t4 = 2, significa que atualmente está indo para a direita
	#$t4 = 3, significa que atualmente está indo para a esquerda
	#esses valores serão usados para impedir movimentos inválidos, por exemplo: impedir que o jogador façaa cobra descer, quando ela estiver subindo
	li $s1, 2 #movimento inicial da cauda, segue o mesmo padrão da cabeça
	# $t1 #base do array de mudanças de movimento
	li $s3, 0 #tamanho inicial do array de mudanças de movimento
	
	
	
loopgame:

	lw $t3, 0xffff0004 #recebe input do usuário
	#$t3 = 100, significa que a tecla D foi pressionada
	#$t3 = 97, significa que a tecla A foi pressionada
	#$t3 = 119, significa que a tecla W foi pressionada
	#$t3 = 115, significa que a tecla S foi pressionada
	
	### comando de sleep para controlar o frame rate do jogo
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 100	# 100 ms
	syscall
	
	beq $t5, 6, counterbytime #quando $t5 for igual a 5, significa que o jogo andou meio segundo, deve atualizar a pontuação
	addi $t5, $t5, 1#caso contrário, aumentar o contador
	j verifyinput #pular a atualização de pontos	
	
counterbytime:
	addi $s0, $s0, 1 #aumentando pontuação
	li $t5, 1	#resetando contador de tempo
	
verifyinput:	
	beq $t3, 100, inputright#se o usuário apertou D, mudar para direita
	beq $t3, 119, inputup #se o usuário apertou W, mudar para cima
	beq $t3, 115, inputdown # se o usuário apertou S, mudar para baixo
	beq $t3, 97, inputleft # se o usuário apertou A, mudar para esquerda
	#caso o usuário não tenha digitado nada ou digitou um input inválido(que não seja W,A,S ou D)
	beq $t4, 0, continueup #se o movimento atual é de subida, seguir subindo
	beq $t4, 1, continuedown#se o movimento atual é de descida, seguir descendo
	beq $t4, 2, continueright#se o movimento atual é para a direita, seguir a direita
	beq $t4, 3, continueleft#se o movimento atual é para a esquerda, seguir a esquerda

#pseudocódigo dos inputs:	
#	if(input.invalid){// exemplo: se estiver indo para a esquerda e o usuário apertar D(direita), ele deve seguir indo a esquerda
#		SeguirMovimentoAtual()
#	}else{//caso contrário, mudar para a direção desejada
#		MudarDireção()
#	}
		
inputright: 
	beq $t4, 3, continueleft#se a cobra está indo para a esquerda, não mudar o movimento
	beq $t4, 2, continueright #se já está indo a direita, continuar
	li $t4, 2 #caso contrário, mudar movimento para a direita
	add $t8, $t1, $s3 #t7 recebe a memória do final do array
	sw $t6, 0($t8) #armazena a posição atual(onde houve a mudança de movimento)
	sw $t4, 4($t8) #armazena a direção do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continueright	#ir para a direita	
		
inputleft: 
	beq $t4, 2, continueright#se a cobra está indo para a direita, não mudar o movimento
	beq $t4, 3, continueleft #se já está indo a esquerda, continuar
	li $t4, 3 #caso contrário, mudar movimento para a esquerda
	add $t8, $t1, $s3 #t7 recebe a memória do final do array
	sw $t6, 0($t8) #armazena a posição atual(onde houve a mudança de movimento)
	sw $t4, 4($t8) #armazena a direção do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continueleft	#ir para a esquerda		
		
inputdown: 
	beq $t4, 0, continueup#se a cobra está indo para cima, não mudar o movimento
	beq $t4, 1, continuedown #se já está indo para baixo, continuar
	li $t4, 1 #caso contrário, mudar movimento para baixo
	add $t8, $t1, $s3 #t7 recebe a memória do final do array
	sw $t6, 0($t8) #armazena a posição atual(onde houve a mudança de movimento)
	sw $t4, 4($t8) #armazena a direção do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continuedown	#ir para baixo
		
inputup: 
	beq $t4, 1, continuedown#se a cobra está indo para cima, não mudar o movimento
	beq $t4, 0, continueup #se já está indo para cima, continuar
	li $t4, 0 #caso contrário, mudar movimento para baixo
	add $t8, $t1, $s3 #t7 recebe a memória do final do array
	sw $t6, 0($t8) #armazena a posição atual(onde houve a mudança de movimento)
	sw $t4, 4($t8) #armazena a direção do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continueup	#ir para baixo			

#pseudocódigo dos continue:
#	if(próximaPosição.Válida){
#		setposição()
#	}else if(próximaPosição.isMaçã){
#		setposição()
#		crescer()
#	}else{
#		setposição()
#		gameOver()
#	}
												
																				
continueright:
	addi $t6, $t6, 4#anda para o pixel a direita
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o próximo pixel for o contorno do cenário ou a própria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o próximo pixel for uma fruta, ir até função de frute
	sw $t2, 0($t6)#caso contrário, apenas pinta pixel
	j tailmov #volta para o loop do game								

continueleft:																											
	addi $t6, $t6, -4#anda para o pixel a esquerda
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o próximo pixel for o contorno do cenário ou a própria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o próximo pixel for uma fruta, ir até função de frute
	sw $t2, 0($t6)	#pinta pixel
	j tailmov #volta para o loop do game	
	
continueup:
	addi $t6, $t6, -128#anda para o pixel acima
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o próximo pixel for o contorno do cenário ou a própria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o próximo pixel for uma fruta, ir até função de frute
	sw $t2, 0($t6)	#pinta pixel
	j tailmov	#volta para o loop do game																	
																												
continuedown:
	addi $t6, $t6, 128 #anda para o pixel abaixo
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o próximo pixel for o contorno do cenário ou a própria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o próximo pixel for uma fruta, ir até função de frute
	sw $t2, 0($t6)	#pinta pixel
	j tailmov	#volta para o loop do game	
	
tailmov:																																																																																																																																																																															
	beq $s1, 0, tailup #se for igual a zero, subir
	beq $s1, 1, taildown #se for igual a 1, descer
	beq $s1, 2, tailright #se for igual a 2, ir para a direita
	beq $s1, 3, tailleft #se for igual a 3, ir para a esquerda
	

tailup:
	lw $t8, 0($t1) #carrega a posição do pixel onde haverá a próxima mudança de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, -128 #anda para o próximo pixel acima
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contrário, alterar direção da cauda
	addi $t1, $t1, 8 #alterando endereço base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame
	
taildown:
	lw $t8, 0($t1) #carrega a posição do pixel onde haverá a próxima mudança de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, 128 #anda para o próximo pixel abaixo
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contrário, alterar direção da cauda
	addi $t1, $t1, 8 #alterando endereço base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame
	
tailright:
	lw $t8, 0($t1) #carrega a posição do pixel onde haverá a próxima mudança de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, 4 #anda para o próximo pixel a direita
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contrário, alterar direção da cauda
	addi $t1, $t1, 8 #alterando endereço base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame
	
tailleft:
	lw $t8, 0($t1) #carrega a posição do pixel onde haverá a próxima mudança de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, -4 #anda para o próximo pixel a esquerda
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contrário, alterar direção da cauda
	addi $t1, $t1, 8 #alterando endereço base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame

getfruit:
	sw $t2, 0($t6) #pinta pixel
	addi $s0, $s0, 5 #aumenta pontuação
	#gerar próxima fruta aleatoriamente
randomfruit:

	addi $v0, $zero, 42        # Syscall 42: Random int range
	add $a0, $zero, $zero   # Set RNG ID to 0
	addi $a1, $zero, 31     # Set upper bound to 4 (exclusive)
	syscall                  # Generate a random number and put it in $a0
	add $s4, $zero, $a0     # Copy the random number to $s1
	

	addi $v0, $zero, 42        # Syscall 42: Random int range
	add $a0, $zero, $zero   # Set RNG ID to 0
	addi $a1, $zero, 31     # Set upper bound to 4 (exclusive)
	syscall                  # Generate a random number and put it in $a0
	add $s5, $zero, $a0     # Copy the random number to $s1
	
	
	
	#li $v0, 42
	#li $a1, 31
	#syscall
	#add $s4, $a0, $zero
	
	#li $v0, 42
	#li $a1, 31
	#syscall
	#add $s5, $a0, $zero
	
	#li $v0, 1
	#addi $a0, $zero, $s4
	#syscall
	
	#li $v0, 1
	#addi $a0, $zero, $s5
	#syscall
	
	la $t8, 0x10010000
	
	beqz $s4, randomfruit
	getRow:
		addi $t8, $t8, 128
		addi $s4, $s4, -1
		bgtz $s4, getRow 

	beqz $s5, randomfruit
	getColumn:
		addi $t8, $t8, 4
		addi $s5, $s5, -1
		bgtz $s5, getColumn 
	
	 
	
	lw $t9, 0($t8)
	beq $t9, $t2, randomfruit
	sw $s2, 0($t8)
	j loopgame

gameover:
	li $v0, 56 #syscall para exibir caixa de diálogo
	la $a0, out_string
	add $a1, $s0, $zero #a1 recebe a pontuação
	syscall
	
	li $v0, 10 #encerra o programa
	syscall
