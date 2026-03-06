SHELL := /bin/bash

OUT := $(BUILD_DIR)

SRC := $(wildcard *.c)
OBJ := $(patsubst %.c,$(OUT)/%.o,$(SRC))
DEP := $(OBJ:.o=.d)

V ?= 0
ifeq ($(V),1)
Q :=
else
Q := @
endif

define log
printf "  %-7s %s\n" "$(1)" "$(2)"
endef

# cek apakah PCH compiled
ifneq ("$(wildcard $(PCH_FILE))","")
PCH_DEP := $(PCH_FILE)
else
PCH_DEP :=
endif

.PHONY: all clean

all: $(OBJ)

$(OUT)/%.o: %.c $(PCH_DEP)
	@mkdir -p $(OUT)
	$(Q)$(call log,CC,$<)
	$(Q)$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

clean:
	@rm -f $(OUT)/*.o $(OUT)/*.d

-include $(DEP)
