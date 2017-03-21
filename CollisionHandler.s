/Marios movement value in r1
//Object collided with in r2
//This method should check what kind of collision has occured. If it is with a question box,
//the question box needs to change to a brick box and mario is pushed back to his old location
//If it is with a brick then mario is moved back his movement amount. If it is with a goomba, 
//from the side, mario dies. If it is with a goomba from above, Mario kills the goomba, if it
//is a collision with ground, Mario is not moved NOT DONE
.globl CollisionHandler
CollisionHandler:
		push    {r4,    r10,    lr}
       
		cmp	r2, #0b00010
		beq	goombaHandler
		
		cmp	r2, #0b00011
		beq	questionBoxHandler

		cmp 	r2, #0b00100
		beq	woodenBlockHandler
		cmp 	r2, #0b00101
		beq	woodenBlockHandler
		cmp 	r2, #0b00110
		beq	woodenBlockHandler
		cmp 	r2, #0b00111
		beq	woodenBlockHandler
		
		cmp	r2, #0b01000
		beq	pipeHandler
		
		cmp	r2, #0b01001
		beq	holeHandler
		
goombaHandler:

	mov r1, r4
	mov r2, r1
	bl Grab
	
	ldr r5, [r0], #4
	ldr r6, [r0]		//load in top left point of goomba
	
	mov r2, #0b00001
	bl Grab
	
	ldr r9, [r0, #24]
	ldr r10, [r0, #28]	//load bottom right point of Mario_loc
	
	mov r2, #0b00000
	bl Grab
	
	ldr r7, [r0, #24]
	ldr r8, [r0, #28]	//load bottom right point of Mario_Temp

	cmp r8, r10
	bgt	killMario
		
	cmp r6, r8
	bge killGoomba
	
	b killMario
	
killGoomba:
	mov r1, #0b00010
	bl Grab
	
	ldr r0, [r0], #4
	ldr r1, [r0], #4
	ldr r2, [r0], #4
	ldr r3, [r0], #4
	
	ldr r4, =blank
	bl CreateImage		//draw blank over the goomba
	
	mov r1, #0b00010
	bl Grab
	
	mov r0, #-1
	mov r1, #-1
	mov r2, #-1
	mov r3, #-1
	
	str r0, [r0], #4
	str r1, [r0], #4
	str r2, [r0], #4
	str r3, [r0], #4		//move goomba coordinates outside of screen so that a collision can't occur again
	
	b incScore

questionBlockHandler:

	mov r1, r4
	mov r2, r1
	bl Grab
	ldr r11, [r0]
	ldr r12, [r0, #4]		//load in top left point of Question Block
	ldr r5, [r0,#24]
	ldr r6, [r0,#28]		//load in bottom right point of Question Block
	
	mov r2, #0b00001
	bl Grab
	
	ldr r9, [r0],	 #4
	ldr r10, [r0]		//load top left point of Mario_loc
	ldr r1, [r0, #24]
	ldr r2, [r0, #28]	//load bottom right point of Mario_loc
	
	mov r2, #0b00000
	bl Grab
	
	ldr r7, [r0]
	ldr r8, [r0,#4]	//load top left point of Mario_Temp
	cmp r8, r10
	bgt exit
	
	cmp r12, r2		//check if the TL point of the question block is greater than or equal
	bge exit			//to the BR point of mario, if >= then do nothing.
	
destroyQuesBlock:

 

woodenBlockHandler:


pipeHandler:


holeHandler:
		

killMario:

incScore:

exit:
		pop     {r4,    r10,    lr}
      bx      lr