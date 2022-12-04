# util.asm - Output Subroutines
#
# PrintHexByte - Print AL in hexadecimal
# PrintHexWord - Print 64 bit (8 byte) word in hexadecimal
# PrintWordB10 - Print 64 bit word as unsigned base 10 decimal number
# ------------------------------------------------------------

.globl	PrintHexByte, PrintHexWord, PrintWordB10

.section	.text

#--------------------------------------------------------------
#  Print HEX value of byte
#  Input:   AL byte to print
#  Output:  none
#--------------------------------------------------------------
PrintHexByte:
	push	%rax		/* preserve for exit */
	push	%rax		/* save for second nibble */
#
#  First print MS nibble
#
	and	$0x0F0, %al	/* Get first nibble */
	shr	$0x004, %al	/* Shift 4 bits to align nibble */
	cmp	$0x09, %al	/* Number or A-F? */
	jg	PrintHexByte1  	/* It's A-F branch */
	orb	$0x30, %al	/* Form ASCII 0-9 */
	jmp	PrintHexBtye2	/* Always taken */
PrintHexByte1:
	sub	$0x09, %al  	/* Adjust and */
	orb	$0x40, %al	/* form ASCII A-F */
PrintHexBtye2:
	call	CharOut		/* output character */
#
# Then print L.S. Nibble
#
	pop	%rax    	/* get L.S. Nibble */
	and	$0x0f, %al	/* Mask to first nibble */
	cmp	$0x09, %al	/* Number or A-F? */
	jg	PrintHexByte3	/* It's A-F branch */
	or	$0x30, %al	/* Else make ASCII */
	jmp	PrintHexByte4	/* Always taken  */
PrintHexByte3:
	sub	$0x09, %al	/* Adjust and */
	or	$0x40, %al	/* and for ASCII */
PrintHexByte4:
	call	CharOut		/* Output character  */
	pop	%rax		/* register preserved */
	ret

#--------------------------------------------------------------
#  Print HEX value of 64 bit word
#  Input:   RAX 64 bit word to print
#  Output:  none
#--------------------------------------------------------------
PrintHexWord:
	push	%rax
	push	%rbx
	push	%rcx
	push	%rdx
	mov 	$16, %rdx	/* Count to print 16 nibbles (4 bit) */
	mov	   %rax, %rbx	/* Save original word in RBX */
PrintHexWord1:
	mov	%rbx, %rax	/* Get un-rotated word */
	mov	%rdx, %rcx	/* Set rotation counter */
	dec	%rcx		/* Print 16 nibbles, only 15 need rotation */
	jz	PrintHexWord3	/* Last nibble, don't rotate */
PrintHexWord2:
	shr	$4, %rax	/* Rotate until nibble in place */
	loop	PrintHexWord2	/* Decrement RCX and loop until done */
PrintHexWord3:
	and	$0x0F, %rax	/* Get first nibble by ANDing other bits */
	cmp	$0x09, %al	/* Number or A-F? */
	jg	PrintHexWord4 	/* It's A-F branch */
	or	$0x30, %al	/* Form ASCII 0-9 */
	jmp	PrintHexWord5   /* always taken */
PrintHexWord4:
	sub	$0x09, %al	/* Adjust and */
	or	$0x40, %al  	/* form ASCII A-F */
PrintHexWord5:
    call	CharOut		/* Output character */
	dec     %rdx		/* one less nibble next time */
	jg      PrintHexWord1	/* Loop back until all 4 bit nibbles printed */
	pop     %rdx
	pop     %rcx
	pop     %rbx
	pop     %rax
	ret

#------------------------------------------------------------------------------------
#  Function  PrintWordB10rax
#  Input:   RAX  positive unsigned integer
#  Output:  text send to CharOut
#  All 64 bits may be printed from 0 to 18446744073709551615 (1.844E+19)
#------------------------------------------------------------------------------------
PrintWordB10:

	push	%rax		/* For DIV command */
	push	%rbx		/* For DIV command */
	push	%rcx		/* Loop Counter */
	push	%rdx		/* For DIV command */
	push	%rsi		/* Power of 10 counter */
	push	%rdi		/* Holds original number */
	push	%rbp		/* For DIV command */
	mov	%rax, %rdi	/* Original Number */

	/* Part 1 of 2, First divide by powers of 10 in inreasing order,
	such as 1, 10, 100, 1000, 10000. Count the number base 10 digits
	by dividing by 10 with a counter until the quotient is zero. */

	/* an unsigned 64 bit integer can be up to 20 digits in base 10 */
	mov	$20, %rcx	/* Loop counter */
	mov	$1, %rsi	/* Counter */
	mov	$1, %rbx	/* RBX Holds power of 10 */
PrintWordB101:
	xor	%rdx, %rdx	/* RDX = 0 */
	mov	%rdi, %rax	/* Get number */
	div     %rbx		/* RAX = RDX:RAX/RBX RDX = Remainder */
	cmp     $10, %rax	/* Is result of division less than 10? */
	jc      PrintWordB102	/* Yes, less than 10, done counting */
	shl	$1, %rbx	/* X 2 */
	mov	%rbx, %rax	/* Save X 2 value */
	shl	$2, %rbx	/* X 2 X 2 --> X 8 */
	add	%rax, %rbx	/* Add (_X8) + (_X2) = ( _X10) */
	inc	%rsi		/* Increment digit counter */
	loop	PrintWordB101			;

	/* Error handler, loop counter too high, something is broken */

	lea	PrintWordB10ErrStr, %rax
	call	StrOut		/* Print error message */
	jmp	exit_program	/* and quit program */

PrintWordB102:

  	/* Part 2 of 2 - Using the digit count, and the highest power of 10,
	next divide by decreasing powers of 10 in a loop, such as 10000, 1000, 100, 10, 1.
	Keep the remainder for the next loop, then print the quotient.
	Form the ASCII digits at each loop by taking the binary value in the range of 0-9
	and adding an integer value (bitwise AND) to get the correct ASCII code. */

	mov	%rsi, %rcx	/* Counter */
PrintWordB103:
	xor	%rdx, %rdx	/* RDX = 0 */
	mov	%rdi, %rax	/* Original number, or remainder in later terms */
	div	%rbx		/* DIV by power of 10, RAX = RDX:RAX / RBX , Remainder = RDX */
	mov	%rdx, %rdi	/* Remainder for next time */
	and	$0x0f, %rax
	or	$0x030, %rax	/* Form ascii */
	call	CharOut		/* Output character */
	xor	%rdx, %rdx	/* RDX = 0 */
	mov	%rbx, %rax	/* last power of 10 */
	mov	$10, %rbp	/* for DIV command */
	div	%rbp		/* Reduce 1 power of 10 RAX = RDX:rax / 10 */
	mov	%rax, %rbx	/* Save next power of 10 */
	loop	PrintWordB103

PrintWordB104:
	pop	%rbp
	pop	%rdi
	pop	%rsi
	pop	%rdx
	pop	%rcx
	pop	%rbx
	pop 	%rax
	ret

.section .data

PrintWordB10ErrStr:
	.asciz	"\nPrintWordB10 - Error, no exit from loop"


