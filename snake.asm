.data
out_string: .asciiz "\nFim de jogo, sua pontua��o foi: "

.text
	
	la $t1, 0x10010000 #posi��o do primeiro pixel do display
	li $t2, 16776960 #cor amarela
	li $s2, 16711680 #cor vermelha para fruta
	
	
	li $t3, 32#tamanho da borda superior
	
#Desenhando borda superior
topborder:
	sw $t2, 0($t1) #colocando cor no pixel
	addi $t1, $t1, 4 #avan�a para o pr�ximo pixel
	addi $t3, $t3, -1 #diminui o contador de pixels da borda superior
	bgtz $t3, topborder#enquanto n�o chegar no fim da borda superior, repetir

	li $t4, 30 #quantidade de linhas no meio


#Desenhando bordas latereis
sideborders:			
		sw $t2, 0($t1) #escrevendo pixel lateral ap�s a borda superior
		addi $t1, $t1, 4 #avan�ando pr�ximo pixel
		li $t3, 30 #30 pixels para o meio
	row:
		addi $t1, $t1, 4 #avan�a para o pr�ximo pixel
		addi $t3, $t3, -1 #diminui o contador de pixels do meio
		bgtz $t3, row#enquanto n�o chegar no penultimo pixel, repetir
	
		sw $t2, 0($t1) #escrevendo �ltimo pixel da linha
		addi $t1, $t1, 4 #avan�ando pr�ximo pixel
	
	addi $t4, $t4, -1
	bgtz $t4, sideborders
	
	li $t3, 32#tamanho da borda inferior

#Desenhando borda inferior

bottomborder:
	sw $t2, 0($t1) #colocando cor no pixel
	addi $t1, $t1, 4 #avan�a para o pr�ximo pixel
	addi $t3, $t3, -1 #diminui o contador de pixels da borda inferior
	bgtz $t3, bottomborder#enquanto n�o chegar no fim da borda inferior, repetir
	
#inicializando dados do jogo------------------------------------------------------------------------------------
	
	li $t6, 268502800 #posi��o inicial da cobra
	sw $t2, 0($t6)#desenhando tamanho inicial da cobra
	sw $t2, -4($t6)#desenhando tamanho inicial da cobra
	sw $t2, -8($t6) #desenhando tamanho inicial da cobra
	addi $t7, $t6, -8 #ponta da cauda
	sw $s2, 32($t6) #desenhando primeira ma�� 
	
	
	li $t5, 1 #contador de tempo para atualizar pontua��o
	li $s0, 0 #pontua��o do jogador
	li $t4, 2 #movimento atual:
	#$t4 = 0, significa que atualmente est� subindo
	#$t4 = 1, significa que atualmente est� descendo
	#$t4 = 2, significa que atualmente est� indo para a direita
	#$t4 = 3, significa que atualmente est� indo para a esquerda
	#esses valores ser�o usados para impedir movimentos inv�lidos, por exemplo: impedir que o jogador fa�aa cobra descer, quando ela estiver subindo
	li $s1, 2 #movimento inicial da cauda, segue o mesmo padr�o da cabe�a
	# $t1 #base do array de mudan�as de movimento
	li $s3, 0 #tamanho inicial do array de mudan�as de movimento
	
	
	
loopgame:

	lw $t3, 0xffff0004 #recebe input do usu�rio
	#$t3 = 100, significa que a tecla D foi pressionada
	#$t3 = 97, significa que a tecla A foi pressionada
	#$t3 = 119, significa que a tecla W foi pressionada
	#$t3 = 115, significa que a tecla S foi pressionada
	
	### comando de sleep para controlar o frame rate do jogo
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 100	# 100 ms
	syscall
	
	beq $t5, 6, counterbytime #quando $t5 for igual a 5, significa que o jogo andou meio segundo, deve atualizar a pontua��o
	addi $t5, $t5, 1#caso contr�rio, aumentar o contador
	j verifyinput #pular a atualiza��o de pontos	
	
