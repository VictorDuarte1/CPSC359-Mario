
.globl displayCheck

displayCheck:

push {r4-r9, lr}

//argument in r0, code for object to check if in range
bl Grab
x1 .req r0		//x of top left
y1 .req r1		//y of top left

x4 .req r2		//x of bottom right
y4 .req r3		//y of bottom right

r8 .req	screenXLeft
r9 .req	screenXRight


mov r5, =Screen_loc
bl Grab

ldr screenXLeft,	[r5], #4
ldr screenXRight, [r5]

cmp x4, screenXLeft
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