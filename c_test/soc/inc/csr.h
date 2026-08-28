#ifndef __CSR_H__
#define __CSR_H__


#define CSR_MEPC (0x341)
#define CSR_CYCLE (0xc00)
#define CSR_CYCLEH (0xc80)
#define CSR_MTVEC (0x305)
#define CSR_MCAUSE (0x342)
#define CSR_MIE (0x304)
#define CSR_MSTATUS (0x300)
#define CSR_MSCRATCH (0x340)

#define STR(S) #S
#define XSTR(S) STR(S)

#define read_csr(reg)                                      \
    ({                                                     \
        unsigned long __tmp;                               \
        asm volatile("csrr %0, " XSTR(reg) : "=r"(__tmp)); \
        __tmp;                                             \
    })

#define write_csr(reg, val) ({ asm volatile("csrw " XSTR(reg) ", %0" ::"rK"(val)); })

#define swap_csr(reg, val)                                                     \
    ({                                                                         \
        unsigned long __tmp;                                                   \
        asm volatile("csrrw %0, " XSTR(reg) ", %1" : "=r"(__tmp) : "rK"(val)); \
        __tmp;                                                                 \
    })

#define set_csr(reg, bit)                                                      \
    ({                                                                         \
        unsigned long __tmp;                                                   \
        asm volatile("csrrs %0, " XSTR(reg) ", %1" : "=r"(__tmp) : "rK"(bit)); \
        __tmp;                                                                 \
    })

#define clear_csr(reg, bit)                                                    \
    ({                                                                         \
        unsigned long __tmp;                                                   \
        asm volatile("csrrc %0, " XSTR(reg) ", %1" : "=r"(__tmp) : "rK"(bit)); \
        __tmp;                                                                 \
    })

#define read_fcsr()                             \
    ({                                          \
        unsigned long __tmp;                    \
        asm volatile("frcsr %0" : "=r"(__tmp)); \
        __tmp;                                  \
    })

#define write_fcsr(val) ({ asm volatile("fscsr %0" ::"rK"(val)); })
#endif