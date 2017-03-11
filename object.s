//pass in resolution of object as argument and location	i.e. 
					//(width in r0, height in r1, xCoorLeft in r2, yCoorUp in r3)

.globl	object
object:
.section .data
		.int	0
		.int	0
		.int	0
		.int	0

push	(r4-r10, lr)

xLeft 	.req 			r4				//left x coordinate for first object
xRight   .req 			r5				//right x coordinate for first object
yDown    .req 			r6				//Down y coordinate for first object
yUp	   .req 		 	r7				//up y coordinate for first object

	mov 	xLeft, r2				
	mov 	yUp, r3
	
	sub	r3,r3,r1
	mov	yDown, r3
	
	add	r0, r0, r2
	mov 	xRight, r0
	
	//store values into data section
	
pop (r4-r10,lr)
bx		lr
