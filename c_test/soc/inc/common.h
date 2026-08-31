/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-31 21:24:52
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-31 21:33:52
 * @FilePath: /swift_riscv/c_test/soc/inc/common.h
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

#ifndef __COMMON_H__
#define __COMMON_H__

#define BIT_MASK(bit_h, bit_l) ((uint64_t)((((uint64_t)0x1 << (1 + bit_h - bit_l)) - (uint64_t)0x1) << bit_l))

#define GET_BIT(var, bit) ((var) & (bit))
#define SET_BIT(var, bit) \
    do {                  \
        (var) |= (bit);   \
    } while (0)
#define CLR_BIT(var, bit) \
    do {                  \
        (var) &= ~(bit);  \
    } while (0)
#define SET_BITS(var, bits) \
    do {                    \
        (var) |= (bits);    \
    } while (0)
#define CLR_BITS(var, bits) \
    do {                    \
        (var) &= ~(bits);   \
    } while (0)

#define GET_MASKED_VALUE(var, mask) ((var) & (mask))
#define SET_FIELD(var, mask, offset, value)                         \
    do {                                                            \
        var = ((var) & (~mask)) | (((value) << (offset)) & (mask)); \
    } while (0)
#define GET_FIELD(var, mask, offset) (((var) & (mask)) >> (offset))

// Error type definition
typedef enum { SUCCESS = 0, FAILED = 1, TIMEOUT = 2, INVALID = 3 } StatusType;

typedef enum { FALSE = 0, TRUE = 1 } boolean;

// Locked status type definition
typedef enum { UNLOCKED = 0, LOCKED = !UNLOCKED } LockStatus;

// Enable/Disable status enumeration
typedef enum { DISABLED = 0, ENABLED = 1 } EnableStatus;

#endif