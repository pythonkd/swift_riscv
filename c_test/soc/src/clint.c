/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-31 21:24:52
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-31 21:34:03
 * @FilePath: /swift_riscv/c_test/soc/src/clint.c
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

#include "clint.h"

static CLINT_RegDef* clint = (CLINT_RegDef*)CLINE_BASE_ADDR;

void clint_irq_set_en(CLINT_IRQ irq, EnableStatus enable) { clint->enable[irq] = enable; }

EnableStatus clint_irq_get_en(CLINT_IRQ irq) { return clint->enable[irq]; }

void clint_irq_set_priority(CLINT_IRQ irq, CLINT_PRIORITYS priority) { clint->priority[irq] = priority; }

CLINT_PRIORITYS clint_irq_get_priority(CLINT_IRQ irq) { return clint->priority[irq]; }