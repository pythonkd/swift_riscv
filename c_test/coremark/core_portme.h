#ifndef FESDK_CORE_PORTME_H
#define FESDK_CORE_PORTME_H

#include <stddef.h>
#include <stdint.h>

#define HAS_FLOAT 0
#define HAS_TIME_H 1
#define USE_CLOCK 1
#define HAS_STDIO 1
#define HAS_PRINTF 1
#define SEED_METHOD SEED_VOLATILE
#define CORE_TICKS uint64_t

typedef signed short ee_s16;
typedef unsigned short ee_u16;
typedef signed int ee_s32;
typedef double ee_f32;
typedef unsigned char ee_u8;
typedef signed int ee_u32;
typedef unsigned long long ee_u64;

#if __riscv_xlen == 32
typedef ee_u32 ee_ptr_int;
#else
typedef ee_u64 ee_ptr_int;
#endif
typedef size_t ee_size_t;

#define COMPILER_FLAGS FLAGS_STR

#define align_mem(x) \
    (void *)(((ee_ptr_int)(x) + sizeof(ee_u32) - 1) & -sizeof(ee_u32))

#ifdef __GNUC__
#ifdef __clang__
#define COMPILER_VERSION __VERSION__
#else
#define COMPILER_VERSION "GCC"__VERSION__
#endif
#else
#error
#endif

#define MEM_METHOD MEM_STACK
#define MEM_LOCATION "STACK"

#define MAIN_HAS_NOARGC 1
#define MAIN_HAS_NORETURN 0

#define MULTITHREAD 1
#define USE_PTHREAD 0
#define USE_FORK 0
#define USE_SOCKET 0

#define default_num_contexts MULTITHREAD

typedef int core_portable;
static void __attribute__((unused)) portable_init(core_portable *p, int *argc,
                                                  char *argv[]) {}
static void __attribute__((unused)) portable_fini(core_portable *p) {}

#if !defined(PROFILE_RUN) && !defined(PERFORMANCE_RUN) && \
    !defined(VALIDATION_RUN)
#if (TOTAL_DATA_SIZE == 1200)
#define PROFILE_RUN 1
#elif (TOTAL_DATA_SIZE == 2000)
#define PERFORMANCE_RUN 1
#else
#define VALIDATION_RUN 1
#endif
#endif

#endif
