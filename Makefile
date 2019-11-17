AS=sh4-linux-gnu-as
LD=sh4-linux-gnu-ld
CC=sh4-linux-gnu-gcc
OBJCOPY=sh4-linux-gnu-objcopy

all: init.bin

init.o: init.s
	$(AS) -little -o init.o init.s

init.elf: init.o main.o
	$(LD) -Ttext 0x8c010000 init.o main.o -o init.elf

init.bin: init.elf
	$(OBJCOPY) -O binary init.elf init.bin

main.o: main.c
	$(CC) -c main.c -nostdlib