counterbytime:
	addi $s0, $s0, 1 #aumentando pontua��o
	li $t5, 1	#resetando contador de tempo
	
verifyinput:	
	beq $t3, 100, inputright#se o usu�rio apertou D, mudar para direita
	beq $t3, 119, inputup #se o usu�rio apertou W, mudar para cima
	beq $t3, 115, inputdown # se o usu�rio apertou S, mudar para baixo
	beq $t3, 97, inputleft # se o usu�rio apertou A, mudar para esquerda
	#caso o usu�rio n�o tenha digitado nada ou digitou um input inv�lido(que n�o seja W,A,S ou D)
	beq $t4, 0, continueup #se o movimento atual � de subida, seguir subindo
	beq $t4, 1, continuedown#se o movimento atual � de descida, seguir descendo
	beq $t4, 2, continueright#se o movimento atual � para a direita, seguir a direita
	beq $t4, 3, continueleft#se o movimento atual � para a esquerda, seguir a esquerda

#pseudoc�digo dos inputs:	
#	if(input.invalid){// exemplo: se estiver indo para a esquerda e o usu�rio apertar D(direita), ele deve seguir indo a esquerda
#		SeguirMovimentoAtual()
#	}else{//caso contr�rio, mudar para a dire��o desejada
#		MudarDire��o()
#	}
		
inputright: 
	beq $t4, 3, continueleft#se a cobra est� indo para a esquerda, n�o mudar o movimento
	beq $t4, 2, continueright #se j� est� indo a direita, continuar
	li $t4, 2 #caso contr�rio, mudar movimento para a direita
	add $t8, $t1, $s3 #t7 recebe a mem�ria do final do array
	sw $t6, 0($t8) #armazena a posi��o atual(onde houve a mudan�a de movimento)
	sw $t4, 4($t8) #armazena a dire��o do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continueright	#ir para a direita	
		
inputleft: 
	beq $t4, 2, continueright#se a cobra est� indo para a direita, n�o mudar o movimento
	beq $t4, 3, continueleft #se j� est� indo a esquerda, continuar
	li $t4, 3 #caso contr�rio, mudar movimento para a esquerda
	add $t8, $t1, $s3 #t7 recebe a mem�ria do final do array
	sw $t6, 0($t8) #armazena a posi��o atual(onde houve a mudan�a de movimento)
	sw $t4, 4($t8) #armazena a dire��o do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continueleft	#ir para a esquerda		
		
inputdown: 
	beq $t4, 0, continueup#se a cobra est� indo para cima, n�o mudar o movimento
	beq $t4, 1, continuedown #se j� est� indo para baixo, continuar
	li $t4, 1 #caso contr�rio, mudar movimento para baixo
	add $t8, $t1, $s3 #t7 recebe a mem�ria do final do array
	sw $t6, 0($t8) #armazena a posi��o atual(onde houve a mudan�a de movimento)
	sw $t4, 4($t8) #armazena a dire��o do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continuedown	#ir para baixo
		
inputup: 
	beq $t4, 1, continuedown#se a cobra est� indo para cima, n�o mudar o movimento
	beq $t4, 0, continueup #se j� est� indo para cima, continuar
	li $t4, 0 #caso contr�rio, mudar movimento para baixo
	add $t8, $t1, $s3 #t7 recebe a mem�ria do final do array
	sw $t6, 0($t8) #armazena a posi��o atual(onde houve a mudan�a de movimento)
	sw $t4, 4($t8) #armazena a dire��o do movimento
	addi $s3, $s3, 8 #aumenta tamanho do array
	j continueup	#ir para baixo			

