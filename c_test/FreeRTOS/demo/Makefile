RISCV_ARCH := rv32im
RISCV_ABI := ilp32
RISCV_MCMODEL := medlow


TARGET = freertos


# RTL仿真时打开这行注释
#CFLAGS += -DSIMULATION
CFLAGS += -O0 
ASM_SRCS := ../Source/portable/RISC-V/portASM.S
#LDFLAGS +=
INCLUDES += -I. -I../Source/portable/RISC-V -I../Source/include -I../../ -I../lib

CFLAGS += -fno-strict-aliasing -fno-builtin-printf -fno-builtin-sprintf \
	-fno-builtin-snprintf -fno-builtin-vsnprintf -fno-builtin-vprintf
# coremark
CFLAGS += -DFLAGS_STR='"RISC-V GCC -O2 -march=rv32imc -nostdlib"'

C_SRCS := \
	../Source/list.c \
	../Source/tasks.c \
	../Source/queue.c \
	../Source/portable/MemMang/heap_1.c \
	../Source/portable/RISC-V/port.c \
	../lib/xprintf.c \
	main.c \

BSP_SRCS = 
COMMON_DIR = ../..
TOOLCHAIN_DIR = ../../../
include ../../common.mk
