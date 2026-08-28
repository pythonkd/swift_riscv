#ifndef __MTIMER_H__
#define __MTIMER_H__
#include <stdio.h>
typedef struct {
    uint32_t mtimer_cnt_lo;
    uint32_t mtimer_cnt_hi;
    uint32_t mtimer_cmp_lo;
    uint32_t mtimer_cmp_hi;
} MTIMER_RegDef;

#endif