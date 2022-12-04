# -------------------------------------------
# Example GAS assembler program printing some 
# values in hexidecimal and base 10 decimal
# -------------------------------------------

.globl _start, exit_program

.section .text
_start:

	/* Print one character */

	lea	char_message, %rax
	call	StrOut			/* Print null terminated string */
	mov	$'M, %al		/* Character "M" */
	call	CharOut			/* Call function to print one character */
	call	CROut			/* Extra carriage return */

	/* Print Hello World */

	lea	str_message, %rax
	call	StrOut
	lea	hello_message, %rax	/* Call function to print a string */
	call	StrOut

	/* Print one byte in hexadecimal */

	lea	byte_message, %rax
	call	StrOut
	mov	$0x55, %rax
	call	PrintHexByte		/* Call function to print 1 byte in hexadecimal*/
	call	CROut

	/* Print one 64 bit word in hexadecimal */

	lea	word_message, %rax
	call	StrOut
	/* Addressing won't take 64 bit immediate value 
	   so the 64 bit value1 is declared as data below
	   and it contains 0x0123456788abcdef 64 bit value */
	mov	value1, %rax		/* rax = 0x0123456789ABCDEF */
	call	PrintHexWord		/* Print one 64 bit word in hexadecimal*/
	call	CROut			/* Extra carriage return */

	/* Print 64 bit unsigned integer as base 10 decimal number */

	lea	word_b10_message, %rax
	call	StrOut			/* Print null terminated string */
	mov	$0xffff, %rax
	call	PrintWordB10
	call	CROut			/* Extra carriage return */

	/* Print 64 bit unsigned integer as both hexadecimal and decimal */

	lea	word_b10_message2, %rax
	call	StrOut
	mov	$'0', %rax		/* ASCII prepend 0x */
	call	CharOut			/* print 0 */
	mov	$'x', %rax
	call	CharOut			/* print x */
	mov	value2, %rax		/* rax = 0xffffffffffffffff */
	call	PrintHexWord		/* rax maintains value2 */
	call	CROut			/* Extra carriage return */
	call	PrintWordB10		/* rax stil contain value2 */
	call	CROut			/* Extra carriage return */

	/* Exit Program */

exit_program:
	mov	$60, %rax		/* syscall 60 - exit */
	xor	%rdi, %rdi		/* exit code - 0 */
	syscall				/* system call to exit */

# ----------------------------------------
.section .data
# ----------------------------------------

value1:
	.quad	0x0123456789abcdef
value2:
	.quad	0xffffffffffffffff

str_message:
	.asciz	"Print null terminated string:"
hello_message:
	.asciz	"Hello world!"
char_message:
	.asciz	"Print one character:"
byte_message:
	.asciz	"Print one byte (0x55) in hexadecimal:"
word_message:
	.asciz	"Print one 64 bit word (0x0123456789ABCDEF) in hexadecimal:"
word_b10_message:
	.asciz	"Convert 64 bit unsigned word (0x000000000000FFFF) to base 10 decimal and print:"
word_b10_message2:
	.asciz	"Print 0xFFFFFFFFFFFFFFFF in hexadecimal (prepend \"0x\"), then in base 10 decimal"

	.byte	0			/* Catch non-zero terminated strings */		
	