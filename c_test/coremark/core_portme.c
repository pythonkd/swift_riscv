#include <stdio.h>
#include <stdlib.h>

#include "config.h"
#include "coremark.h"
#include "platform.h"
// #include "encoding.h"

#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
volatile ee_s32 seed3_volatile = 0x66;
#endif

#if PERFORMANCE_RUN
volatile ee_s32 seed1_volatile = 0x0;
volatile ee_s32 seed2_volatile = 0x0;
volatile ee_s32 seed3_volatile = 0x66;
#endif

#if PROFILE_RUN
volatile ee_s32 seed1_volatile = 0x8;
volatile ee_s32 seed2_volatile = 0x8;
volatile ee_s32 seed3_volatile = 0x8;
#endif

volatile ee_s32 seed4_volatile = ITERATIONS;
volatile ee_s32 seed5_volatile = 0;

static CORE_TICKS t0, t1;

extern uint64_t get_timer_value();

#ifdef CFG_DEBUG
unsigned long long rdmcycle(void) {
#if __riscv_xlen == 32
    do {
        unsigned long hi = read_csr(mcycleh);
        unsigned long lo = read_csr(mcycle);

        if (hi == read_csr(mcycleh)) return ((unsigned long long)hi << 32) | lo;
    } while (1);
#else
    return (unsigned long long)read_csr(mcycle);
#endif
}

unsigned long long rdminstret(void) {
#if __riscv_xlen == 32
    do {
        unsigned long hi = read_csr(CSR_MINSTRETH);
        unsigned long lo = read_csr(CSR_MINSTRET);

        if (hi == read_csr(CSR_MINSTRETH))
            return ((unsigned long long)hi << 32) | lo;
    } while (1);
#else
    return (unsigned long long)read_csr(CSR_MINSTRET);
#endif
}

#endif

void start_time(void) {
#ifdef CFG_MTIME
    printf("\nThe time is from mtime\n");
#else
    printf("\nThe time is from mcycle\n");
#endif
    t0 = get_timer_value();

#ifdef CFG_DEBUG
    printf("The current mcycle value of benchmark are:%u \n",
           (unsigned int)rdmcycle());
    printf("The current minstreth value of benchmark are:%u \n",
           (unsigned int)rdminstret());
#endif
}

void stop_time(void) {
    t1 = get_timer_value();

#ifdef CFG_DEBUG
    printf("The current mcycle value of benchmark are:%u \n",
           (unsigned int)rdmcycle());
    printf("The current minstreth value of benchmark are:%u \n",
           (unsigned int)rdminstret());
#endif
}

CORE_TICKS get_time(void) { return (CORE_TICKS)t1 - t0; }

secs_ret time_in_secs(CORE_TICKS ticks) {
    extern unsigned int get_timer_freq();

    secs_ret delta = (secs_ret)ticks;
    secs_ret freq = (secs_ret)get_timer_freq();
    secs_ret val = delta / freq;
    return val;
}
