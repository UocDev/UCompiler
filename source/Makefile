SHELL := /bin/bash

OUT := $(BUILD_DIR)

SRC := $(wildcard *.cpp)
OBJ := $(patsubst %.cpp,$(OUT)/%.o,$(SRC))
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

.PHONY: all clean

all: $(OBJ)

$(OUT)/%.o: %.cpp
	@mkdir -p $(OUT)
	$(Q)$(call log,CXX,$<)
	$(Q)$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

clean:
	@rm -f $(OUT)/*.o $(OUT)/*.d

-include $(DEP)
