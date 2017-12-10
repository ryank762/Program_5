; ISR.asm
; Name: Ryan Junguk Kim
; UTEid: jk39938
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x2600
               .ORIG x2500
; save regs
	ST	R0, SAVER0
	ST	R1, SAVER1
; initializes R0 to struck key
	LDI	R0, KBDR
;
	LD	R1, COMP_A
	ADD	R1, R0, R1
	BRz	VALID_KEY	;branches if R0 contains A
;
	LD	R1, COMP_U
	ADD	R1, R0, R1
	BRz	VALID_KEY	;branches if R0 contains U
;
	LD	R1, COMP_G
	ADD	R1, R0, R1
	BRz	VALID_KEY	;branches if R0 contains G
;
	LD	R1, COMP_C
	ADD	R1, R0, R1
	BRz	VALID_KEY	;branches if R0 contains C
;
	BR	RESTORE		;since no valid key was struck, returns to the main program without changes
VALID_KEY
	STI	R0, SYMB	;stores A,U,G,C into x2600, where the main program can read access it
; restore regs	
RESTORE
	LD	R0, SAVER0
	LD	R1, SAVER1
	RTI			;returns to main program as if nothing had happened
;local variables and constants
SAVER0	.BLKW	1
SAVER1	.BLKW	1
COMP_A	.FILL	x-41
COMP_U	.FILL	x-75
COMP_G	.FILL	x-47
COMP_C	.FILL	x-43
SYMB	.FILL	x2600
KBDR	.FILL	xFE02
		.END
