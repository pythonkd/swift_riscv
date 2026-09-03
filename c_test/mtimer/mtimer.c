/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-27 22:52:49
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-30 10:06:56
 * @FilePath: /swift_riscv/c_test/mtimer/mtimer.c
 * @Description:
 *
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved.
 */
#include "stddef.h"
#include "swift_config.h"
#include "mtimer.h"
#include "interrupt.h"

static mtimer_callback_t timer_callback;
volatile uint32_t timer_tick_count = 0;
static uint32_t timer_interval_ticks = 0;
static uint64_t system_startup_time = 0;
static MTIMER_RegDef* mtimer_reg = (MTIMER_RegDef*)MTIMER_BASE_ADDR;

static uint64_t mtimer_read_time(void) {
    // Read high and low parts with overflow protection
    do {
        uint32_t hi = mtimer_reg->mtimer_cnt_hi;
        uint32_t lo = mtimer_reg->mtimer_cnt_lo;
        // Verify high part didn't change during read (no overflow occurred)
        if (hi == mtimer_reg->mtimer_cnt_hi) return ((uint64_t)hi << 32) | lo;
    } while (1);
}

static void mtimer_write_compare(uint64_t value) {
    /* Prevent false interrupt by first setting a value larger than current time
     */
    mtimer_reg->mtimer_cmp_hi = 0xFFFFFFFF;
    mtimer_reg->mtimer_cmp_hi = (uint32_t)(value >> 32);
    /* Set final compare value */
    mtimer_reg->mtimer_cmp_lo = (uint32_t)value;
}

void mtimer_delay_us(uint32_t us) {
    uint64_t ticks_needed = (uint64_t)us * MTIMERFRQ / 1000000ULL;

    if (ticks_needed == 0 && us > 0) {
        ticks_needed = 1;
    }

    uint64_t start_time = mtimer_read_time();
    uint64_t current_time;

    do {
        current_time = mtimer_read_time();
        // Use subtraction to handle overflow automatically
    } while ((current_time - start_time) < ticks_needed);
}

void mtimer_delay_ms(uint32_t ms) { mtimer_delay_us(ms * 1000); }

uint64_t mtimer_get_time_us(void) {
    /* ticks -> us: same conversion as mtimer_delay_us (freq in Hz). */
    return (mtimer_read_time() - system_startup_time) * 1000000ULL / MTIMERFRQ;
}

uint64_t mtimer_get_time_ms(void) { return mtimer_get_time_us() / 1000ULL; }

uint32_t mtimer_get_tick_count(void) { return timer_tick_count; }

void mtimer_config(uint32_t interval_ticks, mtimer_callback_t callback_func) {
    // Disable timer interrupt during configuration
    disable_m_mode_timer_interrupt();
    timer_interval_ticks = interval_ticks;
    timer_callback = callback_func;
    timer_tick_count = 0;
    system_startup_time = mtimer_read_time();

    /* First deadline from current MTIME (do not trust reset MTIMECMP) */
    mtimer_write_compare(system_startup_time + interval_ticks);

    // Enable machine timer interrupt
    enable_m_mode_timer_interrupt();
}

static void mtimer_schedule_next(uint32_t ticks) {
    volatile uint32_t* mtimecmp_array = &(mtimer_reg->mtimer_cmp_lo);

    uint32_t hi, lo;
    do {
        hi = mtimecmp_array[1];
        lo = mtimecmp_array[0];
    } while (hi != mtimecmp_array[1]);

    uint64_t next = (((uint64_t)hi << 32) | lo) + ticks;
    uint64_t now = mtimer_read_time();

    while (next <= now) {
        next += ticks;
    }

    mtimer_write_compare(next);
}

void mtime_handler(void) {
    timer_tick_count++;

    // Schedule next interrupt
    mtimer_schedule_next(timer_interval_ticks);

    // Invoke user callback function
    if (timer_callback != NULL) {
        timer_callback();
    }
}