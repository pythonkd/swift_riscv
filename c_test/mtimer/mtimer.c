/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-27 22:52:49
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-27 23:02:15
 * @FilePath: /swift_riscv/c_test/mtimer/mtimer.c
 * @Description:
 *
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved.
 */
#include "swift_config.h"
#include "mtimer.h"

static MTIMER_RegDef* mtimer_reg = (MTIMER_RegDef*)MTIMER_BASE_ADDR;

uint64_t mtimer_get_cycle(void) { 
    uint32_t hi = mtimer_reg->mtimer_cnt_hi;
    uint32_t lo = mtimer_reg->mtimer_cnt_lo;
    return ((uint64_t)hi << 32) | lo;
}