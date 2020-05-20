CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE = arm-none-eabi-size
LOADER = 3rdparty/bin/macos-x86_64/teensy_loader_cli

OUTFILE = firmware

LINKER_SCRIPT=etc/imxrt1062.ld

BUILD_DIR = build
SRC_DIRS ?= src include 3rdparty/src

SRCS := $(shell find $(SRC_DIRS) -name *.c -or -name *.cpp -or -name *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/obj/%.o)
DEPS := $(OBJS:.o=.d)

FLAGS_CPU   := -mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16
FLAGS_OPT   := -O2
FLAGS_COM   := -g -Wall -ffunction-sections -fdata-sections -MMD -nostartfiles

FLAGS_CPP   := -std=gnu++17 -fno-unwind-tables -fno-exceptions -fpermissive -fno-rtti -fno-threadsafe-statics -felide-constructors -Wno-error=narrowing
FLAGS_C     := 
FLAGS_S     := -x assembler-with-cpp
FLAGS_LD    := -Wl,--gc-sections,--print-memory-usage,--relax,-T$(LINKER_SCRIPT) --specs=nosys.specs

INCLUDE_DIRS := $(shell find $(SRC_DIRS) -type d) 3rdparty/include
FLAGS_INCLUDE := $(addprefix -I,$(INCLUDE_DIRS))

LIB_DIRS := 3rdparty/lib
FLAGS_LIB_DIRS = $(addprefix -L,$(LIB_DIRS))

LIBS := m c_nano stdc++_nano gcc
FLAGS_LIBS := $(addprefix -l,$(LIBS))

DEFINES     := __IMXRT1062__
DEFINES     += F_CPU=600000000

FLAGS_DEFINES := $(addprefix -D,$(DEFINES))

CPP_FLAGS   := $(FLAGS_CPU) $(FLAGS_OPT) $(FLAGS_COM) $(FLAGS_DEFINES) $(FLAGS_CPP) $(FLAGS_INCLUDE)
C_FLAGS     := $(FLAGS_CPU) $(FLAGS_OPT) $(FLAGS_COM) $(FLAGS_DEFINES) $(FLAGS_C) $(FLAGS_INCLUDE)
S_FLAGS     := $(FLAGS_CPU) $(FLAGS_OPT) $(FLAGS_COM) $(FLAGS_DEFINES) $(FLAGS_S) $(FLAGS_INCLUDE)
LD_FLAGS    := $(FLAGS_LD) $(FLAGS_LIB_DIRS) $(FLAGS_LIBS)
AR_FLAGS    := rcs


$(BUILD_DIR)/$(OUTFILE).hex: $(BUILD_DIR)/$(OUTFILE).elf
	@$(OBJCOPY) -O ihex -R .eeprom build/$(OUTFILE).elf build/$(OUTFILE).hex
	@$(OBJDUMP) -d -x build/$(OUTFILE).elf > build/$(OUTFILE).dis
	@$(OBJDUMP) -d -S -C build/$(OUTFILE).elf > build/$(OUTFILE).lst
	@$(SIZE) build/$(OUTFILE).elf

$(BUILD_DIR)/$(OUTFILE).elf: $(OBJS)
	@$(CXX) $(CPP_FLAGS) -Xlinker -Map=build/$(OUTFILE).map $(LD_FLAGS) -o $@ $^
	@echo Linking...

$(BUILD_DIR)/obj/%.S.o: %.S
	@echo "Assembling (S)   $<..."
	@$(MKDIR_P) $(dir $@)
	@$(CXX) $(S_FLAGS) -c $< -o $@
	

$(BUILD_DIR)/obj/%.c.o: %.c
	@echo "Compiling  (C++) $<..."
	@$(MKDIR_P) $(dir $@)
	@$(CC) $(C_FLAGS) -c $< -o $@
	
$(BUILD_DIR)/obj/%.cpp.o: %.cpp
	@echo "Compiling  (C)   $<..."
	@$(MKDIR_P) $(dir $@)
	@$(CXX) ${CPP_FLAGS} -c $< -o $@
	
.PHONY: flash
flash: $(BUILD_DIR)/$(OUTFILE).hex
	$(LOADER) --mcu=TEENSY40 -w -v $<

.PHONY: clean
clean:
	@echo "Deleting '$(BUILD_DIR)' directory..."
	@$(RM) -r $(BUILD_DIR)

MKDIR_P ?= mkdir -p