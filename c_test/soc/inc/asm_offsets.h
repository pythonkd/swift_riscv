#ifndef __ASM_OFFSETS_H__
#define __ASM_OFFSETS_H__

#define REGBYTES  4
#define STORE     sw
#define LOAD      lw

#define PT_MEPC 0                           /* offsetof(struct riscv_esf_t, mepc) */
#define PT_MCAUSE (PT_MEPC + REGBYTES)      /* offsetof(struct riscv_esf_t, mcause) */
#define PT_MSTATUS (PT_MCAUSE + REGBYTES)   /* offsetof(struct riscv_esf_t, mstatus) */
#define PT_RA (PT_MSTATUS + REGBYTES)       /* offsetof(struct riscv_esf_t, ra) */
#define PT_T0 (PT_RA + REGBYTES)            /* offsetof(struct riscv_esf_t, t0) */
#define PT_T1 (PT_T0 + REGBYTES)            /* offsetof(struct riscv_esf_t, t1) */
#define PT_T2 (PT_T1 + REGBYTES)            /* offsetof(struct riscv_esf_t, t2) */
#define PT_A0 (PT_T2 + REGBYTES)            /* offsetof(struct riscv_esf_t, a0) */
#define PT_A1 (PT_A0 + REGBYTES)            /* offsetof(struct riscv_esf_t, a1) */
#define PT_A2 (PT_A1 + REGBYTES)            /* offsetof(struct riscv_esf_t, a2) */
#define PT_A3 (PT_A2 + REGBYTES)            /* offsetof(struct riscv_esf_t, a3) */
#define PT_A4 (PT_A3 + REGBYTES)            /* offsetof(struct riscv_esf_t, a4) */
#define PT_A5 (PT_A4 + REGBYTES)            /* offsetof(struct riscv_esf_t, a5) */
#define PT_S0 (PT_A5 + REGBYTES)            /* offsetof(struct riscv_esf_t, s0) */
#define PT_A6 (PT_S0 + REGBYTES)            /* offsetof(struct riscv_esf_t, a6) */
#define PT_A7 (PT_A6 + REGBYTES)            /* offsetof(struct riscv_esf_t, a7) */
#define PT_T3 (PT_A7 + REGBYTES)            /* offsetof(struct riscv_esf_t, t3) */
#define PT_T4 (PT_T3 + REGBYTES)            /* offsetof(struct riscv_esf_t, t4) */
#define PT_T5 (PT_T4 + REGBYTES)            /* offsetof(struct riscv_esf_t, t5) */
#define PT_T6 (PT_T5 + REGBYTES)            /* offsetof(struct riscv_esf_t, t6) */
#define PT_S1 (PT_T6 + REGBYTES)            /* offsetof(struct riscv_esf_t, s1) */
#define PT_S2 (PT_S1 + REGBYTES)            /* offsetof(struct riscv_esf_t, s2) */
#define PT_S3 (PT_S2 + REGBYTES)            /* offsetof(struct riscv_esf_t, s3) */
#define PT_S4 (PT_S3 + REGBYTES)            /* offsetof(struct riscv_esf_t, s4) */
#define PT_S5 (PT_S4 + REGBYTES)            /* offsetof(struct riscv_esf_t, s5) */
#define PT_S6 (PT_S5 + REGBYTES)            /* offsetof(struct riscv_esf_t, s6) */
#define PT_S7 (PT_S6 + REGBYTES)            /* offsetof(struct riscv_esf_t, s7) */
#define PT_S8 (PT_S7 + REGBYTES)            /* offsetof(struct riscv_esf_t, s8) */
#define PT_S9 (PT_S8 + REGBYTES)            /* offsetof(struct riscv_esf_t, s9) */
#define PT_S10 (PT_S9 + REGBYTES)           /* offsetof(struct riscv_esf_t, s10) */
#define PT_S11 (PT_S10 + REGBYTES)          /* offsetof(struct riscv_esf_t, s11) */
#define PT_SIZE (PT_S11 + REGBYTES)
#define PT_LOW_POWER_SIZE PT_SIZE
#endif
