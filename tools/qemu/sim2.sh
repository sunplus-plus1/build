#!/bin/bash
P0=$(tty)
P0=${P0##*/}
P0=$((44000 + ${P0:-0}))
P1=$((11000 + $P0))
#echo $P0 $P1
nc -z 127.0.0.1 $P0 || gnome-terminal -x build/tools/qemu/soc_term $P0 &
nc -z 127.0.0.1 $P1 || gnome-terminal -x build/tools/qemu/soc_term $P1 &
while ! nc -z 127.0.0.1 $P0 || ! nc -z 127.0.0.1 $P1; do sleep 1; done

build/tools/qemu/qemu-system-riscv64 -nographic -machine virt \
	-bios freertos/build/FreeRTOS-simple.elf -kernel linux/kernel/vmlinux -smp 5 \
	-serial tcp:localhost:$P0 -serial tcp:localhost:$P1

killall gnome-terminal-server -9 2> /dev/null
sleep 0
