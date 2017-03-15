
.globl displayCheck

displayCheck:

push (r4-r9, lr)

//argument in r0, code for object to check if in range
bl Grab
x1 .req r0		//x of top left
y1 .req r1		//y of top left
x2	.req r2		//x of top right
y2 .req r3		//y of top right
x3 .req r4		//x of bottom left
y3 .req r5		//y of bottom left
x4 .req r6		//x of bottom right
y4 .req r7		//y of bottom right

r8 .req	screenXLeft
r9 .req	screenXRight


mov r2, //code for screen edges
bl Grab

mov screenXLeft,	//value of left edge of screen
mov screenXRight, //value of right edge of screen

cmp x2, screenXLeft
blt	notAllowed			//check if right x value of object is on left side of the left edge

cmp x1, screenXRight
bgt	notAllowed			//check if left x value of object is on the right side of the right edge

Allowed:
mov r0, #1			//return #1 if drawing is allowed 

b exit:
notAllowed:			
mov r0, #0			//return #0 if drawing is not allowed

exit:
pop (r4-r9, lr)
bx lr