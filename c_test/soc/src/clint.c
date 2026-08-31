#include "clint.h"

static CLINT_RegDef* clint = (CLINT_RegDef*)CLINE_BASE_ADDR;

void clint_irq_set_en(CLINT_IRQ irq, EnableStatus enable) { clint->enable[irq] = enable; }

EnableStatus clint_irq_get_en(CLINT_IRQ irq) { return clint->enable[irq]; }

void clint_irq_set_priority(CLINT_IRQ irq, CLINT_PRIORITYS priority) { clint->priority[irq] = priority; }

CLINT_PRIORITYS clint_irq_get_priority(CLINT_IRQ irq) { return clint->priority[irq]; }