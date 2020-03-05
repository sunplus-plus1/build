.PHONY: sim sim2 sim-freertos sim-linux dbg-freertos dbg-linux

QEMU_PATH = $(TOPDIR)/build/tools/qemu
QEMU = $(QEMU_PATH)/qemu-system-riscv64 -nographic -machine virt -chardev stdio,mux=on,id=char0 -mon chardev=char0,mode=readline $(COM)
COM = -serial chardev:char0
DBG = -S -gdb tcp::$(P0)

_FREERTOS = $(TOPDIR)/freertos/build/FreeRTOS-simple.elf
_LINUX = $(TOPDIR)/linux/kernel/vmlinux
FREERTOS = -bios $(_FREERTOS)
LINUX = -kernel $(_LINUX) -smp 5 -append "earlycon=sbi"

P0 = $(shell expr 1234 + $(shell tty | cut -d'/' -f4))
P1 = 1$(P0)
P2 = 2$(P0)
T0 = $(shell ls -1 /dev/pts | sort -n | tail -1)
T1 = $(shell expr $(T0) + 2)
T2 = $(shell expr $(T0) + 3)
T3 = $(shell expr $(T0) + 4)
T4 = $(shell expr $(T0) + 5)

# $(1): elf-file
# $(2): 1st breakpoint
define debug
	@#adg32 --debugger $(CROSS_FREERTOS_COMPILE)-gdb -nx "-ex 'set style enabled off' -ex 'target remote localhost:$(P0)' -ex 'symbol $(1)' -ex 'b *$(2)' -ex 'c'" &
	@gnome-terminal --geometry=132x43+0+0 -x $(CROSS_FREERTOS_COMPILE)-gdb -ex 'target remote localhost:$(P0)' -ex 'symbol $(1)' -ex 'b *$(2)' -ex 'c' &
	@#terminator -l gdb -x $(CROSS_FREERTOS_COMPILE)-gdb -q \
		-ex 'dashboard registers   -output /dev/pts/$(T1)' \
		-ex 'dashboard source      -output /dev/pts/$(T2)' \
		-ex 'dashboard assembly    -output /dev/pts/$(T3)' \
		-ex 'dashboard stack       -output /dev/pts/$(T4)' \
		-ex 'dashboard breakpoints -output /dev/pts/$(T4)' \
		-ex 'dashboard threads     -output /dev/pts/$(T4)' \
		-ex 'dashboard expressions -output /dev/pts/$(T4)' \
		-ex 'dashboard memory      -output /dev/pts/$(T4)' \
		-ex 'target remote localhost:$(P0)' -ex 'symbol $(1)' -ex 'b *$(2)' -ex 'c' &
	@$(QEMU) $(FREERTOS) $(LINUX) $(COM) $(DBG)
endef


sim:
	@$(QEMU) $(FREERTOS) $(LINUX) $(COM)

sim-freertos:
	@$(QEMU) $(FREERTOS) $(COM)

dbg-freertos:
	$(call debug,$(_FREERTOS),main)

sim-linux:
	@$(QEMU) $(LINUX)

dbg-linux:
	$(call debug,$(_LINUX),start_kernel)

sim2:
	@nc -z 127.0.0.1 $(P1) || gnome-terminal --geometry=80x43+0+0 -x build/tools/qemu/soc_term $(P1) &
	@nc -z 127.0.0.1 $(P2) || gnome-terminal --geometry=80x43+598+0 -x build/tools/qemu/soc_term $(P2) &
	@while ! nc -z 127.0.0.1 $(P1) || ! nc -z 127.0.0.1 $(P2); do sleep 1; done
	@$(QEMU_PATH)/qemu-system-riscv64 -nographic -machine virt $(FREERTOS) $(LINUX) \
		-serial tcp:localhost:$(P1) -serial tcp:localhost:$(P2)
	@killall gnome-terminal-server -9 2> /dev/null; sleep 0


# tmux(tmuxinator) support
TC = .tmuxinator.yml
CLS = echo -e "\033[H\033[J\033[3J"

# $(1): debug
define qemu
	@echo '      panes:' >> $(TC)
	@echo '        - bash -c "while ! nc -z 127.0.0.1 $(P2); do sleep 0; done"; $(CLS) && $(QEMU) $(FREERTOS) $(LINUX) -serial tcp:localhost:$(P2) $(1)' >> $(TC)
	@echo '        - $(CLS) && build/tools/qemu/soc_term $(P2)' >> $(TC)
endef

# $(1): elf-file
# $(2): 1st breakpoint
define debug1
	@echo -e 'name: gdb\nstartup_pane: 2\nwindows:\n  - gdb:\n      layout: af75,269x54,0,0{111x54,0,0[111x35,0,0,0,111x18,0,36,1],157x54,112,0,2}' > $(TC)
	$(call qemu,$(DBG))
	@echo '        - $(CROSS_FREERTOS_COMPILE)-gdb -ex "target remote localhost:$(P0)" -ex "symbol $(1)" -ex "b *$(2)" -ex "c"' >> $(TC)
	@tmuxinator local; sleep 0
endef

dbg-freertos1:
	$(call debug1,$(_FREERTOS),main)

dbg-linux1:
	$(call debug1,$(_LINUX),start_kernel)

sim1:
	@echo -e 'name: qemu\nwindows:\n  - qemu:\n      layout: even-horizontal' > $(TC)
	$(call qemu)
	@tmuxinator local; sleep 0
