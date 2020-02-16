.PHONY: sim sim2 sim-freertos sim-linux dbg-freertos dbg-linux

QEMU_PATH = $(TOPDIR)/build/tools/qemu
QEMU = $(QEMU_PATH)/qemu-system-riscv64 -nographic -machine virt

_FREERTOS = $(TOPDIR)/freertos/build/FreeRTOS-simple.elf
_LINUX = $(TOPDIR)/linux/kernel/vmlinux
FREERTOS = -bios $(_FREERTOS)
LINUX = -kernel $(_LINUX) -smp 5 -append "earlycon=sbi"

P0 = $(shell expr 1234 + $(shell tty | cut -d'/' -f4))
P1 = 1$(P0)
P2 = 2$(P0)

# $(1): elf-file
# $(2): 1st breakpoint
define debug
	@#adg32 "-ex 'set style enabled off' -ex 'target remote localhost:$(P0)' -ex 'symbol $(1)' -ex 'b *$(2)' -ex 'c'" &
	@gnome-terminal --geometry=132x43+0+0 -x $(CROSS_FREERTOS_COMPILE)-gdb -ex 'target remote localhost:$(P0)' -ex 'symbol $(1)' -ex 'b *$(2)' -ex 'c' &
endef


sim:
	@$(QEMU) $(FREERTOS) $(LINUX)

sim-freertos:
	@$(QEMU) $(FREERTOS)

dbg-freertos:
	$(call debug,$(_FREERTOS),main)
	@$(QEMU) $(FREERTOS) $(LINUX) -S -gdb tcp::$(P0)

sim-linux:
	@$(QEMU) $(LINUX)

dbg-linux:
	$(call debug,$(_LINUX),start_kernel)
	@$(QEMU) $(FREERTOS) $(LINUX) -S -gdb tcp::$(P0)

sim2:
	@nc -z 127.0.0.1 $(P1) || gnome-terminal --geometry=80x43+0+0 -x build/tools/qemu/soc_term $(P1) &
	@nc -z 127.0.0.1 $(P2) || gnome-terminal --geometry=80x43+598+0 -x build/tools/qemu/soc_term $(P2) &
	@while ! nc -z 127.0.0.1 $(P1) || ! nc -z 127.0.0.1 $(P2); do sleep 1; done
	@build/tools/qemu/qemu-system-riscv64 -nographic -machine virt \
		-bios freertos/build/FreeRTOS-simple.elf -kernel linux/kernel/vmlinux -smp 5 \
		-serial tcp:localhost:$(P1) -serial tcp:localhost:$(P2)
	@killall gnome-terminal-server -9 2> /dev/null
	@sleep 0
