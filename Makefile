kernel_source_files := $(shell find kernel -name *.c)
kernel_object_files := $(patsubst kernel/%.c, build/kernel/%.o, $(kernel_source_files))

driver_source_files := $(shell find driver/keyboard -name *.c)
driver_object_files := $(patsubst driver/keyboard/%.c, build/driver/keyboard/%.o, $(driver_source_files))

x86_64_c_source_files := $(shell find arch -name *.c)
x86_64_c_object_files := $(patsubst arch/%.c, build/arch/%.o, $(x86_64_c_source_files))

x86_64_asm_source_files := $(shell find boot -name *.asm)
x86_64_asm_object_files := $(patsubst boot/%.asm, build/boot/%.o, $(x86_64_asm_source_files))

x86_64_object_files := $(x86_64_c_object_files) $(x86_64_asm_object_files)

$(kernel_object_files): build/kernel/%.o : kernel/%.c
	mkdir -p $(dir $@) && \
	gcc -c -I src/intf -ffreestanding $(patsubst build/kernel/%.o, kernel/%.c, $@) -o $@

$(driver_object_files): build/driver/keyboard/%.o : driver/keyboard/%.c
	mkdir -p $(dir $@) && \
	gcc -c -I src/intf -ffreestanding $(patsubst build/driver/keyboard/%.o, driver/keyboard/%.c, $@) -o $@

$(x86_64_c_object_files): build/arch/%.o : arch/%.c
	mkdir -p $(dir $@) && \
	gcc -c -I src/intf -ffreestanding $(patsubst build/arch/%.o, arch/%.c, $@) -o $@

$(x86_64_asm_object_files): build/boot/%.o : boot/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/boot/%.o, boot/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(kernel_object_files) $(driver_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64 && \
	ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(kernel_object_files) $(driver_object_files) $(x86_64_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso
