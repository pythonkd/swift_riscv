/*
 * Copyright (c) 2012-2021 Andes Technology Corporation
 * All rights reserved.
 *
 */

#ifndef __CONFIG_H__
#define __CONFIG_H__

#include "platform.h"

#define CPU_MHz (CPUFREQ / MHz)

#ifndef CFG_MAKEFILE
//----------------------------------------------------------------------------------------------------
// Users can configure the defines in this area
// to match different environment setting

// #define CFG_DEBUG     // Uncomment CFG_DEBUG to print debug message
// #define CFG_VH        // Uncomment CFG_VH to redirect IO to the host
// #define CFG_CACHE_ON  // Uncomment CFG_CACHE_ON to evaluate benchmark on
// cache #define CFG_SIMU      // Uncomment CFG_SIMU to reduce the iterations
// for simulation
//----------------------------------------------------------------------------------------------------
#endif

// It's suggested to set ITERATIONS as 7000 to run benchmark on real board
// To speed up CoreMark simulation, the ITERATIONS could be set as 350
#ifndef CFG_SIMU
#define ITERATIONS 7000
#else
#define ITERATIONS 350
#endif

#endif  // __CONFIG_H__
