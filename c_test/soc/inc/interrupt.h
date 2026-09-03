#ifndef __INTERRUPT_H__
#define __INTERRUPT_H__

#include "csr.h"
#define IRQ_M_SOFT 3
#define IRQ_M_TIMER 7
#define IRQ_M_EXT 11
#define MIP_MSIP (1 << IRQ_M_SOFT)
#define MIP_MTIP (1 << IRQ_M_TIMER)
#define MIP_MEIP (1 << IRQ_M_EXT)

#define MSTATUS_MIE 0x00000008
#define MSTATUS_MPIE 0x00000080
#define MSTATUS_FS 0x00006000
#define MSTATUS_MPP 0x00001800

inline __attribute__((always_inline)) void enable_m_mode_external_interrupt(void) { set_csr(CSR_MIE, MIP_MEIP);}
inline __attribute__((always_inline)) void enable_m_mode_timer_interrupt(void) { set_csr(CSR_MIE, MIP_MTIP);}
inline __attribute__((always_inline)) void enable_m_mode_soft_interrupt(void) { set_csr(CSR_MIE, MIP_MSIP);}
inline __attribute__((always_inline)) void disable_m_mode_external_interrupt(void) { clear_csr(CSR_MIE, MIP_MEIP);}
inline __attribute__((always_inline)) void disable_m_mode_timer_interrupt(void) { clear_csr(CSR_MIE, MIP_MTIP);}
inline __attribute__((always_inline)) void disable_m_mode_soft_interrupt(void) { clear_csr(CSR_MIE, MIP_MSIP);}
inline __attribute__((always_inline)) void disable_m_mode_global_interrupt(void) { clear_csr(CSR_MSTATUS, MSTATUS_MIE);}
inline __attribute__((always_inline)) void enable_m_mode_global_interrupt(void) { set_csr(CSR_MSTATUS, MSTATUS_MIE);}

#endif //__INTERRUPT_H__