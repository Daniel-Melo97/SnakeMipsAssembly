.data



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
	
#inicializando dados do jogo
	
	li $t6, 268502800 #posição inicial da cobra
	sw $t2, 0($t6)#desenhando tamanho inicial da cobra
	sw $t2, -4($t6)#desenhando tamanho inicial da cobra
	sw $t2, -8($t6) #desenhando tamanho inicial da cobra
	sw $s2, 32($t6) #desenhando primeira maçã 
	
	
	li $t5, 1 #contador de tempo para atualizar pontuação
	li $s0, 0 #pontuação do jogador
	li $t4, 2 #movimento atual:
	#$t4 = 0, significa que atualmente está subindo
	#$t4 = 1, significa que atualmente está descendo
	#$t4 = 2, significa que atualmente está indo para a direita
	#$t4 = 3, significa que atualmente está indo para a esquerda
	#esses valores serão usados para impedir movimentos inválidos, por exemplo: impedir que o jogador façaa cobra descer, quando ela estiver subindo
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
	
	beq $t5, 5, counterbytime #quando $t5 for igual a 5, significa que o jogo andou meio segundo, deve atualizar a pontuação
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
	li $t4, 2 #caso contrário, mudar movimento para a direita
	j continueright	#ir para a direita	
		
inputleft: 
	beq $t4, 2, continueright#se a cobra está indo para a direita, não mudar o movimento
	li $t4, 3 #caso contrário, mudar movimento para a esquerda
	j continueleft	#ir para a esquerda		
		
inputdown: 
	beq $t4, 0, continueup#se a cobra está indo para cima, não mudar o movimento
	li $t4, 1 #caso contrário, mudar movimento para baixo
	j continuedown	#ir para baixo
		
inputup: 
	beq $t4, 1, continuedown#se a cobra está indo para cima, não mudar o movimento
	li $t4, 0 #caso contrário, mudar movimento para baixo
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
	addi $t6, $t6, 4
	sw $t2, 0($t6)
	j loopgame										

continueleft:																											
	addi $t6, $t6, -4
	sw $t2, 0($t6)	
	j loopgame
	
continueup:
	addi $t6, $t6, -128
	sw $t2, 0($t6)	
	j loopgame																	
																												
continuedown:
	addi $t6, $t6, 128
	sw $t2, 0($t6)	
	j loopgame																																																																																										


	
