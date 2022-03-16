.data



.text

	la $t1, 0x10010000 #posição do primeiro pixel do display
	li $t2, 0x00ffff00 #cor amarela
	
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
	
	li $t5, 1 #contador de tempo para atualizar pontuação
	li $s0, 0 #pontuação do jogador
	li $t4, 0 #movimento atual:
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
	j next	#pular a atualização de pontos	
	
counterbytime:
	addi $s0, $s0, 1 #aumentando pontuação
	li $t5, 1	#resetando contador de tempo
	
next:	