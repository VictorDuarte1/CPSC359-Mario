
.global DrawSquare
.global DrawCharacter

DrawSquare:

push {r5 -r10, lr}
mov     r5, r0
mov     r6, r1
mov     r2, r8
mov     r4, r9

mov r7, r3

loop:

ldrh r2,[r7,#2]!

mov     r0,     r5
mov     r1,     r6
bl DrawPixel
add     r5,     #1
cmp     r5,     r8
blt     loop
mov     r5,     #0
add     r6,     #1
cmp r1, r9
blt     loop


pop { r4 - r10, lr}
bx      lr

//=================================================================================

DrawPixel:
	push	{r4 - r10}




	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4 - r10}
	bx		lr

//=================================================================================

/* Draw the character 'B' to (0,0)
 */
DrawCharB:
	push	{r4-r8, lr}

	chAdr	.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask	.req	r8

	ldr		chAdr,	=font		// load the address of the font map
	mov		r0,		#'B'		// load the character into r0
	add		chAdr,	r0, lsl #4	// char address = font base + (char * 16)

	mov		py,		#0			// init the Y coordinate (pixel coordinate)

charLoop$:
	mov		px,		#0			// init the X coordinate

	mov		mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		// test row byte against the bitmask
	beq		noPixel$

	mov		r0,		px
	mov		r1,		py
	mov		r2,		#0xF800		// red
	bl		DrawPixel			// draw red pixel at (px, py)

noPixel$:
	add		px,		#1			// increment x coordinate by 1
	lsl		mask,	#1			// shift bitmask left by 1

	tst		mask,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py,		#1			// increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r8, pc}
