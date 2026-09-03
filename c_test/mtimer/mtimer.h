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

typedef void (*mtimer_callback_t)(void);
void mtimer_delay_us(uint32_t us);
void mtimer_delay_ms(uint32_t ms);
uint64_t mtimer_get_time_us(void);
uint64_t mtimer_get_time_ms(void);
uint32_t mtimer_get_tick_count(void);
void mtimer_config(uint32_t interval_ticks, mtimer_callback_t callback_func);
#endif