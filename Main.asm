; Main.asm
; Name: Ryan Junguk Kim, James Lin
; UTEid: jk39938, jl62356
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
	TRAP	x21
	ADD	R1, R1, #0
	BRnp	STATE_x		;loops unless x2600 contains A
;
STATE_A
	JSR	CHECK_SYMB
	TRAP	x21
	ADD	R1, R1, #0
	BRz	STATE_A		;returns to A if x2600 contains A
	ADD	R1, R1, #-1
	BRz	STATE_AU	;goes to AU if x2600 contains U
	BR	STATE_x		;goes back to x if x2600 contains G,C
;
STATE_AU
	JSR	CHECK_SYMB
	TRAP	x21
	ADD	R1, R1, #0
	BRz	STATE_A		;goes back to A if x2600 contains A
	ADD	R1, R1, #-2
	BRz	STATE_AUG	;start codon AUG
	BR	STATE_x		;goes back to x if x2600 contains U,C
;
STATE_AUG
	LD	R0, PIPE
	TRAP	x21		;prints pipe to console
	JSR	CHECK_SYMB
	TRAP	x21
	ADD	R1, R1, #-1
	BRnp	STATE_AUG	;loops unless x2600 contains A
;
STATE_AUG_U
	JSR	CHECK_SYMB
	TRAP	x21
	ADD	R1, R1, #0
	BRz	STATE_AUG_UA	;goes to AUG_UA if x2600 contains A
	ADD	R1, R1, #-1
	BRz	STATE_AUG_U	;goes to AUG_U	if x2600 contains U
	ADD	R1, R1, #-1
	BRz	STATE_AUG_UG	;goes to AUG_UG if x2600 contains G
	BR	STATE_AUG	;returns to AUG if x2600 contains C
;
STATE_AUG_UA
	JSR	CHECK_SYMB
	TRAP	x21
	ADD	R1, R1, #0
	BRz	DONE		;stop codon UAA
	ADD	R1, R1, #-1
	BRz	STATE_AUG_U	;returns to AUG_U if x2600 contains U
	ADD	R1, R1, #-1
	BRz	DONE		;stop codon UAG
	BR	STATE_AUG	;returns to AUG if x2600 contains C
;
STATE_AUG_UG
	JSR	CHECK_SYMB
	TRAP	x21
	ADD	R1, R1, #0
	BRz	DONE		;stop codon UGA
	ADD	R1, R1, #-1
	BRz	STATE_AUG_U	;returns to AUG_U if x2600 contains U
	ADD	R1, R1, #-1
	BR	STATE_AUG	;returns to AUG if x2600 ontains G,C
DONE	HALT
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
COMP_U	.FILL	x-55
COMP_G	.FILL	x-47
COMP_C	.FILL	x-43
PIPE	.FILL	x7C
ZERO	.FILL	x0000		;used to clear I/O registers
SYMB	.FILL	x2600		;contains struck key if valid (checked by ISR)
		.END
