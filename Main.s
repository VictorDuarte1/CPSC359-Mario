//Assignment 4 Main

//Assignment3 -SNES CONTROLLER DEVICE DRIVER- James Gilders, Nantong Dai
        //James Gilders 10062731 Jamesapaloosa1@gmail.com
        //Nantong Dai dainantong0@gmail.com
        //Victor Duarte
        //Version Mar.06,13:03-J

.section    .init
.globl     _start

_start:
    b       main
    
.section .text

        .equ            Latch, 9
        .equ            Data,   10
        .equ            Clock,  11
        .equ            GPIOSRC,  0X3f200000
        .equ            NotPressed, 4095

//Function Select Values:
//Input = 000, Output = 001, Alt 0 = 100, Alt 1 = 101, Alt 2 = 110, Alt 3 = 111, Alt4 = 011, Alt5 = 010
//0X3F000000 is the address for the GPIO 
//choose what to do by loading the register with the correct value in the appropriate 3 values
//============================================================================
main:
                mov     	sp, #0x8000
	        bl		EnableJTAG
                bl              InitUART
	        bl		InitFrameBuffer
        //Print Creators here

                ldr     r0,     =Creators
                mov     r1,     #55
                bl      WriteStringUART


       //Initialize pins for GPIO
                
                mov     r0,     #Latch          //Put the Latch in r0
                mov     r1,     #1
                bl      Init_GPIO
                
                mov     r0,     #Data
                mov     r1,     #0
                bl      Init_GPIO

                mov     r0,     #Clock
                mov     r1,     #1                
                bl      Init_GPIO


//Initialize button state and Exit state
                mov     r9,     #0
                mov     r5,     r9
                mov     r10,   #0

//Prompt for input

Prompt:         ldr     r0,     =Request
                mov     r1,     #26
                bl      WriteStringUART
                mov     r9,     r5


//SNES Input
PostPrompt:     bl      Read_SNES
                mov     r5,     r0
                bl      ButtonCheck
                mov     r8,     r1
                cmp     r9,     r5
                beq     PostPrompt      
                mov     r10,    r0
//This code executes when a button is actually pressed
B_Pressed:
                mov     r0,     r5
                bl      Print_message

                cmp     r8,     #0
                moveq   r9,     r5

		beq	PostPrompt

//Jumps to begining of menu loop after a button is pressed
                cmp     r10,   #1
                bne     Prompt
//loop that runs after the program is exited
haltLoop$:
                b       haltLoop$
                

//============================================================================
//Init GPIO: initializes a GPIO line, the line number and function code are passed as parameters.
//R0 is the input pin
//r1 is input desired function
//Initializes the GPIO line at the location specified in r0 when called
Init_GPIO:      
                
                push    {r4-r10, lr}

	        

                ldr     r3,     =GPIOSRC
                mov     r4,     r0
                mov     r5,     #0

ChoosePin:      cmp     r4,     #9                      //loop fetches the appropriate GPIO line 
                subgt   r4,     #10                     //for every time ten is subed, we add 1 to the GPIOline we need
                addgt   r5,     #1
                bgt     ChoosePin                       

                add     r3,     r5,     lsl#2           //This actually fetches the address of the GPIO line needed
                add     r4,     r4,     r4,     lsl#1
                lsl     r1,     r4

                ldr     r6,     [r3]                    //Grabs the particular GPIOline and puts that into r6 to be used
                mov     r7,     #7                      //Bitmask to be used to manipulate the action for the Pin
                lsl     r7,     r4
                bic     r6,     r7
                orr     r6,     r1
                str     r6,     [r3]                    //Store the desired function in the pin spot on the GPIO line
                
                
                pop     {r4-r10, lr}
                bx      lr
//============================================================================
//Write_Latch: writes a bit to the GPIO Latch line CHECKED
//Pin number is input r0
//Function desired is r1