#pseudoc�digo dos continue:
#	if(pr�ximaPosi��o.V�lida){
#		setposi��o()
#	}else if(pr�ximaPosi��o.isMa��){
#		setposi��o()
#		crescer()
#	}else{
#		setposi��o()
#		gameOver()
#	}
												
																				
continueright:
	addi $t6, $t6, 4#anda para o pixel a direita
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o pr�ximo pixel for o contorno do cen�rio ou a pr�pria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o pr�ximo pixel for uma fruta, ir at� fun��o de frute
	sw $t2, 0($t6)#caso contr�rio, apenas pinta pixel
	j tailmov #volta para o loop do game								

continueleft:																											
	addi $t6, $t6, -4#anda para o pixel a esquerda
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o pr�ximo pixel for o contorno do cen�rio ou a pr�pria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o pr�ximo pixel for uma fruta, ir at� fun��o de frute
	sw $t2, 0($t6)	#pinta pixel
	j tailmov #volta para o loop do game	
	
continueup:
	addi $t6, $t6, -128#anda para o pixel acima
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o pr�ximo pixel for o contorno do cen�rio ou a pr�pria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o pr�ximo pixel for uma fruta, ir at� fun��o de frute
	sw $t2, 0($t6)	#pinta pixel
	j tailmov	#volta para o loop do game																	
																												
continuedown:
	addi $t6, $t6, 128 #anda para o pixel abaixo
	lw $t8, 0($t6) #carrega cor do pixel
	beq $t8, $t2, gameover #se o pr�ximo pixel for o contorno do cen�rio ou a pr�pria cobra, ir para gameover
	beq $t8, $s2, getfruit #se o pr�ximo pixel for uma fruta, ir at� fun��o de frute
	sw $t2, 0($t6)	#pinta pixel
	j tailmov	#volta para o loop do game	
	
tailmov:																																																																																																																																																																															
	beq $s1, 0, tailup #se for igual a zero, subir
	beq $s1, 1, taildown #se for igual a 1, descer
	beq $s1, 2, tailright #se for igual a 2, ir para a direita
	beq $s1, 3, tailleft #se for igual a 3, ir para a esquerda
	

tailup:
	lw $t8, 0($t1) #carrega a posi��o do pixel onde haver� a pr�xima mudan�a de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, -128 #anda para o pr�ximo pixel acima
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contr�rio, alterar dire��o da cauda
	addi $t1, $t1, 8 #alterando endere�o base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame
	
taildown:
	lw $t8, 0($t1) #carrega a posi��o do pixel onde haver� a pr�xima mudan�a de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, 128 #anda para o pr�ximo pixel abaixo
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contr�rio, alterar dire��o da cauda
	addi $t1, $t1, 8 #alterando endere�o base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame
	
tailright:
	lw $t8, 0($t1) #carrega a posi��o do pixel onde haver� a pr�xima mudan�a de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, 4 #anda para o pr�ximo pixel a direita
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contr�rio, alterar dire��o da cauda
	addi $t1, $t1, 8 #alterando endere�o base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame
	
tailleft:
	lw $t8, 0($t1) #carrega a posi��o do pixel onde haver� a pr�xima mudan�a de movimento
	sw $zero, 0($t7) #apaga pixel
	addi $t7, $t7, -4 #anda para o pr�ximo pixel a esquerda
	bne $t8, $t7, loopgame #se forem diferentes, seguir loop
	lw $s1, 4($t1) #caso contr�rio, alterar dire��o da cauda
	addi $t1, $t1, 8 #alterando endere�o base do array
	addi $s3, $s3, -8 #atualizando tamanho
	j loopgame

getfruit:
	sw $t2, 0($t6) #pinta pixel
	addi $s0, $s0, 5 #aumenta pontua��o
	#gerar pr�xima fruta aleatoriamente
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
	li $v0, 56 #syscall para exibir caixa de di�logo
	la $a0, out_string
	add $a1, $s0, $zero #a1 recebe a pontua��o
	syscall
	
	li $v0, 10 #encerra o programa
	syscall
