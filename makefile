SRC_DIR = kernel
INC_DIR = include
BUILD_DIR = binaries/boot

CXX_FLAGS = -target x86_64-unknown-elf -m64 -std=c++17 -Wall -Wextra -pedantic -Werror -g -O2 -fno-PIC -mno-red-zone -fno-stack-protector -fno-omit-frame-pointer -ffreestanding -fno-exceptions -fno-rtti

# all source code
CXX_FILES = $(wildcard $(SRC_DIR)/*.cpp)
ASM_FILES = $(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES = $(CXX_FILES:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%_cxx.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.asm=$(BUILD_DIR)/%_asm.o)

# build objects
$(BUILD_DIR)/%_cxx.o: $(SRC_DIR)/%.cpp
	clang++ $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%_asm.o: $(SRC_DIR)/%.asm
	nasm $< -f elf64 -o $@

all: build clean run

build: $(BUILD_DIR)/kernel.bin

clean:
	rm $(BUILD_DIR)/*.o
	rm $(BUILD_DIR)/*.bin

run:
	qemu-system-x86_64 -boot d -cdrom ./FireflyOS.iso

$(BUILD_DIR)/kernel.bin: $(OBJ_FILES)
	ld --no-undefined -T linker.ld -o $(BUILD_DIR)/kernel.bin $(OBJ_FILES)
	grub-mkrescue -o FireflyOS.iso binaries