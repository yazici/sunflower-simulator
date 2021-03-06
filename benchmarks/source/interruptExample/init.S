#include "asm.h"

	.global _vec_stub_begin
	.global _vec_stub_end
	.global _sleep
	.global _atexit

	.align	2
start:
	/*	Clear Status Reg	*/
	AND	#0, r0
	LDC	r0, sr

	/*	Go !	*/
	MOVL	app_stack_addr, r15
	MOVL	start_addr, r0
	JSR	@r0
	NOP

	/*	SYSCALL SYS_exit	*/
	mov	#1, r4
	trapa	#34





	.align	4
_vec_stub_begin:
	/*		Save PR		*/
	MOVL	savestack_addr, r0
	ADD	#36, r0
	STS.L	pr, @-r0

	/*		Save R8 - R15	*/
	BSR	saveregs
	NOP

	/*	It's now safe to call	*/
	MOVL	intr_stack_addr, r15
	MOVL	hdlr_addr, r0
	JSR	@r0
	NOP

	/*	Restore R8 - R15	*/
	BSR	restoreregs
	NOP

	/*	Restore PR		*/
	MOVL	savestack_addr, r0
	ADD	#32, r0
	LDS.L	@r0+, pr

	/*	Return from exception	*/
	RTE
	NOP


	/*								*/
	/*	SR.RB == 1. Save R8-R15. We store items in reverse	*/
	/*	so that we can use MOV.L Rm, @-Rn, rather than have	*/
	/*	to incr the memory store address ourselves.		*/
	/*								*/
saveregs:
	/*	Addr of bottom of save area	*/
	MOVL	savestack_addr, r0

	/*	  Get addr _end_ of stack	*/
	ADD	#32, r0

	/*	  Now store items bkwrds 	*/
	MOVL	r15, @-r0
	MOVL	r14, @-r0
	MOVL	r13, @-r0
	MOVL	r12, @-r0
	MOVL	r11, @-r0
	MOVL	r10, @-r0
	MOVL	r9, @-r0
	MOVL	r8, @-r0

	RTS
	NOP


	/*								*/
	/*			SR.RB == 1.  Restore R8-R15. 		*/
	/*								*/
restoreregs:
	/*	Addr of bottom of save area	*/
	MOVL	savestack_addr, r0

	/*		Pop into approp. reg	*/
	MOVL	@r0+, r8
	MOVL	@r0+, r9
	MOVL	@r0+, r10
	MOVL	@r0+, r11
	MOVL	@r0+, r12
	MOVL	@r0+, r13
	MOVL	@r0+, r14
	MOVL	@r0+, r15

	RTS
	NOP

	.align	4
	hdlr_addr:
	.long	_intr_hdlr

	.align	4
	savestack_addr:
	.long	_REGSAVESTACK

	.align	4
	intr_stack_addr:
	.long	(0x8000000 + (1 << 26))
_vec_stub_end:



_sleep:
	SLEEP
	RTS
	NOP

	/*	fake atexit (mOS has one, but this let's us use eOS with main() instead of startup)	*/
_atexit:
	RTS
	NOP



	.align	2
	/*	Stack is 32M above us	*/
app_stack_addr:	
	.long	(0x8000000 + (1 << 25))

	.align	2
start_addr:
	.long	_main
