#
# Tiny validation Compilation settings.
#

COREMARK_DIR := $(COMMON_DIR)/coremark

C_SRCS += $(COREMARK_DIR)/core_main.c
C_SRCS += $(COREMARK_DIR)/core_list_join.c
C_SRCS += $(COREMARK_DIR)/core_matrix.c
C_SRCS += $(COREMARK_DIR)/core_portme.c
C_SRCS += $(COREMARK_DIR)/core_state.c
C_SRCS += $(COREMARK_DIR)/core_util.c
INCLUDES += -I$(COREMARK_DIR)
FLAGS_STR := $(filter-out -D% -I%, $(CFLAGS))

