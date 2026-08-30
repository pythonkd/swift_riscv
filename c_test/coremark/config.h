/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-08-24 22:53:03
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-08-30 22:37:06
 * @FilePath: /swift_riscv/c_test/coremark/config.h
 * @Description:
 *
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved.
 */
/*
 * Copyright (c) 2012-2021 Andes Technology Corporation
 * All rights reserved.
 *
 */

#ifndef __CONFIG_H__
#define __CONFIG_H__
#include "swift_config.h"

#define CPU_MHz (CPUFREQ / MHz)

#ifndef CFG_MAKEFILE
//----------------------------------------------------------------------------------------------------
// Users can configure the defines in this area
// to match different environment setting
// #define CFG_MTIME
// #define CFG_DEBUG // Uncomment CFG_DEBUG to print debug message
// #define CFG_VH        // Uncomment CFG_VH to redirect IO to the host
// #define CFG_CACHE_ON  // Uncomment CFG_CACHE_ON to evaluate benchmark on
// cache #define CFG_SIMU      // Uncomment CFG_SIMU to reduce the iterations
// for simulation
//----------------------------------------------------------------------------------------------------
#endif

// It's suggested to set ITERATIONS as 7000 to run benchmark on real board
// To speed up CoreMark simulation, the ITERATIONS could be set as 350

#define ITERATIONS 1300

#endif // __CONFIG_H__
