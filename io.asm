# io.asm - Output Subroutines
#
# CharOut - Print character in AL
# CROut - Print Carriage Return
# StrOut - Print null-terminated string, address in RAX
# ------------------------------------------------------------

.globl	CharOut, CROut, StrOut

# Linux system callspop
sys_write = 1

# File descriptors
stdout = 1

.section	.text

# ------------------------------------------------------------
#  Print one character to stdout
#  Input:   al = character to print
#  Output:  none
#-------------------------------------------------------------

CharOut:
	push	%rax
	push	%rdi
	push	%rsi
	push	%rdx
	push	%rcx
	push	%r11

/* Place character to print in buffer */

	movb	%al, CharOutbuf		/* Character to print into buffer */

/* Write to StdOut stream */

	mov		$sys_write, %rax	/* 64 bit syscall code */
	mov		$stdout, %rdi		/* File descriptor StdOut */
	lea		CharOutbuf, %rsi	/* Address of buffer with one output character */
	mov		$1, %rdx			/* Length = 1 for one character */
	syscall

.exit:
	pop		%r11
	pop		%rcx
	pop		%rdx
	pop		%rsi
	pop		%rdi
	pop		%rax
	ret


#--------------------------------------------------------------
#  Print Carriage Return and Line Feed
#  Input:   none
#  Output:  none
#--------------------------------------------------------------
CROut:
	push    %rax
	movb    $0x0d,%al 			/* Print Return \r */
	call    CharOut
 	movb	$0x0A, %al			/* Print Line Feed \n */
	call	CharOut
	pop		%rax
	ret

#--------------------------------------------------------------
#  String Out - Print null terminated string
#  Input:   rax	address of nul terminated string
#  Output:  none
#--------------------------------------------------------------

StrOut:
	push	%rax
	push	%rbx
	mov		%rax, %rbx			/* get address */
StrOut1:
	xor		%rax, %rax
	movb	(%rbx), %al			/* read character from memory */
	or		%al, %al			/* is this last byte? */
	jz		StrOut2				/* yes, end of string, exit loop */
	call	CharOut				/* output character */
	inc		%rbx
	jmp	StrOut1					/* loop for next character */
StrOut2:
	call	CROut				/* Print end of line \r\n */
	pop		%rbx
	pop		%rax
	ret

# ----------------------------------------------------------------
.section	.data 
# ----------------------------------------------------------------

CharOutbuf:	.byte  	0			/* Used by CharOut to hold output character for syscall */
			.byte	0,0,0,0		/* not used */

