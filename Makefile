SHELL := /bin/bash
CC := gcc
BUILD ?= debug

TARGET := build/yuc
SUBDIRS := source
BUILD_DIR := $(CURDIR)/build
INCLUDES := -I$(CURDIR)/include

PCH_HEADER := $(CURDIR)/include/ucc/tools/pch.h
PCH_HEADER_REL := include/ucc/tools/pch.h
PCH_FILE := $(BUILD_DIR)/pch.h.gch

# ================= BUILD MODES =================
ifeq ($(BUILD),debug)
    CFLAGS := -std=gnu11 -g -O0 -Wall -Wextra -Wpedantic -Wstrict-prototypes $(INCLUDES)
    MODETXT := DEBUG
else ifeq ($(BUILD),debugres)
    CFLAGS := -std=gnu11 -O0 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wundef -Wformat -Wsign-conversion -Wcast-align -Wstrict-prototypes -Werror $(INCLUDES)
    MODETXT := DEBUGRES
else ifeq ($(BUILD),release)
    CFLAGS := -std=gnu11 -O2 -w $(INCLUDES)
    MODETXT := RELEASE
else ifeq ($(BUILD),restriction)
    CFLAGS := -std=gnu11 -O0 -Wall -Wextra -Wpedantic -Werror -Wstrict-prototypes $(INCLUDES)
    MODETXT := RESTRICTION
else
    $(error Unknown BUILD type)
endif

# 🔥 Selalu include PCH (penting untuk clangd juga)
CFLAGS += -include $(PCH_HEADER)

# ================= CHECK PCH HEADER =================
ifneq ("$(wildcard $(PCH_HEADER))","")
    HAS_PCH := 1
else
    HAS_PCH := 0
endif

export CC CFLAGS BUILD BUILD_DIR PCH_FILE PCH_HEADER HAS_PCH

MAKEFLAGS += --no-print-directory
V ?= 0
ifeq ($(V),1)
    Q :=
    USE_ABS := 1
else
    Q := @
    USE_ABS :=
endif

logpath = $(if $(USE_ABS),$(1),$(2))
define log
	printf "  %-7s %s\n" "$(1)" "$(2)"
endef

.PHONY: all info subdirs link clear rebuild check_pch

# ================= MAIN =================
all: info check_pch $(PCH_FILE) subdirs link

info:
	@echo "Build mode : $(MODETXT)"
	@if [ "$(HAS_PCH)" = "1" ]; then \
		echo "PCH        : enabled"; \
	else \
		echo "PCH        : missing"; \
	fi

# ❗ Error hanya kalau header tidak ada
check_pch:
ifeq ($(HAS_PCH),0)
	@echo -e "\e[1;31mERROR: pch.h not found!\e[0m"; \
	echo "Expected: $(PCH_HEADER_REL)"; \
	exit 1;
endif

# ================= BUILD PCH (AUTO) =================
$(PCH_FILE): $(PCH_HEADER)
	$(Q)$(call log,PCH,$(call logpath,$(PCH_HEADER),$(PCH_HEADER_REL)))
	@mkdir -p $(BUILD_DIR)
	$(Q)$(CC) $(CFLAGS) -x c-header $(PCH_HEADER) -o $(PCH_FILE)

# ================= SUBDIR =================
subdirs:
	@for dir in $(SUBDIRS); do \
		$(call log,MAKE,$$dir); \
		$(MAKE) -C $$dir V=$(V) || exit 1; \
	done

# ================= LINK =================
link:
	$(Q)$(call log,LINK,$(TARGET))
	@mkdir -p $(BUILD_DIR)
	$(Q)$(CC) $(shell find $(BUILD_DIR) -name '*.o' 2>/dev/null) -o $(TARGET) $(LDFLAGS)

# ================= CLEAN =================
clear:
	$(Q)$(call log,CLEAR,build)
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clear V=$(V); \
	done
	@rm -rf $(BUILD_DIR)

rebuild: clear all
