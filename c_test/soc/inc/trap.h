#ifndef __TRAP_H__
#define __TRAP_H__
#define CLINT_NUM_INTERRUPTS 96UL

typedef enum {
    E_UART_INTR_0 = 0,
    E_FLASH_INTR_1 = 1,
    E_MAX_IRQ = CLINT_NUM_INTERRUPTS - 1,
} CLINT_IRQ;

typedef struct riscv_esf {
    /* Caller-saved registers */
    uint32_t mepc;
    uint32_t mcause;
    uint32_t mstatus;
    uint32_t ra; /* Return address */
    uint32_t t0; /* Caller-saved temporary register */
    uint32_t t1; /* Caller-saved temporary register */
    uint32_t t2; /* Caller-saved temporary register */
    uint32_t a0; /* Function argument/return value */
    uint32_t a1; /* Function argument */
    uint32_t a2; /* Function argument */
    uint32_t a3; /* Function argument */
    uint32_t a4; /* Function argument */
    uint32_t a5; /* Function argument */
    uint32_t s0; /* Frame pointer */
    uint32_t a6; /* Function argument */
    uint32_t a7; /* Function argument */
    uint32_t t3; /* Caller-saved temporary register */
    uint32_t t4; /* Caller-saved temporary register */
    uint32_t t5; /* Caller-saved temporary register */
    uint32_t t6; /* Caller-saved temporary register */
    uint32_t s1;
    uint32_t s2;
    uint32_t s3;
    uint32_t s4;
    uint32_t s5;
    uint32_t s6;
    uint32_t s7;
    uint32_t s8;
    uint32_t s9;
    uint32_t s10;
    uint32_t s11;
} riscv_esf_t;

typedef void (*isr_func)(void);


/* Machine mode MCAUSE */
#define TRAP_M_I_ADDR_MISALIGNED 0 /* Instruction address misaligned */
#define TRAP_M_I_ACC_FAULT 1       /* Instruction access fault */
#define TRAP_M_I_INSTRUCTION 2     /* Illegal instruction */
#define TRAP_M_BREAKPOINT 3        /* Breakpoint */
#define TRAP_M_L_ACC_MISALIGNED 4  /* Load address misaligned */
#define TRAP_M_L_ACC_FAULT 5       /* Data load access fault */
#define TRAP_M_S_ADDR_MISALIGNED 6 /* Store/AMO address misaligned */
#define TRAP_M_S_ACC_FAULT 7       /* Data store access fault */
#define TRAP_U_ECALL 8
#define TRAP_S_ECALL 9
#define TRAP_H_ECALL 10
#define TRAP_M_ECALL 11
#define TRAP_M_I_PAGE_FAULT 12 /* Instruction page fault */
#define TRAP_M_L_PAGE_FAULT 13 /* Data load page fault */
#define TRAP_M_S_PAGE_FAULT 15 /* Data store page fault */
#define TRAP_M_STACKOVF 32
#define TRAP_M_STACKUDF 33

#endif