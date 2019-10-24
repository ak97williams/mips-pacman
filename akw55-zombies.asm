	.data
player:	.word	0x0, 0x0
zombie_loc: .byte	17, 14, 49, 14, 17, 46, 49, 46
prevzombie_loc: .byte 18, 14, 48, 14, 16, 46, 48, 46
defeat:	.asciiz	"Sorry. You were captured"
winner:	.asciiz	"Success! You Won! Your score is "
moves:	.asciiz	" moves"
smartAddresses:	.word 0x0, 0x0		#holds the zombie location and prevlocation while smartMove is running

	.text
	
beginGame:	
	la	$v0, 0xffff0000		# address for reading key press status
	la	$s1, player
	lw	$s2, 0($s1)
	lw	$s3, 4($s1)
	lw	$t0, 0($v0)		# read the key press status
	andi	$t0, $t0, 1
	beq	$t0, $0, beginGame		# no key pressed
	lw	$t0, 4($v0)		# read key value
startkey:	
	addi	$v0, $t0, -0x42		# check for center key press
	bne	$v0, $0, beginGame	# invalid key, ignore it

		
	li	$t0, 0xAA
	la	$t1, 0xFFFF0008
	li	$t2, 0
	li	$t3, 0

DrawHorizEdges:					#starts by drawing a large box around the whole display
	addi	$t2, $t2, 1
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	bne	$t2, 16, DrawHorizEdges
	
	li	$t2, 0
	addi	$t3, $t3, 1
	la	$t1, 0xFFFF03F8
	bne	$t3, 2, DrawHorizEdges
	
	li	$t3, 0
	li	$t2, 0
	la	$t1, 0xFFFF0028
	li	$t0, 0x80
			
DrawVertEdges:
	addi	$t2, $t2, 1
	sb	$t0, 0($t1)
	addi	$t1, $t1, 16
	bne	$t2, 62, DrawVertEdges
	

	addi	$t3, $zero, 1
	li	$t0, 0x2
	la	$t1, 0xFFFF0017
	li	$t2, 0
	beq	$t3, 2, DrawVertEdges	

	li	$t0, 0x8A
	la	$t1, 0xFFFF0018
	li	$t2, 0
	li	$t3, 0

DrawBoxes1:
	beq	$t4, 0, DrawBoxes2
	li	$t0, 0x8A
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	li	$t0, 0xAA
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	bne	$t2, 16, DrawBoxes1
	li	$t2, 0

DrawBoxes2:
	addi	$t4, $zero, 1
	li	$t0, 0x80
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	li	$t0, 0x2
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	bne	$t2, 8, DrawBoxes2
	li	$t2, 0
	
DrawBoxes3:
	addi	$t4, $zero, 1
	li	$t0, 0x8A
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	li	$t0, 0xA2
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	bne	$t2, 8, DrawBoxes3
	li	$t2, 0
	
DrawBoxes4:
	addi	$t4, $zero, 1
	li	$t0, 0x88
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	li	$t0, 0x22
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	bne	$t2, 16, DrawBoxes4
	addi	$t3, $t3, 1
	li	$t2, 0
		
DrawBoxes5:
	addi	$t4, $zero, 1
	li	$t0, 0x8A
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	li	$t0, 0xA2
	sb	$t0, 0($t1)
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	bne	$t2, 8, DrawBoxes5
	li	$t2, 0
	addi	$t1, $t1, 16
	bne	$t3, 8, DrawBoxes1

	li	$t3, 0
	li	$t2, 0
	la	$t1, 0xFFFF0077
	li	$t0, 0x2
			
DrawVertEdges2:
	addi	$t2, $t2, 1
	sb	$t0, 0($t1)
	addi	$t1, $t1, 128
	bne	$t2, 7, DrawVertEdges2
	
	