Write_Latch:   
                push    {r4-r10, lr}
                
                mov     r0,	#Latch
                ldr	r2,	=GPIOSRC
                mov     r3,     #1
                lsl     r3,     r0
                teq     r1,     #0
                streq   r3,     [r2, #40]
                strne   r3,     [r2, #28]

                pop     {r4-r10, lr}
                bx      lr 
//============================================================================
//Write_Clock: Writes a value to the GPIO Clock line CHECKED
//Pin number is input r0
//Function desired is r1

Write_Clock:   
                push    {r4-r10, lr}
                mov     r0,    #Clock
                ldr     r2,     =GPIOSRC
                mov     r3,     #1
                lsl     r3,     r0
                teq     r1,     #0
                streq   r3,     [r2, #40]
                strne   r3,     [r2, #28]

                pop     {r4-r10, lr}
                bx      lr 
//============================================================================
//Read_Data: reads a bit from the GPIO data line 
//Jumps to a particular gpio line representing the input from the SNES and fetches the value there
Read_Data:
                push    {r4-r10, lr}
                
                mov     r0,     #Data
                ldr     r2,     =GPIOSRC
                ldr     r1,     [r2, #52]

                mov     r3,     #1
                lsl     r3,     r0
                and     r1,     r3
                teq     r1,     #0
                moveq   r2,     #0
                movne   r2,     #1
                      
                pop     {r4-r10,lr}
                bx      lr
//============================================================================
//Wait: Waits for a time interval, passed as a parameter, r1 is the input wait time
Wait:
                push    {r4-r10, lr}
                ldr     r0, =0x3f003004
                ldr     r2,     [r0]
                add     r1,     r2                      //Time to wait is added to current time

Checktime:      ldr     r2,     [r0]                    //loop that decides if the desired amount of time was waited
                cmp     r1,     r2
                bhi     Checktime

                pop     {r4-r10, lr}
                bx      lr

//============================================================================
//Read_SNES: main SNES subroutine that reads input (buttons pressed) from a SNES controller. Returns the code of a 
//pressed button register.
Read_SNES:
	push	{r4-r10, lr}

//Create register aliases
	ButtonState     .req r4
	arguments       .req r1	
	index           .req r5
        ReturnVal       .req r2
	
//Section to initialize the clock and latch to the values they need to be before writting.

	mov	ButtonState,    #0
	mov	arguments,      #1
	bl	Write_Clock		
	mov	arguments,      #1
	bl	Write_Latch		
	mov	arguments,      #12
	bl	Wait			
	mov	arguments,      #0
	bl	Write_Latch		
	mov	index,          #0		

//Pulse loop to wait through each button and decide if a button at a particular location is pressed
	
pulseLoop:
	mov	arguments,      #6
	bl	Wait			
	mov	arguments,      #0
	bl 	Write_Clock		
	mov	arguments,      #6
	bl	Wait			
	bl	Read_Data		
	
	mov	r6,             ReturnVal
	orr	ButtonState,    r6	
	lsl	ButtonState,    #1      
	
	mov	arguments,      #1	                
	bl	Write_Clock	
	add	index,          #1	
	cmp	index,          #16	
	blt	pulseLoop		
	mov	r0,             ButtonState             //Return the button state by placing in r0 for use later
	

//Remove register aliases
	.unreq	arguments
	.unreq	index
	.unreq	ReturnVal

	pop	{r4-r10, lr}
	bx	lr


//============================================================================
//Section checks if a button is pressed by comparing to the number that will be in the
//register if none are pressed and then returns if the start button is pushed
ButtonCheck:
	push	{r4-r10, lr}

	mov	r3, r0			//load input into r3, this should be the current button state
	lsr	r3, #5			
	ldr	r2, =NotPressed		//load unpressed all buttons here
	cmp	r3, r2			//Compare with no buttons pressed here
	moveq	r1, #0			
	movne	r1, #1			
	
	lsr	r3, #8			
	ands	r3, #1			
	moveq	r0, #1			
	movne	r0, #0			

	pop	{r4-r10, lr}
	bx 	lr



//============================================================================
//This subroutine takes in the button state and decides if a button is pressed and then 
//prints the appropriate message to the screen using WriteStringUART subroutine
Print_message:  
	
	index .req r6
	Temp .req r5
        

	push	{r4-r9, lr}
	mov	ButtonState,    r0
	mov	index, #0		// counter to read the 12 buttons
	lsr	ButtonState,    #5	// shift the unneeded four bits out (13-16)
	
	ror	Temp,           ButtonState,      #12
	
read:
					add 	index, #1
					lsls	Temp, #1	//logical shift left and set flags
					bcc	cond
					bcs	read

//Section that takes the input for each button and decides if it is pushed
cond:
					mov r3, index
					
					cmp r3, #1
					beq B
					
					cmp r3, #2
					beq Y
					
					cmp r3, #3
					beq Select
					
					cmp r3, #4
					beq Start
					
					cmp r3, #5
					beq Up
					
					cmp r3, #6
					beq Down
					
					cmp r3, #7
					beq Left
					
					cmp r3, #8
					beq Right
					
					cmp r3, #9
					beq A
					
					cmp r3, #10
					beq X
					
					cmp r3, #11
					beq LeftShoulder
					
					cmp r3, #12
					beq RightShoulder
					
test:					cmp 	index,	 #12
					ble	read
					bgt	end
//Print statements for each button are here
//ButtonRight
Right:          

                ldr     r0,     =MarioXY
                
                ldr     r1,     [r0, #4]
                ldr     r4,     [r0]

                add     r4,     r4,     #15
                str     r4,     [r0]
                mov     r0,     r4

                ldr     r3,     =Blank
                
                bl      DrawSquare
                ldr     r0,     =MarioXY
                
                ldr     r1,     [r0, #4]
                ldr     r0,     [r0]

                add     r0,     r0

                ldr     r3,     =mario
                bl      DrawSquare
                b       test
                
//ButtonLeft
Left:           
                ldr     r0,     =MarioXY
                
                ldr     r1,     [r0, #4]
                ldr     r4,     [r0]

                sub     r4,     r4,     #15
                str     r4,     [r0]
                mov     r0,     r4

                ldr     r3,     =Blank
                
                bl      DrawSquare
                ldr     r0,     =MarioXY
                
                ldr     r1,     [r0, #4]
                ldr     r0,     [r0]

                add     r0,     r0

                ldr     r3,     =mario
                bl      DrawSquare
                b       test

//ButtonUp
Up:
                ldr     r0,     =PressUp
                mov     r1,     #29
                bl      WriteStringUART
                b       test

//ButtonDown
Down:
                ldr     r0,     =PressDown
                mov     r1,     #31
                bl      WriteStringUART
                b       test

//ButtonX
X:
                ldr     r0,     =PressX
                mov     r1,     #27
                bl      WriteStringUART
                b       test

//ButtonY
Y:
                ldr     r0,     =PressY
                mov     r1,     #27
                bl      WriteStringUART
                b       test

//ButtonA
A:
                ldr     r0,     =PressA
                mov     r1,     #27
                bl      WriteStringUART
                b       test

//ButtonB
B:
                ldr     r0,     =PressB
                mov     r1,     #27
                bl      WriteStringUART
                b       test

//ButtonStart
Start:
                ldr     r0,     =PressStart
                mov     r1,     #49
                mov     r10,   #1
                bl      WriteStringUART
                b       test
                

//ButtonSelect
Select:
                ldr     r0,     =PressSelect
                mov     r1,     #32
                bl      WriteStringUART
                b       test

//LeftShoulder
LeftShoulder:
		ldr 		r0,	=PressShoulderLeft
		mov 		r1,	#39
                bl      WriteStringUART
                b       test
					
//RightShoulder
RightShoulder:	
		ldr 		r0,	=PressShoulderRight
		mov		r1,	#40
                bl      WriteStringUART
                b       test


	
	.unreq	index
	.unreq	ButtonState
        .unreq  Temp

end:                                    pop     {r4-r9, lr}
                                        bx      lr
//=================================================================================

// Data section starts here
.section .data

MarioXY:  
                .int    0
                .int    0

.align 4
font:		.incbin	"font.bin"

        //Print Statements

Creators:       .ascii "Created by: Nantong Dai, Victor Duarte, James Gilders\n\r" //55                   

        //Control responses

Request:        .ascii "Please press a button...\n\r" //26

PressRight:     .ascii "You have pressed Joy-pad RIGHT\n\r" //32

PressLeft:      .ascii "You have pressed Joy-pad LEFT\n\r" //31

PressUp:        .ascii "You have pressed Joy-pad UP\n\r" //29

PressDown:      .ascii "You have pressed Joy-pad DOWN\n\r" //31

PressX:         .ascii "You have pressed X button\n\r" //27

PressY:         .ascii "You have pressed Y button\n\r" //27

PressA:         .ascii "You have pressed A button\n\r" //27

PressB:         .ascii "You have pressed B button\n\r" //27

PressStart:     .ascii "You have pressed Start button, program exiting.\n\r" //49

PressSelect:    .ascii "You have pressed Select button\n\r" //32

PressShoulderLeft:	.ascii "You have pressed Shoulder Left button\n\r" //39

PressShoulderRight:	.ascii "You have pressed Shoulder Right button\n\r" //40
