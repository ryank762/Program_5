; Main.asm
; Name: Ryan Junguk Kim
; UTEid: jk39938
; Continuously reads from x2600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
               .ORIG x3000
; initialize the stack pointer
	LD	R6, STACK
; set up the keyboard interrupt vector table entry
	LD	R0, KBISR
	STI	R0, KBIVE
; enable keyboard interrupts
	LD	R0, KBINT
	STI	R0, KBSR
; start of actual program

; checking for start codon
STATE_x
	JSR	CHECK_SYMB
STATE_A
	HALT
;
CHECK_SYMB
;
; Inputs: 	None
; Outputs:	R0, containing valid character to be printed
;		R1 [A=0, U=1, G=2, C=3]
;
; save regs
	ST	R7, SAVER7
	LDI	R0, SYMB	;initializes R0 to m[x2600]
	ADD	R0, R0, #0	;setting conditional bits
	BRz	CHECK_SYMB	;checks continuously until x2600 contains nonzero data
	LD	R1, ZERO
	STI	R1, SYMB	;clears x2600
;
	LD	R1, COMP_A
	ADD	R1, R0, R1
	BRnp	CHECK_U
	AND	R1, R1, #0
	BR	CHECK_SYMB_DONE
;
CHECK_U
	LD	R1, COMP_U
	ADD	R1, R0, R1
	BRnp	CHECK_G
	AND	R1, R1, #0
	ADD	R1, R1, #1
	BR	CHECK_SYMB_DONE
;
CHECK_G
	LD	R1, COMP_G
	ADD	R1, R0, R1
	BRnp	CHECK_C
	AND	R1, R1, #0
	ADD	R1, R1, #2
	BR	CHECK_SYMB_DONE
;
CHECK_C
	AND	R1, R1, #0
	ADD	R1, R1, #3
;
CHECK_SYMB_DONE
	
; restore regs
	LD	R1, SAVER1
	LD	R7, SAVER7
	RET	
;

SAVER1	.BLKW	1
SAVER7	.BLKW	1
STACK	.FILL	x4000
KBSR	.FILL	xFE00
KBINT	.FILL	x4000
KBIVE	.FILL	x0180
KBISR	.FILL	x2500
COMP_A	.FILL	x-41
COMP_U	.FILL	x-75
COMP_G	.FILL	x-47
COMP_C	.FILL	x-43
ZERO	.FILL	x0000		;used to clear I/O registers
SYMB	.FILL	x2600		;contains struck key if valid (checked by ISR)
		.END