Cleanup:				#Fixes the remaining bits
	la	$t1, 0xFFFF0008
	li	$t0, 0xA
	sb	$t0, 0($t1)
	la	$t1, 0xFFFF0018
	li	$t0, 0x0
	sb	$t0, 0($t1)
	la	$t1, 0xFFFF0017
	li	$t0, 0xAA
	sb	$t0, 0($t1)
	la	$t1, 0xFFFF03F8
	li	$t0, 0xAA
	sb	$t0, 0($t1)
	la	$t1, 0xFFFF0407
	li	$t0, 0xA0
	sb	$t0, 0($t1)
	
	li	$t0, 0
	li	$t1, 0
	li	$t2, 0
	li	$t3, 0
	li	$t4, 0		#map setup is now complete
	

	li	$v0, 30		#gets the initial clock time
	syscall
	add	$s7, $zero, $a0


playerStart:			#initializes player and zombies, creates the basic leds
	li	$a0, 0
	li	$a1, 0
	li	$a2, 3
	jal	_setLED
	la	$s0, zombie_loc
	lbu	$a0, 0($s0)
	lbu	$a1, 1($s0)
	li	$a2, 1
	jal	_setLED
	lbu	$a0, 2($s0)
	lbu	$a1, 3($s0)
	li	$a2, 1
	jal	_setLED
	lbu	$a0, 4($s0)
	lbu	$a1, 5($s0)
	li	$a2, 1
	jal	_setLED
	lbu	$a0, 6($s0)
	lbu	$a1, 7($s0)
	li	$a2, 1
	jal	_setLED
	add	$s0, $zero, $zero

	
poll:
	li	$v0, 30
	syscall
	subu	$s5, $a0, $s7
	bgt	$s5, 500, moveZombie
		la	$v0, 0xffff0000		# address for reading key press status
	la	$s1, player
	li	$t4, 0				#sets up to run checklose 4 times
	lw	$s2, 0($s1)
	lw	$s3, 4($s1)
	la	$t0, zombie_loc
checkSafe:
	lbu	$t1, 0($t0)
	lbu	$t2, 1($t0)
	addi	$t0, $t0, 2
	addi	$t4, $t4, 1
	bne	$t1, $s2, again
	beq	$t2, $s3, gameOver	
again:	bne	$t4, 4, checkSafe
safe:
checkWin:
	bne	$s2, 63, continue
	beq	$s3, 63, victory
continue:
	lw	$t0, 0($v0)		# read the key press status
	andi	$t0, $t0, 1
	beq	$t0, $0, poll		# no key pressed
	addi	$v1, $v1, 1		#adds 1 to the number of moves
	lw	$t0, 4($v0)		# read key value
lkey:	addi	$v0, $t0, -0xE2		# check for left key press
	bne	$v0, $0, rkey		# wasn't left key, so try right key
	j	moveLeft		

rkey:	addi	$v0,$t0, -0xE3		# check for right key press
	bne	$v0,$0, ukey		# wasn't right key, so try up key
	j	moveRight		#

ukey:	addi	$v0, $t0, -0xE0		# check for left key press
	bne	$v0, $0, dkey		# wasn't up key, so try down key
	j	moveUp			

dkey:	addi	$v0,$t0, -0xE1		# check for right key press
	bne	$v0,$0, poll		# wasn't right key, so check for center
	j	moveDown		


	
moveLeft:
	addi	$s2, $s2, -1
	blt	$s2, 0, poll		#resets s2 and returns to polling if invalid
	add	$a0, $s2, $zero
	add	$a1, $s3, $zero
	li	$a2, 3
	
	jal	_getLED		#returns to polling if move is invalid
	beq	$v0, 2, poll
	
	jal	_setLED
	addi	$a0, $s2, 1
	li	$a2, 0
	jal	_setLED
	
	sw	$s2, 0($s1)
	j	poll
	
