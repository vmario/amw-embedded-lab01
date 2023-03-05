.PHONY: clean build all program reset sizebefore sizeafter

MCU_TARGET_ATmega32A = atmega32a
MCU_TARGET_ATmega1284P = atmega1284p

MCU_TARGET = ${MCU_TARGET_${CONFIGURATION}}
F_CPU = 11059200

USRBIN ?= C:/msys64/usr/bin/
TOOLCHAIN ?= C:/Bin/avr8-gnu-toolchain-win32_x86_64/bin/avr-
AVRDUDE ?= C:/Bin/avrdude-v7.1-windows-x64/avrdude

CC = $(TOOLCHAIN)gcc
CXX = $(TOOLCHAIN)g++
OBJCOPY = $(TOOLCHAIN)objcopy
SIZE = $(TOOLCHAIN)size
OBJDUMP = $(TOOLCHAIN)objdump
NM = $(TOOLCHAIN)nm
RM = $(USRBIN)rm -f
RMDIR = $(USRBIN)rm -rf
MKDIR = $(USRBIN)mkdir

FORMAT = ihex
MSG_SIZE_BEFORE = Size before:
MSG_SIZE_AFTER = Size after:

DEPDIR = dep
OBJDIR = obj
TARGETDIR = bin

INCLUDES = -I.
LIBS = -lm
CFLAGS = -mmcu=$(MCU_TARGET)
CFLAGS += -MD -MP -MF $(DEPDIR)/$(@F).d
CFLAGS += -Wa,-adhlns=$(<:%.c=$(OBJDIR)/%.lst)
CFLAGS += -std=c99 -Wall -Wundef -Wextra -pedantic -Wstrict-prototypes
CFLAGS += -Os -flto
CXXFLAGS = -mmcu=$(MCU_TARGET)
CXXFLAGS += -MD -MP -MF $(DEPDIR)/$(@F).d
CXXFLAGS += -Wa,-adhlns=$(<:%.cpp=$(OBJDIR)/%.lst)
CXXFLAGS += -std=c++14 -Wall -Wundef -Wextra -pedantic
CXXFLAGS += -Os -flto -fno-exceptions
LDFLAGS = -mmcu=$(MCU_TARGET)
LDFLAGS += -Wl,-Map=$(TARGET).map,--cref
LDFLAGS += -Os -flto
DEFS = -DF_CPU=$(F_CPU)ul

SRCS = main.cpp
OBJS = $(addprefix $(OBJDIR)/,$(SRCS:.cpp=.o))
DEPS = $(addprefix $(DEPDIR)/,$(SRCS:.cpp=.d))
TARGET = $(TARGETDIR)/laboratory01

all: sizebefore build sizeafter

build: $(TARGET).hex $(TARGET).lss $(TARGET).sym

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

$(TARGET).elf: $(OBJS) | $(TARGETDIR)
	$(CXX) $(LDFLAGS) $(LIBS) $(DEFS) -o $@ $(OBJS)

$(TARGET).lss: $(TARGET).elf
	$(OBJDUMP) -h -S $< > $@

$(TARGET).sym: $(TARGET).elf
	$(NM) -n $< > $@

$(OBJDIR)/%.o: %.c | $(OBJDIR) $(DEPDIR)
	$(CC) $(CFLAGS) $(INCLUDES) $(DEFS) -o $@ -c $<

$(OBJDIR)/%.o: %.cpp | $(OBJDIR) $(DEPDIR)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(DEFS) -o $@ -c $<

$(TARGETDIR):
	$(MKDIR) $(TARGETDIR)

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

$(DEPDIR):
	$(MKDIR) $(DEPDIR)

-include $(shell MKDIR $(DEPDIR) 2>/dev/null) $(DEPS)

clean:
	$(RM) $(DEPS)
	$(RM) $(OBJS)
	$(RMDIR) $(OBJDIR)
	$(RM) $(DEPS)
	$(RMDIR) $(DEPDIR)
	$(RM) $(TARGET).map
	$(RM) $(TARGET).lss
	$(RM) $(TARGET).sym
	$(RM) $(TARGET).elf
	$(RM) $(TARGET).hex
	$(RMDIR) $(TARGETDIR)

program: all
	$(AVRDUDE) -c usbasp -p $(MCU_TARGET) -U flash:w:$(TARGET).hex:i

erase:
	$(AVRDUDE) -c usbasp -p $(MCU_TARGET) -e

reset:
	$(AVRDUDE) -c usbasp -p $(MCU_TARGET) -v

HEXSIZE = $(SIZE) --target=$(FORMAT) $(TARGET).hex
ELFSIZE = $(SIZE) -A $(TARGET).elf
AVRMEM = avr-mem.sh $(TARGET).elf $(MCU)

sizebefore:
	@if test -f $(TARGET).elf; then echo; echo $(MSG_SIZE_BEFORE); $(ELFSIZE); \
	$(AVRMEM) 2>/dev/null; echo; fi

sizeafter:
	@if test -f $(TARGET).elf; then echo; echo $(MSG_SIZE_AFTER); $(ELFSIZE); \
	$(AVRMEM) 2>/dev/null; echo; fi
