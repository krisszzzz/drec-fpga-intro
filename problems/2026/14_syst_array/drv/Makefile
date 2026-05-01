CROSS_COMPILE ?= arm-linux-gnueabihf-
ARCH ?= arm
obj-m := sa.o

KERNELDIR ?= ../linux-xlnx/build
PWD := $(shell pwd)

all:
	$(MAKE) -C $(KERNELDIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNELDIR) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)  M=$(PWD) clean
	rm -f test