moveRight:
	addi	$s2, $s2, 1
	bgt	$s2, 63, poll
	add	$a0, $s2, $zero
	add	$a1, $s3, $zero
	li	$a2, 3
	
	jal	_getLED
	beq	$v0, 2, poll
	
	jal	_setLED
	addi	$a0, $s2, -1
	li	$a2, 0
	jal	_setLED
	
	sw	$s2, 0($s1)
	j	poll
	
moveUp:
	addi	$s3, $s3, -1
	blt	$s3, 0, poll
	add	$a0, $s2, $zero
	add	$a1, $s3, $zero
	li	$a2, 3
	
	jal	_getLED
	beq	$v0, 2, poll
	
	jal	_setLED
	addi	$a1, $s3, 1
	li	$a2, 0
	jal	_setLED

	sw	$s3, 4($s1)
	j	poll
	
moveDown:
	addi	$s3, $s3, 1
	bgt	$s3, 63, poll
	add	$a0, $s2, $zero
	add	$a1, $s3, $zero
	li	$a2, 3
	
	jal	_getLED
	beq	$v0, 2, poll
	
	jal	_setLED
	addi	$a1, $s3, -1
	li	$a2, 0
	jal	_setLED
	
	sw	$s3, 4($s1)
	j	poll
	
moveZombie:
	addi	$s7, $s7, 500			#moves the timer forward 500 ms
	li	$a2, 1				#sets color to red	
	la	$s1, zombie_loc
	la	$s4, prevzombie_loc		#for backtracking the zombie

	moveZombie_part2:	
	lbu	$a0, 0($s1)
	lbu	$a1, 1($s1)
	beq	$a0, 31, backtrack		#these check if the zombie needs to backtrack
	beq	$a0, 32, backtrack
	beq	$a1, 31, backtrack
	beq	$a1, 32, backtrack


	bgt	$a0, 31, quadRight		#this checks if the zombie and player are in same coord
quadLeft:
	bgt	$a1, 31, quad3
	j	quad1
quadRight:
	bgt	$a1, 31, quad4
	j	quad2
quad1:	addi	$t1, $zero, 0
	j	affirmation
quad2:	addi	$t1,$zero, 1
	j	affirmation
quad3:	addi	$t1, $zero, 2
	j	affirmation
quad4:	addi	$t1, $zero, 3
affirmation:
	#beq	$t1, $s6, smartMove		#this code is what starts intelligent zombie tracking. The zombie will follow but
						#it causes the zombies to occasionally backtrack and freeze the program.
	j	moveZombie_part3		#this jumps to zombieMove
	
