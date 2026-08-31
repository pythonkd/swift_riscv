/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-31 21:24:52
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-31 21:33:45
 * @FilePath: /swift_riscv/c_test/soc/inc/clint.h
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

#ifndef __CLINE_H__
#define __CLINE_H__
#include "swift_config.h"

#define INTERRUPT_MAX_NUM 2
#define PRIORITYS 5
typedef enum {
    FLASH_INTR_0 = 0,
    UART_INTR_1 = 1,
} CLINT_IRQ;

typedef enum {
    CLINT_PRIORITY_LEV0 = 0,
    CLINT_PRIORITY_LEV1,
    CLINT_PRIORITY_LEV2,
    CLINT_PRIORITY_LEV3,
    CLINT_PRIORITY_LEV4,
} CLINT_PRIORITYS;

typedef struct {
    uint8_t priority[INTERRUPT_MAX_NUM];
    uint8_t enable[INTERRUPT_MAX_NUM];
} CLINT_RegDef;

void clint_irq_set_en(CLINT_IRQ irq, EnableStatus enable);
EnableStatus clint_irq_get_en(CLINT_IRQ irq);
void clint_irq_set_priority(CLINT_IRQ irq, CLINT_PRIORITYS priority);
CLINT_PRIORITYS clint_irq_get_priority(CLINT_IRQ irq);
#endif