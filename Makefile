# Path variables
SRC_DIR := $(CURDIR)/src
INC_DIR := $(CURDIR)/src/include
OUT_DIR := $(CURDIR)/dist
BOOT_SRC_DIR := $(SRC_DIR)/boot
BOOT_OUT_DIR := $(OUT_DIR)/boot

# Important files
LD_OUT_BIN := $(OUT_DIR)/linked_project_april.bin
OUT_BIN := $(OUT_DIR)/project_april.bin
LINKERFILE := $(SRC_DIR)/linker.ld

# Compiler variables
CC := @gcc
ASMC := @nasm

# Command variables
CD := @cd
ECHO := @echo
MKDIR := @mkdir -p
BUILD := $(MAKE) --no-print-directory
LD := @ld
CAT := @cat
EMU := @qemu-system-x86_64
CLEAR := @clear
DEL := @rm -rf

# Compiler flags
CFLAGS := -m32 -mno-red-zone -ffreestanding -fno-stack-protector -fno-builtin -fno-pie -nostdlib -I $(INC_DIR) -Ofast -O2 -Wall -Wextra -Werror -c
ASMFLAGS := -f elf32
LDFLAGS := -n -m elf_i386 -Ttext 0x8000 -T $(LINKERFILE) -o $(LD_OUT_BIN)
EMUFLAGS := -drive file=$(OUT_BIN),if=floppy,index=0,media=disk,format=raw -no-reboot -d guest_errors,in_asm

# Export all variables so they are available to other MAKE instances that will be run to compile each module
export

# The default recipie to handle recompiling and emulating the entire system
all: build link run

# Compile each individual module
build:
	$(CD) $(BOOT_SRC_DIR)				&& $(BUILD) MODULE=boot
	$(CD) $(SRC_DIR)/kernel			&& $(BUILD) MODULE=kernel
	$(CD) $(SRC_DIR)/dev				&& $(BUILD) MODULE=dev

# Link all the files together
link:
	$(ECHO) "Linking files"
	$(CD) $(OUT_DIR)
	$(LD) $(LDFLAGS) $(shell find $(OUT_DIR) -name "*.asmo" -o -name "*.o")
	$(CAT) $(BOOT_OUT_DIR)/stage_one.bin $(LD_OUT_BIN) > $(OUT_BIN)

# Emulate the OS
run:
	$(ECHO) "Emulating OS..."
	$(EMU) $(EMUFLAGS)
	$(CLEAR)

# Delete all the compiled files
clean:
	$(DEL) *.o
	$(DEL) *.asmo
	$(DEL) $(OUT_DIR)