backtrack:
	li	$a2, 0
	jal	_setLED
	li	$a2, 1
	lbu	$a0, 0($s4)
	lbu	$a1, 1($s4)
	jal	_setLED
	
	lbu	$s2, 0($s1)
	lbu	$s3, 1($s1)
	sb	$s2, 0($s4)
	sb	$s3, 1($s4)
	sb	$a0, 0($s1)
	sb	$a1, 1($s1)

	addi	$s1, $s1, 2			#moves the address in the zombie array to the next one
	addi	$s4, $s4, 2
	addi	$s6, $s6, 1
	
	bne	$s6, 4, moveZombie_part2	#checks whether or not all the zombies have moved
	j	finishedMoving
	moveZombie_part3:
		li	$a1, 4
		li	$v0, 42
		syscall
		add	$s5, $zero, $a0
	zombieUp:	bne	$s5, 0, zombieDown
	smartUp:
		lbu	$a0, 0($s1)
		lbu	$a1, 1($s1)
		addi	$a1, $a1, -1
		blt	$a1, 0, moveZombie_part3
		jal	_getLED
		lbu	$t0, 0($s4)
		lbu	$t1, 1($s4)
		beq	$v0, 2, moveZombie_part3
		beq	$t1, $a1, moveZombie_part3
		
		jal	_setLED
		sb	$a1, 1($s1)
		addi	$a1, $a1, 1
		sb	$a1, 1($s4)
		sb	$a0, 0($s4)
		li	$a2, 0
		jal	_setLED
		li	$a2, 1
		addi	$s1, $s1, 2
		addi	$s4, $s4, 2
		addi	$s6, $s6, 1
		bne	$s6, 4, moveZombie_part2
		j	finishedMoving
	zombieDown:	bne	$s5, 1, zombieLeft
	smartDown:
		lbu	$a0, 0($s1)
		lbu	$a1, 1($s1)
		addi	$a1, $a1, 1
		bgt	$a1, 63, moveZombie_part3
		jal	_getLED
		lbu	$t0, 0($s4)
		lbu	$t1, 1($s4)
		beq	$v0, 2, moveZombie_part3
		beq	$t1, $a1, moveZombie_part3
		jal	_setLED
		sb	$a1, 1($s1)
		addi	$a1, $a1, -1
		sb	$a1, 1($s4)
		sb	$a0, 0($s4)
		li	$a2, 0
		jal	_setLED
		li	$a2, 1
		addi	$s1, $s1, 2
		addi	$s4, $s4, 2
		addi	$s6, $s6, 1
		bne	$s6, 4, moveZombie_part2
		j	finishedMoving
	zombieLeft:	bne	$s5, 2, zombieRight
	smartLeft:
		lbu	$a0, 0($s1)
		lbu	$a1, 1($s1)
		addi	$a0, $a0, -1
		jal	_getLED
		blt	$a0, 0, moveZombie_part3
		lbu	$t0, 0($s4)
		lbu	$t1, 1($s4)
		beq	$v0, 2, moveZombie_part3
		beq	$t0, $a0, moveZombie_part3
		jal	_setLED
		sb	$a0, 0($s1)
		addi	$a0, $a0, 1
		sb	$a0, 0($s4)
		sb	$a1, 1($s4)
		li	$a2, 0
		jal	_setLED
		li	$a2, 1
		addi	$s1, $s1, 2
		addi	$s4, $s4, 2
		addi	$s6, $s6, 1
		bne	$s6, 4, moveZombie_part2
		j	finishedMoving
	zombieRight:
	smartRight:
		lbu	$a0, 0($s1)
		lbu	$a1, 1($s1)
		addi	$a0, $a0, 1
		bgt	$a0, 63, moveZombie_part3
		jal	_getLED
		lbu	$t0, 0($s4)
		lbu	$t1, 1($s4)
		beq	$v0, 2, moveZombie_part3
		beq	$t0, $a0, moveZombie_part3
		jal	_setLED
		sb	$a0, 0($s1)
		addi	$a0, $a0, -1
		sb	$a0, 0($s4)
		sb	$a1, 1($s4)
		li	$a2, 0
		jal	_setLED
		li	$a2, 1
		addi	$s1, $s1, 2
		addi	$s4, $s4, 2
		addi	$s6, $s6, 1
		bne	$s6, 4, moveZombie_part2
		j	finishedMoving

