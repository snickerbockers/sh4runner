AS=sh4-linux-gnu-as
LD=sh4-linux-gnu-ld
OBJCOPY=sh4-linux-gnu-objcopy

all: init.bin

init.o: init.s
	$(AS) -little -o init.o init.s

init.elf: init.o
	$(LD) -Ttext 0x8c010000 init.o -o init.elf

init.bin: init.elf
	$(OBJCOPY) -O binary init.elf init.bin
