ARM_PREFIX ?= arm-none-eabi-

AS=$(ARM_PREFIX)as
LD=$(ARM_PREFIX)ld
CC=$(ARM_PREFIX)gcc
OBJCOPY=$(ARM_PREFIX)objcopy
OBJDUMP=$(ARM_PREFIX)objdump
READELF=$(ARM_PREFIX)readelf

all:
	$(AS) start.s -o start.o
	$(CC) mul-dev-hello.c -g -c -o mul-dev-hello.o
	$(LD) -T virt.ld mul-dev-hello.o start.o -o mul-dev-hello.elf
	$(OBJCOPY) -O binary mul-dev-hello.elf mul-dev-hello.bin
	$(OBJDUMP) -d --visualize-jumps mul-dev-hello.elf

clean:
	rm -f *.o *.elf *.bin