smartMove:	
		la	$t0, smartAddresses	#saves the addresses the zombie location and previous zombie location are at
		blt	$a0, 0, moveZombie_part3
		bgt	$a0, 63, moveZombie_part3
		blt	$a1, 0, moveZombie_part3
		bgt	$a1, 63, moveZombie_part3
		sw	$s1, 0($t0)
		sw	$s4, 4($t0)
		lbu	$a0, 0($s1)		#acquires player and zombie location
		lbu	$a1, 1($s1)
		la	$s0, player
		lw	$s1, 0($s0)
		lw	$s2, 4($s0)
		
		subu	$s3, $s1, $a0		#finds the distance from zombie to player
		subu	$s4, $s2, $a1
		mul	$s3, $s3, $s3
		mul	$s4, $s4, $s4
		add	$s3, $s3, $s4
		
		addi	$a0, $a0, -1		#checks if left is closer
		jal	_getLED			#checks if move is illegal
		la	$t0, prevzombie_loc
		lbu	$t1, 0($t0)
		beq	$v0, 2, smartMove2	#checks if there is a wall
		beq	$t1, $a0, smartMove2	#checks if it is backtracking
		subu	$s4, $s1, $a0
		subu	$s5, $s2, $a1
		mul	$s4, $s4, $s4
		mul	$s5, $s5, $s5
		add	$s4, $s4, $s5
		bgt	$s4, $s3, smartMove2
		
		la	$t0, smartAddresses	#loads the addresses the zombie location and previous zombie location are at
		lw	$s1, 0($t0)
		lw	$s4, 4($t0)
		j	smartLeft
	smartMove2:
		addi	$a0, $a0, 2		#checks if right is closer
		jal	_getLED			#checks if move is illegal
		la	$t0, prevzombie_loc
		lbu	$t1, 0($t0)
		beq	$v0, 2, smartMove3
		beq	$t1, $a0, smartMove3
		subu	$s4, $s1, $a0
		subu	$s5, $s2, $a1
		mul	$s4, $s4, $s4
		mul	$s5, $s5, $s5
		add	$s4, $s4, $s5
		bgt	$s4, $s3, smartMove3
		
		la	$t0, smartAddresses	#loads the addresses the zombie location and previous zombie location are at
		lw	$s1, 0($t0)
		lw	$s4, 4($t0)
		j	smartRight
	smartMove3:
		addi	$a1, $a1, -1		#checks if up is closer
		addi	$a0, $a0, -1
		jal	_getLED			#checks if move is illegal
		la	$t0, prevzombie_loc
		lbu	$t1, 1($t0)
		beq	$v0, 2, smartMove4
		beq	$t1, $a1, smartMove4
		subu	$s4, $s1, $a0
		subu	$s5, $s2, $a1
		mul	$s4, $s4, $s4
		mul	$s5, $s5, $s5
		add	$s4, $s4, $s5
		bgt	$s4, $s3, smartMove4
		
		la	$t0, smartAddresses	#loads the addresses the zombie location and previous zombie location are at
		lw	$s1, 0($t0)
		lw	$s4, 4($t0)
		j	smartUp
	smartMove4:
		addi	$a1, $a1, 2		#checks if down is closer
		sw	$s1, 0($t0)		#saves the current address that the zombie info is cycling through.
		sw	$s4, 4($t0)
		jal	_getLED			#checks if move is illegal
		la	$t0, prevzombie_loc
		lbu	$t1, 1($t0)
		beq	$v0, 2, normal_move
		beq	$t1, $a1, normal_move
		subu	$s4, $s1, $a0
		subu	$s5, $s2, $a1
		mul	$s4, $s4, $s4
		mul	$s5, $s5, $s5
		add	$s4, $s4, $s5
		bgt	$s4, $s3, normal_move
		
		la	$t0, smartAddresses	#loads the addresses the zombie location and previous zombie location are at
		lw	$s1, 0($t0)
		lw	$s4, 4($t0)
		j	smartDown
		
normal_move:
	la	$t0, smartAddresses	#loads the addresses the zombie location and previous zombie location are at
		lw	$s1, 0($t0)
		lw	$s4, 4($t0)
	j	moveZombie_part3
finishedMoving:
	li	$s6, 0
	
	j	poll
	
		# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=yellow, 3=green
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color
	# trashes:   $t0-$t3
	# returns:   non
	#
	
gameOver:
	la	$a0, defeat
	li	$v0, 4
	syscall
	
	li	$v0, 10
	syscall
	
victory:
	la	$a0, winner
	li	$v0, 4
	syscall
	
	add	$a0, $v1, $zero
	li	$v0, 1
	syscall
	
	la	$a0, moves
	li	$v0, 4
	syscall
	
	li	$v0, 10
	syscall
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008 # base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra
	
	# int _getLED(int x, int y)
	#   returns the value of the LED at position (x,y)
	#
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2 or 3)
	#
_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra
