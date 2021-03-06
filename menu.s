.section .text
.globl startMenu
	.equ	SEL, 0b110111111111
	.equ	START, 0b111011111111
	.equ	UP, 0b111101111111
	.equ	DOWN, 0b111110111111
	.equ	LEFT, 0b111111011111
	.equ	RIGHT, 0b111111101111
	.equ	A, 0b111111110111
startMenu:
	BUTTON .req r6		// contains the button pressed
	FLAG .req r5		// if flag is set, then start game. Else, quit game
	push	{r4-r10, lr}

	mov	FLAG, #1	// initialize main menu so that user is selecting start
	mov	r0, #0		// initial x
	mov	r1, #0		// initial y
	ldr	r2, =1023	// final x
	ldr	r3, =575	// final y
	ldr	r4, =menu_pic
	bl	CreateImage




menuloop:
	bl	getInput
	mov	BUTTON, r0
	
	mov	r0, BUTTON	// arg 1: the user input
	ldr	r1, =A		// arg 2: desired button
	bl	checkButton	// check if user pressed A
	cmp	r0, #1		
	beq	menuexit

	mov	r0, BUTTON	// arg 1: the user input
	ldr	r1, =UP		// arg 2: desired button
	bl	checkButton	// check if user pressed UP
	cmp	r0, #1		// check if the button matches		
	cmpeq	FLAG, #0	// checks if user is currently selecting 'quit game'
	moveq	FLAG, #1	// if so, selection is moved to 'start game'

	ldr	r0, =328	// initial x
	ldr	r1, =379	// initial y
	ldr	r2, =377	// final x
	ldr	r3, =428	// final y
	ldreq	r4, =selector
	bleq	CreateImage
	

	mov	r0, BUTTON	// arg 1: the user input
	ldr	r1, =DOWN	// arg 2: desired button
	bl	checkButton	// check if user pressed DOWN
	cmp	r0, #1		// if the button matches
	cmpeq	FLAG, #1	// checks if user is currenty selecting 'start game'
	moveq	FLAG, #0	// if so, selection is moved to 'quit game'

	ldr	r0, =328	// initial x
	ldr	r1, =479	// initial y
	ldr	r2, =377	// final x
	ldr	r3, =528	// final y
	ldreq	r4, =selector
	bleq	CreateImage
	

	b	menuloop



menuexit:
	mov	r0, FLAG
	pop	{r4-r10, lr}
	bx	lr

	.unreq	BUTTON
	.unreq	FLAG
