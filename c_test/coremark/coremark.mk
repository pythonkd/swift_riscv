#
# Tiny validation Compilation settings.
#

COREMARK_DIR := $(CV_DIR)/coremark

BSP_SRCS += $(COREMARK_DIR)/core_main.c
BSP_SRCS += $(COREMARK_DIR)/core_list_join.c
BSP_SRCS += $(COREMARK_DIR)/core_matrix.c
BSP_SRCS += $(COREMARK_DIR)/core_portme.c
BSP_SRCS += $(COREMARK_DIR)/core_state.c
BSP_SRCS += $(COREMARK_DIR)/core_util.c
INCLUDES += -I$(COREMARK_DIR)
FLAGS_STR := $(filter-out -D% -I%, $(CFLAGS))
DEFINES += -DCFG_SIMU -DPERFORMANCE_RUN=1 -DFLAGS_STR=\""$(FLAGS_STR)"\"
