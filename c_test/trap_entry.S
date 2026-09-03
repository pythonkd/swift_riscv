#include "asm_offsets.h"

    .section      .text.entry	
    .align 2
    .global trap_entry
trap_entry:
	addi sp, sp, -(PT_LOW_POWER_SIZE)
	/* Save caller registers */
	STORE ra,  PT_RA(sp)
	STORE t0,  PT_T0(sp)
	STORE t1,  PT_T1(sp)
	STORE t2,  PT_T2(sp)
	STORE a0,  PT_A0(sp)
	STORE a1,  PT_A1(sp)
	STORE a2,  PT_A2(sp)
	STORE a3,  PT_A3(sp)
	STORE a4,  PT_A4(sp)
	STORE a5,  PT_A5(sp)
	STORE s1,  PT_S1(sp)
	STORE s2,  PT_S2(sp)
	STORE s3,  PT_S3(sp)
	STORE s4,  PT_S4(sp)
	STORE s5,  PT_S5(sp)
	STORE s6,  PT_S6(sp)
	STORE s7,  PT_S7(sp)
	STORE s8,  PT_S8(sp)
	STORE s9,  PT_S9(sp)
	STORE s10, PT_S10(sp)
	STORE s11, PT_S11(sp)
	STORE a6, PT_A6(sp)
	STORE a7, PT_A7(sp)
	STORE t3, PT_T3(sp)
	STORE t4, PT_T4(sp)
	STORE t5, PT_T5(sp)
	STORE t6, PT_T6(sp)
	STORE s0, PT_S0(sp)
	csrr a0, mstatus
	STORE a0, PT_MSTATUS(sp)
	csrr t0, mepc
	STORE t0, PT_MEPC(sp)
	csrr a0, mcause
	STORE a0, PT_MCAUSE(sp)
	/* Check if it's an external interrupt */
	li t2, 0x8000000B
	beq a0, t2, _external_interrupt

	/* Check whether it's a timer interrupt */
	li t2, 0x80000007
	beq a0, t2, _timer_interrupt

	/* Check whether it's a sw interrupt */
	li t2, 0x80000003
	beq a0, t2, _soft_interrupt

	/* go to exception entry*/
	bgez a0, _not_interrupt

context_restore:
	LOAD t0, PT_MSTATUS(sp)
	li t1, 0x1880 // enable MPP MPIE
    or t0, t0, t1
    csrs mstatus, t0
	LOAD t0, PT_MEPC(sp)
	csrw mepc, t0
	/* Restore caller registers */
	LOAD ra,  PT_RA(sp)
	LOAD t0,  PT_T0(sp)
	LOAD t1,  PT_T1(sp)
	LOAD t2,  PT_T2(sp)
	LOAD a0,  PT_A0(sp)
	LOAD a1,  PT_A1(sp)
	LOAD a2,  PT_A2(sp)
	LOAD a3,  PT_A3(sp)
	LOAD a4,  PT_A4(sp)
	LOAD a5,  PT_A5(sp)
	LOAD s0,  PT_S0(sp)
	LOAD s1,  PT_S1(sp)
	LOAD s2,  PT_S2(sp)
	LOAD s3,  PT_S3(sp)
	LOAD s4,  PT_S4(sp)
	LOAD s5,  PT_S5(sp)
	LOAD s6,  PT_S6(sp)
	LOAD s7,  PT_S7(sp)
	LOAD s8,  PT_S8(sp)
	LOAD s9,  PT_S9(sp)
	LOAD s10,  PT_S10(sp)
	LOAD s11,  PT_S11(sp)
	LOAD a6, PT_A6(sp)
	LOAD a7, PT_A7(sp)
	LOAD t3, PT_T3(sp)
	LOAD t4, PT_T4(sp)
	LOAD t5, PT_T5(sp)
	LOAD t6, PT_T6(sp)
	addi sp, sp, PT_LOW_POWER_SIZE
	mret

_not_interrupt:
	call except_entry
	j context_restore

_external_interrupt:
	/* Externel interrupt handler */
	call minterrupt_handler
	j context_restore

_timer_interrupt:
	/* Timer interrupt handler */
	call mtime_handler

	j context_restore

_soft_interrupt:
	/* Soft interrupt handler */
	call mswi_handler
	j context_restore