#include <stdint.h>
#include "trap.h"
#include "csr.h"
#include "interrupt.h"
static volatile isr_func irq_handler[CLINT_NUM_INTERRUPTS];

void minterrupt_handler(void) {

}

void mswi_handler(void) {
    clear_csr(CSR_MIE, MIP_MSIP);
}

void except_entry(riscv_esf_t* context) {
    volatile unsigned long mcause_val = context->mcause;
    // volatile unsigned long mepc_val = context->mepc;
    // volatile unsigned long mtval_val = read_csr(CSR_MTVEC);

    switch (mcause_val) {
        case TRAP_M_I_ADDR_MISALIGNED:
            break;
        case TRAP_M_I_ACC_FAULT:
            break;
        case TRAP_M_I_INSTRUCTION:
            break;
        case TRAP_M_BREAKPOINT:
            break;
        case TRAP_M_L_ACC_MISALIGNED:
            break;
        case TRAP_M_L_ACC_FAULT:
            break;
        case TRAP_M_S_ADDR_MISALIGNED:
            break;
        case TRAP_M_S_ACC_FAULT:
            break;
        case TRAP_U_ECALL:
            context->mepc += 4;
            return;
        case TRAP_M_ECALL:
            context->mepc += 4;
            return;
        case TRAP_M_STACKOVF:
            break;
        case TRAP_M_STACKUDF:
            break;
        default:
            break;
    }
    return;
}
