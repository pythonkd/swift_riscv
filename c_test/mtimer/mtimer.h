/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-30 07:36:20
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-30 10:06:40
 * @FilePath: /swift_riscv/c_test/mtimer/mtimer.h
 * @Description:
 *
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved.
 */
#ifndef __MTIMER_H__
#define __MTIMER_H__
#include <stdint.h>
typedef struct
{
    uint32_t mtimer_cnt_lo;
    uint32_t mtimer_cnt_hi;
    uint32_t mtimer_cmp_lo;
    uint32_t mtimer_cmp_hi;
} MTIMER_RegDef;

uint64_t mtimer_get_cycle(void);
#endif