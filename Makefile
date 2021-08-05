-include flags.mk

TARGET = $(BUILD_DIR)/kernel_$(ARCH).elf
ISO = FireflyOS_$(ARCH).iso

all: create_dirs $(TARGET)

$(TARGET): $(CONV_FILES)

	$(MAKE) -C ./include/stl # Build STL before linking
	ld -o $@ --no-undefined -T linkage/linker_$(ARCH).ld -nostdlib -m elf_$(ARCH) $(OBJ_FILES) $(LIB_OBJS) 
	grub-mkrescue -o FireflyOS_$(ARCH).iso binaries
	
# TODO: Find a better way to copy the folder structure of arch/{arch}/ into binaries/boot
create_dirs:
ifeq ($(ARCH), x86_64)
	mkdir -vp $(BUILD_DIR)/arch/$(ARCH)/kernel/drivers
	mkdir -vp $(BUILD_DIR)/arch/$(ARCH)/kernel/init
	mkdir -vp $(BUILD_DIR)/arch/$(ARCH)/kernel/int
endif
ifeq ($(ARCH), i386)
	mkdir -vp $(BUILD_DIR)/arch/$(ARCH)/kernel/drivers
	mkdir -vp $(BUILD_DIR)/arch/$(ARCH)/kernel/init
	mkdir -vp $(BUILD_DIR)/arch/$(ARCH)/kernel/int
endif

target_archs:
	@printf "Supported architectures:\n";
	@printf "x86_64 (Encouraged)\n";
	@printf "i386 (Very-WIP)\n";
	@printf "\n"

clean:
	rm -rf binaries/boot/arch
	rm binaries/boot/kernel_i386.elf || echo ""
	rm binaries/boot/kernel_x86_64.elf || echo ""
	rm include/stl/stdio.o include/stl/cstd.o

run:
	cp binaries/grub_loader/grub.$(ARCH) binaries/boot/grub/grub.cfg
	qemu-system-$(ARCH) -M q35 -m 256M -boot d -no-shutdown -no-reboot -cdrom $(ISO)

debug: $(ISO) $(TARGET)
	cp binaries/grub_loader/grub.$(ARCH) binaries/boot/grub/grub.cfg
	qemu-system-$(ARCH) -boot d -cdrom ./FireflyOS.iso $(QEMU_FLAGS) -S -s


%.cxx.o: %.cpp
	$(CC) $(CXX_FLAGS) -c $< -o $(BUILD_DIR)/$@

%.asm.o: %.asm
	$(AS) $< $(ASM_FLAGS) -o $(BUILD_DIR)/$@
