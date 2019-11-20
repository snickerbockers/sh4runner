AS=sh4-linux-gnu-as
LD=sh4-linux-gnu-ld
CC=sh4-linux-gnu-gcc
OBJCOPY=sh4-linux-gnu-objcopy

ARM_AS=arm-linux-gnueabi-as
ARM_LD=arm-linux-gnueabi-ld
ARM_OBJCOPY=arm-linux-gnueabi-objcopy

all: init.bin

clean:
	rm -f init.o init.elf init.bin main.o arm_init.o arm_init.elf arm_init.bin arm_prog.h

init.o: init.s
	$(AS) -little -o init.o init.s

init.elf: init.o main.o
	$(CC) -Ttext 0x8c010000 init.o main.o -o init.elf -nostartfiles -nostdlib -lgcc

init.bin: init.elf
	$(OBJCOPY) -O binary -j .text -j .data -j .bss -j .rodata  --set-section-flags .bss=alloc,load,contents init.elf init.bin

main.o: main.c arm_prog.h
	$(CC) -c main.c -nostartfiles -nostdlib -Os

arm_init.o: arm_init.s
	$(ARM_AS) -EL -mcpu=arm7 -o arm_init.o arm_init.s

arm_init.elf: arm_init.o
	$(ARM_LD) -Ttext 0x00000000 arm_init.o -o arm_init.elf

arm_init.bin: arm_init.elf
	$(ARM_OBJCOPY) -O binary -j .text -j .data -j .bss -j .rodata --set-section-flags .data=alloc,load,contents arm_init.elf arm_init.bin

arm_prog.h: arm_init.bin
	./embed_c_code.py -i arm_init.bin -o arm_prog.h -t arm7_program -h arm_prog_h_
